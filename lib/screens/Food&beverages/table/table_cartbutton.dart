import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Models/food/tablecartmodel.dart';
import '../../../Services/App_color_service/app_colours.dart';
import '../../../Services/Auth_service/food_authservice.dart';
import '../../../widgets/widgets/food/cartmode.dart';
import '../../../widgets/widgets/food/currentcart_notifier.dart';

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadQuantity();
    // Re-sync whenever global cart count changes (e.g. after cart clear)
    CartNotifier.count.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    CartNotifier.count.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    // If cart is empty, reset immediately without a network call
    if (CartNotifier.count.value == 0) {
      if (mounted) setState(() => itemCount = 0);
    } else {
      // Cart changed but not empty — re-sync this dish's quantity
      _loadQuantity();
    }
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
      final List<TableCartModel> cartList = await food_Authservice
          .fetchTableCart();

      if (cartList.isEmpty) {
        setState(() => itemCount = 0);
        return;
      }

      // take the FIRST cart model
      final TableCartModel cart = cartList.first;

      // now this works because cart is a TaleCartModel
      // final matchedItems = cart.cartItems
      //     .where((item) => item.dishId == widget.dishId)
      //     .toList();
      final matchedItems = cart.cartItems
          .where(
            (item) => item.dishId == widget.dishId && item.orderStatus == null,
          )
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

  Future<void> _handleAddToCart(int qty) async {
    final prefs = await SharedPreferences.getInstance();
    int? seatingId = prefs.getInt('id');

    if (seatingId == null) {
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

      // ✅ IMPORTANT: update global cart count
      final cartList = await food_Authservice.fetchTableCart();
      if (cartList.isNotEmpty) {
        CartNotifier.count.value = cartList.first.cartItems.length;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120.w,
      height: 39.h,

      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: itemCount == 0
              ? AppColors.of(context).primary
              : Colors.green,

          disabledBackgroundColor: Colors.green,
          disabledForegroundColor: Colors.white,

          padding: EdgeInsets.symmetric(horizontal: 10.w),
        ),
        onPressed: _isLoading || itemCount > 0
            ? null
            : () async {
                setState(() => _isLoading = true);

                try {
                  CartMode.type.value = CartType.table;

                  await _handleAddToCart(1);

                  setState(() => itemCount = 1);
                } catch (e) {
                  AppAlert.error(context, "Failed to add item");
                } finally {
                  if (mounted) {
                    setState(() => _isLoading = false);
                  }
                }
              },
        child: _isLoading
            ? SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                itemCount == 0 ? "Add Cart" : "Added to Cart",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
