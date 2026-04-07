// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// class AppColors {
//   // Primary brand colors
//   static const Color primary   = Color(0xFFB15DC6);
//   static const Color secondary = Color(0xFF1976D2);
//   static const Color accent    = Color(0xFFFFC107);
//
//   // Background colors
//   static const Color background = Color(0xFFF5F5F5);
//   static const Color surface    = Color(0xFFFFFFFF);
//
//   // Status colors
//   static const Color success = Color(0xFF2E7D32);
//   static const Color error   = Color(0xFFD32F2F);
//   static const Color warning = Color(0xFFF9A825);
//   static const Color info    = Color(0xFF0288D1);
//
//   // Divider & border
//   static const Color divider = Color(0xFFE0E0E0);
//   static const Color border  = Color(0xFFBDBDBD);
//
//   // ── Splash gradient (used by SplashScreen) ──────────────────────────────────
//   static const LinearGradient splashGradient = LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [
//       Color(0xFFB15DC6), // primary purple
//       Color(0xFF7B2FBE), // deeper purple
//       Color(0xFF4A1080), // darkest anchor
//     ],
//     stops: [0.0, 0.55, 1.0],
//   );
// }
//
// class AppStyles {
//   static EdgeInsets get cardPadding    => EdgeInsets.all(16.w);
//   static EdgeInsets get sectionPadding => EdgeInsets.symmetric(vertical: 8.h);
//
//   static TextStyle get titleStyle => TextStyle(
//     fontSize: 18.sp,
//     fontWeight: FontWeight.bold,
//     color: Colors.black,
//   );
//
//   static TextStyle get subtitleStyle =>
//       TextStyle(fontSize: 14.sp, color: Colors.grey[600]);
// }
//
// // ── AppText — typography scale used across the app ───────────────────────────
// class AppText {
//   AppText._();
//
//   /// Large display — app name / hero headings
//   static TextStyle get display1 => TextStyle(
//     fontSize: 32.sp,
//     fontWeight: FontWeight.w800,
//     letterSpacing: 0.5,
//     height: 1.15,
//     color: Colors.black,
//   );
//
//   /// Section headings
//   static TextStyle get heading => TextStyle(
//     fontSize: 20.sp,
//     fontWeight: FontWeight.w700,
//     letterSpacing: 0.1,
//     height: 1.25,
//     color: Colors.black,
//   );
//
//   /// Sub-headings / card titles
//   static TextStyle get subheading => TextStyle(
//     fontSize: 16.sp,
//     fontWeight: FontWeight.w600,
//     height: 1.35,
//     color: Colors.black87,
//   );
//
//   /// Body copy
//   static TextStyle get body => TextStyle(
//     fontSize: 14.sp,
//     fontWeight: FontWeight.w400,
//     height: 1.5,
//     color: Colors.black87,
//   );
//
//   /// Small labels / captions
//   static TextStyle get caption => TextStyle(
//     fontSize: 11.sp,
//     fontWeight: FontWeight.w500,
//     letterSpacing: 0.2,
//     height: 1.4,
//     color: Colors.black54,
//   );
//
//   /// Bold label (buttons, tags)
//   static TextStyle get label => TextStyle(
//     fontSize: 12.sp,
//     fontWeight: FontWeight.w700,
//     letterSpacing: 0.3,
//     color: Colors.black87,
//   );
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppColorScheme — one object that holds the entire colour palette
// ─────────────────────────────────────────────────────────────────────────────

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

  /// Derived colours (computed from primary — no need to tweak separately)
  Color get primaryLight => Color.lerp(primary, Colors.white, 0.35)!;
  Color get primaryDark  => Color.lerp(primary, Colors.black, 0.25)!;

  LinearGradient get splashGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark, Color.lerp(primaryDark, Colors.black, 0.35)!],
    stops: const [0.0, 0.55, 1.0],
  );

  /// Create a copy with specific overrides
  AppColorScheme copyWith({Color? primary, Color? secondary, Color? accent}) =>
      AppColorScheme(
        primary:    primary    ?? this.primary,
        secondary:  secondary  ?? this.secondary,
        accent:     accent     ?? this.accent,
        background: background,
        surface:    surface,
        success:    success,
        error:      error,
        warning:    warning,
        info:       info,
        divider:    divider,
        border:     border,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Built-in preset palettes
// ─────────────────────────────────────────────────────────────────────────────

class AppPalettes {
  static const purple = AppColorScheme(
    primary:    Color(0xFFB15DC6),
    secondary:  Color(0xFF1976D2),
    accent:     Color(0xFFFFC107),
    background: Color(0xFFF5F5F5),
    surface:    Color(0xFFFFFFFF),
    success:    Color(0xFF2E7D32),
    error:      Color(0xFFD32F2F),
    warning:    Color(0xFFF9A825),
    info:       Color(0xFF0288D1),
    divider:    Color(0xFFE0E0E0),
    border:     Color(0xFFBDBDBD),
  );

  static const teal = AppColorScheme(
    primary:    Color(0xFF00897B),
    secondary:  Color(0xFF1976D2),
    accent:     Color(0xFFFFC107),
    background: Color(0xFFF5F5F5),
    surface:    Color(0xFFFFFFFF),
    success:    Color(0xFF2E7D32),
    error:      Color(0xFFD32F2F),
    warning:    Color(0xFFF9A825),
    info:       Color(0xFF0288D1),
    divider:    Color(0xFFE0E0E0),
    border:     Color(0xFFBDBDBD),
  );

  static const orange = AppColorScheme(
    primary:    Color(0xFFE65100),
    secondary:  Color(0xFF1976D2),
    accent:     Color(0xFFFFC107),
    background: Color(0xFFF5F5F5),
    surface:    Color(0xFFFFFFFF),
    success:    Color(0xFF2E7D32),
    error:      Color(0xFFD32F2F),
    warning:    Color(0xFFF9A825),
    info:       Color(0xFF0288D1),
    divider:    Color(0xFFE0E0E0),
    border:     Color(0xFFBDBDBD),
  );

  static const rose = AppColorScheme(
    primary:    Color(0xFFC62828),
    secondary:  Color(0xFF1976D2),
    accent:     Color(0xFFFFC107),
    background: Color(0xFFF5F5F5),
    surface:    Color(0xFFFFFFFF),
    success:    Color(0xFF2E7D32),
    error:      Color(0xFFD32F2F),
    warning:    Color(0xFFF9A825),
    info:       Color(0xFF0288D1),
    divider:    Color(0xFFE0E0E0),
    border:     Color(0xFFBDBDBD),
  );

  static const indigo = AppColorScheme(
    primary:    Color(0xFF283593),
    secondary:  Color(0xFF00897B),
    accent:     Color(0xFFFFC107),
    background: Color(0xFFF5F5F5),
    surface:    Color(0xFFFFFFFF),
    success:    Color(0xFF2E7D32),
    error:      Color(0xFFD32F2F),
    warning:    Color(0xFFF9A825),
    info:       Color(0xFF0288D1),
    divider:    Color(0xFFE0E0E0),
    border:     Color(0xFFBDBDBD),
  );

  static const List<({String name, AppColorScheme scheme})> all = [
    (name: 'Purple',  scheme: purple),
    (name: 'Teal',    scheme: teal),
    (name: 'Orange',  scheme: orange),
    (name: 'Rose',    scheme: rose),
    (name: 'Indigo',  scheme: indigo),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// ThemeNotifier — Riverpod StateNotifier that persists the chosen palette
// ─────────────────────────────────────────────────────────────────────────────

const _kPrefKey = 'app_theme_index';

class ThemeNotifier extends StateNotifier<AppColorScheme> {
  ThemeNotifier() : super(AppPalettes.orange) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final idx = prefs.getInt(_kPrefKey) ?? 2; // 2 = orange
    final clamped = idx.clamp(0, AppPalettes.all.length - 1);
    state = AppPalettes.all[clamped].scheme;
  }

  /// Switch to one of the built-in palettes by index.
  Future<void> setPalette(int index) async {
    final clamped = index.clamp(0, AppPalettes.all.length - 1);
    state = AppPalettes.all[clamped].scheme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kPrefKey, clamped);
  }

  /// Swap to any custom colour instantly (not persisted as a named palette).
  void setCustomPrimary(Color color) {
    state = state.copyWith(primary: color);
  }
}

/// The single provider — import this wherever you need colours.
final themeProvider =
StateNotifierProvider<ThemeNotifier, AppColorScheme>(
      (_) => ThemeNotifier(),
);

// ─────────────────────────────────────────────────────────────────────────────
// AppColors — backwards-compatible static accessor
//
// Usage (read-only, in build methods):
//   final colors = AppColors.of(context);   // ← preferred
//   AppColors.primary                        // ← only if you have no context
// ─────────────────────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  // ── Convenience accessor via InheritedWidget ──────────────────────────────
  static AppColorScheme of(BuildContext context) =>
      ProviderScope.containerOf(context).read(themeProvider);

  // ── Static fallbacks (use ONLY outside build / when context unavailable) ──
  static const Color primary    = Color(0xFFE66D33); // Orange
  static const Color secondary  = Color(0xFF1976D2);
  static const Color accent     = Color(0xFFFFC107);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface    = Color(0xFFFFFFFF);
  static const Color success    = Color(0xFF2E7D32);
  static const Color error      = Color(0xFFD32F2F);
  static const Color warning    = Color(0xFFF9A825);
  static const Color info       = Color(0xFF0288D1);
  static const Color divider    = Color(0xFFE0E0E0);
  static const Color border     = Color(0xFFBDBDBD);

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF6D00), // Orange primary
      Color(0xFFE65100), // Orange dark
      Color(0xFFBF360C), // Orange deepest
    ],
    stops: [0.0, 0.55, 1.0],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// AppStyles & AppText — unchanged, kept for compatibility
// ─────────────────────────────────────────────────────────────────────────────

class AppStyles {
  static EdgeInsets get cardPadding    => EdgeInsets.all(16.w);
  static EdgeInsets get sectionPadding => EdgeInsets.symmetric(vertical: 8.h);

  static TextStyle get titleStyle => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static TextStyle get subtitleStyle =>
      TextStyle(fontSize: 14.sp, color: Colors.grey[600]);
}

class AppText {
  AppText._();

  static TextStyle get display1 => TextStyle(
    fontSize: 32.sp,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
    height: 1.15,
    color: Colors.black,
  );

  static TextStyle get heading => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
    height: 1.25,
    color: Colors.black,
  );

  static TextStyle get subheading => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: Colors.black87,
  );

  static TextStyle get body => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: Colors.black87,
  );

  static TextStyle get caption => TextStyle(
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.4,
    color: Colors.black54,
  );

  static TextStyle get label => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    color: Colors.black87,
  );
}