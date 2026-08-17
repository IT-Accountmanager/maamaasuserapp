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
  final Map<int, int> selectedAddons;

  const CartButtonwithout({
    super.key,
    required this.dish,
    this.savedAmount,
    this.sheduleorder,
    this.selectedAddons = const {},
  });

  @override
  // ignore: library_private_types_in_public_api
  _CartButtonwithoutState createState() => _CartButtonwithoutState();
}

class _CartButtonwithoutState extends State<CartButtonwithout> {
  int itemCount = 0;
  bool _isAddingToCart = false;

  bool _isUpdatingQuantity = false;
  double get dishPrice => widget.dish.effectivePrice ?? widget.dish.price ?? 0;

  double get addonTotal {
    double total = 0;

    for (final entry in widget.selectedAddons.entries) {
      final addonId = entry.key;
      final addonQuantity = entry.value;

      if (addonQuantity <= 0) continue;

      try {
        final addon = widget.dish.addons.firstWhere(
          (e) => e.addonId == addonId,
        );

        total += addon.addonPrice * addonQuantity;
      } catch (_) {
        debugPrint("Addon not found for addonId: $addonId");
      }
    }

    return total;
  }

  double get totalPrice {
    final selectedQuantity = itemCount > 0 ? itemCount : 1;

    return (dishPrice * selectedQuantity) + addonTotal;
  }

  @override
  void initState() {
    super.initState();
    _loadQuantity();
    CartNotifier.quantities.addListener(_onCartQuantityChanged);
  }

  @override
  void dispose() {
    CartNotifier.quantities.removeListener(_onCartQuantityChanged);

    super.dispose();
  }

  void _onCartQuantityChanged() {
    if (!mounted) return;

    final quantity = CartNotifier.getDishQuantity(widget.dish.dishId);

    if (itemCount != quantity) {
      setState(() {
        itemCount = quantity;
      });
    }
  }

  // Future<void> _loadQuantity() async {
  //   try {
  //     final cart = await food_Authservice.fetchCart();
  //
  //     CartItem? matchedItem;
  //     if (cart != null) {
  //       for (var item in cart.cartItems) {
  //         if (item.dishId == widget.dish.dishId) {
  //           matchedItem = item;
  //           break;
  //         }
  //       }
  //     }
  //
  //     final prefs = await SharedPreferences.getInstance();
  //
  //     if (matchedItem != null) {
  //       await prefs.setInt(
  //         "dish_${widget.dish.dishId}_itemId",
  //         matchedItem.itemId,
  //       );
  //
  //       await prefs.setInt(
  //         "dish_${widget.dish.dishId}_quantity",
  //         matchedItem.quantity,
  //       );
  //     }
  //
  //     setState(() => itemCount = matchedItem?.quantity ?? 0);
  //   } catch (e) {
  //     if (mounted) setState(() => itemCount = 0);
  //   }
  //
  //   // update global cart badge
  //   Utils.refreshCartCount();
  // }

  Future<void> _loadQuantity() async {
    try {
      final cart = await food_Authservice.fetchCart();

      CartItem? matchedItem;

      if (cart != null) {
        for (final item in cart.cartItems) {
          if (item.dishId == widget.dish.dishId) {
            matchedItem = item;
            break;
          }
        }
      }

      final prefs = await SharedPreferences.getInstance();

      final quantity = matchedItem?.quantity ?? 0;

      if (matchedItem != null) {
        await prefs.setInt(
          "dish_${widget.dish.dishId}_itemId",
          matchedItem.itemId,
        );

        await prefs.setInt(
          "dish_${widget.dish.dishId}_quantity",
          matchedItem.quantity,
        );
      } else {
        await prefs.remove("dish_${widget.dish.dishId}_itemId");

        await prefs.remove("dish_${widget.dish.dishId}_quantity");
      }

      if (mounted) {
        setState(() {
          itemCount = quantity;
        });
      }

      // 🔥 IMPORTANT
      CartNotifier.updateDishQuantity(widget.dish.dishId, quantity);

      await Utils.refreshCartCount();
    } catch (e) {
      if (mounted) {
        setState(() {
          itemCount = 0;
        });
      }

      CartNotifier.updateDishQuantity(widget.dish.dishId, 0);
    }
  }

  // Future<void> _addToCart(int quantity, {bool sheduleorder = false}) async {
  //   if (_isAddingToCart) return;
  //
  //   setState(() {
  //     _isAddingToCart = true;
  //   });
  //
  //   try {
  //     final addons = widget.selectedAddons.entries.map((entry) {
  //       return {"addonId": entry.key, "quantity": entry.value};
  //     }).toList();
  //     final success = await food_Authservice.addToCart(
  //       dishId: widget.dish.dishId,
  //       quantity: quantity,
  //       sheduleorder: sheduleorder,
  //       addons: addons,
  //     );
  //
  //     // if (success) {
  //     //   CartNotifier.count.value += quantity;
  //     //   await _loadQuantity();
  //     // }
  //     if (success) {
  //       await _loadQuantity();
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       AppAlert.error(context, e.toString().replaceFirst('Exception: ', ''));
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _isAddingToCart = false;
  //       });
  //     }
  //   }
  // }
  Future<bool> _addToCart(int quantity, {bool sheduleorder = false}) async {
    if (_isAddingToCart) {
      return false;
    }

    setState(() {
      _isAddingToCart = true;
    });

    try {
      final addons = widget.selectedAddons.entries
          .where((entry) => entry.value > 0)
          .map((entry) => {"addonId": entry.key, "quantity": entry.value})
          .toList();

      debugPrint("====================================");
      debugPrint("ADD CART");
      debugPrint("Dish ID: ${widget.dish.dishId}");
      debugPrint("Quantity: $quantity");
      debugPrint("Schedule: $sheduleorder");
      debugPrint("Addons: $addons");
      debugPrint("====================================");

      final success = await food_Authservice.addToCart(
        dishId: widget.dish.dishId,
        quantity: quantity,
        sheduleorder: sheduleorder,
        addons: addons,
      );

      if (success) {
        await _loadQuantity();

        CartMode.type.value = CartType.normal;

        debugPrint("ADD CART SUCCESS");

        return true;
      }

      debugPrint("ADD CART FAILED");

      return false;
    } catch (e) {
      debugPrint("ADD CART ERROR: $e");

      if (mounted) {
        AppAlert.error(context, e.toString().replaceFirst('Exception: ', ''));
      }

      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  // Future<void> _removeFromCart() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final itemId = prefs.getInt("dish_${widget.dish.dishId}_itemId");
  //
  //   if (itemId == null) return;
  //
  //   CartNotifier.count.value -= itemCount;
  //
  //   final removed = await food_Authservice.removeCartItem(itemId);
  //
  //   if (removed) {
  //     prefs.remove("dish_${widget.dish.dishId}_quantity");
  //     prefs.remove("dish_${widget.dish.dishId}_itemId");
  //
  //     setState(() => itemCount = 0);
  //   }
  // }
  Future<void> _removeFromCart() async {
    final prefs = await SharedPreferences.getInstance();

    final itemId = prefs.getInt("dish_${widget.dish.dishId}_itemId");

    if (itemId == null) return;

    try {
      final removed = await food_Authservice.removeCartItem(itemId);

      if (removed) {
        await prefs.remove("dish_${widget.dish.dishId}_quantity");

        await prefs.remove("dish_${widget.dish.dishId}_itemId");

        if (mounted) {
          setState(() {
            itemCount = 0;
          });
        }

        // 🔥 Tell both scenarios
        CartNotifier.updateDishQuantity(widget.dish.dishId, 0);

        await Utils.refreshCartCount();
      }
    } catch (e) {
      if (mounted) {
        AppAlert.error(context, e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  // Future<void> _updateQuantity(int newQty) async {
  //   final prefs = await SharedPreferences.getInstance();
  //
  //   final itemId = prefs.getInt("dish_${widget.dish.dishId}_itemId");
  //
  //   if (itemId == null) {
  //     return;
  //   }
  //
  //   CartNotifier.count.value = CartNotifier.count.value - itemCount + newQty;
  //
  //   await food_Authservice.updateCartQuantity(itemId, newQty);
  //
  //   prefs.setInt("dish_${widget.dish.dishId}_quantity", newQty);
  // }

  Future<void> _updateQuantity(int newQty) async {
    final prefs = await SharedPreferences.getInstance();

    final itemId = prefs.getInt("dish_${widget.dish.dishId}_itemId");

    if (itemId == null) {
      return;
    }

    try {
      await food_Authservice.updateCartQuantity(itemId, newQty);

      await prefs.setInt("dish_${widget.dish.dishId}_quantity", newQty);

      if (mounted) {
        setState(() {
          itemCount = newQty;
        });
      }

      // 🔥 Synchronize both scenarios
      CartNotifier.updateDishQuantity(widget.dish.dishId, newQty);

      await Utils.refreshCartCount();
    } catch (e) {
      if (mounted) {
        AppAlert.error(context, e.toString().replaceFirst('Exception: ', ''));
      }

      // Reload server value if update failed
      await _loadQuantity();
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

  //   Widget build(BuildContext context) {
  //     return SizedBox(
  //       width: 120.w,
  //       height: 39.h,
  //       child: itemCount == 0
  //           ? ElevatedButton(
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: AppColors.primary,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(10.r),
  //                   side: BorderSide(
  //                     color: AppColors.of(context).primary,
  //                     width: 1.w,
  //                   ),
  //                 ),
  //                 padding: EdgeInsets.symmetric(horizontal: 10.w),
  //               ),
  //
  //               onPressed: () async {
  //                 final allowed = await _checkLogin(context);
  //                 if (!allowed) return;
  //
  //                 final schedule = widget.dish.balanceQuantity <= 0;
  //
  //                 await _addToCart(1, sheduleorder: schedule);
  //
  //                 CartMode.type.value = CartType.normal;
  //               },
  //
  //               child: _isAddingToCart
  //                   ? SizedBox(
  //                       width: 18,
  //                       height: 18,
  //                       child: CircularProgressIndicator(
  //                         strokeWidth: 2,
  //                         color: Colors.white,
  //                       ),
  //                     )
  //                   : Text(
  //                       widget.dish.balanceQuantity <= 0
  //                           ? "Schedule"
  //                           : "Add Cart",
  //                       style: TextStyle(
  //                         fontSize: 14.sp,
  //                         fontWeight: FontWeight.w600,
  //                         color: TextColors.whiteText, // 👈 NEVER greyed out
  //                       ),
  //                     ),
  //             )
  //           : Container(
  //               decoration: BoxDecoration(
  //                 color: AppColors.primary.withOpacity(0.9),
  //                 borderRadius: BorderRadius.circular(10.r),
  //                 border: Border.all(
  //                   color: AppColors.of(context).primary,
  //                   width: 1.w,
  //                 ),
  //               ),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                 children: [
  //                   /// ➖ Minus
  //                   IconButton(
  //                     icon: Icon(Icons.remove, size: 14.sp, color: Colors.white),
  //                     onPressed: () async {
  //                       if (itemCount > 1) {
  //                         setState(() => itemCount--);
  //                         await _updateQuantity(itemCount);
  //                       } else {
  //                         await _removeFromCart();
  //                         setState(() => itemCount = 0);
  //                       }
  //                     },
  //                   ),
  //
  //                   Text(
  //                     "$itemCount",
  //                     style: TextStyle(
  //                       fontSize: 12.sp,
  //                       fontWeight: FontWeight.bold,
  //                       color: Colors.white,
  //                     ),
  //                   ),
  //
  //                   /// ➕ Plus (WITH VALIDATION)
  //                   GestureDetector(
  //                     onTap: itemCount >= widget.dish.balanceQuantity
  //                         ? () {
  //                             AppAlert.error(
  //                               context,
  //                               "📅 Item is out of stock. You can schedule it.",
  //                             );
  //                           }
  //                         : null,
  //                     child: IconButton(
  //                       icon: Icon(Icons.add, size: 14.sp, color: Colors.white),
  //
  //                       onPressed: () async {
  //                         final allowed = await _checkLogin(context);
  //                         if (!allowed) return;
  //
  //                         setState(() => itemCount++);
  //                         await _updateQuantity(itemCount);
  //                       },
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //     );
  //   }
  // }
  Widget _buildAddCartButton() {
    return SizedBox(
      width: 105.w,
      height: 39.h,
      child: ElevatedButton(
        onPressed: _isAddingToCart
            ? null
            : () async {
                final allowed = await _checkLogin(context);
                final schedule = widget.dish.balanceQuantity <= 0;

                if (!allowed) return;

                final success = await _addToCart(1, sheduleorder: schedule);

                if (!success) return;

                if (!mounted) return;

                Navigator.of(context).pop();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 8.w),
        ),
        child: _isAddingToCart
            ? SizedBox(
                width: 18.w,
                height: 18.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                "Add Item ₹${totalPrice.toStringAsFixed(0)}",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: TextColors.whiteText,
                ),
              ),
      ),
    );
  }

  Widget _buildQuantityButton() {
    final bool alreadyInCart =
        CartNotifier.getDishQuantity(widget.dish.dishId) > 0;

    return Container(
      width: 105.w,
      height: 39.h,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.of(context).primary, width: 1.w),
      ),
      child: alreadyInCart
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(Icons.remove, size: 15.sp, color: Colors.white),
                  onPressed: _isUpdatingQuantity
                      ? null
                      : () async {
                          final allowed = await _checkLogin(context);

                          if (!allowed) {
                            return;
                          }

                          if (itemCount > 1) {
                            await _updateQuantity(itemCount - 1);
                          } else {
                            await _removeFromCart();
                          }
                        },
                ),

                Text(
                  "$itemCount",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                // -----------------------------------------------
                // PLUS
                // -----------------------------------------------
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(Icons.add, size: 15.sp, color: Colors.white),
                  onPressed: _isUpdatingQuantity
                      ? null
                      : () async {
                          final allowed = await _checkLogin(context);

                          if (!allowed) {
                            return;
                          }

                          if (itemCount >= widget.dish.balanceQuantity) {
                            AppAlert.error(
                              context,
                              "Item is out of stock. You can schedule it.",
                            );
                            return;
                          }

                          await _updateQuantity(itemCount + 1);
                        },
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(width: 25),

                Text(
                  "$itemCount",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(Icons.add, size: 15.sp, color: Colors.white),
                  onPressed: () {
                    if (itemCount >= widget.dish.balanceQuantity) {
                      AppAlert.error(
                        context,
                        "Item is out of stock. You can schedule it.",
                      );
                      return;
                    }

                    setState(() {
                      itemCount++;
                    });
                  },
                ),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_buildQuantityButton(), _buildAddCartButton()],
    );
  }
}
