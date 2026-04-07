import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Menucolours {
  // Colors
  static final bg = Color(0xFFF7F8FC);
  static final surface = Color(0xFFFFFFFF);
  static final surfaceAlt = Color(0xFFF0F2F8);
  static final border = Color(0xFFE4E8F0);
  static const borderLight = Color(0xFFF0F2F8);

  static const primary = Color(0xFF2D6A4F); // deep forest green
  static const primaryLight = Color(0xFF40916C);
  static const primaryDim = Color(0x1A2D6A4F);
  static const primaryGlow = Color(0x332D6A4F);

  static const accent = Color(0xFFFF6B35); // warm orange
  static const accentDim = Color(0x1AFF6B35);

  static const vegGreen = Color(0xFF2D6A4F);
  static const nonVegRed = Color(0xFFDC2626);

  static const textH = Color(0xFF0F172A);
  static const textB = Color(0xFF334155);
  static const textS = Color(0xFF64748B);
  static const textM = Color(0xFFB0BAC8);

  // Typography scale
  static TextStyle h1({Color? color}) => TextStyle(
    fontFamily: 'serif',
    fontSize: 24.sp,
    fontWeight: FontWeight.w800,
    color: color ?? textH,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle h2({Color? color}) => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w700,
    color: color ?? textH,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static TextStyle body({Color? color, double? size}) => TextStyle(
    fontSize: size ?? 14.sp,
    fontWeight: FontWeight.w400,
    color: color ?? textB,
    height: 1.5,
  );

  static TextStyle label({Color? color, double? size}) => TextStyle(
    fontSize: size ?? 12.sp,
    fontWeight: FontWeight.w600,
    color: color ?? textS,
    letterSpacing: 0.2,
  );

  static TextStyle price({Color? color}) => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w800,
    color: color ?? primary,
    letterSpacing: -0.3,
  );

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.03),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> floatShadow = [
    BoxShadow(
      color: primary.withOpacity(0.3),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  // Radius
  static const r4 = BorderRadius.all(Radius.circular(4));
  static const r8 = BorderRadius.all(Radius.circular(8));
  static const r12 = BorderRadius.all(Radius.circular(12));
  static const r16 = BorderRadius.all(Radius.circular(16));
  static const r20 = BorderRadius.all(Radius.circular(20));
  static const r24 = BorderRadius.all(Radius.circular(24));
}

// ── Responsive Helpers ────────────────────────────────────────────────────────
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
