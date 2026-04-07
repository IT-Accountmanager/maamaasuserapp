import '../widgets/widgets/food/currentcart_notifier.dart';
import '../Services/Auth_service/food_authservice.dart';
import 'package:flutter/cupertino.dart';

class Utils {
  static String? selectedOrderType;
  // static var cartItems = []; // ✅ Initialized with an empty list.
  static bool isOrderNowClicked = false;
  // static ValueNotifier<int> itemCount = ValueNotifier<int>(0);
  static double appliedDiscount = 0.0;
  static ValueNotifier<int> itemCount = ValueNotifier<int>(0);

  static Future<void> refreshCartCount() async {
    final count = await food_Authservice.fetchCartCount();
    CartNotifier.count.value = count < 0 ? 0 : count; // safety
  }
}
