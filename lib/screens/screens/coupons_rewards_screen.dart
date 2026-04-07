// // ignore_for_file: deprecated_member_use
//
//
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../Models/subscrptions/coupon_model.dart';
// import '../../Services/Auth_service/Subscription_authservice.dart';
//
// class CouponsAndRewards extends StatefulWidget {
//   const CouponsAndRewards({super.key});
//
//   @override
//   State<CouponsAndRewards> createState() => _CouponsAndRewardsState();
// }
//
// class _CouponsAndRewardsState extends State<CouponsAndRewards>
//     with SingleTickerProviderStateMixin {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text("Coupons"),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 20.w),
//             child: CouponsTab(),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class CouponsTab extends StatefulWidget {
//   const CouponsTab({super.key});
//
//   @override
//   State<CouponsTab> createState() => _CouponsTabState();
// }
//
// class _CouponsTabState extends State<CouponsTab> {
//   // List<dynamic> coupons = [];
//   bool isLoading = true;
//   List<CouponModel> coupons = [];
//
//   @override
//   void initState() {
//     super.initState();
//     loadCoupons();
//   }
//
//   Future<void> loadCoupons() async {
//     try {
//       final data = await subscription_AuthService.fetchCoupons();
//       setState(() {
//         coupons = data;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() => isLoading = false);
//     }
//   }
//
//   Future<void> saveDiscountToStorage(double discountPercentage) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setDouble('appliedDiscount', discountPercentage);
//     if (mounted) {
//       AppAlert.success(context, '🎉 $discountPercentage% discount applied!');
//     }
//   }
//
//   bool isCouponExpired(String endDate) {
//     try {
//       final expiry = DateTime.parse(endDate);
//       return DateTime.now().isAfter(expiry);
//     } catch (e) {
//       return false;
//     }
//   }
//
//   @override
//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SizedBox(
//               width: 40.w,
//               height: 40.w,
//               child: CircularProgressIndicator(
//                 strokeWidth: 3,
//                 valueColor: AlwaysStoppedAnimation(const Color(0xFFB15DC6)),
//               ),
//             ),
//             SizedBox(height: 16.h),
//             Text(
//               'Loading Coupons...',
//               style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
//             ),
//           ],
//         ),
//       );
//     }
//
//     if (coupons.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.confirmation_num_outlined,
//               size: 80.sp,
//               color: Colors.grey[400],
//             ),
//             SizedBox(height: 16.h),
//             Text(
//               'No Coupons Available',
//               style: TextStyle(
//                 fontSize: 18.sp,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey[600],
//               ),
//             ),
//             SizedBox(height: 8.h),
//             Text(
//               'Check back later for exciting offers!',
//               style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       );
//     }
//
//     return SingleChildScrollView(
//       padding: EdgeInsets.only(bottom: 16.h),
//       child: Column(
//         children: [
//           /// Header
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.all(16.w),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   const Color(0xFFB15DC6).withOpacity(0.1),
//                   const Color(0xFF4A44B5).withOpacity(0.05),
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(12.r),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.local_offer_outlined,
//                   color: const Color(0xFF6C63FF),
//                   size: 20.sp,
//                 ),
//                 SizedBox(width: 8.w),
//                 Flexible(
//                   child: Text(
//                     '${coupons.length} Coupons Available',
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w600,
//                       color: const Color(0xFF2D3748),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           SizedBox(height: 20.h),
//
//           /// Coupons Grid
//           LayoutBuilder(
//             builder: (context, constraints) {
//               int crossAxisCount = 2;
//               double width = constraints.maxWidth;
//
//               if (width > 900) {
//                 crossAxisCount = 4;
//               } else if (width > 600) {
//                 crossAxisCount = 3;
//               }
//
//               return GridView.builder(
//                 shrinkWrap: true, // 🔑 important
//                 physics: const NeverScrollableScrollPhysics(),
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: crossAxisCount,
//                   crossAxisSpacing: 12.w,
//                   mainAxisSpacing: 12.h,
//                   childAspectRatio: 0.9,
//                 ),
//                 itemCount: coupons.length,
//                 itemBuilder: (context, index) {
//                   final coupon = coupons[index];
//
//                   return DiscountCard(
//                     discountText: coupon.discountPercentage.toString(),
//                     promoCode: coupon.code,
//                     startDate: coupon.startDate.toIso8601String(),
//                     endDate: coupon.endDate.toIso8601String(),
//                     isExpired: coupon.isExpired,
//                     couponType: coupon.couponType,
//                     minimumOrderValue: coupon.minimumOrderValue,
//                     discountType: coupon.discountType,
//                     onApply: coupon.isExpired
//                         ? null
//                         : () async {
//                             await saveDiscountToStorage(
//                               coupon.discountPercentage,
//                             );
//                           },
//                   );
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class DiscountCard extends StatelessWidget {
//   final String discountText;
//   final String promoCode;
//   final VoidCallback? onApply;
//   final String startDate;
//   final String endDate;
//   final bool isExpired;
//   final String couponType;
//   final double minimumOrderValue;
//   final String discountType;
//
//   const DiscountCard({
//     required this.discountText,
//     required this.promoCode,
//     required this.startDate,
//     required this.endDate,
//     required this.isExpired,
//     this.onApply,
//     required this.couponType,
//     required this.minimumOrderValue,
//     required this.discountType,
//     super.key,
//   });
//
//   String _formatDate(String date) {
//     try {
//       final dateTime = DateTime.parse(date);
//       return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
//     } catch (e) {
//       return 'Invalid Date';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16.r),
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Stack(
//         children: [
//           // Background Pattern
//           Positioned.fill(
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(16.r),
//                 gradient: LinearGradient(
//                   colors: [
//                     const Color(0xFFB15DC6).withOpacity(0.05),
//                     const Color(0xFF4A44B5).withOpacity(0.02),
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//               ),
//             ),
//           ),
//
//           // Main Content
//           Padding(
//             padding: EdgeInsets.all(16.w),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Center(
//                   child: Text(
//                     couponType,
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//                 // Discount Percentage
//                 // Center(
//                 //   child: Text(
//                 //     discountText == "PERCENTAGE"
//                 //         ? "${discountText}% OFF"
//                 //         : "₹${discountText} OFF",
//                 //     style: TextStyle(
//                 //       color: Colors.black,
//                 //       fontSize: 16,
//                 //       fontWeight: FontWeight.w600,
//                 //     ),
//                 //   ),
//                 // ),
//                 Center(
//                   child: Text(
//                     discountType == "PERCENTAGE"
//                         ? "$discountText% OFF"
//                         : "₹$discountText OFF",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//
//                 SizedBox(height: 12.h),
//
//                 // Promo Code
//                 Container(
//                   width: double.infinity,
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 12.w,
//                     vertical: 8.h,
//                   ),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF6C63FF).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8.r),
//                     border: Border.all(
//                       color: const Color(0xFF6C63FF).withOpacity(0.3),
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       Text(
//                         promoCode,
//                         style: TextStyle(
//                           fontSize: 10.sp,
//                           fontWeight: FontWeight.bold,
//                           color: const Color(0xFF2D3748),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 12.h),
//                 Text(
//                   minimumOrderValue <= 0
//                       ? "Applicable on any order"
//                       : "Min order ₹${minimumOrderValue.toInt()}",
//                   style: TextStyle(color: Colors.black, fontSize: 12),
//                 ),
//                 SizedBox(height: 5.h),
//                 // Validity
//                 Text(
//                   'Valid until ${_formatDate(endDate)}',
//                   style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//           ),
//
//           // Expired Overlay
//           if (isExpired)
//             Positioned.fill(
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(16.r),
//                   color: Colors.black.withOpacity(0.6),
//                 ),
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.highlight_off_rounded,
//                         color: Colors.white,
//                         size: 32.sp,
//                       ),
//                       SizedBox(height: 4.h),
//                       Text(
//                         'EXPIRED',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 12.sp,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
//

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/subscrptions/coupon_model.dart';
import '../../Services/Auth_service/Subscription_authservice.dart';
import '../../Services/Auth_service/food_authservice.dart';

// ── Design tokens ──────────────────────────────────────────────────────────────
class _C {
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
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withOpacity(0.06),
        centerTitle: true,
        title: const Text(
          'Coupons & Offers',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _C.ink,
            letterSpacing: -0.3,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: _C.bg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: _C.ink,
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
          _coupons = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
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
      color: _C.brand,
      backgroundColor: _C.surface,
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
        color: _C.brandSoft,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer_rounded, color: _C.brand, size: 18),
          SizedBox(width: 10.w),
          Text(
            '$active active coupon${active == 1 ? '' : 's'}',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: _C.brand,
            ),
          ),
          const Spacer(),
          if (expired > 0)
            Text(
              '$expired expired',
              style: TextStyle(fontSize: 12.sp, color: _C.sub),
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
                  color: _C.sub,
                  letterSpacing: 0.6,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: _C.border,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: _C.sub,
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
        return (bg: _C.greenSoft, fg: _C.green, badge: _C.green);
      case 'DELIVERY':
        return (bg: _C.amberSoft, fg: _C.amber, badge: _C.amber);
      default:
        return (bg: _C.brandSoft, fg: _C.brand, badge: _C.brand);
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
          color: _C.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _C.border),
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
            _DashedDivider(color: _C.border),

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
                          _Badge(label: 'Expired', bg: _C.redSoft, fg: _C.red),
                      ],
                    ),
                    SizedBox(height: 10.h),

                    // Min order
                    if (coupon.minimumOrderValue > 0)
                      Text(
                        'Min order ₹${coupon.minimumOrderValue.toInt()}',
                        style: TextStyle(fontSize: 11.sp, color: _C.sub),
                      ),
                    if (coupon.minimumOrderValue <= 0)
                      Text(
                        'Applicable on any order',
                        style: TextStyle(fontSize: 11.sp, color: _C.sub),
                      ),

                    SizedBox(height: 4.h),
                    Text(
                      'Valid till ${_fmtDate(coupon.endDate.toIso8601String())}',
                      style: TextStyle(fontSize: 10.sp, color: _C.muted),
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
          color: _copied ? _C.greenSoft : _C.bg,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: _copied ? _C.green : _C.border,
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
                color: _copied ? _C.green : _C.ink,
                letterSpacing: 0.8,
              ),
            ),
            // SizedBox(width: 6.w),
            // Icon(
            //   _copied ? Icons.check_rounded : Icons.copy_rounded,
            //   size: 12.sp,
            //   color: _copied ? _C.green : _C.muted,
            // ),
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

// ── Loading state ──────────────────────────────────────────────────────────────
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 36.r,
            height: 36.r,
            child: const CircularProgressIndicator(
              strokeWidth: 2.5,
              color: _C.brand,
              strokeCap: StrokeCap.round,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'Fetching offers...',
            style: TextStyle(fontSize: 13.sp, color: _C.sub),
          ),
        ],
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
              color: _C.brandSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.confirmation_num_outlined,
              size: 36.sp,
              color: _C.brand,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'No coupons yet',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: _C.ink,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Check back later for exciting offers!',
            style: TextStyle(fontSize: 13.sp, color: _C.sub),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
