import 'package:flutter/cupertino.dart';

class CartNotifier {
  static ValueNotifier<int> count = ValueNotifier(0);

  static void update(int newCount) {
    count.value = newCount < 0 ? 0 : newCount;
  }
}