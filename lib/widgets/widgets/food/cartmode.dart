import 'package:flutter/cupertino.dart';

enum CartType { normal, table }

class CartMode {
  static final ValueNotifier<CartType> type =
  ValueNotifier<CartType>(CartType.normal);
}