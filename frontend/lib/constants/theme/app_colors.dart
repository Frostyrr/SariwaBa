import 'dart:ui';
import 'package:flutter/material.dart';

/// SariwaBa Design System Color Tokens (`SariwaColors`)
/// Extracted from Version 1 Mascot, Logo, and Underwater Backdrop.
class SariwaColors {
  // Brand Colors (Version 1)
  static const Color brandPrimary = Color(0xFF168077);
  static const Color brandPrimaryHover = Color(0xFF126B63);
  static const Color brandPrimaryDark = Color(0xFF126B63);
  static const Color brandLight = Color(0xFFA5E6DF);
  static const Color brandGlow = Color(0xFF39B5A8);

  // Backgrounds & Surfaces (Underwater Environment & Off-White Dashboard)
  static const Color bgAbyssDark = Color(0xFF0A2229);
  static const Color bgLagoonMid = Color(0xFF123C46);
  static const Color bgFoamLight = Color(0xFFF2F9F9);
  static const Color bgDashboard = Color(0xFFF5F9F9);        // Off-white leaning primary teal
  static const Color bgDashboardSubtle = Color(0xFFEBF3F3);  // Slightly darker off-white for wells/chips
  static const Color cardSurfaceLight = Color(0xFFFFFFFF);    // Pure white cards
  static const Color borderLightTeal = Color(0xFFD8E7E7);     // Crisp subtle border
  static const Color surfaceGlass = Color(0xA6123C46); // 65% opacity
  static const Color borderGlass = Color(0x38A5E6DF);  // 22% opacity

  // Text Tokens
  static const Color textPrimaryLight = Color(0xFFFFFFFF);
  static const Color textSecondaryLight = Color(0xFFB8DFDC);
  static const Color textMutedLight = Color(0xFF7FA8A4);
  static const Color textPrimaryDark = Color(0xFF0A2229);
  static const Color textSecondaryDark = Color(0xFF436067);
  static const Color textMutedDark = Color(0xFF6B8B92);

  // Semantic Freshness Classification Tiers
  static const Color statusFresh = Color(0xFF10B981);     // Emerald Green: Sariwa
  static const Color statusModerate = Color(0xFFF59E0B);  // Amber Gold: Katamtaman
  static const Color statusSpoiled = Color(0xFFEF4444);   // Coral Red: Hindi Sariwa
  static const Color statusInfo = Color(0xFF06B6D4);      // Cyan: Scanning / Info

  // Timber Design System 2.0 Semantic Tokens (Mapped to SariwaBa Palette)
  static const Color colorPrimary = brandPrimary;               // #168077
  static const Color colorPrimaryHover = brandPrimaryHover;     // #126B63
  static const Color colorSupporting = brandGlow;               // #39B5A8
  static const Color colorPale = Color(0xFFE6F5F3);             // 8-10% tint on white
  static const Color colorCanvas = Color(0xFFFFFFFF);           // Pure white
  static const Color colorWorkspace = Color(0xFFEEF6F5);        // Ambient tinted foam grey/teal
  static const Color colorSurface = Color(0xFFF7FAFA);          // Secondary well surface
  static const Color colorInk = Color(0xFF0A2229);              // Deep slate teal text (>13.5:1 contrast)
  static const Color colorMutedInk = Color(0xFF436067);         // Supporting slate caption (>4.8:1 contrast)
  static const Color colorLine = Color(0xFFD8E7E7);             // Card borders & dividers
  static const Color colorLineSubtle = Color(0xFFEBF2F2);       // Inner micro-borders

  // Timber Universal Status Tokens
  static const Color warningBg = Color(0xFFFEF6EA);
  static const Color warningText = Color(0xFF8C5410);
  static const Color warningBorder = Color(0xFFF2D9B1);

  static const Color dangerBg = Color(0xFFFDF0F0);
  static const Color dangerText = Color(0xFF9B2C2C);
  static const Color dangerBorder = Color(0xFFF3CACA);

  static const Color successBg = Color(0xFFEEF8F1);
  static const Color successText = Color(0xFF1B6838);
  static const Color successBorder = Color(0xFFC6E7D0);

  // Aliases for compatibility
  static const Color background = bgAbyssDark;
  static const Color surface = bgLagoonMid;
  static const Color surfaceElevated = Color(0xFF184E5B);
  static const Color border = borderGlass;
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;
  static const Color textMuted = textMutedLight;
  static const Color freshGradeA = statusFresh;
  static const Color moderateGradeB = statusModerate;
  static const Color spoiledGradeC = statusSpoiled;
}

// Retain AppColors for backward compatibility across components
typedef AppColors = SariwaColors;

