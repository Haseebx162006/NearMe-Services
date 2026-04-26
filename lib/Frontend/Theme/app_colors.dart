import 'package:flutter/material.dart';

/// Centralized color system updated according to the provided
/// modern neutral / shadcn-inspired white + dark minimal scheme.
class AppColors {
  AppColors._();

  // ── Brand / Primary ──────────────────────────────────────
  static const Color primary        = Color(0xFF030213);
  static const Color primaryLight   = Color(0xFF1A1A2E);
  static const Color primaryDark    = Color(0xFF000000);
  static const Color primarySurface = Color(0xFFF5F5F7);

  // ── Backgrounds ──────────────────────────────────────────
  static const Color background     = Color(0xFFFFFFFF);
  static const Color surface        = Color(0xFFF8F8FA);
  static const Color scaffoldBg     = Color(0xFFF9FAFB);

  // ── Cards / Containers ──────────────────────────────────
  static const Color cardBg         = Color(0xFFFFFFFF);
  static const Color popover        = Color(0xFFFFFFFF);

  // ── Text ─────────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFF111111);
  static const Color textSecondary  = Color(0xFF717182);
  static const Color textHint       = Color(0xFF9CA3AF);
  static const Color textOnPrimary  = Color(0xFFFFFFFF);

  // ── Borders & Dividers ───────────────────────────────────
  static const Color border         = Color(0x1A000000); // 10% black
  static const Color divider        = Color(0xFFF1F2F4);
  static const Color inputBg        = Color(0xFFF3F3F5);

  // ── Accent / Muted ───────────────────────────────────────
  static const Color secondary      = Color(0xFFF2F2F5);
  static const Color accent         = Color(0xFFE9EBEF);
  static const Color muted          = Color(0xFFECECF0);
  static const Color mutedForeground= Color(0xFF717182);

  // ── Semantic ─────────────────────────────────────────────
  static const Color success        = Color(0xFF16A34A);
  static const Color error          = Color(0xFFD4183D);
  static const Color warning        = Color(0xFFF59E0B);
  static const Color info           = Color(0xFF3B82F6);

  // ── Finance Specific ─────────────────────────────────────
  static const Color income         = Color(0xFF16A34A);
  static const Color incomeBg       = Color(0xFFDCFCE7);

  static const Color expense        = Color(0xFFD4183D);
  static const Color expenseBg      = Color(0xFFFFE4E8);

  // ── Extra Utility Colors ────────────────────────────────
  static const Color teal           = Color(0xFF0D9488);
  static const Color tealBg         = Color(0xFFCCFBF1);

  static const Color orange         = Color(0xFFF97316);
  static const Color orangeBg       = Color(0xFFFFF7ED);

  // ── Shadow / Effects ─────────────────────────────────────
  static const Color shadow         = Color(0x0F000000);
  static const Color ring           = Color(0xFFB4B4B4);

  // ── Sidebar (optional dashboard use) ─────────────────────
  static const Color sidebarBg      = Color(0xFFFAFAFA);
  static const Color sidebarText    = Color(0xFF111111);
  static const Color sidebarAccent  = Color(0xFFF5F5F5);

  // ── Gradients ────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softNeutralGradient = LinearGradient(
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF3F4F6),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumDarkGradient = LinearGradient(
    colors: [
      Color(0xFF030213),
      Color(0xFF1A1A2E),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}