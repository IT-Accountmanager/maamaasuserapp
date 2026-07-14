import 'dart:ui';

import 'color_scheme.dart';

class AppPalettes {
  static final orange = AppColorScheme(
    primary: Color(0xFFE65100),
    secondary: Color(0xFF1976D2),
    accent: Color(0xFFFFC107),
    background: Color(0xFFF5F5F5),
    surface: Color(0xFFFFFFFF),
    success: Color(0xFF2E7D32),
    error: Color(0xFFD32F2F),
    warning: Color(0xFFF9A825),
    info: Color(0xFF0288D1),
    divider: Color(0xFFE0E0E0),
    border: Color(0xFFBDBDBD),
  );

  static final List<({String name, AppColorScheme scheme})> all = [
    (name: 'Orange', scheme: orange),
  ];
}
