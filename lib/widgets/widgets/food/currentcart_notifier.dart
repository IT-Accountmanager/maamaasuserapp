import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../Models/food/cart_model.dart';

class CartNotifier {
  static ValueNotifier<int> count = ValueNotifier(0);

  static void update(int newCount) {
    count.value = newCount < 0 ? 0 : newCount;
  }
}

// ignore: camel_case_types
// class websocketCartNotifier extends StateNotifier<CartModel?> {
//   websocketCartNotifier() : super(null);
//
//   void updateCart(CartModel newCart) {
//     state = newCart;
//
//     // ✅ Always sync CartNotifier.count whenever cart state changes
//     final totalItems =
//         newCart.cartItems?.fold<int>(0, (sum, item) => sum + (item.quantity)) ??
//         0;
//
//     CartNotifier.update(totalItems);
//   }
//
//   // ✅ Call this when cart is fully cleared
//   void clearCart() {
//     state = null;
//     CartNotifier.update(0);
//   }
// }
class websocketCartNotifier extends StateNotifier<CartModel?> {
  websocketCartNotifier() : super(null);

  void updateCart(CartModel newCart) {
    state = newCart;

    final totalItems =
        newCart.cartItems?.fold<int>(
          0,
          (sum, item) => sum + (item.quantity ?? 0),
        ) ??
        0;

    CartNotifier.update(totalItems);

    debugPrint("🛒 CART UPDATED: $totalItems");
  }

  void clearCart() {
    state = null;

    CartNotifier.update(0);

    debugPrint("🛒 CART CLEARED");
  }
}

final cartProvider = StateNotifierProvider<websocketCartNotifier, CartModel?>((
  ref,
) {
  return websocketCartNotifier();
});
