import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand colors
  static const Color primary = Color(0xFF006A36);
  static const Color primaryLight = Color(0xFF1F8A4C);
  static const Color primaryDark = Color(0xFF14633A);
  static const Color primaryContainer = Color(0xFFD4F5DD);
  static const Color onPrimary = Colors.white;

  // Secondary / Accent
  static const Color secondary = Color(0xFFFEA619);
  static const Color secondaryDark = Color(0xFFD97706);
  static const Color secondaryContainer = Color(0xFFFEF3C7);
  static const Color onSecondary = Colors.black;

  // Neutrals & Backgrounds
  static const Color background = Color(0xFFF7FAF6);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F5F2);
  static const Color textPrimary = Color(0xFF181C1A);
  static const Color textSecondary = Color(0xFF5A665E);
  static const Color textMuted = Color(0xFF8C9B91);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFEBEFEA);

  // Status Colors
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusPendingBg = Color(0xFFFEF3C7);
  static const Color statusReady = Color(0xFF2563EB);
  static const Color statusReadyBg = Color(0xFFDBEAFE);
  static const Color statusServed = Color(0xFF16A34A);
  static const Color statusServedBg = Color(0xFFDCFCE7);
  static const Color statusCancelled = Color(0xFFDC2626);
  static const Color statusCancelledBg = Color(0xFFFEE2E2);
  static const Color statusExpired = Color(0xFF6B7280);
  static const Color statusExpiredBg = Color(0xFFF3F4F6);

  // Badges & Accents
  static const Color scholarshipBadge = Color(0xFF10B981);
  static const Color nonScholarshipBadge = Color(0xFF6366F1);
}
