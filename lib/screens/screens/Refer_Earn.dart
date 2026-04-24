//
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:share_plus/share_plus.dart';
// import '../../Models/subscrptions/user_account.dart';
// import '../../Services/Auth_service/Subscription_authservice.dart';
// import '../../Services/scaffoldmessenger/messenger.dart';
//
// // ─── Tokens ────────────────────────────────────────────────────────────────
// class refercolour {
//    static const _kPrimary = Color(0xFF7C5CFC);
//    static const _kPrimaryLight = Color(0xFFF0ECFF);
//    static const _kPrimaryDark = Color(0xFF5A3DD8);
//    static const _kSurface = Color(0xFFF8F7FF);
//    static const _kTextDark = Color(0xFF1A1A2E);
//    static const _kTextMid = Color(0xFF6B6B8A);
//    static const _kDivider = Color(0xFFECEBF5);
//    static const _kSuccess = Color(0xFF22C55E);
// }
//
// // ─── Screen ────────────────────────────────────────────────────────────────
//
// class ReferEarn extends StatelessWidget {
//   const ReferEarn({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: refercolour._kSurface,
//         elevation: 0,
//         surfaceTintColor: Colors.transparent,
//         leading: GestureDetector(
//           onTap: () => Navigator.pop(context),
//           child: Container(
//             margin: EdgeInsets.all(8.w),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(10.r),
//               border: Border.all(color: refercolour._kDivider),
//             ),
//             child: Icon(
//               Icons.arrow_back_ios_new_rounded,
//               size: 16.sp,
//               color: refercolour._kTextDark,
//             ),
//           ),
//         ),
//         title: Text(
//           'Refer ',
//           style: TextStyle(
//             fontSize: 17.sp,
//             fontWeight: FontWeight.w700,
//             color: refercolour._kTextDark,
//             letterSpacing: -0.3,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
//           child: const _ReferEarnBody(),
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Body ──────────────────────────────────────────────────────────────────
//
// class _ReferEarnBody extends StatefulWidget {
//   const _ReferEarnBody();
//
//   @override
//   State<_ReferEarnBody> createState() => _ReferEarnBodyState();
// }
//
// class _ReferEarnBodyState extends State<_ReferEarnBody> {
//   late Future<UserAccount?> _futureProfile;
//
//   @override
//   void initState() {
//     super.initState();
//     _futureProfile = subscription_AuthService.getAccount();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<UserAccount?>(
//       future: _futureProfile,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return _LoadingState();
//         }
//         if (!snapshot.hasData || snapshot.data == null) {
//           return _ErrorState();
//         }
//         return _Content(referralCode: snapshot.data!.referralCode ?? '');
//       },
//     );
//   }
// }
//
// // ─── Loading ───────────────────────────────────────────────────────────────
//
// class _LoadingState extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 400.h,
//       child: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SizedBox(
//               width: 36.w,
//               height: 36.w,
//               child: const CircularProgressIndicator(
//                 strokeWidth: 2.5,
//                 color: refercolour._kPrimary,
//               ),
//             ),
//             SizedBox(height: 14.h),
//             Text(
//               'Loading your referral...',
//               style: TextStyle(fontSize: 13.sp, color: refercolour._kTextMid),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Error ─────────────────────────────────────────────────────────────────
//
// class _ErrorState extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 400.h,
//       child: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               padding: EdgeInsets.all(16.w),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFFEF2F2),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.wifi_off_rounded,
//                 size: 28.sp,
//                 color: Colors.red,
//               ),
//             ),
//             SizedBox(height: 12.h),
//             Text(
//               'Could not load referral code',
//               style: TextStyle(
//                 fontSize: 15.sp,
//                 fontWeight: FontWeight.w600,
//                 color: refercolour._kTextDark,
//               ),
//             ),
//             SizedBox(height: 4.h),
//             Text(
//               'Please check your connection and try again.',
//               style: TextStyle(fontSize: 12.sp, color: refercolour._kTextMid),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Main Content ──────────────────────────────────────────────────────────
//
// class _Content extends StatelessWidget {
//   const _Content({required this.referralCode});
//   final String referralCode;
//
//   void _copy(BuildContext context) {
//     Clipboard.setData(ClipboardData(text: referralCode));
//     AppAlert.success(context, '✅ Referral code copied!');
//   }
//
//   void _share() {
//     String appLink = Platform.isIOS
//         ? 'https://apps.apple.com/us/app/maamaas/id6759244693'
//         : 'https://play.google.com/store/apps/details?id=com.maamaas.app';
//     Share.share(
//       '🎉 Join Maamaas using my referral code: $referralCode\n\n'
//       '📲 Download here: $appLink',
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // _HeroBanner(),
//         // SizedBox(height: 20.h),
//         _ReferralCodeCard(
//           referralCode: referralCode,
//           onCopy: () => _copy(context),
//           onShare: _share,
//         ),
//         // SizedBox(height: 20.h),
//         // // _StatsRow(),
//         // SizedBox(height: 20.h),
//         // _HowItWorksCard(),
//         // SizedBox(height: 24.h),
//       ],
//     );
//   }
// }
//
// // ─── Hero Banner ───────────────────────────────────────────────────────────
//
// class _HeroBanner extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(24.w),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [refercolour._kPrimary, refercolour._kPrimaryDark],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(24.r),
//         boxShadow: [
//           BoxShadow(
//             color: refercolour._kPrimary.withOpacity(0.35),
//             blurRadius: 24,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           // Decorative circles
//           Positioned(
//             right: -10,
//             top: -20,
//             child: Container(
//               width: 90.w,
//               height: 90.w,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white.withOpacity(0.07),
//               ),
//             ),
//           ),
//           Positioned(
//             right: 30,
//             bottom: -30,
//             child: Container(
//               width: 60.w,
//               height: 60.w,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white.withOpacity(0.05),
//               ),
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 padding: EdgeInsets.all(10.w),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.18),
//                   borderRadius: BorderRadius.circular(12.r),
//                 ),
//                 child: Icon(
//                   Icons.redeem_rounded,
//                   size: 24.sp,
//                   color: Colors.white,
//                 ),
//               ),
//               SizedBox(height: 16.h),
//               Text(
//                 'Invite Friends,\nEarn Rewards',
//                 style: TextStyle(
//                   fontSize: 22.sp,
//                   fontWeight: FontWeight.w800,
//                   color: Colors.white,
//                   height: 1.2,
//                   letterSpacing: -0.5,
//                 ),
//               ),
//               SizedBox(height: 8.h),
//               Text(
//                 'Share your code and unlock exclusive\nbenefits for you and your friends.',
//                 style: TextStyle(
//                   fontSize: 13.sp,
//                   color: Colors.white.withOpacity(0.82),
//                   height: 1.5,
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
// // ─── Referral Code Card ────────────────────────────────────────────────────
//
// class _ReferralCodeCard extends StatelessWidget {
//   const _ReferralCodeCard({
//     required this.referralCode,
//     required this.onCopy,
//     required this.onShare,
//   });
//   final String referralCode;
//   final VoidCallback onCopy;
//   final VoidCallback onShare;
//
//   @override
//   Widget build(BuildContext context) {
//     return _Card(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Text(
//           //   'Your Referral Code',
//           //   style: TextStyle(
//           //     fontSize: 13.sp,
//           //     fontWeight: FontWeight.w600,
//           //     color: _kTextMid,
//           //     letterSpacing: 0.2,
//           //   ),
//           // ),
//           // SizedBox(height: 12.h),
//           // Code pill
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
//             decoration: BoxDecoration(
//               color: refercolour._kPrimaryLight,
//               borderRadius: BorderRadius.circular(16.r),
//               border: Border.all(color: refercolour._kPrimary.withOpacity(0.2), width: 1.5),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   referralCode,
//                   style: TextStyle(
//                     fontSize: 26.sp,
//                     fontWeight: FontWeight.w800,
//                     color: refercolour._kPrimary,
//                     letterSpacing: 3,
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: onCopy,
//                   child: Container(
//                     padding: EdgeInsets.all(8.w),
//                     decoration: BoxDecoration(
//                       color: refercolour._kPrimary.withOpacity(0.12),
//                       borderRadius: BorderRadius.circular(8.r),
//                     ),
//                     child: Icon(
//                       Icons.copy_rounded,
//                       size: 18.sp,
//                       color: refercolour._kPrimary,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 14.h),
//           // Buttons row
//           Row(
//             children: [
//               Expanded(
//                 child: _OutlineButton(
//                   icon: Icons.copy_rounded,
//                   label: 'Copy Code',
//                   onTap: onCopy,
//                 ),
//               ),
//               SizedBox(width: 10.w),
//               Expanded(
//                 child: _FilledButton(
//                   icon: Icons.share_rounded,
//                   label: 'Share Now',
//                   onTap: onShare,
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
// // ─── Stats Row ─────────────────────────────────────────────────────────────
//
// class _StatsRow extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: _StatTile(
//             icon: Icons.people_alt_rounded,
//             value: '0',
//             label: 'Referred',
//             color: const Color(0xFF7C5CFC),
//           ),
//         ),
//         SizedBox(width: 12.w),
//         Expanded(
//           child: _StatTile(
//             icon: Icons.emoji_events_rounded,
//             value: '0',
//             label: 'Rewards',
//             color: const Color(0xFFF59E0B),
//           ),
//         ),
//         SizedBox(width: 12.w),
//         Expanded(
//           child: _StatTile(
//             icon: Icons.check_circle_rounded,
//             value: '0',
//             label: 'Joined',
//             color: refercolour._kSuccess,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class _StatTile extends StatelessWidget {
//   const _StatTile({
//     required this.icon,
//     required this.value,
//     required this.label,
//     required this.color,
//   });
//   final IconData icon;
//   final String value;
//   final String label;
//   final Color color;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(vertical: 16.h),
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
//               color: refercolour._kTextDark,
//             ),
//           ),
//           SizedBox(height: 2.h),
//           Text(
//             label,
//             style: TextStyle(fontSize: 11.sp, color: refercolour._kTextMid),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─── How It Works Card ─────────────────────────────────────────────────────
//
// class _HowItWorksCard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return _Card(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'How it Works',
//             style: TextStyle(
//               fontSize: 16.sp,
//               fontWeight: FontWeight.w700,
//               color: refercolour._kTextDark,
//               letterSpacing: -0.3,
//             ),
//           ),
//           SizedBox(height: 20.h),
//           _Step(
//             step: 1,
//             icon: Icons.ios_share_rounded,
//             title: 'Share your code',
//             subtitle: 'Send your unique code to friends & family',
//             isLast: false,
//           ),
//           _Step(
//             step: 2,
//             icon: Icons.person_add_rounded,
//             title: 'Friends sign up',
//             subtitle: 'They register using your referral code',
//             isLast: false,
//           ),
//           _Step(
//             step: 3,
//             icon: Icons.stars_rounded,
//             title: 'Both earn rewards',
//             subtitle: 'You and your friend get exclusive benefits',
//             isLast: true,
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _Step extends StatelessWidget {
//   const _Step({
//     required this.step,
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.isLast,
//   });
//   final int step;
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   final bool isLast;
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Left: number + line
//         Column(
//           children: [
//             Container(
//               width: 36.w,
//               height: 36.w,
//               decoration: const BoxDecoration(
//                 color: refercolour._kPrimary,
//                 shape: BoxShape.circle,
//               ),
//               child: Center(
//                 child: Text(
//                   '$step',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ),
//             ),
//             if (!isLast)
//               Container(
//                 width: 2.w,
//                 height: 40.h,
//                 margin: EdgeInsets.symmetric(vertical: 4.h),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       refercolour._kPrimary.withOpacity(0.4),
//                       refercolour._kPrimary.withOpacity(0.05),
//                     ],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         SizedBox(width: 14.w),
//         // Right: content
//         Expanded(
//           child: Padding(
//             padding: EdgeInsets.only(top: 6.h, bottom: isLast ? 0 : 32.h),
//             child: Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(8.w),
//                   decoration: BoxDecoration(
//                     color: refercolour._kPrimaryLight,
//                     borderRadius: BorderRadius.circular(10.r),
//                   ),
//                   child: Icon(icon, size: 18.sp, color: refercolour._kPrimary),
//                 ),
//                 SizedBox(width: 12.w),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         title,
//                         style: TextStyle(
//                           fontSize: 14.sp,
//                           fontWeight: FontWeight.w700,
//                           color: refercolour._kTextDark,
//                         ),
//                       ),
//                       SizedBox(height: 3.h),
//                       Text(
//                         subtitle,
//                         style: TextStyle(fontSize: 12.sp, color: refercolour._kTextMid),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // ─── Shared Primitives ─────────────────────────────────────────────────────
//
// class _Card extends StatelessWidget {
//   const _Card({required this.child});
//   final Widget child;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(20.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 20,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }
// }
//
// class _FilledButton extends StatelessWidget {
//   const _FilledButton({
//     required this.icon,
//     required this.label,
//     required this.onTap,
//   });
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: 13.h),
//         decoration: BoxDecoration(
//           color: refercolour._kPrimary,
//           borderRadius: BorderRadius.circular(12.r),
//           boxShadow: [
//             BoxShadow(
//               color: refercolour._kPrimary.withOpacity(0.35),
//               blurRadius: 12,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 16.sp, color: Colors.white),
//             SizedBox(width: 6.w),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 13.sp,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _OutlineButton extends StatelessWidget {
//   const _OutlineButton({
//     required this.icon,
//     required this.label,
//     required this.onTap,
//   });
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: 13.h),
//         decoration: BoxDecoration(
//           color: refercolour._kPrimaryLight,
//           borderRadius: BorderRadius.circular(12.r),
//           border: Border.all(color: refercolour._kPrimary.withOpacity(0.25)),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 16.sp, color: refercolour._kPrimary),
//             SizedBox(width: 6.w),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 13.sp,
//                 fontWeight: FontWeight.w700,
//                 color: refercolour._kPrimary,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import '../../Models/subscrptions/user_account.dart';
import '../../Services/Auth_service/Subscription_authservice.dart';
import '../../Services/scaffoldmessenger/messenger.dart';

// ─── Tokens ────────────────────────────────────────────────────────────────
class refercolour {
  static const _kPrimary = Color(0xFF7C5CFC);
  static const _kPrimaryLight = Color(0xFFF0ECFF);
  static const _kPrimaryDark = Color(0xFF5A3DD8);
  static const _kSurface = Color(0xFFF8F7FF);
  static const _kTextDark = Color(0xFF1A1A2E);
  static const _kTextMid = Color(0xFF6B6B8A);
  static const _kDivider = Color(0xFFECEBF5);
  static const _kSuccess = Color(0xFF22C55E);
}

// ─── Screen ────────────────────────────────────────────────────────────────

class ReferEarn extends StatelessWidget {
  const ReferEarn({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: refercolour._kSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: refercolour._kDivider),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16.sp,
              color: refercolour._kTextDark,
            ),
          ),
        ),
        title: Text(
          'Refer',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: refercolour._kTextDark,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          child: const _ReferEarnBody(),
        ),
      ),
    );
  }
}

// ─── Body ──────────────────────────────────────────────────────────────────

class _ReferEarnBody extends StatefulWidget {
  const _ReferEarnBody();

  @override
  State<_ReferEarnBody> createState() => _ReferEarnBodyState();
}

class _ReferEarnBodyState extends State<_ReferEarnBody> {
  late Future<UserAccount?> _futureProfile;

  @override
  void initState() {
    super.initState();
    _futureProfile = subscription_AuthService.getAccount();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserAccount?>(
      future: _futureProfile,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _LoadingState();
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return _ErrorState();
        }
        return _Content(referralCode: snapshot.data!.referralCode ?? '');
      },
    );
  }
}

// ─── Loading ───────────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400.h,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 36.w,
              height: 36.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2.5,
                color: refercolour._kPrimary,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              'Loading your referral...',
              style: TextStyle(fontSize: 13.sp, color: refercolour._kTextMid),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error ─────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400.h,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 28.sp,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Could not load referral code',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: refercolour._kTextDark,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Please check your connection and try again.',
              style: TextStyle(fontSize: 12.sp, color: refercolour._kTextMid),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Main Content ──────────────────────────────────────────────────────────

class _Content extends StatelessWidget {
  const _Content({required this.referralCode});
  final String referralCode;

  // ── Deep-link URL that smart-redirects: ─────────────────────────────────
  //   • App installed  → opens Signup screen with referralCode pre-filled
  //   • Not installed  → redirect.html tries the app link, falls back to
  //                       Play Store with referrer=referralCode=XXX so the
  //                       install referrer mechanism picks it up after install.
  String get _referralDeepLink {
    final encoded = Uri.encodeComponent(referralCode); // MAMA%23234
    return 'https://applink.maamaas.com/referral?referralCode=$encoded';
  }

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: referralCode));
    AppAlert.success(context, '✅ Referral code copied!');
  }

  /// Shares a smart link.  When opened:
  ///   - App installed  → opens directly to Signup with code pre-filled.
  ///   - Not installed  → your redirect HTML opens Play Store with
  ///                       referrer=referralCode=XXX embedded, so after
  ///                       install _handleInstallReferrer() picks it up.
  void _share() {
    final encoded = Uri.encodeComponent(referralCode);
    final link = 'https://applink.maamaas.com/referral?referralCode=$encoded';
    Share.share(
      '🎉 Join Maamaas using my referral code: *$referralCode*\n\n'
      '📲 Tap to download & sign up — your code is applied automatically:\n'
      '$link',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ReferralCodeCard(
          referralCode: referralCode,
          onCopy: () => _copy(context),
          onShare: _share,
        ),
      ],
    );
  }
}

// ─── Referral Code Card ────────────────────────────────────────────────────

class _ReferralCodeCard extends StatelessWidget {
  const _ReferralCodeCard({
    required this.referralCode,
    required this.onCopy,
    required this.onShare,
  });
  final String referralCode;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title ───────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: refercolour._kPrimaryLight,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.card_giftcard_rounded,
                  color: refercolour._kPrimary,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Referral Code',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: refercolour._kTextDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Share the link — the code is applied automatically',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: refercolour._kTextMid,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // ── Code display ─────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: refercolour._kPrimaryLight,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: refercolour._kPrimary.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  referralCode,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: refercolour._kPrimary,
                    letterSpacing: 3,
                  ),
                ),
                GestureDetector(
                  onTap: onCopy,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: refercolour._kPrimary,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.copy_rounded,
                          color: Colors.white,
                          size: 13.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Copy',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // ── Share button ─────────────────────────────────────────────────
          _FilledButton(
            icon: Icons.ios_share_rounded,
            label: 'Share Referral Link',
            onTap: onShare,
          ),
        ],
      ),
    );
  }
}

// ─── How It Works Card ─────────────────────────────────────────────────────

class _HowItWorksCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How it Works',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: refercolour._kTextDark,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 20.h),
          _Step(
            step: 1,
            icon: Icons.ios_share_rounded,
            title: 'Share your link',
            subtitle:
                'Tap Share — your code is embedded in the link automatically',
            isLast: false,
          ),
          _Step(
            step: 2,
            icon: Icons.person_add_rounded,
            title: 'Friend downloads & signs up',
            subtitle: 'The referral code is pre-filled on their Signup screen',
            isLast: false,
          ),
          _Step(
            step: 3,
            icon: Icons.stars_rounded,
            title: 'Both earn rewards',
            subtitle: 'You and your friend get exclusive benefits',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.step,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isLast,
  });
  final int step;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: const BoxDecoration(
                color: refercolour._kPrimary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$step',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2.w,
                height: 40.h,
                margin: EdgeInsets.symmetric(vertical: 4.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      refercolour._kPrimary.withOpacity(0.4),
                      refercolour._kPrimary.withOpacity(0.05),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 6.h, bottom: isLast ? 0 : 32.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: refercolour._kPrimaryLight,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, size: 18.sp, color: refercolour._kPrimary),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: refercolour._kTextDark,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: refercolour._kTextMid,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Shared Primitives ─────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FilledButton extends StatelessWidget {
  const _FilledButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 13.h),
        decoration: BoxDecoration(
          color: refercolour._kPrimary,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: refercolour._kPrimary.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16.sp, color: Colors.white),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 13.h),
        decoration: BoxDecoration(
          color: refercolour._kPrimaryLight,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: refercolour._kPrimary.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16.sp, color: refercolour._kPrimary),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: refercolour._kPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
