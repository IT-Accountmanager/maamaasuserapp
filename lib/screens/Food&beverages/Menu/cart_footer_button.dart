import '../../../main.dart';
import '../../../widgets/widgets/food/currentcart_notifier.dart';
import '../../../Services/Auth_service/food_authservice.dart';
import '../food_cartscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: camel_case_types
class food_Cart_count extends StatefulWidget {
  final double? savedAmount;

  const food_Cart_count({super.key, this.savedAmount});

  @override
  State<food_Cart_count> createState() => _OrderCartFooterState();
}

class _OrderCartFooterState extends State<food_Cart_count>
    with RouteAware, SingleTickerProviderStateMixin {
  late AnimationController _bounceCtrl;
  late Animation<double> _scaleAnim;
  int _previousCount = 0;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.06), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.06, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeOut));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 500));
      _loadCartData();
    });

    // Animate whenever count changes
    CartNotifier.count.addListener(_onCountChange);
  }

  void _onCountChange() {
    final newCount = CartNotifier.count.value;

    debugPrint("🔵 Cart count changed → $newCount");
    if (newCount != _previousCount && newCount > 0) {
      _bounceCtrl.forward(from: 0);
      HapticFeedback.lightImpact();
    }
    _previousCount = newCount;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  Future<void> _loadCartData() async {
    try {
      final count = await food_Authservice.fetchCartCount();
      final safeCount = count < 0 ? 0 : count;

      debugPrint("🟣 API Cart Count → $count");

      // ✅ Only update if server count is HIGHER than current optimistic count
      // This prevents server lag from wiping out the optimistic UI update
      if (safeCount > CartNotifier.count.value) {
        CartNotifier.count.value = safeCount;
      }
    } catch (e) {
      debugPrint('❌ Cart load error: $e');
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    CartNotifier.count.removeListener(_onCountChange);
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  void didPopNext() => _loadCartData();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder<int>(
        valueListenable: CartNotifier.count,
        builder: (context, count, _) {
          debugPrint("🟢 Cart widget rebuild → count: $count");

          final safeCount = count < 0 ? 0 : count;
          if (safeCount == 0) return const SizedBox.shrink();

          return ScaleTransition(
            scale: _scaleAnim,
            child: _CartBar(
              count: safeCount,
              savedAmount: widget.savedAmount ?? 0.0,
              onTap: () async {
                debugPrint("🟡 Cart tapped → count: $safeCount");
                HapticFeedback.mediumImpact();
                await Navigator.push(
                  context,
                  _slideRoute(
                    food_cartScreen(
                      savedAmount: widget.savedAmount ?? 0.0,
                      showSavedPopup: true,
                    ),
                  ),
                );
                await _loadCartData();
              },
            ),
          );
        },
      ),
    );
  }
}

// ── The actual cart bar widget ────────────────────────────────────────────────
class _CartBar extends StatelessWidget {
  final int count;
  final double savedAmount;
  final VoidCallback onTap;

  const _CartBar({
    required this.count,
    required this.savedAmount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isSmall = w < 360;
    final isTablet = w >= 600;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isTablet ? 62 : 56,
        constraints: isTablet
            ? const BoxConstraints(maxWidth: 480)
            : const BoxConstraints(),
        margin: isTablet
            ? EdgeInsets.symmetric(horizontal: (w - 480) / 2)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF2D6A4F), Color(0xFF40916C)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2D6A4F).withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            splashColor: Colors.white.withOpacity(0.12),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmall ? 14.w : 18.w),
              child: Row(
                children: [
                  // Cart icon with count badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 38.r,
                        height: 38.r,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.shopping_bag_rounded,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                      // Positioned(
                      //   top: -4,
                      //   right: -4,
                      //   child: Container(
                      //     padding: EdgeInsets.all(2.r),
                      //     constraints: BoxConstraints(
                      //       minWidth: 18.r,
                      //       minHeight: 18.r,
                      //     ),
                      //     decoration: BoxDecoration(
                      //       color: const Color(0xFFFF6B35),
                      //       shape: BoxShape.circle,
                      //       border: Border.all(color: Colors.white, width: 1.5),
                      //     ),
                      //     child: Text(
                      //       '$count',
                      //       style: TextStyle(
                      //         color: Colors.white,
                      //         fontSize: isSmall ? 8.sp : 9.sp,
                      //         fontWeight: FontWeight.w800,
                      //       ),
                      //       textAlign: TextAlign.center,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),

                  SizedBox(width: isSmall ? 10.w : 12.w),

                  // Center text
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$count ${count == 1 ? "item" : "items"}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmall ? 12.sp : 13.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1,
                          ),
                        ),
                        if (savedAmount > 0) ...[
                          SizedBox(height: 1.h),
                          Text(
                            'You saved ₹${savedAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // CTA
                  _CTAButton(isSmall: isSmall),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── CTA button ────────────────────────────────────────────────────────────────
class _CTAButton extends StatelessWidget {
  final bool isSmall;

  const _CTAButton({required this.isSmall});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 10.w : 14.w,
        vertical: 7.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'View',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmall ? 12.sp : 13.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 11.sp,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

// ── Slide-up route transition ─────────────────────────────────────────────────
Route _slideRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      final slide = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return SlideTransition(position: slide, child: child);
    },
    transitionDuration: const Duration(milliseconds: 380),
  );
}

//
// import '../../main.dart';
// import '../../widgets/widgets/food/currentcart_notifier.dart';
// import '../../Services/Auth_service/food_authservice.dart';
// import '../../Services/App_color_service/app_colours.dart';
// import '../Food&beverages/food_cartscreen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
//
// // ignore: camel_case_types
// class food_Cart_count extends StatefulWidget {
//   final double? savedAmount;
//
//   const food_Cart_count({super.key, this.savedAmount});
//
//   @override
//   State<food_Cart_count> createState() => _OrderCartFooterState();
// }
//
// class _OrderCartFooterState extends State<food_Cart_count>
//     with RouteAware, SingleTickerProviderStateMixin {
//   late AnimationController _bounceCtrl;
//   late Animation<double> _scaleAnim;
//   int _previousCount = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _bounceCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//     _scaleAnim = TweenSequence<double>([
//       TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.06), weight: 50),
//       TweenSequenceItem(tween: Tween(begin: 1.06, end: 1.0), weight: 50),
//     ]).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeOut));
//
//     WidgetsBinding.instance.addPostFrameCallback((_) => _loadCartData());
//
//     // Animate whenever count changes
//     CartNotifier.count.addListener(_onCountChange);
//   }
//
//   void _onCountChange() {
//     final newCount = CartNotifier.count.value;
//     if (newCount != _previousCount && newCount > 0) {
//       _bounceCtrl.forward(from: 0);
//       HapticFeedback.lightImpact();
//     }
//     _previousCount = newCount;
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     routeObserver.subscribe(this, ModalRoute.of(context)!);
//   }
//
//   Future<void> _loadCartData() async {
//     try {
//       final count = await food_Authservice.fetchCartCount();
//       CartNotifier.count.value = count < 0 ? 0 : count;
//     } catch (e) {
//       debugPrint('Cart load error: $e');
//     }
//   }
//
//   @override
//   void dispose() {
//     routeObserver.unsubscribe(this);
//     CartNotifier.count.removeListener(_onCountChange);
//     _bounceCtrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   void didPopNext() => _loadCartData();
//
//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<int>(
//       valueListenable: CartNotifier.count,
//       builder: (context, count, _) {
//         final safeCount = count < 0 ? 0 : count;
//         if (safeCount == 0) return const SizedBox.shrink();
//
//         return ScaleTransition(
//           scale: _scaleAnim,
//           child: _CartBar(
//             count: safeCount,
//             savedAmount: widget.savedAmount ?? 0.0,
//             onTap: () async {
//               HapticFeedback.mediumImpact();
//               await Navigator.push(
//                 context,
//                 _slideRoute(
//                   food_cartScreen(
//                     savedAmount: widget.savedAmount ?? 0.0,
//                     showSavedPopup: true,
//                   ),
//                 ),
//               );
//               await _loadCartData();
//             },
//           ),
//         );
//       },
//     );
//   }
// }
//
// // ── The actual cart bar widget ────────────────────────────────────────────────
// class _CartBar extends StatelessWidget {
//   final int count;
//   final double savedAmount;
//   final VoidCallback onTap;
//
//   const _CartBar({
//     required this.count,
//     required this.savedAmount,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = AppColors.of(context); // 👈 dynamic theme
//     final w = MediaQuery.of(context).size.width;
//     final isSmall = w < 360;
//     final isTablet = w >= 600;
//
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: isTablet ? 62 : 56,
//         constraints: isTablet
//             ? const BoxConstraints(maxWidth: 480)
//             : const BoxConstraints(),
//         margin: isTablet
//             ? EdgeInsets.symmetric(horizontal: (w - 480) / 2)
//             : EdgeInsets.zero,
//         decoration: BoxDecoration(
//           // 👇 Gradient uses primary → primaryDark from active palette
//           gradient: LinearGradient(
//             begin: Alignment.centerLeft,
//             end: Alignment.centerRight,
//             colors: [colors.primary, colors.primaryDark],
//           ),
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: colors.primary.withOpacity(0.35),
//               blurRadius: 20,
//               offset: const Offset(0, 6),
//             ),
//           ],
//         ),
//         child: Material(
//           color: Colors.transparent,
//           child: InkWell(
//             onTap: onTap,
//             borderRadius: BorderRadius.circular(16),
//             splashColor: Colors.white.withOpacity(0.12),
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: isSmall ? 14.w : 18.w),
//               child: Row(
//                 children: [
//                   // Cart icon with count badge
//                   Stack(
//                     clipBehavior: Clip.none,
//                     children: [
//                       Container(
//                         width: 38.r,
//                         height: 38.r,
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.15),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(
//                           Icons.shopping_bag_rounded,
//                           color: Colors.white,
//                           size: 20.sp,
//                         ),
//                       ),
//                       Positioned(
//                         top: -4,
//                         right: -4,
//                         child: Container(
//                           padding: EdgeInsets.all(2.r),
//                           constraints: BoxConstraints(
//                             minWidth: 18.r,
//                             minHeight: 18.r,
//                           ),
//                           decoration: BoxDecoration(
//                             // 👇 Badge uses accent color from active palette
//                             color: colors.accent,
//                             shape: BoxShape.circle,
//                             border: Border.all(color: Colors.white, width: 1.5),
//                           ),
//                           child: Text(
//                             '$count',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: isSmall ? 8.sp : 9.sp,
//                               fontWeight: FontWeight.w800,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   SizedBox(width: isSmall ? 10.w : 12.w),
//
//                   // Center text
//                   Expanded(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           '$count ${count == 1 ? "item" : "items"} in cart',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: isSmall ? 12.sp : 13.sp,
//                             fontWeight: FontWeight.w700,
//                             letterSpacing: 0.1,
//                           ),
//                         ),
//                         if (savedAmount > 0) ...[
//                           SizedBox(height: 1.h),
//                           Text(
//                             'You saved ₹${savedAmount.toStringAsFixed(0)}',
//                             style: TextStyle(
//                               color: Colors.white.withOpacity(0.8),
//                               fontSize: 10.sp,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//
//                   // CTA
//                   _CTAButton(isSmall: isSmall),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ── CTA button ────────────────────────────────────────────────────────────────
// class _CTAButton extends StatelessWidget {
//   final bool isSmall;
//
//   const _CTAButton({required this.isSmall});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: isSmall ? 10.w : 14.w,
//         vertical: 7.h,
//       ),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             'View',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: isSmall ? 12.sp : 13.sp,
//               fontWeight: FontWeight.w700,
//               letterSpacing: 0.2,
//             ),
//           ),
//           SizedBox(width: 4.w),
//           Icon(
//             Icons.arrow_forward_ios_rounded,
//             size: 11.sp,
//             color: Colors.white,
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ── Slide-up route transition ─────────────────────────────────────────────────
// Route _slideRoute(Widget page) {
//   return PageRouteBuilder(
//     pageBuilder: (_, __, ___) => page,
//     transitionsBuilder: (_, animation, __, child) {
//       final slide = Tween<Offset>(
//         begin: const Offset(0, 1),
//         end: Offset.zero,
//       ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
//       return SlideTransition(position: slide, child: child);
//     },
//     transitionDuration: const Duration(milliseconds: 380),
//   );
// }
