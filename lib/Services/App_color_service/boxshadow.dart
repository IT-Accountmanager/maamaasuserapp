import 'package:flutter/material.dart';

import 'app_colours.dart';

class boxshadow {
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      // ignore: deprecated_member_use
      color: Colors.black.withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      // ignore: deprecated_member_use
      color: Colors.black.withOpacity(0.03),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> floatShadow = [
    BoxShadow(
      color: AppColors.green.withOpacity(0.3),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}
