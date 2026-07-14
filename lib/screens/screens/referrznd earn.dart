// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:share_plus/share_plus.dart';
// import '../../Models/subscrptions/referals.dart';
// import '../../Services/Auth_service/Subscription_authservice.dart';
// import '../../Services/scaffoldmessenger/messenger.dart';
//
// // ─── Enums ─────────────────────────────────────────────────────────────────
//
// enum ReferralCategory {
//   user,
//   vendor,
//   // enterprise,
//   driver,
//   vehicle,
// }
//
// enum ReferralStatus {
//   invited,
//   // registered,
//   // verified,
//   // activated,
//   rewardReleased,
// }
//
// // ─── Design Tokens ─────────────────────────────────────────────────────────
//
// class _K {
//   // Brand
//   static const primary = Color(0xFFE66D33);
//   static const bg = Color(0xFFF6F7FB);
//   static const textDark = Color(0xFF1A0E08);
//   static const textMid = Color(0xFF8A6A5A);
//   static const ink = Color(0xFF111827);
//
//   // Status colours (shared)
//   static const green = Color(0xFF16A34A);
//   static const amber = Color(0xFFD97706);
//   static const purple = Color(0xFF7C3AED);
//   static const blue = Color(0xFF2563EB);
//   static const grey = Color(0xFF6B7280);
// }
//
// // ─── Category Config ────────────────────────────────────────────────────────
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
// const Map<ReferralCategory, CategoryConfig> categoryConfig = {
//   ReferralCategory.user: CategoryConfig(
//     label: 'Users',
//     color: Color(0xFFEA580C),
//     icon: '👤',
//   ),
//   ReferralCategory.vendor: CategoryConfig(
//     label: 'Vendors',
//     color: Color(0xFF16A34A),
//     icon: '🏪',
//   ),
//   // ReferralCategory.enterprise: CategoryConfig(
//   //   label: 'Enterprise',
//   //   color: Color(0xFF2563EB),
//   //   icon: '🏢',
//   // ),
//   ReferralCategory.driver: CategoryConfig(
//     label: 'Drivers',
//     color: Color(0xFF9333EA),
//     icon: '🚗',
//   ),
//   ReferralCategory.vehicle: CategoryConfig(
//     label: 'Vehicles',
//     color: Color(0xFFCA8A04),
//     icon: '🛵',
//   ),
// };
//
// ReferralCategory getCategory(ReferralResponse r) {
//   if (r.usedByVendorId != null) {
//     return ReferralCategory.vendor;
//   }
//
//   if (r.usedByPartnerId != null) {
//     return ReferralCategory.driver;
//   }
//
//   return ReferralCategory.user;
// }
//
// // ReferralStatus getStatus(ReferralResponse r) {
// //   if (r.rewardGiven) {
// //     return ReferralStatus.rewardReleased;
// //   }
// //
// //   return ReferralStatus.activated;
// // }
// ReferralStatus getStatus(ReferralResponse r) {
//   return r.rewardGiven ? ReferralStatus.rewardReleased : ReferralStatus.invited;
// }
//
// // ─── Screen ─────────────────────────────────────────────────────────────────
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
//   // ── API state ──────────────────────────────────────────────────────────────
//   late Future<ReferralHistoryResponse> _futureProfile;
//   // ── Tab state ──────────────────────────────────────────────────────────────
//   int _selectedTabIndex = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _futureProfile = subscription_AuthService.getReferralHistory();
//   }
//
//   // ─── Status helpers ──────────────────────────────────────────────────────
//
//   String _statusLabel(ReferralStatus s) {
//     switch (s) {
//       case ReferralStatus.invited:
//         return 'Invited';
//       // case ReferralStatus.registered:
//       //   return 'Registered';
//       // case ReferralStatus.verified:
//       //   return 'Verified';
//       // case ReferralStatus.activated:
//       //   return 'Activated';
//       case ReferralStatus.rewardReleased:
//         return 'Reward Released';
//     }
//   }
//
//   Color _statusColor(ReferralStatus s) {
//     switch (s) {
//       case ReferralStatus.invited:
//         return _K.grey;
//       // case ReferralStatus.registered:
//       //   return _K.blue;
//       // case ReferralStatus.verified:
//       //   return const Color(0xFF059669);
//       // case ReferralStatus.activated:
//       //   return _K.green;
//       case ReferralStatus.rewardReleased:
//         return _K.purple;
//     }
//   }
//
//   String _getReferralType(ReferralCategory category) {
//     switch (category) {
//       case ReferralCategory.user:
//         return "user";
//
//       case ReferralCategory.vendor:
//         return "vendor";
//
//       case ReferralCategory.driver:
//         return "mover";
//
//       case ReferralCategory.vehicle:
//         return "vehicle";
//     }
//   }
//
//   // ─── Actions — one referral code for ALL categories ──────────────────────
//
//   // void _copyCode(BuildContext context, String referralCode) {
//   //   // Clipboard.setData(ClipboardData(text: referralCode));
//   //   final encoded = Uri.encodeComponent(referralCode);
//   //   final link = 'https://applink.maamaas.com/referral?referralCode=$encoded';
//   //   Clipboard.setData(
//   //     ClipboardData(
//   //       text:
//   //           '🎉 Join Maamaas using my referral code: *$referralCode*\n\n'
//   //           '📲 Tap to download & sign up — using this code:\n'
//   //           '$link',
//   //     ),
//   //   );
//   //   AppAlert.success(context, '✅ Referral code copied!');
//   // }
//   //
//   // void _shareCode(String referralCode) {
//   //   final encoded = Uri.encodeComponent(referralCode);
//   //   final link = 'https://applink.maamaas.com/referral?referralCode=$encoded';
//   //   // ignore: deprecated_member_use
//   //   Share.share(
//   //     '🎉 Join Maamaas using my referral code: *$referralCode*\n\n'
//   //     '📲 Tap to download & sign up — using this code:\n'
//   //     '$link',
//   //   );
//   // }
//
//   void _copyCode(
//     BuildContext context,
//     String referralCode,
//     ReferralCategory category,
//   ) {
//     final encoded = Uri.encodeComponent(referralCode);
//
//     final type = _getReferralType(category);
//
//     final link =
//         'https://applink.maamaas.com/referral?type=$type&referralCode=$encoded';
//
//     Clipboard.setData(
//       ClipboardData(
//         text:
//             '🎉 Join Maamaas using my referral code: $referralCode\n\n'
//             '📲 Tap to download & sign up:\n'
//             '$link',
//       ),
//     );
//
//     AppAlert.success(context, '✅ Referral link copied!');
//   }
//
//   void _shareCode(String referralCode, ReferralCategory category) {
//     final encoded = Uri.encodeComponent(referralCode);
//
//     final type = _getReferralType(category);
//
//     final link =
//         'https://applink.maamaas.com/referral?type=$type&referralCode=$encoded';
//
//     Share.share(
//       '🎉 Join Maamaas using my referral code: $referralCode\n\n'
//       '📲 Tap to download & sign up:\n'
//       '$link',
//     );
//   }
//
//   // ─── Build ───────────────────────────────────────────────────────────────
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _K.bg,
//       body: FutureBuilder<ReferralHistoryResponse>(
//         future: _futureProfile,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return _LoadingState();
//           }
//
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//
//           if (!snapshot.hasData) {
//             return _ErrorState(
//               onRetry: () => setState(() {
//                 _futureProfile = subscription_AuthService.getReferralHistory();
//               }),
//             );
//           }
//
//           final response = snapshot.data!;
//
//           final referrals = response.referrals;
//
//           final totalCashBack = response.totalReferralAmount;
//
//           final referralCode = referrals.isNotEmpty
//               ? referrals.first.referralCode
//               : '';
//
//           final totalReferals = referrals.length;
//
//           return Column(
//             children: [
//               // ── App Bar ────────────────────────────────────────────────
//               Container(
//                 color: Colors.white,
//                 padding: EdgeInsets.only(
//                   top: MediaQuery.of(context).padding.top + 8,
//                   left: 12.w,
//                   right: 16.w,
//                   bottom: 12.h,
//                 ),
//                 child: Row(
//                   children: [
//                     GestureDetector(
//                       onTap: () => Navigator.of(context).pop(),
//                       child: Container(
//                         margin: EdgeInsets.all(6.w),
//                         padding: EdgeInsets.all(8.w),
//                         decoration: BoxDecoration(
//                           color: _K.bg,
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(
//                           Icons.arrow_back_ios_new_rounded,
//                           size: 16.sp,
//                           color: _K.ink,
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: Container(
//                         height: 40.h,
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFF1F5F9),
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                         child: Row(
//                           children: [
//                             _buildOptionTab('Overview', 0),
//                             _buildOptionTab('Users', 1),
//                             _buildOptionTab('Vendor', 2),
//                             _buildOptionTab('Movers', 3),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // ── Tab Body ───────────────────────────────────────────────
//               Expanded(
//                 child: IndexedStack(
//                   index: _selectedTabIndex,
//                   children: [
//                     // Overview tab
//                     _OverviewTab(
//                       referralCode: referralCode,
//                       totalReferals: totalReferals,
//                       totalCashBack: totalCashBack,
//                       onCopy: _copyCode,
//                       onShare: _shareCode,
//                       // onCopy: () => _copyCode(context, referralCode,type),
//                       // onShare: () => _shareCode(referralCode ,type),
//                       // onTabChange: (i) => setState(() => _selectedTabIndex = i),
//                     ),
//
//                     // Users tab
//                     _CategoryReferralsTab(
//                       category: ReferralCategory.user,
//                       referrals: referrals,
//                       referralCode: referralCode,
//                       statusLabel: _statusLabel,
//                       statusColor: _statusColor,
//                       onCopy: () => _copyCode(
//                         context,
//                         referralCode,
//                         ReferralCategory.user,
//                       ),
//                       onShare: () =>
//                           _shareCode(referralCode, ReferralCategory.user),
//                     ),
//                     // Enterprise tab
//                     _CategoryReferralsTab(
//                       category: ReferralCategory.vendor,
//                       referrals: referrals,
//                       referralCode: referralCode,
//                       statusLabel: _statusLabel,
//                       statusColor: _statusColor,
//                       onCopy: () => _copyCode(
//                         context,
//                         referralCode,
//                         ReferralCategory.user,
//                       ),
//                       onShare: () =>
//                           _shareCode(referralCode, ReferralCategory.user),
//                     ),
//                     // Movers tab
//                     _MoversTab(
//                       referrals: referrals,
//                       referralCode: referralCode,
//                       statusLabel: _statusLabel,
//                       statusColor: _statusColor,
//                       onCopy: () => _copyCode(
//                         context,
//                         referralCode,
//                         ReferralCategory.user,
//                       ),
//                       onShare: () =>
//                           _shareCode(referralCode, ReferralCategory.user),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildOptionTab(String label, int index) {
//     final isSelected = _selectedTabIndex == index;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => setState(() => _selectedTabIndex = index),
//         child: Container(
//           margin: EdgeInsets.all(4.w),
//           decoration: BoxDecoration(
//             color: isSelected ? Colors.white : Colors.transparent,
//             borderRadius: BorderRadius.circular(10.r),
//             boxShadow: isSelected
//                 ? [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 4,
//                       offset: const Offset(0, 1),
//                     ),
//                   ]
//                 : null,
//           ),
//           child: Center(
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12.sp,
//                 fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
//                 color: isSelected
//                     ? const Color(0xFF1E40AF)
//                     : const Color(0xFF64748B),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Loading State ───────────────────────────────────────────────────────────
//
// class _LoadingState extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           SizedBox(
//             width: 36.w,
//             height: 36.w,
//             child: const CircularProgressIndicator(
//               strokeWidth: 2.5,
//               color: _K.primary,
//             ),
//           ),
//           SizedBox(height: 14.h),
//           Text(
//             'Loading your referral...',
//             style: TextStyle(fontSize: 13.sp, color: _K.textMid),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─── Error State ─────────────────────────────────────────────────────────────
//
// class _ErrorState extends StatelessWidget {
//   final VoidCallback onRetry;
//   const _ErrorState({required this.onRetry});
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             padding: EdgeInsets.all(16.w),
//             decoration: const BoxDecoration(
//               color: Color(0xFFFEF2F2),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(Icons.wifi_off_rounded, size: 28.sp, color: Colors.red),
//           ),
//           SizedBox(height: 12.h),
//           Text(
//             'Could not load referral code',
//             style: TextStyle(
//               fontSize: 15.sp,
//               fontWeight: FontWeight.w600,
//               color: _K.textDark,
//             ),
//           ),
//           SizedBox(height: 4.h),
//           Text(
//             'Please check your connection and try again.',
//             style: TextStyle(fontSize: 12.sp, color: _K.textMid),
//             textAlign: TextAlign.center,
//           ),
//           SizedBox(height: 20.h),
//           GestureDetector(
//             onTap: onRetry,
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
//               decoration: BoxDecoration(
//                 color: _K.primary,
//                 borderRadius: BorderRadius.circular(12.r),
//               ),
//               child: Text(
//                 'Retry',
//                 style: TextStyle(
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─── Overview Tab ────────────────────────────────────────────────────────────
//
// class _OverviewTab extends StatelessWidget {
//   final String referralCode;
//   final int totalReferals;
//   final double totalCashBack;
//   final Function(BuildContext, String, ReferralCategory) onCopy;
//   final Function(String, ReferralCategory) onShare;
//   // final VoidCallback onCopy;
//   // final VoidCallback onShare;
//
//   // final ValueChanged<int> onTabChange;
//
//   const _OverviewTab({
//     required this.referralCode,
//     required this.totalReferals,
//     required this.totalCashBack,
//     required this.onCopy,
//     required this.onShare,
//     // required this.onTabChange,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       physics: const BouncingScrollPhysics(),
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//       child: Column(
//         children: [
//           // ── Stats row (live from API) ──────────────────────────────────
//           Row(
//             children: [
//               Expanded(
//                 child: _StatTile(
//                   icon: Icons.people_alt_rounded,
//                   value: totalReferals.toString(),
//                   label: 'Referred',
//                   color: _K.purple,
//                 ),
//               ),
//               SizedBox(width: 12.w),
//               Expanded(
//                 child: _StatTile(
//                   icon: Icons.emoji_events_rounded,
//                   value: '₹${totalCashBack.toStringAsFixed(0)}',
//                   label: 'Cashback',
//                   color: const Color(0xFFF59E0B),
//                 ),
//               ),
//             ],
//           ),
//
//           SizedBox(height: 20.h),
//
//           // ── Category cards (one shared code for all) ───────────────────
//           _buildFullCard(
//             context: context,
//             category: ReferralCategory.user,
//             title: 'Users',
//             reward: '₹25',
//             // rewardDetail: 'per user referral',
//             rewardDetail: 'On completion of their First order',
//             gradientColors: const [
//               Color(0xFF1E3A8A),
//               Color(0xFF2563EB),
//               Color(0xFF3B82F6),
//             ],
//             onCopy: onCopy,
//             onShare: onShare,
//             // onCopy: onCopy,
//             // onShare: onShare,
//             // onTap: () => onTabChange(1),
//           ),
//
//           SizedBox(height: 16.h),
//
//           _buildFullCard(
//             context: context,
//             category: ReferralCategory.vendor,
//             title: 'Vendors',
//             reward: '₹200',
//             // rewardDetail: 'per vendor onboarding',
//             rewardDetail: 'On completion of 20 Orders',
//             gradientColors: const [
//               Color(0xFF14532D),
//               Color(0xFF16A34A),
//               Color(0xFF22C55E),
//             ],
//             onCopy: onCopy,
//             onShare: onShare,
//             // onCopy: onCopy,
//             // onShare: onShare,
//             // onTap: () => onTabChange(2),
//           ),
//
//           SizedBox(height: 16.h),
//
//           _buildFullCard(
//             context: context,
//             category: ReferralCategory.driver,
//             title: 'Movers',
//             reward: '₹150',
//             rewardDetail: 'On Completion of 15 deliveries',
//             gradientColors: const [
//               Color(0xFF4C1D95),
//               Color(0xFF9333EA),
//               Color(0xFFA855F7),
//             ],
//             onCopy: onCopy,
//             onShare: onShare,
//             // onCopy: onCopy,
//             // onShare: onShare,
//             // onTap: () => onTabChange(3),
//           ),
//
//           SizedBox(height: 24.h),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFullCard({
//     required BuildContext context,
//     required ReferralCategory category,
//     required String title,
//     required String reward,
//     required String rewardDetail,
//     required List<Color> gradientColors,
//     required Function(BuildContext, String, ReferralCategory) onCopy,
//     required Function(String, ReferralCategory) onShare,
//     // required VoidCallback onCopy,
//     // required VoidCallback onShare,
//     // required VoidCallback onTap,
//   }) {
//     final cfg = categoryConfig[category]!;
//
//     return
//     // GestureDetector(
//     // onTap: onTap,
//     // child:
//     Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Category header
//           // Container(
//           //   padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//           //   decoration: BoxDecoration(
//           //     color: cfg.color.withOpacity(0.1),
//           //     borderRadius: BorderRadius.only(
//           //       topLeft: Radius.circular(20.r),
//           //       topRight: Radius.circular(20.r),
//           //     ),
//           //   ),
//           //   child: Row(
//           //     children: [
//           //       Container(
//           //         width: 36.w,
//           //         height: 36.w,
//           //         decoration: BoxDecoration(
//           //           color: cfg.color,
//           //           borderRadius: BorderRadius.circular(10.r),
//           //         ),
//           //         child: Center(
//           //           child: Text(cfg.icon, style: const TextStyle(fontSize: 20)),
//           //         ),
//           //       ),
//           //       // SizedBox(width: 12.w),
//           //       // Text(
//           //       //   title,
//           //       //   style: TextStyle(
//           //       //     fontSize: 16.sp,
//           //       //     fontWeight: FontWeight.w700,
//           //       //     color: cfg.color,
//           //       //   ),
//           //       // ),
//           //     ],
//           //   ),
//           // ),
//
//           // Hero gradient section
//           Container(
//             padding: EdgeInsets.all(20.w),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: gradientColors,
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         '$title Refer & Earn ",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 22.sp,
//                           fontWeight: FontWeight.w800,
//                         ),
//                       ),
//                       // Text(
//                       //   reward,
//                       //   style: TextStyle(
//                       //     color: Colors.white,
//                       //     fontSize: 28.sp,
//                       //     fontWeight: FontWeight.w800,
//                       //   ),
//                       // ),
//                       // SizedBox(height: 4.h),
//                       // Text(
//                       //   rewardDetail,
//                       //   style: TextStyle(
//                       //     color: Colors.white.withOpacity(0.8),
//                       //     fontSize: 11.sp,
//                       //   ),
//                       // ),
//                     ],
//                   ),
//                 ),
//
//                 Text(
//                   "get $reward",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 28.sp,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 // Container(
//                 //   width: 60.w,
//                 //   height: 60.w,
//                 //   decoration: BoxDecoration(
//                 //     color: Colors.white.withOpacity(0.15),
//                 //     shape: BoxShape.circle,
//                 //   ),
//                 //   child: Center(
//                 //     child: Text(cfg.icon, style: const TextStyle(fontSize: 30)),
//                 //   ),
//                 // ),
//               ],
//             ),
//           ),
//
//           // Referral code section (real code from API)
//           Padding(
//             padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Your Referral Code',
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w600,
//                     color: const Color(0xFF1E293B),
//                   ),
//                 ),
//                 SizedBox(height: 8.h),
//                 Container(
//                   padding: EdgeInsets.all(14.w),
//                   decoration: BoxDecoration(
//                     color: cfg.color.withOpacity(0.05),
//                     borderRadius: BorderRadius.circular(16.r),
//                     border: Border.all(color: cfg.color.withOpacity(0.15)),
//                   ),
//                   child: Column(
//                     children: [
//                       // Referral Code
//                       Container(
//                         width: double.infinity,
//                         padding: EdgeInsets.symmetric(
//                           vertical: 12.h,
//                           horizontal: 12.w,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             // Text(
//                             //   cfg.icon,
//                             //   style: TextStyle(fontSize: 20.sp),
//                             // ),
//                             // SizedBox(width: 8.w),
//                             Text(
//                               referralCode,
//                               style: TextStyle(
//                                 color: cfg.color,
//                                 fontSize: 18.sp,
//                                 fontWeight: FontWeight.w800,
//                                 letterSpacing: 1.2,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       SizedBox(height: 12.h),
//
//                       // Actions
//                       Row(
//                         children: [
//                           Expanded(
//                             child: InkWell(
//                               borderRadius: BorderRadius.circular(10.r),
//                               onTap: () =>
//                                   onCopy(context, referralCode, category),
//                               child: Container(
//                                 height: 42.h,
//                                 decoration: BoxDecoration(
//                                   color: cfg.color,
//                                   borderRadius: BorderRadius.circular(10.r),
//                                 ),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(
//                                       Icons.copy_rounded,
//                                       color: Colors.white,
//                                       size: 16.sp,
//                                     ),
//                                     SizedBox(width: 6.w),
//                                     Text(
//                                       'Copy',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 12.sp,
//                                         fontWeight: FontWeight.w700,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//
//                           SizedBox(width: 10.w),
//
//                           Expanded(
//                             child: InkWell(
//                               borderRadius: BorderRadius.circular(10.r),
//                               onTap: () => onShare(referralCode, category),
//                               child: Container(
//                                 height: 42.h,
//                                 decoration: BoxDecoration(
//                                   color: const Color(0xFF1E40AF),
//                                   borderRadius: BorderRadius.circular(10.r),
//                                 ),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(
//                                       Icons.share_rounded,
//                                       color: Colors.white,
//                                       size: 16.sp,
//                                     ),
//                                     SizedBox(width: 6.w),
//                                     Text(
//                                       'Share',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 12.sp,
//                                         fontWeight: FontWeight.w700,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // How it works
//           _HowItWorksSection(reward: reward, rewardDetail: rewardDetail),
//         ],
//       ),
//       // ),
//     );
//   }
// }
//
// // ─── How It Works (reusable) ─────────────────────────────────────────────────
//
// class _HowItWorksSection extends StatelessWidget {
//   final String reward;
//   final String rewardDetail;
//   const _HowItWorksSection({required this.reward, required this.rewardDetail});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.all(16.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'How It Works',
//             style: TextStyle(
//               fontSize: 16.sp,
//               fontWeight: FontWeight.w700,
//               color: const Color(0xFF1E293B),
//             ),
//           ),
//           SizedBox(height: 12.h),
//           _buildStep(
//             number: '1',
//             icon: Icons.share_rounded,
//             color: _K.blue,
//             title: 'Share Your Code',
//             description: 'Share your unique referral code',
//           ),
//           _buildStep(
//             number: '2',
//             icon: Icons.person_add_rounded,
//             color: _K.green,
//             title: 'They Sign Up',
//             description: 'Friend registers using your code',
//           ),
//           _buildStep(
//             number: '3',
//             icon: Icons.verified_rounded,
//             color: const Color(0xFFD97706),
//             title: 'Get Verified',
//             description: 'Referral completes verification',
//           ),
//           _buildStep(
//             number: '4',
//             icon: Icons.account_balance_wallet_rounded,
//             color: _K.purple,
//             title: 'Earn Rewards',
//             description: '$reward $rewardDetail',
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStep({
//     required String number,
//     required IconData icon,
//     required Color color,
//     required String title,
//     required String description,
//   }) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 10.h),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 28.w,
//             height: 28.w,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8.r),
//             ),
//             child: Icon(icon, color: color, size: 14.sp),
//           ),
//           SizedBox(width: 10.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 12.sp,
//                     color: const Color(0xFF1E293B),
//                   ),
//                 ),
//                 Text(
//                   description,
//                   style: TextStyle(
//                     fontSize: 10.sp,
//                     color: const Color(0xFF94A3B8),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             width: 18.w,
//             height: 18.w,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Center(
//               child: Text(
//                 number,
//                 style: TextStyle(
//                   color: color,
//                   fontSize: 9.sp,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─── Category Referrals Tab ───────────────────────────────────────────────────
//
// class _CategoryReferralsTab extends StatefulWidget {
//   final ReferralCategory category;
//   final List<ReferralResponse> referrals;
//   final String referralCode;
//   final String Function(ReferralStatus) statusLabel;
//   final Color Function(ReferralStatus) statusColor;
//   final VoidCallback onCopy;
//   final VoidCallback onShare;
//
//   const _CategoryReferralsTab({
//     required this.category,
//     required this.referrals,
//     required this.referralCode,
//     required this.statusLabel,
//     required this.statusColor,
//     required this.onCopy,
//     required this.onShare,
//     super.key,
//   });
//
//   @override
//   State<_CategoryReferralsTab> createState() => _CategoryReferralsTabState();
// }
//
// class _CategoryReferralsTabState extends State<_CategoryReferralsTab> {
//   String _filterType = 'All';
//
//   @override
//   Widget build(BuildContext context) {
//     final filtered = widget.referrals
//         .where((r) => getCategory(r) == widget.category)
//         .toList();
//     final cfg = categoryConfig[widget.category]!;
//
//     final displayList = filtered.where((r) {
//       if (_filterType == 'All') return true;
//       if (_filterType == 'Registered') {
//         return getStatus(r) != ReferralStatus.invited;
//       }
//       if (_filterType == 'Pending') {
//         return getStatus(r) == ReferralStatus.invited;
//       }
//       return true;
//     }).toList();
//
//     final totalShared = filtered.length;
//     final registeredCount = filtered
//         .where((r) => getStatus(r) != ReferralStatus.invited)
//         .length;
//     final pendingCount = filtered
//         .where((r) => getStatus(r) == ReferralStatus.invited)
//         .length;
//     final totalEarned = filtered.fold(0.0, (sum, r) => sum + r.bonusAmount);
//
//     return SingleChildScrollView(
//       physics: const BouncingScrollPhysics(),
//       padding: EdgeInsets.all(16.w),
//       child: Column(
//         children: [
//           // Inline referral code card for this tab
//           _InlineCodeCard(
//             referralCode: widget.referralCode,
//             cfg: cfg,
//             onCopy: widget.onCopy,
//             onShare: widget.onShare,
//           ),
//
//           SizedBox(height: 16.h),
//
//           // Summary stat cards
//           SizedBox(
//             height: 50.h,
//             child: Row(
//               children: [
//                 Expanded(
//                   child: _SummaryCard(
//                     title: 'Total',
//                     value: totalShared.toString(),
//                     icon: Icons.share_rounded,
//                     color: cfg.color,
//                     bgColor: cfg.color.withOpacity(0.1),
//                   ),
//                 ),
//                 SizedBox(width: 6.w),
//                 Expanded(
//                   child: _SummaryCard(
//                     title: 'Registered',
//                     value: registeredCount.toString(),
//                     icon: Icons.person_add_rounded,
//                     color: _K.green,
//                     bgColor: _K.green.withOpacity(0.1),
//                   ),
//                 ),
//                 SizedBox(width: 6.w),
//                 Expanded(
//                   child: _SummaryCard(
//                     title: 'Pending',
//                     value: pendingCount.toString(),
//                     icon: Icons.hourglass_top_rounded,
//                     color: _K.amber,
//                     bgColor: _K.amber.withOpacity(0.1),
//                   ),
//                 ),
//                 SizedBox(width: 6.w),
//                 Expanded(
//                   child: _SummaryCard(
//                     title: 'Earned',
//                     value: '₹${totalEarned.toInt()}',
//                     icon: Icons.monetization_on_rounded,
//                     color: _K.purple,
//                     bgColor: _K.purple.withOpacity(0.1),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           SizedBox(height: 16.h),
//
//           // List header + filter
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 '${cfg.label} Referrals',
//                 style: TextStyle(
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.w700,
//                   color: const Color(0xFF1E293B),
//                 ),
//               ),
//               _FilterDropdown(
//                 value: _filterType,
//                 color: cfg.color,
//                 onChanged: (v) => setState(() => _filterType = v!),
//               ),
//             ],
//           ),
//
//           SizedBox(height: 12.h),
//
//           // Referral list
//           displayList.isEmpty
//               ? _EmptyState(cfg: cfg, filterType: _filterType)
//               : _ReferralList(
//                   referrals: displayList,
//                   cfg: cfg,
//                   statusLabel: widget.statusLabel,
//                   statusColor: widget.statusColor,
//                 ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─── Movers Tab ──────────────────────────────────────────────────────────────
//
// class _MoversTab extends StatefulWidget {
//   final List<ReferralResponse> referrals;
//   final String referralCode;
//   final String Function(ReferralStatus) statusLabel;
//   final Color Function(ReferralStatus) statusColor;
//   final VoidCallback onCopy;
//   final VoidCallback onShare;
//
//   const _MoversTab({
//     required this.referrals,
//     required this.referralCode,
//     required this.statusLabel,
//     required this.statusColor,
//     required this.onCopy,
//     required this.onShare,
//     super.key,
//   });
//
//   @override
//   State<_MoversTab> createState() => _MoversTabState();
// }
//
// class _MoversTabState extends State<_MoversTab> {
//   String _filterType = 'All';
//
//   @override
//   Widget build(BuildContext context) {
//     final movers = widget.referrals
//         .where(
//           (r) =>
//               getCategory(r) == ReferralCategory.driver ||
//               getCategory(r) == ReferralCategory.vehicle,
//         )
//         .toList();
//
//     const moverColor = Color(0xFF9333EA);
//     const moverCfg = CategoryConfig(
//       label: 'Movers',
//       color: moverColor,
//       icon: '🚗',
//     );
//
//     final displayList = movers.where((r) {
//       if (_filterType == 'All') return true;
//       if (_filterType == 'Registered') {
//         return getStatus(r) != ReferralStatus.invited;
//       }
//       if (_filterType == 'Pending') {
//         return getStatus(r) == ReferralStatus.invited;
//       }
//       return true;
//     }).toList();
//
//     final totalShared = movers.length;
//     final registeredCount = movers
//         .where((r) => getStatus(r) != ReferralStatus.invited)
//         .length;
//     final pendingCount = movers
//         .where((r) => getStatus(r) == ReferralStatus.invited)
//         .length;
//     final totalEarned = movers.fold(0.0, (sum, r) => sum + r.bonusAmount);
//
//     return SingleChildScrollView(
//       physics: const BouncingScrollPhysics(),
//       padding: EdgeInsets.all(16.w),
//       child: Column(
//         children: [
//           // Inline referral code card for movers
//           _InlineCodeCard(
//             referralCode: widget.referralCode,
//             cfg: moverCfg,
//             onCopy: widget.onCopy,
//             onShare: widget.onShare,
//           ),
//
//           SizedBox(height: 16.h),
//
//           // Summary stat cards
//           SizedBox(
//             height: 50.h,
//             child: Row(
//               children: [
//                 Expanded(
//                   child: _SummaryCard(
//                     title: 'Total',
//                     value: totalShared.toString(),
//                     icon: Icons.share_rounded,
//                     color: moverColor,
//                     bgColor: moverColor.withOpacity(0.1),
//                   ),
//                 ),
//                 SizedBox(width: 6.w),
//                 Expanded(
//                   child: _SummaryCard(
//                     title: 'Registered',
//                     value: registeredCount.toString(),
//                     icon: Icons.person_add_rounded,
//                     color: _K.green,
//                     bgColor: _K.green.withOpacity(0.1),
//                   ),
//                 ),
//                 SizedBox(width: 6.w),
//                 Expanded(
//                   child: _SummaryCard(
//                     title: 'Pending',
//                     value: pendingCount.toString(),
//                     icon: Icons.hourglass_top_rounded,
//                     color: _K.amber,
//                     bgColor: _K.amber.withOpacity(0.1),
//                   ),
//                 ),
//                 SizedBox(width: 6.w),
//                 Expanded(
//                   child: _SummaryCard(
//                     title: 'Earned',
//                     value: '₹${totalEarned.toInt()}',
//                     icon: Icons.monetization_on_rounded,
//                     color: _K.purple,
//                     bgColor: _K.purple.withOpacity(0.1),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           SizedBox(height: 16.h),
//
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Movers Referrals',
//                 style: TextStyle(
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.w700,
//                   color: const Color(0xFF1E293B),
//                 ),
//               ),
//               _FilterDropdown(
//                 value: _filterType,
//                 color: moverColor,
//                 onChanged: (v) => setState(() => _filterType = v!),
//               ),
//             ],
//           ),
//
//           SizedBox(height: 12.h),
//
//           displayList.isEmpty
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text('🚗🛵', style: TextStyle(fontSize: 48.sp)),
//                       SizedBox(height: 12.h),
//                       Text(
//                         'No movers referrals yet',
//                         style: TextStyle(
//                           color: const Color(0xFF94A3B8),
//                           fontSize: 14.sp,
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               : ListView.separated(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: displayList.length,
//                   separatorBuilder: (_, __) => SizedBox(height: 10.h),
//                   itemBuilder: (_, i) {
//                     final r = displayList[i];
//                     final cfg = categoryConfig[getCategory(r)]!;
//                     return _ReferralCard(
//                       referral: r,
//                       cfg: cfg,
//                       statusLabel: widget.statusLabel,
//                       statusColor: widget.statusColor,
//                     );
//                   },
//                 ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─── Inline Code Card (shown in each detail tab) ─────────────────────────────
//
// class _InlineCodeCard extends StatelessWidget {
//   final String referralCode;
//   final CategoryConfig cfg;
//   final VoidCallback onCopy;
//   final VoidCallback onShare;
//
//   const _InlineCodeCard({
//     required this.referralCode,
//     required this.cfg,
//     required this.onCopy,
//     required this.onShare,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
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
//           Text(
//             'Your Referral Code',
//             style: TextStyle(
//               fontSize: 14.sp,
//               fontWeight: FontWeight.w600,
//               color: const Color(0xFF1E293B),
//             ),
//           ),
//           SizedBox(height: 10.h),
//           // Container(
//           //   padding: EdgeInsets.all(12.w),
//           //   decoration: BoxDecoration(
//           //     color: cfg.color.withOpacity(0.06),
//           //     borderRadius: BorderRadius.circular(12.r),
//           //     border: Border.all(color: cfg.color.withOpacity(0.2)),
//           //   ),
//           //   child: Column(
//           //     children: [
//           //       Row(
//           //         children: [
//           //           Expanded(
//           //             child: Text(
//           //               referralCode,
//           //               style: TextStyle(
//           //                 color: cfg.color,
//           //                 fontSize: 15.sp,
//           //                 fontWeight: FontWeight.w800,
//           //                 letterSpacing: 1.2,
//           //               ),
//           //             ),
//           //           ),
//           //         ],
//           //       ),
//           //       Row(
//           //         children: [
//           //           GestureDetector(
//           //             onTap: onCopy,
//           //             child: Container(
//           //               padding: EdgeInsets.symmetric(
//           //                 horizontal: 10.w,
//           //                 vertical: 6.h,
//           //               ),
//           //               decoration: BoxDecoration(
//           //                 color: cfg.color,
//           //                 borderRadius: BorderRadius.circular(8.r),
//           //               ),
//           //               child: Row(
//           //                 children: [
//           //                   Icon(
//           //                     Icons.copy_rounded,
//           //                     color: Colors.white,
//           //                     size: 14.sp,
//           //                   ),
//           //                   SizedBox(width: 4.w),
//           //                   Text(
//           //                     'Copy',
//           //                     style: TextStyle(
//           //                       color: Colors.white,
//           //                       fontSize: 11.sp,
//           //                       fontWeight: FontWeight.w600,
//           //                     ),
//           //                   ),
//           //                 ],
//           //               ),
//           //             ),
//           //           ),
//           //           SizedBox(width: 8.w),
//           //           GestureDetector(
//           //             onTap: onShare,
//           //             child: Container(
//           //               padding: EdgeInsets.symmetric(
//           //                 horizontal: 10.w,
//           //                 vertical: 6.h,
//           //               ),
//           //               decoration: BoxDecoration(
//           //                 color: const Color(0xFF1E40AF),
//           //                 borderRadius: BorderRadius.circular(8.r),
//           //               ),
//           //               child: Row(
//           //                 children: [
//           //                   Icon(
//           //                     Icons.share_rounded,
//           //                     color: Colors.white,
//           //                     size: 14.sp,
//           //                   ),
//           //                   SizedBox(width: 4.w),
//           //                   Text(
//           //                     'Share',
//           //                     style: TextStyle(
//           //                       color: Colors.white,
//           //                       fontSize: 11.sp,
//           //                       fontWeight: FontWeight.w600,
//           //                     ),
//           //                   ),
//           //                 ],
//           //               ),
//           //             ),
//           //           ),
//           //         ],
//           //       ),
//           //     ],
//           //   ),
//           // ),
//           Container(
//             padding: EdgeInsets.all(14.w),
//             decoration: BoxDecoration(
//               color: cfg.color.withOpacity(0.05),
//               borderRadius: BorderRadius.circular(16.r),
//               border: Border.all(color: cfg.color.withOpacity(0.15)),
//             ),
//             child: Column(
//               children: [
//                 // Referral Code
//                 Container(
//                   width: double.infinity,
//                   padding: EdgeInsets.symmetric(
//                     vertical: 12.h,
//                     horizontal: 12.w,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       // Text(
//                       //   cfg.icon,
//                       //   style: TextStyle(fontSize: 20.sp),
//                       // ),
//                       // SizedBox(width: 8.w),
//                       Text(
//                         referralCode,
//                         style: TextStyle(
//                           color: cfg.color,
//                           fontSize: 18.sp,
//                           fontWeight: FontWeight.w800,
//                           letterSpacing: 1.2,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 SizedBox(height: 12.h),
//
//                 // Actions
//                 Row(
//                   children: [
//                     Expanded(
//                       child: InkWell(
//                         borderRadius: BorderRadius.circular(10.r),
//
//                         onTap: onCopy,
//                         child: Container(
//                           height: 42.h,
//                           decoration: BoxDecoration(
//                             color: cfg.color,
//                             borderRadius: BorderRadius.circular(10.r),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 Icons.copy_rounded,
//                                 color: Colors.white,
//                                 size: 16.sp,
//                               ),
//                               SizedBox(width: 6.w),
//                               Text(
//                                 'Copy',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 12.sp,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     SizedBox(width: 10.w),
//
//                     Expanded(
//                       child: InkWell(
//                         borderRadius: BorderRadius.circular(10.r),
//                         onTap: onShare,
//                         child: Container(
//                           height: 42.h,
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF1E40AF),
//                             borderRadius: BorderRadius.circular(10.r),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 Icons.share_rounded,
//                                 color: Colors.white,
//                                 size: 16.sp,
//                               ),
//                               SizedBox(width: 6.w),
//                               Text(
//                                 'Share',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 12.sp,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─── Referral List ────────────────────────────────────────────────────────────
//
// class _ReferralList extends StatelessWidget {
//   final List<ReferralResponse> referrals;
//   final CategoryConfig cfg;
//   final String Function(ReferralStatus) statusLabel;
//   final Color Function(ReferralStatus) statusColor;
//
//   const _ReferralList({
//     required this.referrals,
//     required this.cfg,
//     required this.statusLabel,
//     required this.statusColor,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView.separated(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: referrals.length,
//       separatorBuilder: (_, __) => SizedBox(height: 10.h),
//       itemBuilder: (_, i) => _ReferralCard(
//         referral: referrals[i],
//         cfg: cfg,
//         statusLabel: statusLabel,
//         statusColor: statusColor,
//       ),
//     );
//   }
// }
//
// // ─── Referral Card ───────────────────────────────────────────────────────────
//
// class _ReferralCard extends StatelessWidget {
//   final ReferralResponse referral;
//   final CategoryConfig cfg;
//   final String Function(ReferralStatus) statusLabel;
//   final Color Function(ReferralStatus) statusColor;
//
//   const _ReferralCard({
//     required this.referral,
//     required this.cfg,
//     required this.statusLabel,
//     required this.statusColor,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final r = referral;
//     return Container(
//       padding: EdgeInsets.all(14.w),
//       decoration: BoxDecoration(
//         color: r.rewardGiven
//             ? const Color(0xFFF0FDF4)
//             : const Color(0xFFFFFBEB),
//         borderRadius: BorderRadius.circular(14.r),
//         border: Border.all(
//           color: r.rewardGiven
//               ? const Color(0xFF22C55E)
//               : const Color(0xFFF59E0B),
//           width: 1,
//         ),
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
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   r.name.toUpperCase(),
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 13.5.sp,
//                     color: const Color(0xFF1E293B),
//                   ),
//                 ),
//                 // Text(
//                 //   r.email,
//                 //   style: TextStyle(
//                 //     fontWeight: FontWeight.w600,
//                 //     fontSize: 13.5.sp,
//                 //     color: const Color(0xFF1E293B),
//                 //   ),
//                 // ),
//                 SizedBox(height: 3.h),
//                 Row(
//                   children: [
//                     Text(
//                       "${r.createdAt.day}/${r.createdAt.month}/${r.createdAt.year}",
//                       style: TextStyle(
//                         fontSize: 11.sp,
//                         color: const Color(0xFF94A3B8),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               if (r.bonusAmount > 0)
//                 Text(
//                   '₹${r.bonusAmount.toInt()}',
//                   style: TextStyle(
//                     color: r.rewardGiven ? _K.green : _K.amber,
//                     fontWeight: FontWeight.w700,
//                     fontSize: 15.sp,
//                   ),
//                 )
//               else
//                 Text(
//                   '—',
//                   style: TextStyle(
//                     color: const Color(0xFFCBD5E1),
//                     fontSize: 15.sp,
//                   ),
//                 ),
//               SizedBox(height: 4.h),
//               if (r.bonusAmount > 0)
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
//                   decoration: BoxDecoration(
//                     color: r.rewardGiven
//                         ? const Color(0xFFF0FDF4)
//                         : const Color(0xFFFFFBEB),
//                     borderRadius: BorderRadius.circular(5.r),
//                   ),
//                   child: Text(
//                     r.rewardGiven ? 'Paid' : 'Pending',
//                     style: TextStyle(
//                       fontSize: 9.5.sp,
//                       fontWeight: FontWeight.w600,
//                       color: r.rewardGiven ? _K.green : _K.amber,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─── Filter Dropdown ─────────────────────────────────────────────────────────
//
// class _FilterDropdown extends StatelessWidget {
//   final String value;
//   final Color color;
//   final ValueChanged<String?> onChanged;
//
//   const _FilterDropdown({
//     required this.value,
//     required this.color,
//     required this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF1F5F9),
//         borderRadius: BorderRadius.circular(8.r),
//         border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
//       ),
//       child: DropdownButton<String>(
//         value: value,
//         underline: const SizedBox(),
//         icon: Icon(Icons.arrow_drop_down, size: 18.sp, color: color),
//         style: TextStyle(
//           fontSize: 13.sp,
//           fontWeight: FontWeight.w500,
//           color: color,
//         ),
//         isDense: true,
//         items: [
//           DropdownMenuItem(
//             value: 'All',
//             child: Row(
//               children: [
//                 Icon(Icons.list, size: 16.sp, color: Colors.grey.shade600),
//                 SizedBox(width: 6.w),
//                 Text('All', style: TextStyle(color: Colors.grey.shade800)),
//               ],
//             ),
//           ),
//           DropdownMenuItem(
//             value: 'Registered',
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.person_add,
//                   size: 16.sp,
//                   color: Colors.green.shade600,
//                 ),
//                 SizedBox(width: 6.w),
//                 Text(
//                   'Registered',
//                   style: TextStyle(color: Colors.grey.shade800),
//                 ),
//               ],
//             ),
//           ),
//           DropdownMenuItem(
//             value: 'Pending',
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.hourglass_top,
//                   size: 16.sp,
//                   color: Colors.orange.shade600,
//                 ),
//                 SizedBox(width: 6.w),
//                 Text('Pending', style: TextStyle(color: Colors.grey.shade800)),
//               ],
//             ),
//           ),
//         ],
//         onChanged: onChanged,
//       ),
//     );
//   }
// }
//
// // ─── Empty State ─────────────────────────────────────────────────────────────
//
// class _EmptyState extends StatelessWidget {
//   final CategoryConfig cfg;
//   final String filterType;
//
//   const _EmptyState({required this.cfg, required this.filterType});
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(cfg.icon, style: TextStyle(fontSize: 48.sp)),
//           SizedBox(height: 12.h),
//           Text(
//             'No ${filterType.toLowerCase()} ${cfg.label.toLowerCase()} referrals yet',
//             style: TextStyle(color: const Color(0xFF94A3B8), fontSize: 14.sp),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─── Summary Card ─────────────────────────────────────────────────────────────
//
// class _SummaryCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final IconData icon;
//   final Color color;
//   final Color bgColor;
//
//   const _SummaryCard({
//     required this.title,
//     required this.value,
//     required this.icon,
//     required this.color,
//     required this.bgColor,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 4,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: EdgeInsets.all(4.w),
//             decoration: BoxDecoration(
//               color: bgColor,
//               borderRadius: BorderRadius.circular(6.r),
//             ),
//             child: Icon(icon, color: color, size: 12.sp),
//           ),
//           SizedBox(width: 6.w),
//           Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 value,
//                 style: TextStyle(
//                   color: color,
//                   fontSize: 12.sp,
//                   fontWeight: FontWeight.w800,
//                 ),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               Text(
//                 title,
//                 style: TextStyle(
//                   color: const Color(0xFF64748B),
//                   fontSize: 8.sp,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─── Stat Tile (Overview) ─────────────────────────────────────────────────────
//
// class _StatTile extends StatelessWidget {
//   final IconData icon;
//   final String value;
//   final String label;
//   final Color color;
//
//   const _StatTile({
//     required this.icon,
//     required this.value,
//     required this.label,
//     required this.color,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(vertical: 10.h),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: EdgeInsets.all(8.w),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, size: 18.sp, color: color),
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 20.sp,
//               fontWeight: FontWeight.w800,
//               color: _K.textDark,
//             ),
//           ),
//           SizedBox(height: 2.h),
//           Text(
//             label,
//             style: TextStyle(fontSize: 11.sp, color: _K.textMid),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import '../../Models/subscrptions/referals.dart';
import '../../Services/Auth_service/Subscription_authservice.dart';
import '../../Services/scaffoldmessenger/messenger.dart';

// ─── Enums ─────────────────────────────────────────────────────────────────

enum ReferralCategory { user, vendor, driver }

enum ReferralStatus { invited, earned }

// ─── Design Tokens ─────────────────────────────────────────────────────────

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
        'https://applink.maamaas.com/referral?type=$type&referralCode=${Uri.encodeComponent(code)}';
    print(link);
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
        'https://applink.maamaas.com/referral?type=$type&referralCode=${Uri.encodeComponent(code)}';
    print(link);
    // ignore: deprecated_member_use
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
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: referrals.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (_, i) => _ReferralCard(
        referral: referrals[i],
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
