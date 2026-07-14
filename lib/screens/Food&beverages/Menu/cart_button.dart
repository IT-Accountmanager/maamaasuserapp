import 'dart:convert';

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

class CartButton extends StatefulWidget {
  final Dish dish;
  // final int dishId;
  final double? savedAmount;
  // final int balanceQuantity;
  final bool? sheduleorder;

  const CartButton({
    super.key,
    required this.dish,
    // required this.dishId,
    this.savedAmount,
    // required this.balanceQuantity,
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

  // Future<void> _addToCart(int quantity, {bool sheduleorder = false}) async {
  //   CartNotifier.count.value += quantity;
  //
  //   await food_Authservice.addToCart(
  //     dishId: widget.dish.dishId,
  //     quantity: quantity,
  //     sheduleorder: sheduleorder,
  //   );
  //
  //   debugPrint("✅ AddToCart finished");
  //   // final itemId = await food_Authservice.getItemIdByDishId(widget.dish.dishId);
  //   //
  //   // if (itemId != null) {
  //   //   final prefs = await SharedPreferences.getInstance();
  //   //   await prefs.setInt("dish_${widget.dish.dishId}_itemId", itemId);
  //   //   await prefs.setInt("dish_${widget.dish.dishId}_quantity", quantity);
  //   // }
  //   final itemId = await food_Authservice.getItemIdByDishId(widget.dish.dishId);
  //
  //   debugPrint("Fetched ItemId after Add: $itemId");
  //
  //   debugPrint("Calling getItemIdByDishId...");
  //
  //   final prefs = await SharedPreferences.getInstance();
  //
  //   if (itemId != null) {
  //     await prefs.setInt("dish_${widget.dish.dishId}_itemId", itemId);
  //     debugPrint("Returned ItemId = $itemId");
  //
  //     debugPrint(
  //       "Saved ItemId: ${prefs.getInt("dish_${widget.dish.dishId}_itemId")}",
  //     );
  //   }
  // }
  Future<void> _addToCart(int quantity, {bool sheduleorder = false}) async {
    CartNotifier.count.value += quantity;

    await food_Authservice.addToCart(
      dishId: widget.dish.dishId,
      quantity: quantity,
      sheduleorder: sheduleorder,
    );

    await _loadQuantity();
  }

  Future<void> _removeFromCart() async {
    final prefs = await SharedPreferences.getInstance();
    final itemId = prefs.getInt("dish_${widget.dish.dishId}_itemId");

    if (itemId == null) return;

    // INSTANT SUBTRACT FROM CART BADGE
    CartNotifier.count.value -= itemCount;

    final removed = await food_Authservice.removeCartItem(itemId);

    if (removed) {
      prefs.remove("dish_${widget.dish.dishId}_quantity");
      prefs.remove("dish_${widget.dish.dishId}_itemId");

      setState(() => itemCount = 0);
    }
  }

  Future<void> _updateQuantity(int newQty) async {
    debugPrint("========== UPDATE CART START ==========");

    final prefs = await SharedPreferences.getInstance();

    final itemId = prefs.getInt("dish_${widget.dish.dishId}_itemId");

    debugPrint("Dish Id      : ${widget.dish.dishId}");
    debugPrint("Item Id      : $itemId");
    debugPrint("Old Qty(UI)  : $itemCount");
    debugPrint("New Qty      : $newQty");

    if (itemId == null) {
      debugPrint("❌ ItemId is NULL");
      return;
    }

    CartNotifier.count.value = CartNotifier.count.value - itemCount + newQty;

    debugPrint("Calling updateCartQuantity...");

    final success = await food_Authservice.updateCartQuantity(itemId, newQty);

    debugPrint("API Success : $success");

    prefs.setInt("dish_${widget.dish.dishId}_quantity", newQty);

    debugPrint(
      "Saved Qty in Prefs : ${prefs.getInt("dish_${widget.dish.dishId}_quantity")}",
    );

    debugPrint("========== UPDATE CART END ==========");
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

  void _showAddonBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddonBottomSheet(
        dish: widget.dish,
        // onAdd: (addons) async {
        //   Navigator.pop(context);
        //
        //   setState(() => itemCount = 1);
        //
        //   // await food_Authservice.addToCart(
        //   //   dishId: widget.dish.dishId,
        //   //   quantity: 1,
        //   //   addons: addons,
        //   //   sheduleorder: sheduleorder,
        //   // );
        //   await food_Authservice.addToCart(
        //     dishId: widget.dish.dishId,
        //     quantity: 1,
        //     sheduleorder: false,
        //     addons: addons,
        //   );
        // },
        // onAdd: (addons, quantity) async {
        //   Navigator.pop(context);
        //
        //   setState(() => itemCount = quantity);
        //
        //   await food_Authservice.addToCart(
        //     dishId: widget.dish.dishId,
        //     quantity: quantity,
        //     sheduleorder: false,
        //     addons: addons,
        //   );
        // },
        onAdd: (addons, quantity) async {
          Navigator.pop(context);

          setState(() => itemCount = quantity);

          await food_Authservice.addToCart(
            dishId: widget.dish.dishId,
            quantity: quantity,
            sheduleorder: false,
            addons: addons,
          );

          await _loadQuantity();
        },
      ),
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

                // setState(() => itemCount = 1);
                // await _addToCart(1, sheduleorder: schedule);
                if (widget.dish.addons.isEmpty) {
                  setState(() => itemCount = 1);

                  await _addToCart(1, sheduleorder: schedule);
                } else {
                  _showAddonBottomSheet();
                }
                CartMode.type.value = CartType.normal;
              },

              child: Text(
                widget.dish.balanceQuantity <= 0 ? "Schedule" : "Add Cart",
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
                      color: Colors.white
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
                      icon: Icon(
                        Icons.add,
                        size: 14.sp,
                        color:
                            // itemCount >= widget.balanceQuantity
                            //     ? Colors.grey
                            //     :
                            Colors.white,
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

class AddonBottomSheet extends StatefulWidget {
  final Dish dish;

  final Function(List<Map<String, dynamic>> addons, int quantity) onAdd;

  const AddonBottomSheet({super.key, required this.dish, required this.onAdd});

  @override
  State<AddonBottomSheet> createState() => _AddonBottomSheetState();
}

class _AddonBottomSheetState extends State<AddonBottomSheet> {
  final Set<int> selected = {};
  Map<int, int> addonQty = {};

  int quantity = 1;

  double get dishPrice => widget.dish.effectivePrice ?? widget.dish.price ?? 0;

  // double get addonTotal {
  //   double total = 0;
  //
  //   for (final addon in widget.dish.addons) {
  //     if (selected.contains(addon.addonId)) {
  //       total += addon.addonPrice;
  //     }
  //   }
  //
  //   return total;
  // }
  double get addonTotal {
    double total = 0;

    addonQty.forEach((id, qty) {
      final addon = widget.dish.addons.firstWhere((e) => e.addonId == id);

      total += addon.addonPrice * qty;
    });

    return total;
  }

  double get totalPrice => ((dishPrice * quantity) + addonTotal);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .70,

        child: Column(
          children: [
            const SizedBox(height: 10),

            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    widget.dish.dishName ?? "",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    widget.dish.description ?? "",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "Select Addons",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),

            // Expanded(
            //   child: ListView.builder(
            //     itemCount: widget.dish.addons.length,
            //
            //     itemBuilder: (_, index) {
            //       final addon = widget.dish.addons[index];
            //
            //       return CheckboxListTile(
            //         value: selected.contains(addon.addonId),
            //
            //         title: Text(addon.addonName),
            //
            //         subtitle: Text("₹${addon.addonPrice.toStringAsFixed(0)}"),
            //
            //         onChanged: (value) {
            //           setState(() {
            //             if (value == true) {
            //               selected.add(addon.addonId);
            //             } else {
            //               selected.remove(addon.addonId);
            //             }
            //           });
            //         },
            //       );
            //     },
            //   ),
            // ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.dish.addons.length,
                itemBuilder: (context, index) {
                  final addon = widget.dish.addons[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                addon.addonName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              Text(
                                "₹${addon.addonPrice}",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),

                        _qtyButton(addon),
                      ],
                    ),
                  );
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black12)],
              ),

              child: SafeArea(
                top: false,

                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),

                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),

                            onPressed: () {
                              if (quantity > 1) {
                                setState(() {
                                  quantity--;
                                });
                              }
                            },
                          ),

                          Text(
                            "$quantity",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          IconButton(
                            icon: const Icon(Icons.add),

                            onPressed: () {
                              setState(() {
                                quantity++;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: SizedBox(
                        height: 50,

                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppColors.primary,
                          ),
                          onPressed: () {
                            final addons = addonQty.entries.map((e) {
                              return {"addonId": e.key, "quantity": e.value};
                            }).toList();

                            debugPrint("Addon Qty Map: $addonQty");
                            debugPrint("Addons Payload: ${jsonEncode(addons)}");

                            widget.onAdd(addons, quantity);
                          },

                          child: Text(
                            "Add Item ₹${totalPrice.toStringAsFixed(0)}",
                          ),
                        ),
                      ),
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

  Widget _qtyButton(Addon addon) {
    final qty = addonQty[addon.addonId] ?? 0;

    if (qty == 0) {
      return SizedBox(
        width: 80,
        height: 34,
        child: OutlinedButton(
          onPressed: () {
            setState(() {
              addonQty[addon.addonId] = 1;
            });
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary, width: 1.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.zero,
          ),
          child: const Text(
            "ADD",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      );
    }

    return Container(
      width: 90,
      height: 34,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  if (qty == 1) {
                    addonQty.remove(addon.addonId);
                  } else {
                    addonQty[addon.addonId] = qty - 1;
                  }
                });
              },
              child: const Center(child: Icon(Icons.remove, size: 18)),
            ),
          ),

          // Container(width: 1, color: Colors.grey.shade300),
          Expanded(
            child: Center(
              child: Text(
                "$qty",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          // Container(width: 1, color: Colors.grey.shade300),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  addonQty[addon.addonId] = qty + 1;
                });
              },
              child: const Center(child: Icon(Icons.add, size: 18)),
            ),
          ),
        ],
      ),
    );
  }
}

// class AddonBottomSheet extends StatefulWidget {
//   final Dish dish;
//
//   // final Function(List<Map<String, dynamic>>) onAdd;
//   final Function(List<Map<String, dynamic>> addons, int quantity) onAdd;
//
//   const AddonBottomSheet({super.key, required this.dish, required this.onAdd});
//
//   @override
//   State<AddonBottomSheet> createState() => _AddonBottomSheetState();
// }
//
// class _AddonBottomSheetState extends State<AddonBottomSheet> {
//   final Set<int> selected = {};
//   int quantity = 1;
//
//   double get totalPrice {
//     double addonPrice = 0;
//
//     for (final addon in widget.dish.addons) {
//       if (selected.contains(addon.addonId)) {
//         addonPrice += addon.addonPrice;
//       }
//     }
//
//     return (widget.dish.effectivePrice ?? widget.dish.price ?? 0 + addonPrice) *
//         quantity;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//
//         children: [
//           Text(
//             "Select Addons",
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//
//           Text("${widget.dish.description}", style: TextStyle(fontSize: 14)),
//
//           const SizedBox(height: 16),
//
//           ...widget.dish.addons.map((addon) {
//             return CheckboxListTile(
//               value: selected.contains(addon.addonId),
//
//               title: Text(addon.addonName),
//
//               subtitle: Text("₹${addon.addonPrice}"),
//
//               onChanged: (v) {
//                 setState(() {
//                   if (v == true) {
//                     selected.add(addon.addonId);
//                   } else {
//                     selected.remove(addon.addonId);
//                   }
//                 });
//               },
//             );
//           }),
//
//           Expanded(
//             child: ElevatedButton(
//               onPressed: () {
//                 final addons = selected.map((id) {
//                   return {"addonId": id, "quantity": 1};
//                 }).toList();
//
//                 widget.onAdd(addons, quantity);
//               },
//
//               child: Text("Add Item ₹${totalPrice.toStringAsFixed(0)}"),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
