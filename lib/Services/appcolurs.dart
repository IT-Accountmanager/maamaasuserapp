// import 'package:flutter/material.dart';
//
// /// Unified colour & style tokens for the entire app.
// /// All screen-specific colour classes have been merged here.
// /// Access via  AppColours.<token>  or the nested sub-classes below.
// class AppColoursall {
//   AppColoursall._();
//
//   // ─────────────────────────────────────────────
//   //  SHARED NEUTRAL BASE (used across most screens)
//   // ─────────────────────────────────────────────
//   static const Color bg           = Color(0xFFF6F7FB);   // page background
//   static const Color surface      = Colors.white;         // card / sheet surface
//   static const Color border       = Color(0xFFE8ECF4);   // general border
//   static const Color divider      = Color(0xFFEEF0F5);   // divider lines
//
//   // ─────────────────────────────────────────────
//   //  TEXT
//   // ─────────────────────────────────────────────
//   static const Color ink          = Color(0xFF111827);   // primary text
//   static const Color inkSub       = Color(0xFF374151);   // secondary body text
//   static const Color inkMuted     = Color(0xFF6B7280);   // muted / captions
//   static const Color inkLight     = Color(0xFFB0B8CC);   // placeholder / disabled
//
//   // ─────────────────────────────────────────────
//   //  BRAND PRIMARIES
//   //  (pick the one that fits each screen – kept separate so they don't collide)
//   // ─────────────────────────────────────────────
//
//   /// Indigo — profile, coupons, support-team screens
//   static const Color indigo       = Color(0xFF4F46E5);
//   static const Color indigoSoft   = Color(0xFFEEEDFD);
//   static const Color indigoLight  = Color(0xFFEEF2FF);
//
//   /// Violet — cart, wallet, saved-addresses, OTP screens
//   static const Color violet       = Color(0xFF6C63FF);
//   static const Color violetDim    = Color(0x1A6C63FF);
//   static const Color violetSoft   = Color(0xFFEEEDFF);
//
//   /// Blue — enquiry, sign-up screens
//   static const Color blue         = Color(0xFF2563EB);
//   static const Color blueSoft     = Color(0xFFEFF6FF);
//   static const Color blueDark     = Color(0xFF1A56DB);
//   static const Color blueLighter  = Color(0xFFEEF2FF);
//
//   /// Orange / Red — restaurants, referral, invoice, food-order screens
//   static const Color orange       = Color(0xFFFF6B35);
//   static const Color orangeLight  = Color(0xFFFBEAE0);
//   static const Color orangeDark   = Color(0xFFC1501F);
//   static const Color brandRed     = Color(0xFFE23744);
//   static const Color brandRedSoft = Color(0xFFFFECED);
//   static const Color accentOrange = Color(0xFFFF5722);
//
//   /// Green — catVnd, food-order, enquiry, cat-orders screens
//   static const Color green        = Color(0xFF2ECC71);
//   static const Color emerald      = Color(0xFF10B981);
//   static const Color emeraldSoft  = Color(0xFFD1FAE5);
//   static const Color teal         = Color(0xFF16A34A);
//   static const Color tealSoft     = Color(0xFFF0FDF4);
//   static const Color deepGreen    = Color(0xFF1B7A50);
//   static const Color deepGreenSoft = Color(0xFFE8F5EE);
//
//   /// Dark navy — catVnd screen primary / text
//   static const Color navy         = Color(0xFF1A1A2E);
//   static const Color navySoft     = Color(0xFFEAF4EC);
//
//   // ─────────────────────────────────────────────
//   //  SEMANTIC / STATUS
//   // ─────────────────────────────────────────────
//   static const Color danger       = Color(0xFFEF4444);
//   static const Color dangerSoft   = Color(0xFFFEF2F2);
//   static const Color dangerAlt    = Color(0xFFDC2626);   // slightly darker red
//   static const Color warning      = Color(0xFFF59E0B);   // amber
//   static const Color warningSoft  = Color(0xFFFFF8EC);
//   static const Color warningLight = Color(0xFFFFFBEB);
//   static const Color success      = Color(0xFF10B981);   // alias → emerald
//   static const Color successSoft  = Color(0xFFF0FDF4);
//   static const Color info         = Color(0xFF4F46E5);   // alias → indigo
//   static const Color infoSoft     = Color(0xFFEEF2FF);
//
//   // ─────────────────────────────────────────────
//   //  TICKET / BOOKING STATUS
//   // ─────────────────────────────────────────────
//   static const Color statusOpen       = Color(0xFF10B981);  // emerald
//   static const Color statusProgress   = Color(0xFFF59E0B);  // amber
//   static const Color statusResolved   = Color(0xFF3B82F6);
//   static const Color statusResolvedDim= Color(0x153B82F6);
//   static const Color statusRejected   = Color(0xFFEF4444);
//
//   static const Color waiting          = Color(0xFFF59E0B);
//   static const Color waitingLight     = Color(0xFFFFFBEB);
//   static const Color confirmed        = Color(0xFF10B981);
//   static const Color confirmedLight   = Color(0xFFECFDF5);
//   static const Color completed        = Color(0xFF9CA3AF);
//   static const Color completedLight   = Color(0xFFF9FAFB);
//   static const Color delivered        = Color(0xFF6366F1);
//
//   // ─────────────────────────────────────────────
//   //  MISC ACCENT COLOURS
//   // ─────────────────────────────────────────────
//   static const Color accentGold   = Color(0xFFF4A830);
//   static const Color purple       = Color(0xFF8B5CF6);
//   static const Color nonVegRed    = Color(0xFFE74C3C);
//   static const Color vegGreen     = Color(0xFF2ECC71);    // alias → green
//   static const Color cashback     = Color(0xFFF59E0B);    // alias → warning
//   static const Color credit       = Color(0xFF10B981);    // alias → success
//   static const Color debit        = Color(0xFFEF4444);    // alias → danger
//
//   // ─────────────────────────────────────────────
//   //  SURFACE VARIANTS
//   // ─────────────────────────────────────────────
//   static const Color surfaceAlt   = Color(0xFFF0F2F8);
//   static const Color surfaceWarm  = Color(0xFFFFF8F5);
//   static const Color cardShadow   = Color(0x0D000000);
//   static const Color bgLight      = Color(0xFFF8F9FA);    // catVnd page bg
//
//   // ─────────────────────────────────────────────
//   //  RADIUS & SPACING CONSTANTS
//   // ─────────────────────────────────────────────
//   static const double radius      = 16.0;
//   static const double radiusSm    = 8.0;
//   static const double radiusMd    = 14.0;
//
//   // ─────────────────────────────────────────────
//   //  SHARED BOX SHADOWS
//   // ─────────────────────────────────────────────
//   static List<BoxShadow> cardShadows = [
//     BoxShadow(
//       // ignore: deprecated_member_use
//       color: const Color(0xFF000000).withOpacity(0.05),
//       blurRadius: 12,
//       offset: const Offset(0, 2),
//     ),
//   ];
//
//   // ─────────────────────────────────────────────
//   //  SHARED TEXT STYLES
//   // ─────────────────────────────────────────────
//   static const TextStyle h1 = TextStyle(
//     fontSize: 22,
//     fontWeight: FontWeight.w700,
//     color: ink,
//     letterSpacing: -0.5,
//   );
//
//   static const TextStyle h2 = TextStyle(
//     fontSize: 16,
//     fontWeight: FontWeight.w600,
//     color: ink,
//     letterSpacing: -0.2,
//   );
//
//   static const TextStyle h2Sm = TextStyle(
//     fontSize: 15,
//     fontWeight: FontWeight.w600,
//     color: ink,
//     letterSpacing: -0.2,
//   );
//
//   static const TextStyle titleLg = TextStyle(
//     fontSize: 15,
//     fontWeight: FontWeight.w700,
//     color: ink,
//     letterSpacing: -0.2,
//   );
//
//   static const TextStyle titleSm = TextStyle(
//     fontSize: 13,
//     fontWeight: FontWeight.w600,
//     color: ink,
//   );
//
//   static const TextStyle body = TextStyle(
//     fontSize: 13,
//     color: inkMuted,
//     height: 1.4,
//   );
//
//   static const TextStyle bodyMd = TextStyle(
//     fontSize: 13,
//     color: inkMuted,
//     height: 1.4,
//   );
//
//   static const TextStyle bodyRelaxed = TextStyle(
//     fontSize: 13,
//     color: inkMuted,
//     height: 1.5,
//   );
//
//   static const TextStyle bodySm = TextStyle(
//     fontSize: 12,
//     color: inkLight,
//   );
//
//   static const TextStyle label = TextStyle(
//     fontSize: 11,
//     fontWeight: FontWeight.w600,
//     color: inkMuted,
//     letterSpacing: 0.5,
//   );
//
//   static const TextStyle labelTight = TextStyle(
//     fontSize: 11,
//     fontWeight: FontWeight.w600,
//     letterSpacing: 0.4,
//   );
// }