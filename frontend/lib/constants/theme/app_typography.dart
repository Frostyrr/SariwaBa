import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography configuration using Vercel's Geist font across the app,
/// with Fredoka retained exclusively for the SariwaBa brand wordmark/logo.
class AppTypography {
  static const String fontFamily = 'Geist';
  static const double defaultLetterSpacing = -0.25;

  // Desktop & Mobile Hero Headlines (Geist)
  static TextStyle get heroHeadlineDesktop => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 48,
        fontWeight: FontWeight.w600,
        height: 1.1,
        letterSpacing: defaultLetterSpacing,
        color: SariwaColors.textPrimaryLight,
      );

  static TextStyle get heroHeadlineMobile => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 1.15,
        letterSpacing: defaultLetterSpacing,
        color: SariwaColors.textPrimaryLight,
      );

  // General Screen Headings
  static TextStyle get displayLarge => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 36,
        fontWeight: FontWeight.w600,
        height: 1.15,
        letterSpacing: defaultLetterSpacing,
        color: SariwaColors.textPrimaryLight,
      );

  static TextStyle get headlineLarge => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 26,
        fontWeight: FontWeight.w600,
        letterSpacing: defaultLetterSpacing,
        color: SariwaColors.textPrimaryLight,
      );

  static TextStyle get titleLarge => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: defaultLetterSpacing,
        color: SariwaColors.textPrimaryLight,
      );

  static TextStyle get titleMedium => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: defaultLetterSpacing,
        color: SariwaColors.textPrimaryLight,
      );

  // Body & Descriptions (Geist)
  static TextStyle get bodyLarge => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: defaultLetterSpacing,
        color: SariwaColors.textPrimaryLight,
      );

  static TextStyle get bodyMedium => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
        letterSpacing: defaultLetterSpacing,
        color: SariwaColors.textSecondaryLight,
      );

  static TextStyle get heroSubtitle => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 15.5,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: defaultLetterSpacing,
        color: SariwaColors.textSecondaryLight,
      );

  // Auth Headings
  static TextStyle get authTitle => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 26,
        fontWeight: FontWeight.w600,
        letterSpacing: defaultLetterSpacing,
        color: SariwaColors.textPrimaryLight,
      );

  static TextStyle get authSubtitle => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: defaultLetterSpacing,
        color: SariwaColors.textSecondaryLight,
      );

  // Buttons (Geist SemiBold)
  static TextStyle get buttonPrimary => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: defaultLetterSpacing,
        color: Colors.white,
      );

  static TextStyle get buttonSecondary => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        letterSpacing: defaultLetterSpacing,
        color: SariwaColors.textPrimaryLight,
      );

  // Nav Links
  static TextStyle get navLink => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        letterSpacing: defaultLetterSpacing,
        color: SariwaColors.textSecondaryLight,
      );

  static TextStyle get navLinkActive => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        letterSpacing: defaultLetterSpacing,
        color: SariwaColors.brandLight,
      );

  // Badges & Captions
  static TextStyle get caption => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: defaultLetterSpacing,
        color: SariwaColors.textMutedLight,
      );

  static TextStyle get labelMedium => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        letterSpacing: defaultLetterSpacing,
        color: SariwaColors.textPrimaryLight,
      );

  // Brand Logo / Mascot Wordmark (Fredoka retained for the friendly brand curved identity)
  static TextStyle get brandLogo => GoogleFonts.fredoka(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: defaultLetterSpacing,
        color: SariwaColors.textPrimaryLight,
      );

  // Monospace (Metrics & AI Confidence)
  static TextStyle get monoMetric => GoogleFonts.jetBrainsMono(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: defaultLetterSpacing,
        color: SariwaColors.brandLight,
      );
}
