import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Models/food/tablecartmodel.dart';
import '../../../Services/Auth_service/food_authservice.dart';
import '../../../screens/Food&beverages/tablecart.dart';
import '../../../utils/utils.dart';
import 'cartmode.dart';

import 'package:maamaas/Services/App_color_service/app_colours.dart';

class TableCartButton extends StatefulWidget {
  final int dishId;
  final int id;
  final int balanceQuantity;

  const TableCartButton({
    super.key,
    required this.dishId,
    required this.id,
    required this.balanceQuantity,
  });

  @override
  // ignore: library_private_types_in_public_api
  _TableCartButtonState createState() => _TableCartButtonState();
}

class _TableCartButtonState extends State<TableCartButton> {
  int itemCount = 0;

  @override
  void initState() {
    super.initState();
    _loadQuantity();
  }

  // ✔ Load previous table-cart quantity (same as normal cart logic)
  Future<void> _loadQuantity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int? seatingId = prefs.getInt('id');

      if (seatingId == null) {
        setState(() => itemCount = 0);
        return;
      }

      // fetchTableCart returns List<TaleCartModel>
      final List<TaleCartModel> cartList = await food_Authservice
          .fetchTableCart(seatingId);

      if (cartList.isEmpty) {
        setState(() => itemCount = 0);
        return;
      }

      // take the FIRST cart model
      final TaleCartModel cart = cartList.first;

      // now this works because cart is a TaleCartModel
      final matchedItems = cart.cartItems
          .where((item) => item.dishId == widget.dishId)
          .toList();

      if (matchedItems.isNotEmpty) {
        final matchedItem = matchedItems.first;

        setState(() => itemCount = matchedItem.quantity);

        // store itemId locally
        prefs.setInt("table_dish_${widget.dishId}_itemId", matchedItem.itemId);
        prefs.setInt(
          "table_dish_${widget.dishId}_quantity",
          matchedItem.quantity,
        );
      } else {
        setState(() => itemCount = 0);
      }
    } catch (e) {
      // debugPrint("❌ Table cart load error: $e");
      setState(() => itemCount = 0);
    }
  }

  // ✔ Add to Table Cart (same logic as normal cart)
  Future<void> _handleAddToCart(int qty) async {
    final prefs = await SharedPreferences.getInstance();
    int? seatingId = prefs.getInt('id');

    if (seatingId == null) {
      // ignore: use_build_context_synchronously
      AppAlert.error(context, "Please mark your arrival first");
      return;
    }

    final added = await food_Authservice.addToTableCart(
      dishId: widget.dishId,
      quantity: qty,
      seatingId: seatingId,
    );

    if (added) {
      final itemId = await food_Authservice.getTableItemIdByDishId(
        widget.dishId,
        seatingId,
      );

      if (itemId != null) {
        prefs.setInt("table_dish_${widget.dishId}_itemId", itemId);
        prefs.setInt("table_dish_${widget.dishId}_quantity", qty);
      }
    }
  }

  // ✔ Remove item (same as cart button)
  Future<void> _handleRemoveItem() async {
    final prefs = await SharedPreferences.getInstance();
    final itemId = prefs.getInt("table_dish_${widget.dishId}_itemId");

    if (itemId == null) return;

    bool removed = await food_Authservice.removeCartItem(itemId);

    if (removed) {
      prefs.remove("table_dish_${widget.dishId}_itemId");
      prefs.remove("table_dish_${widget.dishId}_quantity");

      setState(() => itemCount = 0);
      Utils.itemCount.value = 0;
    }
  }

  // Future<void> _goToCart() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   int? seatingId = prefs.getInt('id');
  //
  //   Navigator.push(
  //     // ignore: use_build_context_synchronously
  //     context,
  //     MaterialPageRoute(builder: (_) => tablecart(seatingId: seatingId!)),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120.w,
      height: 39.h,
      child: itemCount == 0
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(
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
                setState(() => itemCount = 1);
                CartMode.type.value = CartType.table;

                await _handleAddToCart(1);

                // ignore: use_build_context_synchronously
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(
                //     content: const Text("1 item added to cart"),
                //     duration: const Duration(seconds: 2),
                //     backgroundColor: Colors.green,
                //     behavior: SnackBarBehavior.floating,
                //     margin: EdgeInsets.only(
                //       bottom: 10.h,
                //       left: 16.w,
                //       right: 16.w,
                //     ),
                //     action: SnackBarAction(
                //       label: "Go to Cart",
                //       textColor: Colors.white,
                //       onPressed: _goToCart,
                //     ),
                //   ),
                // );
              },
              child: Text(
                "Add Cart",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
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
                  IconButton(
                    icon: Icon(Icons.remove, size: 14.sp),
                    onPressed: () async {
                      if (itemCount > 1) {
                        setState(() => itemCount--);

                        final prefs = await SharedPreferences.getInstance();
                        final itemId = prefs.getInt(
                          "table_dish_${widget.dishId}_itemId",
                        );

                        if (itemId != null) {
                          await food_Authservice.updateCartItemQuantity(
                            itemId: itemId,
                            quantity: itemCount,
                          );
                        }
                      } else {
                        await _handleRemoveItem();
                      }
                    },
                    padding: EdgeInsets.zero,
                  ),
                  Text(
                    "$itemCount",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, size: 14.sp),
                    onPressed: () async {
                      setState(() => itemCount++);

                      final prefs = await SharedPreferences.getInstance();
                      final itemId = prefs.getInt(
                        "table_dish_${widget.dishId}_itemId",
                      );

                      if (itemId != null) {
                        await food_Authservice.updateCartItemQuantity(
                          itemId: itemId,
                          quantity: itemCount,
                        );
                      }

                      // ignore: use_build_context_synchronously
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(
                      //     content: Text("$itemCount item(s) in cart"),
                      //     backgroundColor: Colors.green,
                      //     behavior: SnackBarBehavior.floating,
                      //     action: SnackBarAction(
                      //       label: "Go to Cart",
                      //       textColor: Colors.white,
                      //       onPressed: _goToCart,
                      //     ),
                      //   ),
                      // );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
