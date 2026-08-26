import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import '../../Models/subscrptions/referals.dart';
import '../../Services/Auth_service/Subscription_authservice.dart';
import '../../Services/scaffoldmessenger/messenger.dart';

enum ReferralCategory { user, vendor, driver }

enum ReferralStatus { invited, earned }

class _K {
  static const primary = Color(0xFFE66D33);
  static const bg = Color(0xFFF4F6FA);
  static const surface = Colors.white;
  static const textDark = Color(0xFF0F172A);
  static const textMid = Color(0xFF64748B);
  static const textLight = Color(0xFFB0BDCF);
  static const divider = Color(0xFFEEF0F4);

  // Status / accent
  static const green = Color(0xFF16A34A);
  static const greenBg = Color(0xFFECFDF5);
  static const amber = Color(0xFFD97706);
  static const amberBg = Color(0xFFFFFBEB);
  static const purple = Color(0xFF7C3AED);
  static const purpleBg = Color(0xFFF5F3FF);
  static const blue = Color(0xFF2563EB);
  static const blueBg = Color(0xFFEFF6FF);

  // Category palette
  static const userColor = Color(0xFFE66D33);
  static const userBg = Color(0xFFFFF4EE);
  static const vendorColor = Color(0xFF16A34A);
  static const vendorBg = Color(0xFFECFDF5);
  static const moverColor = Color(0xFF7C3AED);
  static const moverBg = Color(0xFFF5F3FF);
}

// ─── Category Config ────────────────────────────────────────────────────────

class CategoryConfig {
  final String label;
  final Color color;
  final Color bgColor;
  final IconData icon;
  const CategoryConfig({
    required this.label,
    required this.color,
    required this.bgColor,
    required this.icon,
  });
}

const Map<ReferralCategory, CategoryConfig> categoryConfig = {
  ReferralCategory.user: CategoryConfig(
    label: 'Users',
    color: _K.userColor,
    bgColor: _K.userBg,
    icon: Icons.person_rounded,
  ),
  ReferralCategory.vendor: CategoryConfig(
    label: 'Vendors',
    color: _K.vendorColor,
    bgColor: _K.vendorBg,
    icon: Icons.storefront_rounded,
  ),
  ReferralCategory.driver: CategoryConfig(
    label: 'Movers',
    color: _K.moverColor,
    bgColor: _K.moverBg,
    icon: Icons.delivery_dining_rounded,
  ),
};

ReferralCategory getCategory(ReferralResponse r) {
  if (r.usedByVendorId != null) return ReferralCategory.vendor;
  if (r.usedByPartnerId != null) return ReferralCategory.driver;
  return ReferralCategory.user;
}

ReferralStatus getStatus(ReferralResponse r) =>
    r.rewardGiven ? ReferralStatus.earned : ReferralStatus.invited;

// ─── Screen ─────────────────────────────────────────────────────────────────

class ReferEarnScreen extends StatefulWidget {
  const ReferEarnScreen({super.key});

  @override
  State<ReferEarnScreen> createState() => _ReferEarnScreenState();
}

class _ReferEarnScreenState extends State<ReferEarnScreen> {
  late Future<ReferralHistoryResponse> _futureProfile;
  int _selectedTabIndex = 0;

  final List<String> _tabLabels = ['Overview', 'Users', 'Vendors', 'Movers'];

  @override
  void initState() {
    super.initState();
    _futureProfile = subscription_AuthService.getReferralHistory();
  }

  String _statusLabel(ReferralStatus s) => switch (s) {
    ReferralStatus.invited => 'Invited',
    ReferralStatus.earned => 'Reward Earned',
  };

  Color _statusColor(ReferralStatus s) => switch (s) {
    ReferralStatus.invited => _K.textMid,
    ReferralStatus.earned => _K.purple,
  };

  Color _statusBg(ReferralStatus s) => switch (s) {
    ReferralStatus.invited => _K.divider,
    ReferralStatus.earned => _K.purpleBg,
  };

  String _getReferralType(ReferralCategory category) => switch (category) {
    ReferralCategory.user => 'user',
    ReferralCategory.vendor => 'vendor',
    ReferralCategory.driver => 'mover',
  };

  void _copyCode(BuildContext context, String code, ReferralCategory cat) {
    final type = _getReferralType(cat);

    final link =
        'https://applink.maamaas.com/$type/referral?referralCode=${Uri.encodeComponent(code)}';

    Clipboard.setData(
      ClipboardData(
        text:
            '🎉 Join Maamaas using my referral code: $code\n\n📲 Tap to download & sign up:\n$link',
      ),
    );

    AppAlert.success(context, 'Referral link copied!');
  }

  void _shareCode(String code, ReferralCategory cat) {
    final type = _getReferralType(cat);

    final link =
        'https://applink.maamaas.com/$type/referral?referralCode=${Uri.encodeComponent(code)}';

    Share.share(
      '🎉 Join Maamaas using my referral code: $code\n\n📲 Tap to download & sign up:\n$link',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _K.bg,
      body: FutureBuilder<ReferralHistoryResponse>(
        future: _futureProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingState();
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: _K.textMid),
              ),
            );
          }
          if (!snapshot.hasData) {
            return _ErrorState(
              onRetry: () => setState(() {
                _futureProfile = subscription_AuthService.getReferralHistory();
              }),
            );
          }

          final response = snapshot.data!;
          final referrals = response.referrals;
          final totalCashBack = response.totalReferralAmount;
          final referralCode = response.referralCode;

          final totalReferals = referrals.length;

          return Column(
            children: [
              // ── Top Bar ─────────────────────────────────────────────
              _TopBar(
                selectedIndex: _selectedTabIndex,
                labels: _tabLabels,
                onBack: () => Navigator.of(context).pop(),
                onTabChange: (i) => setState(() => _selectedTabIndex = i),
              ),

              // ── Content ──────────────────────────────────────────────
              Expanded(
                child: IndexedStack(
                  index: _selectedTabIndex,
                  children: [
                    _OverviewTab(
                      referralCode: referralCode,
                      totalReferals: totalReferals,
                      totalCashBack: totalCashBack,
                      onCopy: _copyCode,
                      onShare: _shareCode,
                    ),
                    _CategoryReferralsTab(
                      category: ReferralCategory.user,
                      referrals: referrals,
                      referralCode: referralCode,
                      statusLabel: _statusLabel,
                      statusColor: _statusColor,
                      statusBg: _statusBg,
                      onCopy: () => _copyCode(
                        context,
                        referralCode,
                        ReferralCategory.user,
                      ),
                      onShare: () =>
                          _shareCode(referralCode, ReferralCategory.user),
                    ),
                    _CategoryReferralsTab(
                      category: ReferralCategory.vendor,
                      referrals: referrals,
                      referralCode: referralCode,
                      statusLabel: _statusLabel,
                      statusColor: _statusColor,
                      statusBg: _statusBg,
                      onCopy: () => _copyCode(
                        context,
                        referralCode,
                        ReferralCategory.vendor,
                      ),
                      onShare: () =>
                          _shareCode(referralCode, ReferralCategory.vendor),
                    ),
                    _MoversTab(
                      referrals: referrals,
                      referralCode: referralCode,
                      statusLabel: _statusLabel,
                      statusColor: _statusColor,
                      statusBg: _statusBg,
                      onCopy: () => _copyCode(
                        context,
                        referralCode,
                        ReferralCategory.driver,
                      ),
                      onShare: () =>
                          _shareCode(referralCode, ReferralCategory.driver),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Top Bar ─────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final int selectedIndex;
  final List<String> labels;
  final VoidCallback onBack;
  final ValueChanged<int> onTabChange;

  const _TopBar({
    required this.selectedIndex,
    required this.labels,
    required this.onBack,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _K.surface,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 4.w,
        right: 12.w,
        bottom: 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back row
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18.sp,
                  color: _K.textDark,
                ),
                splashRadius: 20.r,
              ),
              Text(
                'Refer & Earn',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: _K.textDark,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),

          SizedBox(height: 4.h),

          // Tabs
          Row(
            children: List.generate(labels.length, (i) {
              final selected = selectedIndex == i;
              return GestureDetector(
                onTap: () => onTabChange(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  margin: EdgeInsets.only(left: 4.w, right: 4.w),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: selected ? _K.primary : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                  ),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? _K.primary : _K.textMid,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Loading ──────────────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32.w,
            height: 32.w,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: _K.primary,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Loading…',
            style: TextStyle(fontSize: 13.sp, color: _K.textMid),
          ),
        ],
      ),
    );
  }
}

// ─── Error ────────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 26.sp,
                color: Colors.red.shade400,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Could not load referrals',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: _K.textDark,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Check your connection and try again.',
              style: TextStyle(fontSize: 13.sp, color: _K.textMid),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            _PillButton(label: 'Retry', color: _K.primary, onTap: onRetry),
          ],
        ),
      ),
    );
  }
}

// ─── Overview Tab ─────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final String referralCode;
  final int totalReferals;
  final double totalCashBack;
  final Function(BuildContext, String, ReferralCategory) onCopy;
  final Function(String, ReferralCategory) onShare;

  const _OverviewTab({
    required this.referralCode,
    required this.totalReferals,
    required this.totalCashBack,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero stats ────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _HeroStatCard(
                  icon: Icons.group_rounded,
                  iconColor: _K.purple,
                  iconBg: _K.purpleBg,
                  value: totalReferals.toString(),
                  label: 'Total Referred',
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _HeroStatCard(
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: _K.amber,
                  iconBg: _K.amberBg,
                  value: '₹${totalCashBack.toStringAsFixed(0)}',
                  label: 'Total Earned',
                ),
              ),
            ],
          ),

          SizedBox(height: 28.h),

          Text(
            'Invite & Earn Rewards',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: _K.textDark,
              letterSpacing: -0.2,
            ),
          ),

          SizedBox(height: 14.h),

          // ── Category cards ─────────────────────────────────────────────
          _ReferralCategoryCard(
            context: context,
            category: ReferralCategory.user,
            reward: '₹25',
            rewardDetail: 'On their first order',
            gradient: const [Color(0xFFE66D33), Color(0xFFFF9B6A)],
            referralCode: referralCode,
            onCopy: onCopy,
            onShare: onShare,
          ),

          SizedBox(height: 14.h),

          _ReferralCategoryCard(
            context: context,
            category: ReferralCategory.vendor,
            reward: '₹200',
            rewardDetail: 'After 20 completed orders',
            gradient: const [Color(0xFF16A34A), Color(0xFF4ADE80)],
            referralCode: referralCode,
            onCopy: onCopy,
            onShare: onShare,
          ),

          SizedBox(height: 14.h),

          _ReferralCategoryCard(
            context: context,
            category: ReferralCategory.driver,
            reward: '₹150',
            rewardDetail: 'After 15 deliveries',
            gradient: const [Color(0xFF7C3AED), Color(0xFFA78BFA)],
            referralCode: referralCode,
            onCopy: onCopy,
            onShare: onShare,
          ),
        ],
      ),
    );
  }
}

// ─── Referral Category Card ───────────────────────────────────────────────────

class _ReferralCategoryCard extends StatelessWidget {
  final BuildContext context;
  final ReferralCategory category;
  final String reward;
  final String rewardDetail;
  final List<Color> gradient;
  final String referralCode;
  final Function(BuildContext, String, ReferralCategory) onCopy;
  final Function(String, ReferralCategory) onShare;

  const _ReferralCategoryCard({
    required this.context,
    required this.category,
    required this.reward,
    required this.rewardDetail,
    required this.gradient,
    required this.referralCode,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext ctx) {
    final cfg = categoryConfig[category]!;

    return Container(
      decoration: BoxDecoration(
        color: _K.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFEEF0F4), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Gradient Header ──────────────────────────────────────
            Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon badge
                  Container(
                    width: 42.w,
                    height: 42.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(cfg.icon, color: Colors.white, size: 22.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Refer ${cfg.label}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Get $reward',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Code + Actions ────────────────────────────────────────
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   'Your referral code',
                  //   style: TextStyle(
                  //     fontSize: 11.sp,
                  //     fontWeight: FontWeight.w600,
                  //     color: _K.textMid,
                  //     letterSpacing: 0.3,
                  //   ),
                  // ),
                  // SizedBox(height: 8.h),
                  // Container(
                  //   padding: EdgeInsets.symmetric(
                  //     horizontal: 16.w,
                  //     vertical: 14.h,
                  //   ),
                  //   decoration: BoxDecoration(
                  //     color: cfg.bgColor,
                  //     borderRadius: BorderRadius.circular(12.r),
                  //     border: Border.all(
                  //       color: cfg.color.withOpacity(0.2),
                  //       width: 1,
                  //     ),
                  //   ),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       Text(
                  //         referralCode.isEmpty ? '—' : referralCode,
                  //         style: TextStyle(
                  //           color: cfg.color,
                  //           fontSize: 18.sp,
                  //           fontWeight: FontWeight.w800,
                  //           letterSpacing: 3,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: cfg.bgColor,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: cfg.color.withOpacity(0.18),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Label + Code stacked
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your referral code',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                  color: _K.textMid,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Center(
                                child: Text(
                                  referralCode.isEmpty ? '—' : referralCode,
                                  style: TextStyle(
                                    color: cfg.color,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.copy_all_rounded,
                          label: 'Copy',
                          color: cfg.color,
                          onTap: () => onCopy(ctx, referralCode, category),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.ios_share_rounded,
                          label: 'Share',
                          color: const Color(0xFF1E40AF),
                          onTap: () => onShare(referralCode, category),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── How it works ──────────────────────────────────────────
            _HowItWorks(reward: reward, detail: rewardDetail, color: cfg.color),
          ],
        ),
      ),
    );
  }
}

// ─── How It Works ─────────────────────────────────────────────────────────────

class _HowItWorks extends StatelessWidget {
  final String reward;
  final String detail;
  final Color color;
  const _HowItWorks({
    required this.reward,
    required this.detail,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      (Icons.share_rounded, 'Share your code', 'Send it to a friend'),
      (
        Icons.how_to_reg_rounded,
        'They sign up',
        'Friend registers using your code',
      ),
      (Icons.task_alt_rounded, 'Complete requirement', detail),
      (Icons.payments_rounded, 'You earn $reward', 'Credited to your wallet'),
    ];

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: _K.bg,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How it works',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: _K.textDark,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 10.h),
          ...steps.asMap().entries.map((e) {
            final idx = e.key;
            final step = e.value;
            final isLast = idx == steps.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 28.w,
                      height: 28.w,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(step.$1, size: 14.sp, color: color),
                    ),
                    if (!isLast)
                      Container(
                        width: 1.5,
                        height: 20.h,
                        color: color.withOpacity(0.2),
                        margin: EdgeInsets.symmetric(vertical: 2.h),
                      ),
                  ],
                ),
                SizedBox(width: 10.w),
                Padding(
                  padding: EdgeInsets.only(top: 5.h, bottom: isLast ? 0 : 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.$2,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: _K.textDark,
                        ),
                      ),
                      Text(
                        step.$3,
                        style: TextStyle(fontSize: 10.5.sp, color: _K.textMid),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ─── Category Referrals Tab ───────────────────────────────────────────────────

class _CategoryReferralsTab extends StatefulWidget {
  final ReferralCategory category;
  final List<ReferralResponse> referrals;
  final String referralCode;
  final String Function(ReferralStatus) statusLabel;
  final Color Function(ReferralStatus) statusColor;
  final Color Function(ReferralStatus) statusBg;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const _CategoryReferralsTab({
    required this.category,
    required this.referrals,
    required this.referralCode,
    required this.statusLabel,
    required this.statusColor,
    required this.statusBg,
    required this.onCopy,
    required this.onShare,
    super.key,
  });

  @override
  State<_CategoryReferralsTab> createState() => _CategoryReferralsTabState();
}

class _CategoryReferralsTabState extends State<_CategoryReferralsTab> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final cfg = categoryConfig[widget.category]!;
    final filtered = widget.referrals
        .where((r) => getCategory(r) == widget.category)
        .toList();

    final display = filtered.where((r) {
      return switch (_filter) {
        'Registered' => getStatus(r) != ReferralStatus.invited,
        'Pending' => getStatus(r) == ReferralStatus.invited,
        _ => true,
      };
    }).toList();

    final earned = filtered.fold(0.0, (s, r) => s + r.bonusAmount);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Referral code mini-card
          _MiniCodeCard(
            referralCode: widget.referralCode,
            cfg: cfg,
            onCopy: widget.onCopy,
            onShare: widget.onShare,
          ),

          SizedBox(height: 16.h),

          // Stat row
          _StatsRow(filtered: filtered, cfg: cfg, earned: earned),

          SizedBox(height: 20.h),

          // List header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${cfg.label} Referrals',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: _K.textDark,
                ),
              ),
              _FilterChip(
                value: _filter,
                color: cfg.color,
                onChanged: (v) => setState(() => _filter = v!),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          display.isEmpty
              ? _EmptyReferrals(label: cfg.label, filter: _filter)
              : _ReferralList(
                  referrals: display,
                  cfg: cfg,
                  statusLabel: widget.statusLabel,
                  statusColor: widget.statusColor,
                  statusBg: widget.statusBg,
                ),
        ],
      ),
    );
  }
}

// ─── Movers Tab ──────────────────────────────────────────────────────────────

class _MoversTab extends StatefulWidget {
  final List<ReferralResponse> referrals;
  final String referralCode;
  final String Function(ReferralStatus) statusLabel;
  final Color Function(ReferralStatus) statusColor;
  final Color Function(ReferralStatus) statusBg;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const _MoversTab({
    required this.referrals,
    required this.referralCode,
    required this.statusLabel,
    required this.statusColor,
    required this.statusBg,
    required this.onCopy,
    required this.onShare,
    super.key,
  });

  @override
  State<_MoversTab> createState() => _MoversTabState();
}

class _MoversTabState extends State<_MoversTab> {
  String _filter = 'All';

  static const _cfg = CategoryConfig(
    label: 'Movers',
    color: _K.moverColor,
    bgColor: _K.moverBg,
    icon: Icons.delivery_dining_rounded,
  );

  @override
  Widget build(BuildContext context) {
    final movers = widget.referrals
        .where((r) => getCategory(r) == ReferralCategory.driver)
        .toList();

    final display = movers.where((r) {
      return switch (_filter) {
        'Registered' => getStatus(r) != ReferralStatus.invited,
        'Pending' => getStatus(r) == ReferralStatus.invited,
        _ => true,
      };
    }).toList();

    final earned = movers.fold(0.0, (s, r) => s + r.bonusAmount);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MiniCodeCard(
            referralCode: widget.referralCode,
            cfg: _cfg,
            onCopy: widget.onCopy,
            onShare: widget.onShare,
          ),
          SizedBox(height: 16.h),
          _StatsRow(filtered: movers, cfg: _cfg, earned: earned),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Movers Referrals',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: _K.textDark,
                ),
              ),
              _FilterChip(
                value: _filter,
                color: _K.moverColor,
                onChanged: (v) => setState(() => _filter = v!),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          display.isEmpty
              ? _EmptyReferrals(label: 'Mover', filter: _filter)
              : _ReferralList(
                  referrals: display,
                  cfg: _cfg,
                  statusLabel: widget.statusLabel,
                  statusColor: widget.statusColor,
                  statusBg: widget.statusBg,
                ),
        ],
      ),
    );
  }
}

// ─── Mini Code Card ────────────────────────────────────────────────────────────

class _MiniCodeCard extends StatelessWidget {
  final String referralCode;
  final CategoryConfig cfg;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const _MiniCodeCard({
    required this.referralCode,
    required this.cfg,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _K.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _K.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: cfg.bgColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(cfg.icon, color: cfg.color, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your referral code',
                  style: TextStyle(fontSize: 11.sp, color: _K.textMid),
                ),
                Text(
                  referralCode.isEmpty ? '—' : referralCode,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: cfg.color,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          _IconBtn(
            icon: Icons.copy_all_rounded,
            color: cfg.color,
            onTap: onCopy,
          ),
          SizedBox(width: 8.w),
          _IconBtn(
            icon: Icons.ios_share_rounded,
            color: const Color(0xFF1E40AF),
            onTap: onShare,
          ),
        ],
      ),
    );
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final List<ReferralResponse> filtered;
  final CategoryConfig cfg;
  final double earned;

  const _StatsRow({
    required this.filtered,
    required this.cfg,
    required this.earned,
  });

  @override
  Widget build(BuildContext context) {
    final registered = filtered
        .where((r) => getStatus(r) != ReferralStatus.invited)
        .length;
    final pending = filtered
        .where((r) => getStatus(r) == ReferralStatus.invited)
        .length;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _K.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _K.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _StatPill(
            label: 'Total',
            value: '${filtered.length}',
            color: cfg.color,
            bg: cfg.bgColor,
          ),
          SizedBox(width: 8.w),
          _StatPill(
            label: 'Active',
            value: '$registered',
            color: _K.green,
            bg: _K.greenBg,
          ),
          SizedBox(width: 8.w),
          _StatPill(
            label: 'Pending',
            value: '$pending',
            color: _K.amber,
            bg: _K.amberBg,
          ),
          SizedBox(width: 8.w),
          _StatPill(
            label: 'Earned',
            value: '₹${earned.toInt()}',
            color: _K.purple,
            bg: _K.purpleBg,
          ),
        ],
      ),
    );
  }
}

// ─── Referral List ────────────────────────────────────────────────────────────

class _ReferralList extends StatelessWidget {
  final List<ReferralResponse> referrals;
  final CategoryConfig cfg;
  final String Function(ReferralStatus) statusLabel;
  final Color Function(ReferralStatus) statusColor;
  final Color Function(ReferralStatus) statusBg;

  const _ReferralList({
    required this.referrals,
    required this.cfg,
    required this.statusLabel,
    required this.statusColor,
    required this.statusBg,
  });

  @override
  Widget build(BuildContext context) {
    final sortedReferrals = [...referrals]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: referrals.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (_, i) => _ReferralCard(
        referral: sortedReferrals[i],
        cfg: cfg,
        statusLabel: statusLabel,
        statusColor: statusColor,
        statusBg: statusBg,
      ),
    );
  }
}

// ─── Referral Card ────────────────────────────────────────────────────────────

class _ReferralCard extends StatelessWidget {
  final ReferralResponse referral;
  final CategoryConfig cfg;
  final String Function(ReferralStatus) statusLabel;
  final Color Function(ReferralStatus) statusColor;
  final Color Function(ReferralStatus) statusBg;

  const _ReferralCard({
    required this.referral,
    required this.cfg,
    required this.statusLabel,
    required this.statusColor,
    required this.statusBg,
  });

  @override
  Widget build(BuildContext context) {
    final r = referral;
    final status = getStatus(r);
    final sColor = statusColor(status);
    final sBg = statusBg(status);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: _K.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _K.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Name + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.name.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5.sp,
                    color: _K.textDark,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  '${r.createdAt.day}/${r.createdAt.month}/${r.createdAt.year}',
                  style: TextStyle(fontSize: 10.sp, color: _K.textLight),
                ),
              ],
            ),
          ),

          // Amount + status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (r.bonusAmount > 0)
                Text(
                  '₹${r.bonusAmount.toInt()}',
                  style: TextStyle(
                    color: _K.textDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 15.sp,
                  ),
                ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: sBg,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  statusLabel(status),
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: sColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Shared Small Components ─────────────────────────────────────────────────

class _HeroStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String label;

  const _HeroStatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: _K.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _K.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: iconColor, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: _K.textDark,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.w),
          Center(
            child: Text(
              label,
              style: TextStyle(fontSize: 11.sp, color: _K.textMid),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color bg;

  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(fontSize: 9.sp, color: color.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 15.sp),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: color, size: 17.sp),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PillButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 13.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ─── Filter Chip ──────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String value;
  final Color color;
  final ValueChanged<String?> onChanged;

  const _FilterChip({
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _K.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: _K.divider),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 16.sp,
          color: color,
        ),
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
        isDense: true,
        items: ['All', 'Registered', 'Pending'].map((v) {
          return DropdownMenuItem(value: v, child: Text(v));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyReferrals extends StatelessWidget {
  final String label;
  final String filter;

  const _EmptyReferrals({required this.label, required this.filter});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: _K.divider,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 28.sp,
                color: _K.textMid,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              'No ${filter == 'All' ? '' : '${filter.toLowerCase()} '}${label.toLowerCase()} referrals yet',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: _K.textMid,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            Text(
              'Share your code to get started.',
              style: TextStyle(fontSize: 12.sp, color: _K.textLight),
            ),
          ],
        ),
      ),
    );
  }
}
