import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ReferralCategory { user, vendor, enterprise, driver, vehicle }

enum ReferralStatus { invited, registered, verified, activated, rewardReleased }

enum RewardType {
  cash,
  coupon,
  points,
  commissionReduction,
  promotionCredits,
  freeDelivery,
  vendorCredits,
  driverBonus,
}

class CategoryConfig {
  final String label;
  final Color color;
  final String icon;
  const CategoryConfig({
    required this.label,
    required this.color,
    required this.icon,
  });
}

class Referral {
  final String id;
  final String refereeName;
  final ReferralCategory category;
  final ReferralStatus status;
  final String date;
  final double rewardEarned;
  final bool rewardPaid;
  final String codeUsed;
  const Referral({
    required this.id,
    required this.refereeName,
    required this.category,
    required this.status,
    required this.date,
    required this.rewardEarned,
    required this.rewardPaid,
    required this.codeUsed,
  });
}

final Map<ReferralCategory, CategoryConfig> categoryConfig = {
  ReferralCategory.user: CategoryConfig(
    label: 'Users',
    color: const Color(0xFFEA580C),
    icon: '👤',
  ),
  ReferralCategory.vendor: CategoryConfig(
    label: 'Vendors',
    color: const Color(0xFF16A34A),
    icon: '🏪',
  ),
  ReferralCategory.enterprise: CategoryConfig(
    label: 'Enterprise',
    color: const Color(0xFF2563EB),
    icon: '🏢',
  ),
  ReferralCategory.driver: CategoryConfig(
    label: 'Drivers',
    color: const Color(0xFF9333EA),
    icon: '🚗',
  ),
  ReferralCategory.vehicle: CategoryConfig(
    label: 'Vehicles',
    color: const Color(0xFFCA8A04),
    icon: '🛵',
  ),
};

final Map<ReferralCategory, Map<String, String>> categoryReferralCodes = {
  ReferralCategory.user: {
    'code': 'MAA-USR-2024',
    'link': 'https://maamaas.com/join/user?ref=MAA-USR-2024',
  },
  ReferralCategory.vendor: {
    'code': 'MAA-VND-2024',
    'link': 'https://maamaas.com/join/vendor?ref=MAA-VND-2024',
  },
  ReferralCategory.enterprise: {
    'code': 'MAA-ENT-2024',
    'link': 'https://maamaas.com/join/enterprise?ref=MAA-ENT-2024',
  },
  ReferralCategory.driver: {
    'code': 'MAA-DRV-2024',
    'link': 'https://maamaas.com/join/driver?ref=MAA-DRV-2024',
  },
  ReferralCategory.vehicle: {
    'code': 'MAA-VEH-2024',
    'link': 'https://maamaas.com/join/vehicle?ref=MAA-VEH-2024',
  },
};

const Map<ReferralCategory, int> byCategory = {
  ReferralCategory.user: 62,
  ReferralCategory.vendor: 28,
  ReferralCategory.enterprise: 12,
  ReferralCategory.driver: 31,
  ReferralCategory.vehicle: 14,
};

final List<Referral> referrals = [
  const Referral(
    id: 'R001',
    refereeName: 'Priya Sharma',
    category: ReferralCategory.user,
    status: ReferralStatus.activated,
    date: '2024-03-01',
    rewardEarned: 100,
    rewardPaid: true,
    codeUsed: 'MAA-USR-2024',
  ),
  const Referral(
    id: 'R002',
    refereeName: 'Spice Junction',
    category: ReferralCategory.vendor,
    status: ReferralStatus.rewardReleased,
    date: '2024-02-28',
    rewardEarned: 2000,
    rewardPaid: true,
    codeUsed: 'MAA-VND-2024',
  ),
  const Referral(
    id: 'R003',
    refereeName: 'TechCorp India',
    category: ReferralCategory.enterprise,
    status: ReferralStatus.verified,
    date: '2024-03-05',
    rewardEarned: 0,
    rewardPaid: false,
    codeUsed: 'MAA-ENT-2024',
  ),
  const Referral(
    id: 'R004',
    refereeName: 'Rajesh Kumar',
    category: ReferralCategory.driver,
    status: ReferralStatus.registered,
    date: '2024-03-07',
    rewardEarned: 0,
    rewardPaid: false,
    codeUsed: 'MAA-DRV-2024',
  ),
  const Referral(
    id: 'R005',
    refereeName: 'Honda Activa - KA01',
    category: ReferralCategory.vehicle,
    status: ReferralStatus.activated,
    date: '2024-02-20',
    rewardEarned: 500,
    rewardPaid: true,
    codeUsed: 'MAA-VEH-2024',
  ),
  const Referral(
    id: 'R006',
    refereeName: 'Anita Desai',
    category: ReferralCategory.user,
    status: ReferralStatus.invited,
    date: '2024-03-08',
    rewardEarned: 0,
    rewardPaid: false,
    codeUsed: 'MAA-USR-2024',
  ),
  const Referral(
    id: 'R007',
    refereeName: 'Royal Biryani House',
    category: ReferralCategory.vendor,
    status: ReferralStatus.verified,
    date: '2024-03-04',
    rewardEarned: 0,
    rewardPaid: false,
    codeUsed: 'MAA-VND-2024',
  ),
  const Referral(
    id: 'R008',
    refereeName: 'Vikram Singh',
    category: ReferralCategory.driver,
    status: ReferralStatus.activated,
    date: '2024-02-15',
    rewardEarned: 1000,
    rewardPaid: true,
    codeUsed: 'MAA-DRV-2024',
  ),
  const Referral(
    id: 'R009',
    refereeName: 'FoodieVentures Pvt Ltd',
    category: ReferralCategory.enterprise,
    status: ReferralStatus.activated,
    date: '2024-01-20',
    rewardEarned: 5000,
    rewardPaid: true,
    codeUsed: 'MAA-ENT-2024',
  ),
  const Referral(
    id: 'R010',
    refereeName: 'Bajaj RE - MH02',
    category: ReferralCategory.vehicle,
    status: ReferralStatus.registered,
    date: '2024-03-06',
    rewardEarned: 0,
    rewardPaid: false,
    codeUsed: 'MAA-VEH-2024',
  ),
];

// APP

class ReferEarnScreen extends StatefulWidget {
  const ReferEarnScreen({super.key});

  @override
  State<ReferEarnScreen> createState() => _ReferEarnScreenState();
}

class _ReferEarnScreenState extends State<ReferEarnScreen>
    with TickerProviderStateMixin {
  int _selectedTabIndex = 0;
  ReferralCategory _selectedCategory = ReferralCategory.user;
  bool _copiedCode = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _statusLabel(ReferralStatus s) {
    switch (s) {
      case ReferralStatus.invited:
        return 'Invited';
      case ReferralStatus.registered:
        return 'Registered';
      case ReferralStatus.verified:
        return 'Verified';
      case ReferralStatus.activated:
        return 'Activated';
      case ReferralStatus.rewardReleased:
        return 'Reward Released';
    }
  }

  Color _statusColor(ReferralStatus s) {
    switch (s) {
      case ReferralStatus.invited:
        return const Color(0xFF6B7280);
      case ReferralStatus.registered:
        return const Color(0xFF2563EB);
      case ReferralStatus.verified:
        return const Color(0xFF059669);
      case ReferralStatus.activated:
        return const Color(0xFF16A34A);
      case ReferralStatus.rewardReleased:
        return const Color(0xFF7C3AED);
    }
  }

  void _copyCodeForCategory(ReferralCategory category) {
    final code = categoryReferralCodes[category]!['code']!;
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $code'),
        backgroundColor: categoryConfig[category]!.color,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareCodeForCategory(ReferralCategory category) {
    final link = categoryReferralCodes[category]!['link']!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing: $link'),
        backgroundColor: const Color(0xFF1E40AF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(
              top: 48,
              left: 16,
              right: 16,
              bottom: 12,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  color: const Color(0xFF1E293B),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, maxWidth: 32),
                ),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _buildOptionTab('Overview', 0),
                        _buildOptionTab('Users', 1),
                        _buildOptionTab('Enterprise', 2),
                        _buildOptionTab('Movers', 3),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _OverviewTab(
                  onCopyUser: () => _copyCodeForCategory(ReferralCategory.user),
                  onShareUser: () =>
                      _shareCodeForCategory(ReferralCategory.user),
                  onCopyVendor: () =>
                      _copyCodeForCategory(ReferralCategory.vendor),
                  onShareVendor: () =>
                      _shareCodeForCategory(ReferralCategory.vendor),
                  onCopyMover: () =>
                      _copyCodeForCategory(ReferralCategory.driver),
                  onShareMover: () =>
                      _shareCodeForCategory(ReferralCategory.driver),
                  onTabChange: (index) {
                    setState(() {
                      _selectedTabIndex = index;
                    });
                  },
                ),
                _CategoryReferralsTab(
                  category: ReferralCategory.user,
                  referrals: referrals,
                  statusLabel: _statusLabel,
                  statusColor: _statusColor,
                  showSummaryCards: true,
                ),
                _CategoryReferralsTab(
                  category: ReferralCategory.vendor,
                  referrals: referrals,
                  statusLabel: _statusLabel,
                  statusColor: _statusColor,
                  showSummaryCards: true,
                ),
                _MoversTab(
                  referrals: referrals,
                  statusLabel: _statusLabel,
                  statusColor: _statusColor,
                  showSummaryCards: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTab(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF1E40AF)
                    : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// OVERVIEW TAB WITH 3 CARDS
// ============================================================

class _OverviewTab extends StatelessWidget {
  final VoidCallback onCopyUser;
  final VoidCallback onShareUser;
  final VoidCallback onCopyVendor;
  final VoidCallback onShareVendor;
  final VoidCallback onCopyMover;
  final VoidCallback onShareMover;
  final ValueChanged<int> onTabChange;

  const _OverviewTab({
    required this.onCopyUser,
    required this.onShareUser,
    required this.onCopyVendor,
    required this.onShareVendor,
    required this.onCopyMover,
    required this.onShareMover,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    final filteredCategories = byCategory.entries
        .where(
          (e) =>
              e.key != ReferralCategory.vendor &&
              e.key != ReferralCategory.vehicle,
        )
        .toList();
    final total = filteredCategories.fold(0, (sum, e) => sum + e.value);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFullCard(
            category: ReferralCategory.user,
            title: 'Refer Users',
            subtitle: '',
            reward: '₹25',
            rewardDetail: 'per user referral',
            icon: '👤',
            gradientColors: const [
              Color(0xFF1E3A8A),
              Color(0xFF2563EB),
              Color(0xFF3B82F6),
            ],
            onCopy: onCopyUser,
            onShare: onShareUser,
            onTap: () => onTabChange(1),
          ),
          const SizedBox(height: 16),
          _buildFullCard(
            category: ReferralCategory.vendor,
            title: 'Refer Vendors',
            subtitle: '',
            reward: '₹2,000',
            rewardDetail: 'per vendor onboarding',
            icon: '🏪',
            gradientColors: const [
              Color(0xFF14532D),
              Color(0xFF16A34A),
              Color(0xFF22C55E),
            ],
            onCopy: onCopyVendor,
            onShare: onShareVendor,
            onTap: () => onTabChange(2),
          ),
          const SizedBox(height: 16),
          _buildFullCard(
            category: ReferralCategory.driver,
            title: 'Refer Movers',
            subtitle: '',
            reward: '₹60',
            rewardDetail: 'per completed ride',
            icon: '🚗',
            gradientColors: const [
              Color(0xFF4C1D95),
              Color(0xFF9333EA),
              Color(0xFFA855F7),
            ],
            onCopy: onCopyMover,
            onShare: onShareMover,
            onTap: () => onTabChange(3),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Referrals by Category',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 16),
                _buildCategoryRow(
                  category: ReferralCategory.user,
                  count: byCategory[ReferralCategory.user]!,
                  total: total,
                ),
                _buildCategoryRow(
                  category: ReferralCategory.enterprise,
                  count: byCategory[ReferralCategory.enterprise]!,
                  total: total,
                ),
                _buildCategoryRow(
                  category: ReferralCategory.driver,
                  count: byCategory[ReferralCategory.driver]!,
                  total: total,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow({
    required ReferralCategory category,
    required int count,
    required int total,
  }) {
    final cfg = categoryConfig[category]!;
    final percentage = count / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: cfg.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(cfg.icon, style: const TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 70,
            child: Text(
              cfg.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 8,
                backgroundColor: cfg.color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(cfg.color),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: cfg.color,
            ),
          ),
        ],
      ),
    );
  }

  // Update the _buildFullCard method - remove the "Tap to view" badge

  Widget _buildFullCard({
    required ReferralCategory category,
    required String title,
    required String subtitle,
    required String reward,
    required String rewardDetail,
    required String icon,
    required List<Color> gradientColors,
    required VoidCallback onCopy,
    required VoidCallback onShare,
    required VoidCallback onTap,
  }) {
    final cfg = categoryConfig[category]!;
    final codeData = categoryReferralCodes[category]!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Category Header - WITHOUT "Tap to view"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cfg.color.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cfg.color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(icon, style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: cfg.color,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 11,
                            color: cfg.color.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // REMOVED: "Tap to view" badge container
                ],
              ),
            ),
            // Hero Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Refer & Earn',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          reward,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rewardDetail,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(icon, style: const TextStyle(fontSize: 30)),
                    ),
                  ),
                ],
              ),
            ),
            // Your Referral Code Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Referral Code',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cfg.color.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cfg.color.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Text(cfg.icon, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            codeData['code']!,
                            style: TextStyle(
                              color: cfg.color,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: onCopy,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: cfg.color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.copy_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Copy',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: onShare,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E40AF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.share_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Share',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // How it Works
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How It Works',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStep(
                    number: '1',
                    icon: Icons.share_rounded,
                    color: const Color(0xFF2563EB),
                    title: 'Share Your Code',
                    description: 'Share your unique referral code',
                  ),
                  _buildStep(
                    number: '2',
                    icon: Icons.person_add_rounded,
                    color: const Color(0xFF16A34A),
                    title: 'They Sign Up',
                    description: 'Friend registers using your code',
                  ),
                  _buildStep(
                    number: '3',
                    icon: Icons.verified_rounded,
                    color: const Color(0xFFD97706),
                    title: 'Get Verified',
                    description: 'Referral completes verification',
                  ),
                  _buildStep(
                    number: '4',
                    icon: Icons.account_balance_wallet_rounded,
                    color: const Color(0xFF7C3AED),
                    title: 'Earn Rewards',
                    description: '$reward credited to your wallet',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CATEGORY REFERRALS TAB WITH DROPDOWN FILTER
// ============================================================

class _CategoryReferralsTab extends StatefulWidget {
  final ReferralCategory category;
  final List<Referral> referrals;
  final String Function(ReferralStatus) statusLabel;
  final Color Function(ReferralStatus) statusColor;
  final bool showSummaryCards;

  const _CategoryReferralsTab({
    required this.category,
    required this.referrals,
    required this.statusLabel,
    required this.statusColor,
    this.showSummaryCards = true,
    super.key,
  });

  @override
  State<_CategoryReferralsTab> createState() => _CategoryReferralsTabState();
}

class _CategoryReferralsTabState extends State<_CategoryReferralsTab> {
  String _filterType = 'All';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.referrals
        .where((r) => r.category == widget.category)
        .toList();
    final cfg = categoryConfig[widget.category]!;

    final displayList = filtered.where((r) {
      if (_filterType == 'All') return true;
      if (_filterType == 'Registered')
        return r.status != ReferralStatus.invited;
      if (_filterType == 'Pending')
        return r.status == ReferralStatus.invited ||
            r.status == ReferralStatus.registered;
      return true;
    }).toList();

    final totalShared = filtered.length;
    final registeredUsers = filtered
        .where((r) => r.status != ReferralStatus.invited)
        .length;
    final pendingReferrals = filtered
        .where(
          (r) =>
              r.status == ReferralStatus.invited ||
              r.status == ReferralStatus.registered,
        )
        .length;
    final totalEarned = filtered.fold(0.0, (sum, r) => sum + r.rewardEarned);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (widget.showSummaryCards) ...[
            Container(
              height: 50,
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Total',
                      value: totalShared.toString(),
                      icon: Icons.share_rounded,
                      color: cfg.color,
                      bgColor: cfg.color.withOpacity(0.1),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Registered',
                      value: registeredUsers.toString(),
                      icon: Icons.person_add_rounded,
                      color: const Color(0xFF16A34A),
                      bgColor: const Color(0xFF16A34A).withOpacity(0.1),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Pending',
                      value: pendingReferrals.toString(),
                      icon: Icons.hourglass_top_rounded,
                      color: const Color(0xFFD97706),
                      bgColor: const Color(0xFFD97706).withOpacity(0.1),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Earned',
                      value: '₹${totalEarned.toInt()}',
                      icon: Icons.monetization_on_rounded,
                      color: const Color(0xFF7C3AED),
                      bgColor: const Color(0xFF7C3AED).withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${cfg.label} Referrals',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 0.5,
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: _filterType,
                    underline: const SizedBox(),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      size: 18,
                      color: cfg.color,
                    ),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: cfg.color,
                    ),
                    isDense: true,
                    items: [
                      DropdownMenuItem(
                        value: 'All',
                        child: Row(
                          children: [
                            Icon(
                              Icons.list,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'All',
                              style: TextStyle(color: Colors.grey.shade800),
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Registered',
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_add,
                              size: 16,
                              color: Colors.green.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Registered',
                              style: TextStyle(color: Colors.grey.shade800),
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Pending',
                        child: Row(
                          children: [
                            Icon(
                              Icons.hourglass_top,
                              size: 16,
                              color: Colors.orange.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Pending',
                              style: TextStyle(color: Colors.grey.shade800),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filterType = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          displayList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(cfg.icon, style: const TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text(
                        'No ${_filterType.toLowerCase()} ${cfg.label.toLowerCase()} referrals yet',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final r = displayList[i];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
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
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: cfg.color.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                cfg.icon,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.refereeName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.5,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Text(
                                      cfg.label,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: cfg.color,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Text(
                                      ' · ',
                                      style: TextStyle(
                                        color: Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    Text(
                                      r.date,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: widget
                                            .statusColor(r.status)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        widget.statusLabel(r.status),
                                        style: TextStyle(
                                          color: widget.statusColor(r.status),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      r.codeUsed,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFFCBD5E1),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (r.rewardEarned > 0)
                                Text(
                                  '₹${r.rewardEarned.toInt()}',
                                  style: TextStyle(
                                    color: r.rewardPaid
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFD97706),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                )
                              else
                                const Text(
                                  '—',
                                  style: TextStyle(
                                    color: Color(0xFFCBD5E1),
                                    fontSize: 15,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              if (r.rewardEarned > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: r.rewardPaid
                                        ? const Color(0xFFF0FDF4)
                                        : const Color(0xFFFFFBEB),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    r.rewardPaid ? 'Paid' : 'Pending',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600,
                                      color: r.rewardPaid
                                          ? const Color(0xFF16A34A)
                                          : const Color(0xFFD97706),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 12),
          ),
          const SizedBox(width: 6),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MOVERS TAB WITH DROPDOWN FILTER
// ============================================================

class _MoversTab extends StatefulWidget {
  final List<Referral> referrals;
  final String Function(ReferralStatus) statusLabel;
  final Color Function(ReferralStatus) statusColor;
  final bool showSummaryCards;

  const _MoversTab({
    required this.referrals,
    required this.statusLabel,
    required this.statusColor,
    this.showSummaryCards = true,
    super.key,
  });

  @override
  State<_MoversTab> createState() => _MoversTabState();
}

class _MoversTabState extends State<_MoversTab> {
  String _filterType = 'All';

  @override
  Widget build(BuildContext context) {
    final movers = widget.referrals
        .where(
          (r) =>
              r.category == ReferralCategory.driver ||
              r.category == ReferralCategory.vehicle,
        )
        .toList();

    final displayList = movers.where((r) {
      if (_filterType == 'All') return true;
      if (_filterType == 'Registered')
        return r.status != ReferralStatus.invited;
      if (_filterType == 'Pending')
        return r.status == ReferralStatus.invited ||
            r.status == ReferralStatus.registered;
      return true;
    }).toList();

    final totalShared = movers.length;
    final registeredUsers = movers
        .where((r) => r.status != ReferralStatus.invited)
        .length;
    final pendingReferrals = movers
        .where(
          (r) =>
              r.status == ReferralStatus.invited ||
              r.status == ReferralStatus.registered,
        )
        .length;
    final totalEarned = movers.fold(0.0, (sum, r) => sum + r.rewardEarned);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (widget.showSummaryCards) ...[
            Container(
              height: 50,
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Total',
                      value: totalShared.toString(),
                      icon: Icons.share_rounded,
                      color: const Color(0xFF9333EA),
                      bgColor: const Color(0xFF9333EA).withOpacity(0.1),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Registered',
                      value: registeredUsers.toString(),
                      icon: Icons.person_add_rounded,
                      color: const Color(0xFF16A34A),
                      bgColor: const Color(0xFF16A34A).withOpacity(0.1),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Pending',
                      value: pendingReferrals.toString(),
                      icon: Icons.hourglass_top_rounded,
                      color: const Color(0xFFD97706),
                      bgColor: const Color(0xFFD97706).withOpacity(0.1),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Earned',
                      value: '₹${totalEarned.toInt()}',
                      icon: Icons.monetization_on_rounded,
                      color: const Color(0xFF7C3AED),
                      bgColor: const Color(0xFF7C3AED).withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Movers Referrals',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 0.5,
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: _filterType,
                    underline: const SizedBox(),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      size: 18,
                      color: const Color(0xFF9333EA),
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9333EA),
                    ),
                    isDense: true,
                    items: [
                      DropdownMenuItem(
                        value: 'All',
                        child: Row(
                          children: [
                            Icon(
                              Icons.list,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'All',
                              style: TextStyle(color: Colors.grey.shade800),
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Registered',
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_add,
                              size: 16,
                              color: Colors.green.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Registered',
                              style: TextStyle(color: Colors.grey.shade800),
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Pending',
                        child: Row(
                          children: [
                            Icon(
                              Icons.hourglass_top,
                              size: 16,
                              color: Colors.orange.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Pending',
                              style: TextStyle(color: Colors.grey.shade800),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filterType = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
          displayList.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🚗🛵', style: TextStyle(fontSize: 48)),
                      SizedBox(height: 12),
                      Text(
                        'No movers referrals yet',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final r = displayList[i];
                    final cfg = categoryConfig[r.category]!;
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
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
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: cfg.color.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                cfg.icon,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.refereeName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.5,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Text(
                                      cfg.label,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: cfg.color,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Text(
                                      ' · ',
                                      style: TextStyle(
                                        color: Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    Text(
                                      r.date,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: widget
                                            .statusColor(r.status)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        widget.statusLabel(r.status),
                                        style: TextStyle(
                                          color: widget.statusColor(r.status),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      r.codeUsed,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFFCBD5E1),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (r.rewardEarned > 0)
                                Text(
                                  '₹${r.rewardEarned.toInt()}',
                                  style: TextStyle(
                                    color: r.rewardPaid
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFD97706),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                )
                              else
                                const Text(
                                  '—',
                                  style: TextStyle(
                                    color: Color(0xFFCBD5E1),
                                    fontSize: 15,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              if (r.rewardEarned > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: r.rewardPaid
                                        ? const Color(0xFFF0FDF4)
                                        : const Color(0xFFFFFBEB),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    r.rewardPaid ? 'Paid' : 'Pending',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600,
                                      color: r.rewardPaid
                                          ? const Color(0xFF16A34A)
                                          : const Color(0xFFD97706),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
