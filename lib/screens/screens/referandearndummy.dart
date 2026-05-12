// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// enum ReferralCategory { user, vendor, enterprise, driver, vehicle }
//
// enum ReferralStatus { invited, registered, verified, activated, rewardReleased }
//
// enum RewardType {
//   cash,
//   coupon,
//   points,
//   commissionReduction,
//   promotionCredits,
//   freeDelivery,
//   vendorCredits,
//   driverBonus,
// }
//
// class CategoryConfig {
//   final String label;
//   final Color color;
//   final String icon;
//   const CategoryConfig({
//     required this.label,
//     required this.color,
//     required this.icon,
//   });
// }
//
// class Referral {
//   final String id;
//   final String refereeName;
//   final ReferralCategory category;
//   final ReferralStatus status;
//   final String date;
//   final double rewardEarned;
//   final bool rewardPaid;
//   final String codeUsed;
//   const Referral({
//     required this.id,
//     required this.refereeName,
//     required this.category,
//     required this.status,
//     required this.date,
//     required this.rewardEarned,
//     required this.rewardPaid,
//     required this.codeUsed,
//   });
// }
//
// class RewardHistoryItem {
//   final String id;
//   final String date;
//   final String referralName;
//   final ReferralCategory referralType;
//   final RewardType rewardType;
//   final String rewardDescription;
//   final double amount;
//   final String status; // 'credited' | 'pending' | 'expired'
//   const RewardHistoryItem({
//     required this.id,
//     required this.date,
//     required this.referralName,
//     required this.referralType,
//     required this.rewardType,
//     required this.rewardDescription,
//     required this.amount,
//     required this.status,
//   });
// }
//
// class WalletTransaction {
//   final String id;
//   final String type; // 'credit' | 'debit'
//   final double amount;
//   final String description;
//   final String date;
//   final ReferralCategory category;
//   const WalletTransaction({
//     required this.id,
//     required this.type,
//     required this.amount,
//     required this.description,
//     required this.date,
//     required this.category,
//   });
// }
//
// // ─────────────────────────────────────────────
// // STATIC DATA
// // ─────────────────────────────────────────────
//
// final Map<ReferralCategory, CategoryConfig> categoryConfig = {
//   ReferralCategory.user: CategoryConfig(
//     label: 'Users',
//     color: const Color(0xFFEA580C),
//     icon: '👤',
//   ),
//   ReferralCategory.vendor: CategoryConfig(
//     label: 'Vendors',
//     color: const Color(0xFF16A34A),
//     icon: '🏪',
//   ),
//   ReferralCategory.enterprise: CategoryConfig(
//     label: 'Enterprise',
//     color: const Color(0xFF2563EB),
//     icon: '🏢',
//   ),
//   ReferralCategory.driver: CategoryConfig(
//     label: 'Drivers',
//     color: const Color(0xFF9333EA),
//     icon: '🚗',
//   ),
//   ReferralCategory.vehicle: CategoryConfig(
//     label: 'Vehicles',
//     color: const Color(0xFFCA8A04),
//     icon: '🛵',
//   ),
// };
//
// final Map<ReferralCategory, Map<String, String>> categoryReferralCodes = {
//   ReferralCategory.user: {
//     'code': 'MAA-USR-2024',
//     'link': 'https://maamaas.com/join/user?ref=MAA-USR-2024',
//   },
//   ReferralCategory.vendor: {
//     'code': 'MAA-VND-2024',
//     'link': 'https://maamaas.com/join/vendor?ref=MAA-VND-2024',
//   },
//   ReferralCategory.enterprise: {
//     'code': 'MAA-ENT-2024',
//     'link': 'https://maamaas.com/join/enterprise?ref=MAA-ENT-2024',
//   },
//   ReferralCategory.driver: {
//     'code': 'MAA-DRV-2024',
//     'link': 'https://maamaas.com/join/driver?ref=MAA-DRV-2024',
//   },
//   ReferralCategory.vehicle: {
//     'code': 'MAA-VEH-2024',
//     'link': 'https://maamaas.com/join/vehicle?ref=MAA-VEH-2024',
//   },
// };
//
// const dashboardStats = {
//   'totalReferrals': 147,
//   'successfulReferrals': 89,
//   'pendingReferrals': 42,
//   'rewardsEarned': 24500.0,
//   'rewardsRedeemed': 18200.0,
//   'walletBalance': 6300.0,
// };
//
// const Map<ReferralCategory, int> byCategory = {
//   ReferralCategory.user: 62,
//   ReferralCategory.vendor: 28,
//   ReferralCategory.enterprise: 12,
//   ReferralCategory.driver: 31,
//   ReferralCategory.vehicle: 14,
// };
//
// final List<Referral> referrals = [
//   const Referral(
//     id: 'R001',
//     refereeName: 'Priya Sharma',
//     category: ReferralCategory.user,
//     status: ReferralStatus.activated,
//     date: '2024-03-01',
//     rewardEarned: 100,
//     rewardPaid: true,
//     codeUsed: 'MAA-USR-2024',
//   ),
//   const Referral(
//     id: 'R002',
//     refereeName: 'Spice Junction',
//     category: ReferralCategory.vendor,
//     status: ReferralStatus.rewardReleased,
//     date: '2024-02-28',
//     rewardEarned: 2000,
//     rewardPaid: true,
//     codeUsed: 'MAA-VND-2024',
//   ),
//   const Referral(
//     id: 'R003',
//     refereeName: 'TechCorp India',
//     category: ReferralCategory.enterprise,
//     status: ReferralStatus.verified,
//     date: '2024-03-05',
//     rewardEarned: 0,
//     rewardPaid: false,
//     codeUsed: 'MAA-ENT-2024',
//   ),
//   const Referral(
//     id: 'R004',
//     refereeName: 'Rajesh Kumar',
//     category: ReferralCategory.driver,
//     status: ReferralStatus.registered,
//     date: '2024-03-07',
//     rewardEarned: 0,
//     rewardPaid: false,
//     codeUsed: 'MAA-DRV-2024',
//   ),
//   const Referral(
//     id: 'R005',
//     refereeName: 'Honda Activa - KA01',
//     category: ReferralCategory.vehicle,
//     status: ReferralStatus.activated,
//     date: '2024-02-20',
//     rewardEarned: 500,
//     rewardPaid: true,
//     codeUsed: 'MAA-VEH-2024',
//   ),
//   const Referral(
//     id: 'R006',
//     refereeName: 'Anita Desai',
//     category: ReferralCategory.user,
//     status: ReferralStatus.invited,
//     date: '2024-03-08',
//     rewardEarned: 0,
//     rewardPaid: false,
//     codeUsed: 'MAA-USR-2024',
//   ),
//   const Referral(
//     id: 'R007',
//     refereeName: 'Royal Biryani House',
//     category: ReferralCategory.vendor,
//     status: ReferralStatus.verified,
//     date: '2024-03-04',
//     rewardEarned: 0,
//     rewardPaid: false,
//     codeUsed: 'MAA-VND-2024',
//   ),
//   const Referral(
//     id: 'R008',
//     refereeName: 'Vikram Singh',
//     category: ReferralCategory.driver,
//     status: ReferralStatus.activated,
//     date: '2024-02-15',
//     rewardEarned: 1000,
//     rewardPaid: true,
//     codeUsed: 'MAA-DRV-2024',
//   ),
//   const Referral(
//     id: 'R009',
//     refereeName: 'FoodieVentures Pvt Ltd',
//     category: ReferralCategory.enterprise,
//     status: ReferralStatus.activated,
//     date: '2024-01-20',
//     rewardEarned: 5000,
//     rewardPaid: true,
//     codeUsed: 'MAA-ENT-2024',
//   ),
//   const Referral(
//     id: 'R010',
//     refereeName: 'Bajaj RE - MH02',
//     category: ReferralCategory.vehicle,
//     status: ReferralStatus.registered,
//     date: '2024-03-06',
//     rewardEarned: 0,
//     rewardPaid: false,
//     codeUsed: 'MAA-VEH-2024',
//   ),
// ];
//
// final List<RewardHistoryItem> rewardHistory = [
//   const RewardHistoryItem(
//     id: 'RW001',
//     date: '2024-03-01',
//     referralName: 'Priya Sharma',
//     referralType: ReferralCategory.user,
//     rewardType: RewardType.cash,
//     rewardDescription: 'Wallet credit for user referral',
//     amount: 100,
//     status: 'credited',
//   ),
//   const RewardHistoryItem(
//     id: 'RW002',
//     date: '2024-02-28',
//     referralName: 'Spice Junction',
//     referralType: ReferralCategory.vendor,
//     rewardType: RewardType.vendorCredits,
//     rewardDescription: 'Vendor onboarding reward',
//     amount: 2000,
//     status: 'credited',
//   ),
//   const RewardHistoryItem(
//     id: 'RW003',
//     date: '2024-02-20',
//     referralName: 'Honda Activa - KA01',
//     referralType: ReferralCategory.vehicle,
//     rewardType: RewardType.cash,
//     rewardDescription: 'Vehicle onboarding bonus',
//     amount: 500,
//     status: 'credited',
//   ),
//   const RewardHistoryItem(
//     id: 'RW004',
//     date: '2024-02-15',
//     referralName: 'Vikram Singh',
//     referralType: ReferralCategory.driver,
//     rewardType: RewardType.driverBonus,
//     rewardDescription: 'Driver referral bonus after 20 deliveries',
//     amount: 1000,
//     status: 'credited',
//   ),
//   const RewardHistoryItem(
//     id: 'RW005',
//     date: '2024-01-20',
//     referralName: 'FoodieVentures Pvt Ltd',
//     referralType: ReferralCategory.enterprise,
//     rewardType: RewardType.cash,
//     rewardDescription: 'Enterprise referral reward',
//     amount: 5000,
//     status: 'credited',
//   ),
//   const RewardHistoryItem(
//     id: 'RW006',
//     date: '2024-03-05',
//     referralName: 'TechCorp India',
//     referralType: ReferralCategory.enterprise,
//     rewardType: RewardType.points,
//     rewardDescription: 'Enterprise verification bonus points',
//     amount: 200,
//     status: 'pending',
//   ),
//   const RewardHistoryItem(
//     id: 'RW007',
//     date: '2024-03-04',
//     referralName: 'Royal Biryani House',
//     referralType: ReferralCategory.vendor,
//     rewardType: RewardType.promotionCredits,
//     rewardDescription: 'Free promotion credits on verification',
//     amount: 500,
//     status: 'pending',
//   ),
//   const RewardHistoryItem(
//     id: 'RW009',
//     date: '2024-01-15',
//     referralName: 'Express Cargo - TN01',
//     referralType: ReferralCategory.vehicle,
//     rewardType: RewardType.freeDelivery,
//     rewardDescription: 'Fleet incentive credit',
//     amount: 300,
//     status: 'expired',
//   ),
// ];
//
// final List<WalletTransaction> walletTransactions = [
//   const WalletTransaction(
//     id: 'W001',
//     type: 'credit',
//     amount: 100,
//     description: 'User referral reward - Priya Sharma',
//     date: '2024-03-01',
//     category: ReferralCategory.user,
//   ),
//   const WalletTransaction(
//     id: 'W002',
//     type: 'credit',
//     amount: 2000,
//     description: 'Vendor referral reward - Spice Junction',
//     date: '2024-02-28',
//     category: ReferralCategory.vendor,
//   ),
//   const WalletTransaction(
//     id: 'W003',
//     type: 'debit',
//     amount: 500,
//     description: 'Redeemed to main wallet',
//     date: '2024-03-02',
//     category: ReferralCategory.user,
//   ),
//   const WalletTransaction(
//     id: 'W004',
//     type: 'credit',
//     amount: 500,
//     description: 'Vehicle registration bonus - Honda Activa',
//     date: '2024-02-20',
//     category: ReferralCategory.vehicle,
//   ),
//   const WalletTransaction(
//     id: 'W005',
//     type: 'credit',
//     amount: 1000,
//     description: 'Driver referral reward - Vikram Singh',
//     date: '2024-02-15',
//     category: ReferralCategory.driver,
//   ),
//   const WalletTransaction(
//     id: 'W006',
//     type: 'credit',
//     amount: 5000,
//     description: 'Enterprise referral reward - FoodieVentures',
//     date: '2024-01-20',
//     category: ReferralCategory.enterprise,
//   ),
//   const WalletTransaction(
//     id: 'W007',
//     type: 'debit',
//     amount: 2000,
//     description: 'Order discount applied',
//     date: '2024-02-25',
//     category: ReferralCategory.user,
//   ),
// ];
//
// // ─────────────────────────────────────────────
// // APP
// // ─────────────────────────────────────────────
//
// class ReferEarnScreen extends StatefulWidget {
//   const ReferEarnScreen({super.key});
//
//   @override
//   State<ReferEarnScreen> createState() => _ReferEarnScreenState();
// }
//
// class _ReferEarnScreenState extends State<ReferEarnScreen>
//     with TickerProviderStateMixin {
//   late TabController _tabController;
//   ReferralCategory _selectedCategory = ReferralCategory.user;
//   bool _copiedCode = false;
//   String _activeTab = 'overview'; // overview | referrals | rewards | wallet
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   String _statusLabel(ReferralStatus s) {
//     switch (s) {
//       case ReferralStatus.invited:
//         return 'Invited';
//       case ReferralStatus.registered:
//         return 'Registered';
//       case ReferralStatus.verified:
//         return 'Verified';
//       case ReferralStatus.activated:
//         return 'Activated';
//       case ReferralStatus.rewardReleased:
//         return 'Reward Released';
//     }
//   }
//
//   Color _statusColor(ReferralStatus s) {
//     switch (s) {
//       case ReferralStatus.invited:
//         return const Color(0xFF6B7280);
//       case ReferralStatus.registered:
//         return const Color(0xFF2563EB);
//       case ReferralStatus.verified:
//         return const Color(0xFF059669);
//       case ReferralStatus.activated:
//         return const Color(0xFF16A34A);
//       case ReferralStatus.rewardReleased:
//         return const Color(0xFF7C3AED);
//     }
//   }
//
//   String _rewardTypeLabel(RewardType r) {
//     switch (r) {
//       case RewardType.cash:
//         return 'Cash Reward';
//       case RewardType.coupon:
//         return 'Coupon';
//       case RewardType.points:
//         return 'Points';
//       case RewardType.commissionReduction:
//         return 'Commission Reduction';
//       case RewardType.promotionCredits:
//         return 'Promotion Credits';
//       case RewardType.freeDelivery:
//         return 'Free Delivery';
//       case RewardType.vendorCredits:
//         return 'Vendor Credits';
//       case RewardType.driverBonus:
//         return 'Driver Bonus';
//     }
//   }
//
//   void _copyCode() {
//     final code = categoryReferralCodes[_selectedCategory]!['code']!;
//     Clipboard.setData(ClipboardData(text: code));
//     setState(() => _copiedCode = true);
//     Future.delayed(
//       const Duration(seconds: 2),
//       () => mounted ? setState(() => _copiedCode = false) : null,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       body: NestedScrollView(
//         headerSliverBuilder: (context, _) => [
//           SliverAppBar(
//             expandedHeight: 0,
//             floating: true,
//             snap: true,
//             backgroundColor: Colors.white,
//             elevation: 0,
//             surfaceTintColor: Colors.white,
//             shadowColor: Colors.black12,
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
//               color: const Color(0xFF1E293B),
//               onPressed: () {},
//             ),
//             centerTitle: true,
//             title: Text(
//               'Refer & Earn',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//                 color: Color(0xFF1E293B),
//               ),
//             ),
//
//             // actions: [
//             //   Container(
//             //     margin: const EdgeInsets.only(right: 16),
//             //     padding:
//             //     const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             //     decoration: BoxDecoration(
//             //       color: const Color(0xFFF0FDF4),
//             //       borderRadius: BorderRadius.circular(20),
//             //       border: Border.all(color: const Color(0xFF86EFAC)),
//             //     ),
//             //     child: Row(
//             //       children: [
//             //         const Icon(Icons.account_balance_wallet_rounded,
//             //             size: 14, color: Color(0xFF16A34A)),
//             //         const SizedBox(width: 4),
//             //         Text(
//             //           '₹${dashboardStats['walletBalance']!.toInt()}',
//             //           style: const TextStyle(
//             //               color: Color(0xFF16A34A),
//             //               fontWeight: FontWeight.w700,
//             //               fontSize: 13),
//             //         ),
//             //       ],
//             //     ),
//             //   ),
//             // ],
//             bottom: TabBar(
//               controller: _tabController,
//               labelColor: const Color(0xFF1E40AF),
//               unselectedLabelColor: const Color(0xFF94A3B8),
//               indicatorColor: const Color(0xFF1E40AF),
//               indicatorWeight: 2.5,
//               labelStyle: const TextStyle(
//                 fontSize: 12.5,
//                 fontWeight: FontWeight.w600,
//               ),
//               unselectedLabelStyle: const TextStyle(fontSize: 12.5),
//               tabs: const [
//                 Tab(text: 'Overview'),
//                 Tab(text: 'Referrals'),
//                 Tab(text: 'Rewards'),
//                 // Tab(text: 'Wallet'),
//               ],
//             ),
//           ),
//         ],
//         body: TabBarView(
//           controller: _tabController,
//           children: [
//             _OverviewTab(
//               selectedCategory: _selectedCategory,
//               copiedCode: _copiedCode,
//               onCategoryChanged: (c) => setState(() => _selectedCategory = c),
//               onCopy: _copyCode,
//               onShare: () => ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(
//                     'Sharing: ${categoryReferralCodes[_selectedCategory]!['link']}',
//                   ),
//                   backgroundColor: const Color(0xFF1E40AF),
//                   behavior: SnackBarBehavior.floating,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//             ),
//             _ReferralsTab(
//               referrals: referrals,
//               statusLabel: _statusLabel,
//               statusColor: _statusColor,
//             ),
//             _RewardsTab(
//               rewardHistory: rewardHistory,
//               rewardTypeLabel: _rewardTypeLabel,
//             ),
//             // _WalletTab(transactions: walletTransactions),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// // TAB 1: OVERVIEW
// // ─────────────────────────────────────────────
//
// class _OverviewTab extends StatelessWidget {
//   final ReferralCategory selectedCategory;
//   final bool copiedCode;
//   final ValueChanged<ReferralCategory> onCategoryChanged;
//   final VoidCallback onCopy;
//   final VoidCallback onShare;
//
//   const _OverviewTab({
//     required this.selectedCategory,
//     required this.copiedCode,
//     required this.onCategoryChanged,
//     required this.onCopy,
//     required this.onShare,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // Hero Banner
//           _HeroBanner(),
//           const SizedBox(height: 16),
//
//           // Stats Grid
//           _StatsGrid(),
//           const SizedBox(height: 16),
//
//           // Category breakdown
//           _CategoryBreakdown(),
//           const SizedBox(height: 16),
//
//           // Category selector + code card
//           _CategoryCodeCard(
//             selectedCategory: selectedCategory,
//             copiedCode: copiedCode,
//             onCategoryChanged: onCategoryChanged,
//             onCopy: onCopy,
//             onShare: onShare,
//           ),
//           const SizedBox(height: 16),
//
//           // How it works
//           _HowItWorksCard(),
//           const SizedBox(height: 24),
//         ],
//       ),
//     );
//   }
// }
//
// class _HeroBanner extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF3B82F6)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF1E40AF).withOpacity(0.3),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: const Text(
//                     '🚀  Multi-Category Referrals',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 10.5,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 const Text(
//                   'Refer & Earn\nBig Rewards!',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.w800,
//                     height: 1.2,
//                     letterSpacing: -0.5,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   'Refer users, vendors, drivers,\nvehicles & enterprises.',
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.8),
//                     fontSize: 12.5,
//                     height: 1.4,
//                   ),
//                 ),
//                 const SizedBox(height: 14),
//                 Row(
//                   children: [
//                     _MiniChip('👤 ₹100'),
//                     const SizedBox(width: 6),
//                     _MiniChip('🏪 ₹2000'),
//                     const SizedBox(width: 6),
//                     _MiniChip('🏢 ₹5000'),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 12),
//           Column(
//             children: [
//               Container(
//                 width: 70,
//                 height: 70,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.15),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Center(
//                   child: Text('🎁', style: TextStyle(fontSize: 36)),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Earn up to',
//                 style: TextStyle(
//                   color: Colors.white.withOpacity(0.7),
//                   fontSize: 10,
//                 ),
//               ),
//               const Text(
//                 '₹24,500+',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _MiniChip extends StatelessWidget {
//   final String text;
//   const _MiniChip(this.text);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.white.withOpacity(0.25)),
//       ),
//       child: Text(
//         text,
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 10.5,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }
// }
//
// class _StatsGrid extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final stats = [
//       {
//         'label': 'Total Referrals',
//         'value': '147',
//         'icon': Icons.people_alt_rounded,
//         'color': const Color(0xFF2563EB),
//         'bg': const Color(0xFFEFF6FF),
//       },
//       {
//         'label': 'Successful',
//         'value': '89',
//         'icon': Icons.check_circle_rounded,
//         'color': const Color(0xFF16A34A),
//         'bg': const Color(0xFFF0FDF4),
//       },
//       {
//         'label': 'Pending',
//         'value': '42',
//         'icon': Icons.hourglass_top_rounded,
//         'color': const Color(0xFFD97706),
//         'bg': const Color(0xFFFFFBEB),
//       },
//       {
//         'label': 'Rewards Earned',
//         'value': '₹24.5K',
//         'icon': Icons.monetization_on_rounded,
//         'color': const Color(0xFF7C3AED),
//         'bg': const Color(0xFFF5F3FF),
//       },
//       {
//         'label': 'Redeemed',
//         'value': '₹18.2K',
//         'icon': Icons.redeem_rounded,
//         'color': const Color(0xFFDB2777),
//         'bg': const Color(0xFFFFF1F7),
//       },
//       {
//         'label': 'Wallet Balance',
//         'value': '₹6,300',
//         'icon': Icons.account_balance_wallet_rounded,
//         'color': const Color(0xFF059669),
//         'bg': const Color(0xFFF0FDF4),
//       },
//     ];
//
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//         childAspectRatio: 0.95,
//       ),
//       itemCount: stats.length,
//       itemBuilder: (_, i) {
//         final s = stats[i];
//         return Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(14),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.04),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(7),
//                 decoration: BoxDecoration(
//                   color: s['bg'] as Color,
//                   borderRadius: BorderRadius.circular(9),
//                 ),
//                 child: Icon(
//                   s['icon'] as IconData,
//                   color: s['color'] as Color,
//                   size: 16,
//                 ),
//               ),
//               const Spacer(),
//               Text(
//                 s['value'] as String,
//                 style: TextStyle(
//                   color: s['color'] as Color,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w800,
//                   letterSpacing: -0.3,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 s['label'] as String,
//                 style: const TextStyle(
//                   color: Color(0xFF94A3B8),
//                   fontSize: 9.5,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
// class _CategoryBreakdown extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final total = byCategory.values.fold(0, (a, b) => a + b);
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Referrals by Category',
//             style: TextStyle(
//               color: Color(0xFF1E293B),
//               fontSize: 15,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           const SizedBox(height: 14),
//           ...byCategory.entries.map((e) {
//             final cfg = categoryConfig[e.key]!;
//             final pct = e.value / total;
//             return Padding(
//               padding: const EdgeInsets.only(bottom: 10),
//               child: Row(
//                 children: [
//                   Text(cfg.icon, style: const TextStyle(fontSize: 16)),
//                   const SizedBox(width: 8),
//                   SizedBox(
//                     width: 72,
//                     child: Text(
//                       cfg.label,
//                       style: const TextStyle(
//                         fontSize: 12.5,
//                         fontWeight: FontWeight.w500,
//                         color: Color(0xFF475569),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(4),
//                       child: LinearProgressIndicator(
//                         value: pct,
//                         minHeight: 7,
//                         backgroundColor: cfg.color.withOpacity(0.1),
//                         valueColor: AlwaysStoppedAnimation<Color>(cfg.color),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     '${e.value}',
//                     style: TextStyle(
//                       fontSize: 12.5,
//                       fontWeight: FontWeight.w700,
//                       color: cfg.color,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }
// }
//
// class _CategoryCodeCard extends StatelessWidget {
//   final ReferralCategory selectedCategory;
//   final bool copiedCode;
//   final ValueChanged<ReferralCategory> onCategoryChanged;
//   final VoidCallback onCopy;
//   final VoidCallback onShare;
//
//   const _CategoryCodeCard({
//     required this.selectedCategory,
//     required this.copiedCode,
//     required this.onCategoryChanged,
//     required this.onCopy,
//     required this.onShare,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final cfg = categoryConfig[selectedCategory]!;
//     final codeData = categoryReferralCodes[selectedCategory]!;
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Your Referral Codes',
//             style: TextStyle(
//               color: Color(0xFF1E293B),
//               fontSize: 15,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           const SizedBox(height: 4),
//           const Text(
//             'Select category to see your code',
//             style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
//           ),
//           const SizedBox(height: 14),
//
//           // Category pills
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: ReferralCategory.values.map((cat) {
//                 final c = categoryConfig[cat]!;
//                 final selected = cat == selectedCategory;
//                 return GestureDetector(
//                   onTap: () => onCategoryChanged(cat),
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     margin: const EdgeInsets.only(right: 8),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 7,
//                     ),
//                     decoration: BoxDecoration(
//                       color: selected ? c.color : c.color.withOpacity(0.08),
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(
//                         color: selected ? c.color : c.color.withOpacity(0.2),
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Text(c.icon, style: const TextStyle(fontSize: 13)),
//                         const SizedBox(width: 5),
//                         Text(
//                           c.label,
//                           style: TextStyle(
//                             color: selected ? Colors.white : c.color,
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//
//           const SizedBox(height: 14),
//
//           // Code display
//           Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: cfg.color.withOpacity(0.05),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: cfg.color.withOpacity(0.2)),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Text(cfg.icon, style: const TextStyle(fontSize: 18)),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         codeData['code']!,
//                         style: TextStyle(
//                           color: cfg.color,
//                           fontSize: 18,
//                           fontWeight: FontWeight.w800,
//                           letterSpacing: 2,
//                         ),
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: onCopy,
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 200),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 7,
//                         ),
//                         decoration: BoxDecoration(
//                           color: copiedCode
//                               ? const Color(0xFF16A34A)
//                               : cfg.color,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(
//                               copiedCode
//                                   ? Icons.check_rounded
//                                   : Icons.copy_rounded,
//                               color: Colors.white,
//                               size: 14,
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               copiedCode ? 'Copied!' : 'Copy',
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.link_rounded,
//                       size: 12,
//                       color: cfg.color.withOpacity(0.6),
//                     ),
//                     const SizedBox(width: 4),
//                     Expanded(
//                       child: Text(
//                         codeData['link']!,
//                         style: TextStyle(
//                           color: cfg.color.withOpacity(0.7),
//                           fontSize: 10.5,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 12),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: onShare,
//               icon: const Icon(
//                 Icons.share_rounded,
//                 size: 16,
//                 color: Colors.white,
//               ),
//               label: const Text(
//                 'Share Referral Link',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w700,
//                   fontSize: 14,
//                   color: Colors.white,
//                 ),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF1E40AF),
//                 padding: const EdgeInsets.symmetric(vertical: 13),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 elevation: 0,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _HowItWorksCard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final steps = [
//       {
//         'icon': Icons.share_rounded,
//         'color': const Color(0xFF2563EB),
//         'title': 'Share Your Code',
//         'desc': 'Pick a category and share your unique referral code or link.',
//       },
//       {
//         'icon': Icons.person_add_rounded,
//         'color': const Color(0xFF16A34A),
//         'title': 'They Sign Up',
//         'desc': 'Your referral registers using your code.',
//       },
//       {
//         'icon': Icons.verified_rounded,
//         'color': const Color(0xFFD97706),
//         'title': 'Get Verified',
//         'desc': 'Referral completes verification and gets activated.',
//       },
//       {
//         'icon': Icons.account_balance_wallet_rounded,
//         'color': const Color(0xFF7C3AED),
//         'title': 'Earn Rewards',
//         'desc': 'Reward is credited to your wallet automatically.',
//       },
//     ];
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'How It Works',
//             style: TextStyle(
//               color: Color(0xFF1E293B),
//               fontSize: 15,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           const SizedBox(height: 16),
//           ...steps.asMap().entries.map((e) {
//             final i = e.key;
//             final s = e.value;
//             return Column(
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       width: 40,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         color: (s['color'] as Color).withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(11),
//                       ),
//                       child: Icon(
//                         s['icon'] as IconData,
//                         color: s['color'] as Color,
//                         size: 20,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             s['title'] as String,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 13.5,
//                               color: Color(0xFF1E293B),
//                             ),
//                           ),
//                           const SizedBox(height: 2),
//                           Text(
//                             s['desc'] as String,
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: Color(0xFF94A3B8),
//                               height: 1.4,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       width: 22,
//                       height: 22,
//                       decoration: BoxDecoration(
//                         color: (s['color'] as Color).withOpacity(0.1),
//                         shape: BoxShape.circle,
//                       ),
//                       child: Center(
//                         child: Text(
//                           '${i + 1}',
//                           style: TextStyle(
//                             color: s['color'] as Color,
//                             fontSize: 11,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 if (i < steps.length - 1)
//                   Padding(
//                     padding: const EdgeInsets.only(left: 19),
//                     child: Container(
//                       width: 2,
//                       height: 16,
//                       margin: const EdgeInsets.symmetric(vertical: 4),
//                       color: const Color(0xFFE2E8F0),
//                     ),
//                   ),
//               ],
//             );
//           }),
//         ],
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// // TAB 2: REFERRALS
// // ─────────────────────────────────────────────
//
// class _ReferralsTab extends StatefulWidget {
//   final List<Referral> referrals;
//   final String Function(ReferralStatus) statusLabel;
//   final Color Function(ReferralStatus) statusColor;
//
//   const _ReferralsTab({
//     required this.referrals,
//     required this.statusLabel,
//     required this.statusColor,
//   });
//
//   @override
//   State<_ReferralsTab> createState() => _ReferralsTabState();
// }
//
// class _ReferralsTabState extends State<_ReferralsTab> {
//   ReferralCategory? _filter;
//
//   @override
//   Widget build(BuildContext context) {
//     final filtered = _filter == null
//         ? widget.referrals
//         : widget.referrals.where((r) => r.category == _filter).toList();
//
//     return Column(
//       children: [
//         // Filter row
//         Container(
//           color: Colors.white,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: [
//                 _FilterChip(
//                   label: 'All',
//                   selected: _filter == null,
//                   color: const Color(0xFF1E40AF),
//                   onTap: () => setState(() => _filter = null),
//                 ),
//                 ...ReferralCategory.values.map((c) {
//                   final cfg = categoryConfig[c]!;
//                   return _FilterChip(
//                     label: '${cfg.icon} ${cfg.label}',
//                     selected: _filter == c,
//                     color: cfg.color,
//                     onTap: () => setState(() => _filter = c),
//                   );
//                 }),
//               ],
//             ),
//           ),
//         ),
//         Expanded(
//           child: ListView.separated(
//             padding: const EdgeInsets.all(16),
//             itemCount: filtered.length,
//             separatorBuilder: (_, __) => const SizedBox(height: 10),
//             itemBuilder: (_, i) {
//               final r = filtered[i];
//               final cfg = categoryConfig[r.category]!;
//               return Container(
//                 padding: const EdgeInsets.all(14),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(14),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.04),
//                       blurRadius: 8,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 44,
//                       height: 44,
//                       decoration: BoxDecoration(
//                         color: cfg.color.withOpacity(0.12),
//                         shape: BoxShape.circle,
//                       ),
//                       child: Center(
//                         child: Text(
//                           cfg.icon,
//                           style: const TextStyle(fontSize: 20),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             r.refereeName,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 13.5,
//                               color: Color(0xFF1E293B),
//                             ),
//                           ),
//                           const SizedBox(height: 3),
//                           Row(
//                             children: [
//                               Text(
//                                 cfg.label,
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   color: cfg.color,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               const Text(
//                                 ' · ',
//                                 style: TextStyle(color: Color(0xFFCBD5E1)),
//                               ),
//                               Text(
//                                 r.date,
//                                 style: const TextStyle(
//                                   fontSize: 11,
//                                   color: Color(0xFF94A3B8),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 5),
//                           Row(
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 8,
//                                   vertical: 3,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: widget
//                                       .statusColor(r.status)
//                                       .withOpacity(0.1),
//                                   borderRadius: BorderRadius.circular(6),
//                                 ),
//                                 child: Text(
//                                   widget.statusLabel(r.status),
//                                   style: TextStyle(
//                                     color: widget.statusColor(r.status),
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 6),
//                               Text(
//                                 r.codeUsed,
//                                 style: const TextStyle(
//                                   fontSize: 10,
//                                   color: Color(0xFFCBD5E1),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         if (r.rewardEarned > 0)
//                           Text(
//                             '₹${r.rewardEarned.toInt()}',
//                             style: TextStyle(
//                               color: r.rewardPaid
//                                   ? const Color(0xFF16A34A)
//                                   : const Color(0xFFD97706),
//                               fontWeight: FontWeight.w700,
//                               fontSize: 15,
//                             ),
//                           )
//                         else
//                           const Text(
//                             '—',
//                             style: TextStyle(
//                               color: Color(0xFFCBD5E1),
//                               fontSize: 15,
//                             ),
//                           ),
//                         const SizedBox(height: 4),
//                         if (r.rewardEarned > 0)
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 6,
//                               vertical: 2,
//                             ),
//                             decoration: BoxDecoration(
//                               color: r.rewardPaid
//                                   ? const Color(0xFFF0FDF4)
//                                   : const Color(0xFFFFFBEB),
//                               borderRadius: BorderRadius.circular(5),
//                             ),
//                             child: Text(
//                               r.rewardPaid ? 'Paid' : 'Pending',
//                               style: TextStyle(
//                                 fontSize: 9.5,
//                                 fontWeight: FontWeight.w600,
//                                 color: r.rewardPaid
//                                     ? const Color(0xFF16A34A)
//                                     : const Color(0xFFD97706),
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class _FilterChip extends StatelessWidget {
//   final String label;
//   final bool selected;
//   final Color color;
//   final VoidCallback onTap;
//
//   const _FilterChip({
//     required this.label,
//     required this.selected,
//     required this.color,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         margin: const EdgeInsets.only(right: 8),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         decoration: BoxDecoration(
//           color: selected ? color : color.withOpacity(0.07),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: selected ? color : color.withOpacity(0.2)),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             color: selected ? Colors.white : color,
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// // TAB 3: REWARDS
// // ─────────────────────────────────────────────
//
// class _RewardsTab extends StatelessWidget {
//   final List<RewardHistoryItem> rewardHistory;
//   final String Function(RewardType) rewardTypeLabel;
//
//   const _RewardsTab({
//     required this.rewardHistory,
//     required this.rewardTypeLabel,
//   });
//
//   Color _statusColor(String s) {
//     switch (s) {
//       case 'credited':
//         return const Color(0xFF16A34A);
//       case 'pending':
//         return const Color(0xFFD97706);
//       case 'expired':
//         return const Color(0xFFEF4444);
//       default:
//         return const Color(0xFF94A3B8);
//     }
//   }
//
//   IconData _statusIcon(String s) {
//     switch (s) {
//       case 'credited':
//         return Icons.check_circle_rounded;
//       case 'pending':
//         return Icons.schedule_rounded;
//       case 'expired':
//         return Icons.cancel_rounded;
//       default:
//         return Icons.info_rounded;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Summary row
//     final credited = rewardHistory
//         .where((r) => r.status == 'credited')
//         .fold(0.0, (a, b) => a + b.amount);
//     final pending = rewardHistory
//         .where((r) => r.status == 'pending')
//         .fold(0.0, (a, b) => a + b.amount);
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // Summary
//           Row(
//             children: [
//               Expanded(
//                 child: _SummaryCard(
//                   label: 'Total Credited',
//                   value: '₹${credited.toInt()}',
//                   color: const Color(0xFF16A34A),
//                   icon: Icons.check_circle_rounded,
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: _SummaryCard(
//                   label: 'Pending',
//                   value: '₹${pending.toInt()}',
//                   color: const Color(0xFFD97706),
//                   icon: Icons.schedule_rounded,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//
//           // List
//           ...rewardHistory.map((rw) {
//             final cfg = categoryConfig[rw.referralType]!;
//             return Container(
//               margin: const EdgeInsets.only(bottom: 10),
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(14),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.04),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 42,
//                     height: 42,
//                     decoration: BoxDecoration(
//                       color: cfg.color.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(11),
//                     ),
//                     child: Center(
//                       child: Text(
//                         cfg.icon,
//                         style: const TextStyle(fontSize: 19),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           rw.referralName,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 13.5,
//                             color: Color(0xFF1E293B),
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           rw.rewardDescription,
//                           style: const TextStyle(
//                             fontSize: 11.5,
//                             color: Color(0xFF94A3B8),
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 5),
//                         Row(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 7,
//                                 vertical: 2,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: cfg.color.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(5),
//                               ),
//                               child: Text(
//                                 rewardTypeLabel(rw.rewardType),
//                                 style: TextStyle(
//                                   fontSize: 9.5,
//                                   color: cfg.color,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 6),
//                             Text(
//                               rw.date,
//                               style: const TextStyle(
//                                 fontSize: 10.5,
//                                 color: Color(0xFFCBD5E1),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text(
//                         '₹${rw.amount.toInt()}',
//                         style: TextStyle(
//                           color: _statusColor(rw.status),
//                           fontWeight: FontWeight.w800,
//                           fontSize: 15,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Icon(
//                         _statusIcon(rw.status),
//                         color: _statusColor(rw.status),
//                         size: 16,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }
// }
//
// class _SummaryCard extends StatelessWidget {
//   final String label;
//   final String value;
//   final Color color;
//   final IconData icon;
//
//   const _SummaryCard({
//     required this.label,
//     required this.value,
//     required this.color,
//     required this.icon,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, color: color, size: 18),
//           ),
//           const SizedBox(width: 10),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 value,
//                 style: TextStyle(
//                   color: color,
//                   fontWeight: FontWeight.w800,
//                   fontSize: 17,
//                 ),
//               ),
//               Text(
//                 label,
//                 style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// // TAB 4: WALLET
// // ─────────────────────────────────────────────
//
// class _WalletTab extends StatelessWidget {
//   final List<WalletTransaction> transactions;
//
//   const _WalletTab({required this.transactions});
//
//   @override
//   Widget build(BuildContext context) {
//     final balance = transactions.fold(0.0, (sum, t) {
//       return t.type == 'credit' ? sum + t.amount : sum - t.amount;
//     });
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // Balance card
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xFF059669), Color(0xFF10B981)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(18),
//               boxShadow: [
//                 BoxShadow(
//                   color: const Color(0xFF059669).withOpacity(0.3),
//                   blurRadius: 16,
//                   offset: const Offset(0, 6),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     const Icon(
//                       Icons.account_balance_wallet_rounded,
//                       color: Colors.white70,
//                       size: 18,
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       'Referral Wallet',
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.8),
//                         fontSize: 13,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   '₹${balance.toInt()}',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 36,
//                     fontWeight: FontWeight.w800,
//                     letterSpacing: -1,
//                   ),
//                 ),
//                 const SizedBox(height: 14),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {},
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       foregroundColor: const Color(0xFF059669),
//                       padding: const EdgeInsets.symmetric(vertical: 11),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       elevation: 0,
//                     ),
//                     child: const Text(
//                       'Redeem to Main Wallet',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w700,
//                         fontSize: 13,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 20),
//
//           const Align(
//             alignment: Alignment.centerLeft,
//             child: Text(
//               'Transaction History',
//               style: TextStyle(
//                 color: Color(0xFF1E293B),
//                 fontSize: 15,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//           const SizedBox(height: 12),
//
//           ...transactions.map((t) {
//             final cfg = categoryConfig[t.category]!;
//             final isCredit = t.type == 'credit';
//             return Container(
//               margin: const EdgeInsets.only(bottom: 10),
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(14),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.04),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 42,
//                     height: 42,
//                     decoration: BoxDecoration(
//                       color: isCredit
//                           ? const Color(0xFFF0FDF4)
//                           : const Color(0xFFFFF1F2),
//                       borderRadius: BorderRadius.circular(11),
//                     ),
//                     child: Icon(
//                       isCredit
//                           ? Icons.arrow_downward_rounded
//                           : Icons.arrow_upward_rounded,
//                       color: isCredit
//                           ? const Color(0xFF16A34A)
//                           : const Color(0xFFEF4444),
//                       size: 20,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           t.description,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.w500,
//                             fontSize: 12.5,
//                             color: Color(0xFF1E293B),
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 3),
//                         Row(
//                           children: [
//                             Text(
//                               cfg.icon,
//                               style: const TextStyle(fontSize: 11),
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               cfg.label,
//                               style: TextStyle(
//                                 fontSize: 10.5,
//                                 color: cfg.color,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             const Text(
//                               ' · ',
//                               style: TextStyle(color: Color(0xFFCBD5E1)),
//                             ),
//                             Text(
//                               t.date,
//                               style: const TextStyle(
//                                 fontSize: 10.5,
//                                 color: Color(0xFF94A3B8),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   Text(
//                     '${isCredit ? '+' : '-'}₹${t.amount.toInt()}',
//                     style: TextStyle(
//                       color: isCredit
//                           ? const Color(0xFF16A34A)
//                           : const Color(0xFFEF4444),
//                       fontWeight: FontWeight.w700,
//                       fontSize: 15,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }
// }