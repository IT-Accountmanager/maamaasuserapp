import 'package:flutter/material.dart';

class AppColornew {
  // =========================
  // PRIMARY BRAND COLORS
  // =========================

  static const primaryOrange = Color(0xFFFF6B35);
  static const primaryRed = Color(0xFFE23744);
  static const primaryViolet = Color(0xFF6C63FF);
  static const primaryIndigo = Color(0xFF4F46E5);
  static const primaryBlue = Color(0xFF2563EB);
  static const primaryGreen = Color(0xFF1B7A50);

  // =========================
  // LIGHT VARIANTS
  // =========================

  static const orangeLight = Color(0xFFFBEAE0);
  static const redLight = Color(0xFFFFECED);
  static const violetLight = Color(0xFFEEEDFF);
  static const indigoLight = Color(0xFFEEF2FF);
  static const greenLight = Color(0xFFE8F5EE);

  // =========================
  // BACKGROUNDS
  // =========================

  static const bgPrimary = Color(0xFFF6F7FB);
  static const bgSecondary = Color(0xFFF5F6FA);
  static const bgTertiary = Color(0xFFF6F7F9);
  static const bgLight = Color(0xFFF7F8FC);
  static const bgSoft = Color(0xFFF8F9FA);

  static const surface = Color(0xFFFFFFFF);
  static const card = Color(0xFFFFFFFF);

  // =========================
  // TEXT COLORS
  // =========================

  static const textPrimary = Color(0xFF111827);
  static const textDark = Color(0xFF1A1A2E);
  static const textBlack = Color(0xFF1C1C1C);

  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFF64748B);
  static const textLight = Color(0xFFB0B8CC);

  // =========================
  // BORDER / DIVIDER
  // =========================

  static const border = Color(0xFFE5E7EB);
  static const borderLight = Color(0xFFE8ECF4);
  static const divider = Color(0xFFECEFF6);

  // =========================
  // STATUS COLORS
  // =========================

  static const success = Color(0xFF10B981);
  static const successLight = Color(0xFFD1FAE5);

  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFFF8EC);

  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFEF2F2);

  static const info = Color(0xFF3B82F6);
  static const infoLight = Color(0xFFEFF6FF);

  // =========================
  // FOOD CATEGORY COLORS
  // =========================

  static const vegGreen = Color(0xFF2ECC71);
  static const nonVegRed = Color(0xFFE74C3C);

  // =========================
  // SPECIAL COLORS
  // =========================

  static const accentMint = Color(0xFF00C896);
  static const accentGold = Color(0xFFF4A830);

  static const transparent = Colors.transparent;
  static const white = Colors.white;
  static const black = Colors.black;

  // =========================
  // SHADOWS
  // =========================

  static const cardShadow = Color(0x0D000000);

  // =========================
  // RADIUS
  // =========================

  static const double radiusXs = 8.0;
  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 24.0;

  // =========================
  // COMMON TEXT STYLES
  // =========================

  static const titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static const titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.2,
  );

  static const titleSmall = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const body = TextStyle(
    fontSize: 13,
    color: textSecondary,
    height: 1.4,
  );

  static const bodySmall = TextStyle(fontSize: 12, color: textMuted);

  static const label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: textSecondary,
  );

  // =========================
  // COMMON SHADOWS
  // =========================

  static List<BoxShadow> softCardShadow = [
    BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 2)),
  ];
}
