// // import 'package:maamaas/Services/Auth_service/Subscription_authservice.dart';
// // import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import '../../../Services/App_color_service/app_colours.dart';
// // import '../../../Services/App_color_service/textstyles.dart';
// // import '../../../Services/Auth_service/food_authservice.dart';
// // import '../../../Models/food/cart_model.dart';
// // import 'package:flutter/material.dart';
// // import '../../../widgets/signinrequired.dart';
// // import '../../../widgets/widgets/food/currentcart_notifier.dart';
// // import '../../../widgets/widgets/food/cartmode.dart';
// // class CartButton extends StatefulWidget {
// //   final int dishId;
// //   final double? savedAmount;
// //   final int balanceQuantity;
// //   final bool? sheduleorder;
// //
// //   const CartButton({
// //     super.key,
// //     required this.dishId,
// //     this.savedAmount,
// //     required this.balanceQuantity,
// //     this.sheduleorder,
// //   });
// //
// //   @override
// //   // ignore: library_private_types_in_public_api
// //   _CartButtonState createState() => _CartButtonState();
// // }
// //
// // class _CartButtonState extends State<CartButton> {
// //   int itemCount = 0;
// //   bool _isLoading = false;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadQuantity();
// //   }
// //
// //   Future<void> _loadQuantity() async {
// //     try {
// //       final cart = await food_Authservice.fetchCart();
// //
// //       CartItem? matchedItem;
// //       if (cart != null) {
// //         for (var item in cart.cartItems) {
// //           if (item.dishId == widget.dishId) {
// //             matchedItem = item;
// //             break;
// //           }
// //         }
// //       }
// //
// //       setState(() => itemCount = matchedItem?.quantity ?? 0);
// //     } catch (e) {
// //       if (mounted) setState(() => itemCount = 0);
// //     }
// //
// //     // update global cart badge
// //     // Utils.refreshCartCount();
// //   }
// //
// //   Future<void> _addToCart(int quantity, {bool sheduleorder = false}) async {
// //     CartNotifier.count.value += quantity;
// //
// //     await food_Authservice.addToCart(
// //       dishId: widget.dishId,
// //       quantity: quantity,
// //       sheduleorder: sheduleorder,
// //     );
// //     final itemId = await food_Authservice.getItemIdByDishId(widget.dishId);
// //
// //     if (itemId != null) {
// //       final prefs = await SharedPreferences.getInstance();
// //       await prefs.setInt("dish_${widget.dishId}_itemId", itemId);
// //       await prefs.setInt("dish_${widget.dishId}_quantity", quantity);
// //     }
// //   }
// //
// //
// //
// //   Future<void> _removeFromCart() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final itemId = prefs.getInt("dish_${widget.dishId}_itemId");
// //     if (itemId == null) return;
// //
// //     final removed = await food_Authservice.removeCartItem(itemId);
// //
// //     if (removed) {
// //       // ✅ Only subtract AFTER confirmed removal
// //       CartNotifier.count.value = (CartNotifier.count.value - itemCount).clamp(
// //         0,
// //         9999,
// //       );
// //       prefs.remove("dish_${widget.dishId}_quantity");
// //       prefs.remove("dish_${widget.dishId}_itemId");
// //       setState(() => itemCount = 0);
// //     }
// //   }
// //
// //   Future<void> _updateQuantity(int newQty) async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final itemId = prefs.getInt("dish_${widget.dishId}_itemId");
// //     prefs.getInt("cartId");
// //
// //     if (itemId != null) {
// //       // INSTANT CART BADGE UPDATE
// //       CartNotifier.count.value = CartNotifier.count.value - itemCount + newQty;
// //
// //       await food_Authservice.updateCartQuantity(itemId, newQty);
// //
// //       prefs.setInt("dish_${widget.dishId}_quantity", newQty);
// //     }
// //   }
// //
// //   Future<bool> _checkLogin(BuildContext context) async {
// //     final isLoggedIn = await subscription_AuthService.isLoggedIn();
// //
// //     if (!isLoggedIn) {
// //       // ignore: use_build_context_synchronously
// //       showAuthRequiredSheet(context);
// //       return false;
// //     }
// //
// //     return true;
// //   }
// //
// //   void showAuthRequiredSheet(BuildContext context) {
// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       backgroundColor: Colors.white,
// //       shape: const RoundedRectangleBorder(
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //       ),
// //       builder: (_) => const AuthRequiredWidget(),
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return SizedBox(
// //       width: 120.w,
// //       height: 39.h,
// //       child: itemCount == 0
// //           ? ElevatedButton(
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: AppColors.primary,
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(10.r),
// //                   side: BorderSide(
// //                     color: AppColors.of(context).primary,
// //                     width: 1.w,
// //                   ),
// //                 ),
// //                 padding: EdgeInsets.symmetric(horizontal: 10.w),
// //               ),
// //
// //               onPressed: _isLoading
// //                   ? null
// //                   : () async {
// //                       final allowed = await _checkLogin(context);
// //                       if (!allowed) return;
// //
// //                       final schedule = widget.balanceQuantity <= 0;
// //
// //                       setState(() => _isLoading = true);
// //
// //                       try {
// //                         await _addToCart(1, sheduleorder: schedule);
// //                         setState(() => itemCount = 1);
// //                         CartMode.type.value = CartType.normal;
// //                       } catch (e) {
// //                         AppAlert.error(context, "Failed to add item");
// //                       } finally {
// //                         if (mounted) setState(() => _isLoading = false);
// //                       }
// //                     },
// //
// //               child: _isLoading
// //                   ? SizedBox(
// //                       height: 18,
// //                       width: 18,
// //                       child: CircularProgressIndicator(
// //                         strokeWidth: 2,
// //                         color: Colors.white,
// //                       ),
// //                     )
// //                   : Text(
// //                       widget.balanceQuantity <= 0 ? "Schedule" : "Add Cart",
// //                       style: TextStyle(
// //                         fontSize: 14.sp,
// //                         fontWeight: FontWeight.w600,
// //                         color: TextColors.whiteText,
// //                       ),
// //                     ),
// //             )
// //           : Container(
// //               decoration: BoxDecoration(
// //                 borderRadius: BorderRadius.circular(10.r),
// //                 border: Border.all(
// //                   color: AppColors.of(context).primary,
// //                   width: 1.w,
// //                 ),
// //               ),
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                 children: [
// //                   /// ➖ Minus
// //                   IconButton(
// //                     icon: Icon(Icons.remove, size: 14.sp),
// //                     onPressed: _isLoading
// //                         ? null
// //                         : () async {
// //                             setState(() => _isLoading = true);
// //
// //                             try {
// //                               if (itemCount > 1) {
// //                                 await _updateQuantity(itemCount - 1);
// //                                 setState(() => itemCount--);
// //                               } else {
// //                                 await _removeFromCart();
// //                                 setState(() => itemCount = 0);
// //                               }
// //                             } catch (e) {
// //                               AppAlert.error(context, "Update failed");
// //                             } finally {
// //                               if (mounted) setState(() => _isLoading = false);
// //                             }
// //                           },
// //                   ),
// //
// //                   Text(
// //                     "$itemCount",
// //                     style: TextStyle(
// //                       fontSize: 12.sp,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //
// //                   /// ➕ Plus (WITH VALIDATION)
// //                   GestureDetector(
// //                     onTap: itemCount >= widget.balanceQuantity
// //                         ? () {
// //                             AppAlert.error(
// //                               context,
// //                               "📅 Item is out of stock. You can schedule it.",
// //                             );
// //                           }
// //                         : null,
// //                     child: IconButton(
// //                       icon: Icon(
// //                         Icons.add,
// //                         size: 14.sp,
// //                         color:
// //                             // itemCount >= widget.balanceQuantity
// //                             //     ? Colors.grey
// //                             //     :
// //                             Colors.black,
// //                       ),
// //
// //                       onPressed: _isLoading
// //                           ? null
// //                           : () async {
// //                               final allowed = await _checkLogin(context);
// //                               if (!allowed) return;
// //
// //                               setState(() => _isLoading = true);
// //
// //                               try {
// //                                 await _updateQuantity(itemCount + 1);
// //                                 setState(() => itemCount++);
// //                               } catch (e) {
// //                                 AppAlert.error(context, "Update failed");
// //                               } finally {
// //                                 if (mounted) setState(() => _isLoading = false);
// //                               }
// //                             },
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //     );
// //   }
// // }
//
//
// import 'package:maamaas/Services/Auth_service/Subscription_authservice.dart';
// import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../Services/App_color_service/app_colours.dart';
// import '../../../Services/App_color_service/textstyles.dart';
// import '../../../Services/Auth_service/food_authservice.dart';
// import 'package:flutter/material.dart';
// import '../../../widgets/signinrequired.dart';
// import '../../../widgets/widgets/food/currentcart_notifier.dart';
// import '../../../widgets/widgets/food/cartmode.dart';
//
//
//
// class CartButton extends StatefulWidget {
//   final int dishId;
//   final double? savedAmount;
//   final int balanceQuantity;
//   final bool? sheduleorder;
//
//   const CartButton({
//     super.key,
//     required this.dishId,
//     this.savedAmount,
//     required this.balanceQuantity,
//     this.sheduleorder,
//   });
//
//   @override
//   // ignore: library_private_types_in_public_api
//   _CartButtonState createState() => _CartButtonState();
// }
//
// class _CartButtonState extends State<CartButton> {
//   int itemCount = 0;
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadQuantity();
//   }
//
//
//   Future<void> _loadQuantity() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final saved = prefs.getInt("dish_${widget.dishId}_quantity") ?? 0;
//       if (mounted) setState(() => itemCount = saved);
//     } catch (e) {
//       if (mounted) setState(() => itemCount = 0);
//     }
//     // ✅ No Utils.refreshCartCount() — CartNotifier.count is the cart
//     //    footer's responsibility, not the individual dish button's.
//   }
//
//   Future<void> _addToCart(int quantity, {bool sheduleorder = false}) async {
//     // Optimistic badge increment — this is correct because we are ADDING
//     // a brand-new item that wasn't in the cart before.
//     CartNotifier.count.value += quantity;
//
//     await food_Authservice.addToCart(
//       dishId: widget.dishId,
//       quantity: quantity,
//       sheduleorder: sheduleorder,
//     );
//
//     final itemId = await food_Authservice.getItemIdByDishId(widget.dishId);
//     if (itemId != null) {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setInt("dish_${widget.dishId}_itemId", itemId);
//       await prefs.setInt("dish_${widget.dishId}_quantity", quantity);
//     }
//   }
//
//   Future<void> _removeFromCart() async {
//     final prefs = await SharedPreferences.getInstance();
//     final itemId = prefs.getInt("dish_${widget.dishId}_itemId");
//     if (itemId == null) return;
//
//     final removed = await food_Authservice.removeCartItem(itemId);
//
//     if (removed) {
//       // Only subtract AFTER confirmed removal
//       CartNotifier.count.value = (CartNotifier.count.value - itemCount).clamp(
//         0,
//         9999,
//       );
//       await prefs.remove("dish_${widget.dishId}_quantity");
//       await prefs.remove("dish_${widget.dishId}_itemId");
//       if (mounted) setState(() => itemCount = 0);
//     }
//   }
//
//   Future<void> _updateQuantity(int newQty) async {
//     final prefs = await SharedPreferences.getInstance();
//     final itemId = prefs.getInt("dish_${widget.dishId}_itemId");
//
//     if (itemId != null) {
//       // Instant badge update — delta only, not a full recount
//       CartNotifier.count.value =
//           (CartNotifier.count.value - itemCount + newQty).clamp(0, 9999);
//
//       await food_Authservice.updateCartQuantity(itemId, newQty);
//       await prefs.setInt("dish_${widget.dishId}_quantity", newQty);
//     }
//   }
//
//   // ── FIX 2: When cart is cleared externally (e.g. delete cart button),
//   //   CartNotifier.count drops to 0. Listen to it and reset local itemCount
//   //   so the button goes back to "Add Cart" without needing a restart.
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     CartNotifier.count.addListener(_onGlobalCountReset);
//   }
//
//   void _onGlobalCountReset() {
//     // If the global count dropped to 0, the cart was cleared — reset this
//     // button's local counter too so it shows "Add Cart" again.
//     if (CartNotifier.count.value == 0 && itemCount != 0) {
//       if (mounted) {
//         setState(() => itemCount = 0);
//         // Also clear SharedPreferences for this dish
//         SharedPreferences.getInstance().then((prefs) {
//           prefs.remove("dish_${widget.dishId}_quantity");
//           prefs.remove("dish_${widget.dishId}_itemId");
//         });
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     CartNotifier.count.removeListener(_onGlobalCountReset);
//     super.dispose();
//   }
//
//   Future<bool> _checkLogin(BuildContext context) async {
//     final isLoggedIn = await subscription_AuthService.isLoggedIn();
//     if (!isLoggedIn) {
//       // ignore: use_build_context_synchronously
//       showAuthRequiredSheet(context);
//       return false;
//     }
//     return true;
//   }
//
//   void showAuthRequiredSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) => const AuthRequiredWidget(),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 120.w,
//       height: 39.h,
//       child: itemCount == 0
//           ? ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.primary,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10.r),
//             side: BorderSide(
//               color: AppColors.of(context).primary,
//               width: 1.w,
//             ),
//           ),
//           padding: EdgeInsets.symmetric(horizontal: 10.w),
//         ),
//         onPressed: _isLoading
//             ? null
//             : () async {
//           final allowed = await _checkLogin(context);
//           if (!allowed) return;
//
//           final schedule = widget.balanceQuantity <= 0;
//           setState(() => _isLoading = true);
//
//           try {
//             await _addToCart(1, sheduleorder: schedule);
//             setState(() => itemCount = 1);
//             CartMode.type.value = CartType.normal;
//           } catch (e) {
//             // Rollback optimistic increment on failure
//             CartNotifier.count.value =
//                 (CartNotifier.count.value - 1).clamp(0, 9999);
//             AppAlert.error(context, "Failed to add item");
//           } finally {
//             if (mounted) setState(() => _isLoading = false);
//           }
//         },
//         child: _isLoading
//             ? const SizedBox(
//           height: 18,
//           width: 18,
//           child: CircularProgressIndicator(
//             strokeWidth: 2,
//             color: Colors.white,
//           ),
//         )
//             : Text(
//           widget.balanceQuantity <= 0 ? "Schedule" : "Add Cart",
//           style: TextStyle(
//             fontSize: 14.sp,
//             fontWeight: FontWeight.w600,
//             color: TextColors.whiteText,
//           ),
//         ),
//       )
//           : Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10.r),
//           border: Border.all(
//             color: AppColors.of(context).primary,
//             width: 1.w,
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             /// ➖ Minus
//             IconButton(
//               icon: Icon(Icons.remove, size: 14.sp),
//               onPressed: _isLoading
//                   ? null
//                   : () async {
//                 setState(() => _isLoading = true);
//                 try {
//                   if (itemCount > 1) {
//                     await _updateQuantity(itemCount - 1);
//                     setState(() => itemCount--);
//                   } else {
//                     await _removeFromCart();
//                     setState(() => itemCount = 0);
//                   }
//                 } catch (e) {
//                   AppAlert.error(context, "Update failed");
//                 } finally {
//                   if (mounted) setState(() => _isLoading = false);
//                 }
//               },
//             ),
//
//             Text(
//               "$itemCount",
//               style: TextStyle(
//                 fontSize: 12.sp,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//
//             /// ➕ Plus
//             GestureDetector(
//               onTap: itemCount >= widget.balanceQuantity
//                   ? () {
//                 AppAlert.error(
//                   context,
//                   "📅 Item is out of stock. You can schedule it.",
//                 );
//               }
//                   : null,
//               child: IconButton(
//                 icon: Icon(Icons.add, size: 14.sp, color: Colors.black),
//                 onPressed: _isLoading
//                     ? null
//                     : () async {
//                   final allowed = await _checkLogin(context);
//                   if (!allowed) return;
//
//                   setState(() => _isLoading = true);
//                   try {
//                     await _updateQuantity(itemCount + 1);
//                     setState(() => itemCount++);
//                   } catch (e) {
//                     AppAlert.error(context, "Update failed");
//                   } finally {
//                     if (mounted) setState(() => _isLoading = false);
//                   }
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:maamaas/Services/Auth_service/Subscription_authservice.dart';
import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Services/App_color_service/app_colours.dart';
import '../../../Services/App_color_service/textstyles.dart';
import '../../../Services/Auth_service/food_authservice.dart';
import 'package:flutter/material.dart';
import '../../../widgets/signinrequired.dart';
import '../../../widgets/widgets/food/currentcart_notifier.dart';
import '../../../widgets/widgets/food/cartmode.dart';

class CartButton extends StatefulWidget {
  final int dishId;
  final double? savedAmount;
  final int balanceQuantity;
  final bool? sheduleorder;

  const CartButton({
    super.key,
    required this.dishId,
    this.savedAmount,
    required this.balanceQuantity,
    this.sheduleorder,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CartButtonState createState() => _CartButtonState();
}

class _CartButtonState extends State<CartButton> {
  int itemCount = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadQuantity();
    // Listen to global cart count to detect external clears (e.g. "Clear Cart"
    // button on the cart screen).
    CartNotifier.count.addListener(_onGlobalCountReset);
  }

  /// Reads this dish's quantity from SharedPreferences.
  /// SharedPreferences are the source of truth for per-dish counts because
  /// they are written on every add/update and cleared on remove/cart-clear.
  Future<void> _loadQuantity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getInt("dish_${widget.dishId}_quantity") ?? 0;
      if (mounted) setState(() => itemCount = saved);
    } catch (e) {
      if (mounted) setState(() => itemCount = 0);
    }
  }

  Future<void> _addToCart(int quantity, {bool sheduleorder = false}) async {
    // Optimistic badge increment.
    CartNotifier.count.value += quantity;

    await food_Authservice.addToCart(
      dishId: widget.dishId,
      quantity: quantity,
      sheduleorder: sheduleorder,
    );

    final itemId = await food_Authservice.getItemIdByDishId(widget.dishId);
    if (itemId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt("dish_${widget.dishId}_itemId", itemId);
      await prefs.setInt("dish_${widget.dishId}_quantity", quantity);
    }
  }

  Future<void> _removeFromCart() async {
    final prefs = await SharedPreferences.getInstance();
    final itemId = prefs.getInt("dish_${widget.dishId}_itemId");
    if (itemId == null) return;

    final removed = await food_Authservice.removeCartItem(itemId);

    if (removed) {
      // Only subtract AFTER confirmed removal.
      CartNotifier.count.value = (CartNotifier.count.value - itemCount).clamp(
        0,
        9999,
      );
      await prefs.remove("dish_${widget.dishId}_quantity");
      await prefs.remove("dish_${widget.dishId}_itemId");
      if (mounted) setState(() => itemCount = 0);
    }
  }

  Future<void> _updateQuantity(int newQty) async {
    final prefs = await SharedPreferences.getInstance();
    final itemId = prefs.getInt("dish_${widget.dishId}_itemId");

    if (itemId != null) {
      // Instant badge update — delta only, not a full recount.
      CartNotifier.count.value =
          (CartNotifier.count.value - itemCount + newQty).clamp(0, 9999);

      await food_Authservice.updateCartQuantity(itemId, newQty);
      await prefs.setInt("dish_${widget.dishId}_quantity", newQty);
    }
  }

  /// Fires whenever the global CartNotifier.count changes.
  ///
  /// When the cart is cleared externally (e.g. "Clear Cart" on the cart screen
  /// sets CartNotifier.count = 0 after the authoritative server fetch in
  /// cart_footer_button.dart → didPopNext), this resets the dish button back
  /// to "Add Cart" and wipes the stale SharedPreferences entry so that the
  /// next time MenuScreen is visited the button starts fresh.
  void _onGlobalCountReset() {
    if (CartNotifier.count.value == 0 && itemCount != 0) {
      if (mounted) {
        setState(() => itemCount = 0);
      }
      // Wipe prefs even if widget is no longer mounted so stale data is gone
      // before the next _loadQuantity() call.
      SharedPreferences.getInstance().then((prefs) {
        prefs.remove("dish_${widget.dishId}_quantity");
        prefs.remove("dish_${widget.dishId}_itemId");
      });
    }
  }

  @override
  void dispose() {
    CartNotifier.count.removeListener(_onGlobalCountReset);
    super.dispose();
  }

  Future<bool> _checkLogin(BuildContext context) async {
    final isLoggedIn = await subscription_AuthService.isLoggedIn();
    if (!isLoggedIn) {
      // ignore: use_build_context_synchronously
      showAuthRequiredSheet(context);
      return false;
    }
    return true;
  }

  void showAuthRequiredSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AuthRequiredWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120.w,
      height: 39.h,
      child: itemCount == 0
          ? ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
            side: BorderSide(
              color: AppColors.of(context).primary,
              width: 1.w,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10.w),
        ),
        onPressed: _isLoading
            ? null
            : () async {
          final allowed = await _checkLogin(context);
          if (!allowed) return;

          final schedule = widget.balanceQuantity <= 0;
          setState(() => _isLoading = true);

          try {
            await _addToCart(1, sheduleorder: schedule);
            setState(() => itemCount = 1);
            CartMode.type.value = CartType.normal;
          } catch (e) {
            // Rollback optimistic increment on failure.
            CartNotifier.count.value =
                (CartNotifier.count.value - 1).clamp(0, 9999);
            AppAlert.error(context, "Failed to add item");
          } finally {
            if (mounted) setState(() => _isLoading = false);
          }
        },
        child: _isLoading
            ? const SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Text(
          widget.balanceQuantity <= 0 ? "Schedule" : "Add Cart",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: TextColors.whiteText,
          ),
        ),
      )
          : Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: AppColors.of(context).primary,
            width: 1.w,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            /// ➖ Minus
            IconButton(
              icon: Icon(Icons.remove, size: 14.sp),
              onPressed: _isLoading
                  ? null
                  : () async {
                setState(() => _isLoading = true);
                try {
                  if (itemCount > 1) {
                    await _updateQuantity(itemCount - 1);
                    setState(() => itemCount--);
                  } else {
                    await _removeFromCart();
                    setState(() => itemCount = 0);
                  }
                } catch (e) {
                  AppAlert.error(context, "Update failed");
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
            ),

            Text(
              "$itemCount",
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),

            /// ➕ Plus
            GestureDetector(
              onTap: itemCount >= widget.balanceQuantity
                  ? () {
                AppAlert.error(
                  context,
                  "📅 Item is out of stock. You can schedule it.",
                );
              }
                  : null,
              child: IconButton(
                icon: Icon(Icons.add, size: 14.sp, color: Colors.black),
                onPressed: _isLoading
                    ? null
                    : () async {
                  final allowed = await _checkLogin(context);
                  if (!allowed) return;

                  setState(() => _isLoading = true);
                  try {
                    await _updateQuantity(itemCount + 1);
                    setState(() => itemCount++);
                  } catch (e) {
                    AppAlert.error(context, "Update failed");
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}