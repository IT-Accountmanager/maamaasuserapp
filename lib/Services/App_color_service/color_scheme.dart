import 'package:flutter/material.dart';

class AppColorScheme {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color success;
  final Color error;
  final Color warning;
  final Color info;
  final Color divider;
  final Color border;

  const AppColorScheme({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
    required this.divider,
    required this.border,
  });

  Color get primaryLight => Color.lerp(primary, Colors.white, 0.35)!;
  Color get primaryDark => Color.lerp(primary, Colors.black, 0.25)!;

  LinearGradient get splashGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primary,
      primaryDark,
      Color.lerp(primaryDark, Colors.black, 0.35)!,
    ],
    stops: const [0.0, 0.55, 1.0],
  );

  AppColorScheme copyWith({Color? primary, Color? secondary, Color? accent}) =>
      AppColorScheme(
        primary: primary ?? this.primary,
        secondary: secondary ?? this.secondary,
        accent: accent ?? this.accent,
        background: background,
        surface: surface,
        success: success,
        error: error,
        warning: warning,
        info: info,
        divider: divider,
        border: border,
      );
}
