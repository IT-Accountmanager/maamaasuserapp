import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../Models/food/cart_model.dart';

// class CartNotifier {
//   static ValueNotifier<int> count = ValueNotifier(0);
//
//   static void update(int newCount) {
//     count.value = newCount < 0 ? 0 : newCount;
//   }
// }


class CartNotifier {
  static final ValueNotifier<int> count = ValueNotifier<int>(0);

  // dishId -> quantity
  static final ValueNotifier<Map<int, int>> quantities =
  ValueNotifier<Map<int, int>>({});

  static void updateDishQuantity(int dishId, int quantity) {
    final updated = Map<int, int>.from(quantities.value);

    if (quantity <= 0) {
      updated.remove(dishId);
    } else {
      updated[dishId] = quantity;
    }

    quantities.value = updated;
  }

  static int getDishQuantity(int dishId) {
    return quantities.value[dishId] ?? 0;
  }
  static void update(int newCount) {
    count.value = newCount < 0 ? 0 : newCount;
  }
}



class websocketCartNotifier extends StateNotifier<CartModel?> {
  websocketCartNotifier() : super(null);

  void updateCart(CartModel newCart) {
    state = newCart;

    final totalItems =
        newCart.cartItems?.fold<int>(0, (sum, item) => sum + (item.quantity)) ??
        0;

    CartNotifier.update(totalItems);
    //
    //     debugPrint("🛒 CART UPDATED: $totalItems");
  }

  void clearCart() {
    state = null;

    CartNotifier.update(0);
    //
    //     debugPrint("🛒 CART CLEARED");
  }
}

final cartProvider = StateNotifierProvider<websocketCartNotifier, CartModel?>((
  ref,
) {
  return websocketCartNotifier();
});
