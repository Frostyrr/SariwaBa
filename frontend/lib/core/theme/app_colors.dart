import 'package:flutter/material.dart';

/// Application Color Palette
/// Clean, minimalist monochrome dark theme inspired by Resend/Vercel.
class AppColors {
  // Pure / Deep Blacks
  static const Color background = Color(0xFF0A0A0A);
  static const Color backgroundSecondary = Color(0xFF111111);
  static const Color surface = Color(0xFF141414);
  static const Color surfaceElevated = Color(0xFF171717);
  static const Color surfaceHover = Color(0xFF1E1E1E);

  // Borders
  static const Color border = Color(0xFF262626);
  static const Color borderSubtle = Color(0xFF1F1F1F);
  static const Color borderLight = Color(0xFF333333);
  static const Color borderFocused = Color(0xFFFFFFFF);

  // Primary Button (White with Black Text)
  static const Color buttonPrimaryBg = Color(0xFFFFFFFF);
  static const Color buttonPrimaryText = Color(0xFF000000);
  static const Color buttonPrimaryHover = Color(0xFFEBEBEB);

  // Secondary Button (Dark with White Text)
  static const Color buttonSecondaryBg = Color(0xFF171717);
  static const Color buttonSecondaryBorder = Color(0xFF2E2E2E);
  static const Color buttonSecondaryHover = Color(0xFF222222);
  static const Color buttonSecondaryText = Color(0xFFEDEDED);

  // Typography
  static const Color textPrimary = Color(0xFFEDEDED);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textMuted = Color(0xFF71717A);
  static const Color textSubtle = Color(0xFF52525B);
  static const Color textDark = Color(0xFF000000);

  // Badge / Pill
  static const Color badgeBg = Color(0xFF262626);
  static const Color badgeText = Color(0xFFA1A1AA);

  // Accents (Clean Ocean & Freshness indicators)
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color freshGradeA = Color(0xFF10B981);
  static const Color moderateGradeB = Color(0xFFF59E0B);
  static const Color spoiledGradeC = Color(0xFFEF4444);

  // Backward compatibility aliases
  static const Color oceanAbyss = background;
  static const Color oceanDeep = backgroundSecondary;
  static const Color oceanSurface = surface;
  static const Color oceanSurfaceLight = surfaceElevated;
  static const Color primary = buttonPrimaryBg;
  static const Color primaryHover = buttonPrimaryHover;
  static const Color primaryLight = accentBlue;
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color bioluminescentCyan = Color(0xFF38BDF8);
}
