import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../../Services/Auth_service/food_authservice.dart';
import '../../Models/subscrptions/coupon_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Design tokens ──────────────────────────────────────────────────────────────
class couponscolours {
  static const bg = Color(0xFFF6F7FB);
  static const surface = Color(0xFFFFFFFF);
  static const brand = Color(0xFF4F46E5);
  static const brandSoft = Color(0xFFEEEDFD);
  static const ink = Color(0xFF111827);
  static const sub = Color(0xFF6B7280);
  static const muted = Color(0xFFD1D5DB);
  static const border = Color(0xFFE5E7EB);
  static const green = Color(0xFF10B981);
  static const greenSoft = Color(0xFFD1FAE5);
  static const amber = Color(0xFFF59E0B);
  static const amberSoft = Color(0xFFFEF3C7);
  static const red = Color(0xFFEF4444);
  static const redSoft = Color(0xFFFEE2E2);
}

// ── Screen ─────────────────────────────────────────────────────────────────────
class CouponsAndRewards extends StatelessWidget {
  const CouponsAndRewards({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: couponscolours.bg,
      appBar: AppBar(
        backgroundColor: couponscolours.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withOpacity(0.06),
        centerTitle: true,
        title: const Text(
          'Coupons',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: couponscolours.ink,
            letterSpacing: -0.3,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: couponscolours.bg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: couponscolours.ink,
            ),
          ),
        ),
      ),
      body: const SafeArea(child: CouponsTab()),
    );
  }
}

// ── Coupons tab ────────────────────────────────────────────────────────────────
class CouponsTab extends StatefulWidget {
  const CouponsTab({super.key});

  @override
  State<CouponsTab> createState() => _CouponsTabState();
}

class _CouponsTabState extends State<CouponsTab> {
  bool _isLoading = true;
  List<CouponModel> _coupons = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await food_Authservice.fetchCoupons();

      if (mounted) {
        setState(() {
          _coupons = data.where((c) => c.isCurrentlyAvailable).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _applyDiscount(CouponModel coupon) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('appliedDiscount', coupon.discountPercentage);
    HapticFeedback.lightImpact();
    if (mounted) {
      AppAlert.success(
        context,
        coupon.discountType == 'PERCENTAGE'
            ? '${coupon.discountPercentage.toStringAsFixed(0)}% discount applied!'
            : '₹${coupon.discountPercentage.toStringAsFixed(0)} discount applied!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const _LoadingState();
    if (_coupons.isEmpty) return const _EmptyState();

    // Split active / expired
    final active = _coupons.where((c) => !c.isExpired).toList();
    final expired = _coupons.where((c) => c.isExpired).toList();

    return RefreshIndicator(
      color: couponscolours.brand,
      backgroundColor: couponscolours.surface,
      onRefresh: _load,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Active coupons ──────────────────────────────────────────
          if (active.isNotEmpty) ...[
            _SectionHeader('Available', active.length),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _CouponCard(
                      coupon: active[i],
                      onApply: () => _applyDiscount(active[i]),
                    ),
                  ),
                  childCount: active.length,
                ),
              ),
            ),
          ],

          // ── Expired coupons ─────────────────────────────────────────
          if (expired.isNotEmpty) ...[
            _SectionHeader('Expired', expired.length),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _CouponCard(coupon: expired[i]),
                  ),
                  childCount: expired.length,
                ),
              ),
            ),
          ],

          SliverToBoxAdapter(child: SizedBox(height: 32.h)),
        ],
      ),
    );
  }
}

// ── Summary bar ────────────────────────────────────────────────────────────────
// ignore: unused_element
class _SummaryBar extends StatelessWidget {
  final int active;
  final int expired;

  const _SummaryBar({required this.active, required this.expired});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: couponscolours.brandSoft,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_offer_rounded,
            color: couponscolours.brand,
            size: 18,
          ),
          SizedBox(width: 10.w),
          Text(
            '$active active coupon${active == 1 ? '' : 's'}',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: couponscolours.brand,
            ),
          ),
          const Spacer(),
          if (expired > 0)
            Text(
              '$expired expired',
              style: TextStyle(fontSize: 12.sp, color: couponscolours.sub),
            ),
        ],
      ),
    );
  }
}

// ── Section header ─────────────────────────────────────────────────────────────
class _SectionHeader extends SliverToBoxAdapter {
  _SectionHeader(String title, int count)
    : super(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 10.h),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: couponscolours.sub,
                  letterSpacing: 0.6,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: couponscolours.border,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: couponscolours.sub,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

// ── Coupon card ────────────────────────────────────────────────────────────────
class _CouponCard extends StatelessWidget {
  final CouponModel coupon;
  final VoidCallback? onApply;

  const _CouponCard({required this.coupon, this.onApply});

  String _fmtDate(String raw) {
    try {
      final d = DateTime.parse(raw);
      const months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${d.day} ${months[d.month]} ${d.year}';
    } catch (_) {
      return '—';
    }
  }

  // Color pair based on coupon type
  ({Color bg, Color fg, Color badge}) get _palette {
    switch (coupon.couponType.toUpperCase()) {
      case 'FOOD':
        return (
          bg: couponscolours.greenSoft,
          fg: couponscolours.green,
          badge: couponscolours.green,
        );
      case 'DELIVERY':
        return (
          bg: couponscolours.amberSoft,
          fg: couponscolours.amber,
          badge: couponscolours.amber,
        );
      default:
        return (
          bg: couponscolours.brandSoft,
          fg: couponscolours.brand,
          badge: couponscolours.brand,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _palette;
    final expired = coupon.isExpired;
    final discountLabel = coupon.discountType == 'PERCENTAGE'
        ? '${coupon.discountPercentage.toStringAsFixed(0)}% OFF'
        : '₹${coupon.discountPercentage.toStringAsFixed(0)} OFF';

    return Opacity(
      opacity: expired ? 0.55 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: couponscolours.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: couponscolours.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Left accent strip + discount ───────────────────────────
            Container(
              width: 88.w,
              decoration: BoxDecoration(
                color: p.bg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  bottomLeft: Radius.circular(16.r),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20.h),
                  Icon(
                    Icons.confirmation_num_rounded,
                    color: p.fg,
                    size: 22.sp,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    discountLabel,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: p.fg,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),

            // ── Dashed separator ────────────────────────────────────────
            _DashedDivider(color: couponscolours.border),

            // ── Right: details + action ─────────────────────────────────
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type badge + expired tag
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _CodePill(code: coupon.code),
                        _Badge(label: coupon.couponType, bg: p.bg, fg: p.fg),
                        const Spacer(),
                        if (expired)
                          _Badge(
                            label: 'Expired',
                            bg: couponscolours.redSoft,
                            fg: couponscolours.red,
                          ),
                      ],
                    ),
                    SizedBox(height: 10.h),

                    // Min order
                    if (coupon.minimumOrderValue > 0)
                      Text(
                        'Min order ₹${coupon.minimumOrderValue.toInt()}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: couponscolours.sub,
                        ),
                      ),
                    if (coupon.minimumOrderValue <= 0)
                      Text(
                        'Applicable on any order',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: couponscolours.sub,
                        ),
                      ),

                    SizedBox(height: 4.h),
                    Text(
                      'Valid till ${_fmtDate(coupon.endDate.toIso8601String())}',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: couponscolours.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dashed vertical divider ────────────────────────────────────────────────────
class _DashedDivider extends StatelessWidget {
  final Color color;
  const _DashedDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.h,
      width: 16.w,
      child: CustomPaint(painter: _DashedPainter(color: color)),
    );
  }
}

class _DashedPainter extends CustomPainter {
  final Color color;
  const _DashedPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dashH = 5.0;
    const gap = 4.0;
    double y = 0;
    final cx = size.width / 2;
    while (y < size.height) {
      canvas.drawLine(Offset(cx, y), Offset(cx, y + dashH), paint);
      y += dashH + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── Code pill ──────────────────────────────────────────────────────────────────
class _CodePill extends StatefulWidget {
  final String code;
  const _CodePill({required this.code});

  @override
  State<_CodePill> createState() => _CodePillState();
}

class _CodePillState extends State<_CodePill> {
  bool _copied = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.code));
    HapticFeedback.selectionClick();
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _copy,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: _copied ? couponscolours.greenSoft : couponscolours.bg,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: _copied ? couponscolours.green : couponscolours.border,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.code,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: _copied ? couponscolours.green : couponscolours.ink,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Badge ──────────────────────────────────────────────────────────────────────
class _Badge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _Badge({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w800,
          color: fg,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      itemCount: 5,
      itemBuilder: (_, index) => Padding(
        padding: EdgeInsets.only(bottom: 14.h),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 120.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                // Left coupon strip
                Container(
                  width: 88.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      bottomLeft: Radius.circular(16.r),
                    ),
                  ),
                ),

                SizedBox(width: 14.w),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 16.h,
                      horizontal: 8.w,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _skeletonBox(90.w, 22.h),
                            const Spacer(),
                            _skeletonBox(60.w, 20.h),
                          ],
                        ),

                        SizedBox(height: 16.h),

                        _skeletonBox(double.infinity, 12.h),

                        SizedBox(height: 10.h),

                        _skeletonBox(120.w, 10.h),

                        const Spacer(),

                        Align(
                          alignment: Alignment.bottomRight,
                          child: _skeletonBox(80.w, 32.h),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _skeletonBox(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.r,
            height: 80.r,
            decoration: BoxDecoration(
              color: couponscolours.brandSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.confirmation_num_outlined,
              size: 36.sp,
              color: couponscolours.brand,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'No coupons yet',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: couponscolours.ink,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Check back later for exciting offers!',
            style: TextStyle(fontSize: 13.sp, color: couponscolours.sub),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
