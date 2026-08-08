import 'package:flutter/material.dart';
import '../../../Models/food/cart_model.dart';
import '../../../Models/food/dish.dart';
import '../../../utils/utils.dart';
import '../../../widgets/signinrequired.dart';
import '../../../widgets/widgets/food/cartmode.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Services/App_color_service/textstyles.dart';
import '../../../Services/App_color_service/app_colours.dart';
import '../../../Services/Auth_service/food_authservice.dart';
import '../../../widgets/widgets/food/currentcart_notifier.dart';
import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import 'package:maamaas/Services/Auth_service/Subscription_authservice.dart';

class CartButtonwithout extends StatefulWidget {
  final Dish dish;
  final double? savedAmount;
  final bool? sheduleorder;

  const CartButtonwithout({
    super.key,
    required this.dish,
    this.savedAmount,
    this.sheduleorder,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CartButtonwithoutState createState() => _CartButtonwithoutState();
}

class _CartButtonwithoutState extends State<CartButtonwithout> {
  int itemCount = 0;
  bool _isAddingToCart = false;

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
          if (item.dishId == widget.dish.dishId) {
            matchedItem = item;
            break;
          }
        }
      }

      final prefs = await SharedPreferences.getInstance();

      if (matchedItem != null) {
        await prefs.setInt(
          "dish_${widget.dish.dishId}_itemId",
          matchedItem.itemId,
        );

        await prefs.setInt(
          "dish_${widget.dish.dishId}_quantity",
          matchedItem.quantity,
        );
      }

      setState(() => itemCount = matchedItem?.quantity ?? 0);
    } catch (e) {
      if (mounted) setState(() => itemCount = 0);
    }

    // update global cart badge
    Utils.refreshCartCount();
  }

  Future<void> _addToCart(int quantity, {bool sheduleorder = false}) async {
    if (_isAddingToCart) return;

    setState(() {
      _isAddingToCart = true;
    });

    try {
      final success = await food_Authservice.addToCart(
        dishId: widget.dish.dishId,
        quantity: quantity,
        sheduleorder: sheduleorder,
      );

      if (success) {
        CartNotifier.count.value += quantity;
        await _loadQuantity();
      }
    } catch (e) {
      if (mounted) {
        AppAlert.error(context, e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  Future<void> _removeFromCart() async {
    final prefs = await SharedPreferences.getInstance();
    final itemId = prefs.getInt("dish_${widget.dish.dishId}_itemId");

    if (itemId == null) return;

    CartNotifier.count.value -= itemCount;

    final removed = await food_Authservice.removeCartItem(itemId);

    if (removed) {
      prefs.remove("dish_${widget.dish.dishId}_quantity");
      prefs.remove("dish_${widget.dish.dishId}_itemId");

      setState(() => itemCount = 0);
    }
  }

  Future<void> _updateQuantity(int newQty) async {
    final prefs = await SharedPreferences.getInstance();

    final itemId = prefs.getInt("dish_${widget.dish.dishId}_itemId");

    if (itemId == null) {
      return;
    }

    CartNotifier.count.value = CartNotifier.count.value - itemCount + newQty;

    await food_Authservice.updateCartQuantity(itemId, newQty);

    prefs.setInt("dish_${widget.dish.dishId}_quantity", newQty);
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

                final schedule = widget.dish.balanceQuantity <= 0;

                await _addToCart(1, sheduleorder: schedule);

                CartMode.type.value = CartType.normal;
              },

              child: _isAddingToCart
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      widget.dish.balanceQuantity <= 0
                          ? "Schedule"
                          : "Add Cart",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: TextColors.whiteText, // 👈 NEVER greyed out
                      ),
                    ),
            )
          : Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.9),
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
                    icon: Icon(Icons.remove, size: 14.sp, color: Colors.white),
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
                      color: Colors.white,
                    ),
                  ),

                  /// ➕ Plus (WITH VALIDATION)
                  GestureDetector(
                    onTap: itemCount >= widget.dish.balanceQuantity
                        ? () {
                            AppAlert.error(
                              context,
                              "📅 Item is out of stock. You can schedule it.",
                            );
                          }
                        : null,
                    child: IconButton(
                      icon: Icon(Icons.add, size: 14.sp, color: Colors.white),

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
