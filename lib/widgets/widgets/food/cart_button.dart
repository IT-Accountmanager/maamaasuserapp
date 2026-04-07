import 'package:maamaas/Services/Auth_service/Subscription_authservice.dart';
import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Services/App_color_service/textstyles.dart';
import '../../../Services/Auth_service/food_authservice.dart';
import '../../../Models/food/cart_model.dart';
import 'package:flutter/material.dart';
import '../../../utils/utils.dart';
import '../../signinrequired.dart';
import 'currentcart_notifier.dart';
import 'cartmode.dart';

import 'package:maamaas/Services/App_color_service/app_colours.dart';

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

  @override
  void initState() {
    super.initState();
    _loadQuantity();
  }

  Future<void> _loadQuantity() async {
    try {
      final cart = await food_Authservice.fetchCart();

      CartItem? matchedItem;
      if (cart != null) {
        for (var item in cart.cartItems) {
          if (item.dishId == widget.dishId) {
            matchedItem = item;
            break;
          }
        }
      }

      setState(() => itemCount = matchedItem?.quantity ?? 0);
    } catch (e) {
      if (mounted) setState(() => itemCount = 0);
    }

    // update global cart badge
    Utils.refreshCartCount();
  }

  Future<void> _addToCart(int quantity, {bool sheduleorder = false}) async {
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

    // INSTANT SUBTRACT FROM CART BADGE
    CartNotifier.count.value -= itemCount;

    final removed = await food_Authservice.removeCartItem(itemId);

    if (removed) {
      prefs.remove("dish_${widget.dishId}_quantity");
      prefs.remove("dish_${widget.dishId}_itemId");

      setState(() => itemCount = 0);
    }
  }

  Future<void> _updateQuantity(int newQty) async {
    final prefs = await SharedPreferences.getInstance();
    final itemId = prefs.getInt("dish_${widget.dishId}_itemId");
    prefs.getInt("cartId");

    if (itemId != null) {
      // INSTANT CART BADGE UPDATE
      CartNotifier.count.value = CartNotifier.count.value - itemCount + newQty;

      await food_Authservice.updateCartQuantity(itemId, newQty);

      prefs.setInt("dish_${widget.dishId}_quantity", newQty);
    }
  }

  Future<bool> _checkLogin(BuildContext context) async {
    final isLoggedIn = await subscription_AuthService.isLoggedIn();

    if (!isLoggedIn) {
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

              onPressed: () async {
                final allowed = await _checkLogin(context);
                if (!allowed) return;

                final schedule = widget.balanceQuantity <= 0;

                setState(() => itemCount = 1);
                await _addToCart(1, sheduleorder: schedule);
                CartMode.type.value = CartType.normal;
              },

              child: Text(
                widget.balanceQuantity <= 0 ? "Schedule" : "Add Cart",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: TextColors.whiteText, // 👈 NEVER greyed out
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
                    onPressed: () async {
                      if (itemCount > 1) {
                        setState(() => itemCount--);
                        await _updateQuantity(itemCount);
                      } else {
                        await _removeFromCart();
                        setState(() => itemCount = 0);
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

                  /// ➕ Plus (WITH VALIDATION)
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
                      icon: Icon(
                        Icons.add,
                        size: 14.sp,
                        color:
                            // itemCount >= widget.balanceQuantity
                            //     ? Colors.grey
                            //     :
                            Colors.black,
                      ),

                      onPressed: () async {
                        final allowed = await _checkLogin(context);
                        if (!allowed) return;

                        setState(() => itemCount++);
                        await _updateQuantity(itemCount);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
