import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../Models/food/cart_model.dart';

class CartNotifier {
  static ValueNotifier<int> count = ValueNotifier(0);

  static void update(int newCount) {
    count.value = newCount < 0 ? 0 : newCount;
  }
}

class websocketCartNotifier extends StateNotifier<CartModel?> {
  websocketCartNotifier() : super(null);

  void updateCart(CartModel newCart) {
    state = newCart;

    // ✅ Always sync CartNotifier.count whenever cart state changes
    final totalItems =
        newCart.cartItems?.fold<int>(
          0,
          (sum, item) => sum + (item.quantity),
        ) ??
        0;

    CartNotifier.update(totalItems);
  }

  // ✅ Call this when cart is fully cleared
  void clearCart() {
    state = null;
    CartNotifier.update(0);
  }
}

final cartProvider = StateNotifierProvider<websocketCartNotifier, CartModel?>((
  ref,
) {
  return websocketCartNotifier();
});












// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../Models/food/cart_model.dart';
//
// class CartNotifier extends StateNotifier<CartModel?> {
//   CartNotifier() : super(null);
//
//   bool _hasSocketUpdate = false;
//
//   int get totalItems {
//     return state?.cartItems?.fold<int>(
//       0,
//           (sum, item) => sum + (item.quantity ?? 0),
//     ) ??
//         0;
//   }
//
//   // 🔥 Socket = highest priority
//   void updateFromSocket(CartModel newCart) {
//     _hasSocketUpdate = true;
//     state = newCart;
//   }
//
//   // ⚠️ HTTP fallback only
//   void updateFromHttp(CartModel newCart) {
//     if (_hasSocketUpdate) return;
//     state = newCart;
//   }
//
//   void clearCart() {
//     _hasSocketUpdate = false;
//     state = null;
//   }
// }
//
// final cartProvider =
// StateNotifierProvider<CartNotifier, CartModel?>(
//       (ref) => CartNotifier(),
// );