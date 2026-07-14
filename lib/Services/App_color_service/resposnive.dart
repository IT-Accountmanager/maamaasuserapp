import 'package:flutter/cupertino.dart';

class Radiusc {
  static bool isPhone(BuildContext ctx) => MediaQuery.of(ctx).size.width < 600;
  static bool isTablet(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width >= 600 &&
          MediaQuery.of(ctx).size.width < 900;
  static bool isDesktop(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width >= 900;

  static int crossAxis(BuildContext ctx) {
    final w = MediaQuery.of(ctx).size.width;
    if (w < 480) return 2;
    if (w < 700) return 3;
    if (w < 1000) return 4;
    return 5;
  }

  static double cardExtent(BuildContext ctx, {required bool showCart}) {
    final w = MediaQuery.of(ctx).size.width;
    final base = showCart ? 280.0 : 240.0;
    if (w >= 700) return base + 20;
    return base;
  }
}