import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography configuration using Google Fonts (Fredoka + Plus Jakarta Sans + JetBrains Mono)
/// Specified in SariwaBa UI Design System.
class AppTypography {
  // Brand & Heading Font (Approachability & Soft Curves)
  static TextStyle get displayLarge => GoogleFonts.fredoka(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 1.15,
        color: SariwaColors.textPrimaryLight,
      );

  static TextStyle get headlineLarge => GoogleFonts.fredoka(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: SariwaColors.textPrimaryLight,
      );

  static TextStyle get titleLarge => GoogleFonts.fredoka(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: SariwaColors.textPrimaryLight,
      );

  static TextStyle get titleMedium => GoogleFonts.fredoka(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: SariwaColors.textPrimaryLight,
      );

  // Desktop & Mobile Hero Headlines
  static TextStyle get heroHeadlineDesktop => GoogleFonts.fredoka(
        fontSize: 52,
        fontWeight: FontWeight.w700,
        height: 1.1,
        color: SariwaColors.textPrimaryLight,
      );

  static TextStyle get heroHeadlineMobile => GoogleFonts.fredoka(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.15,
        color: SariwaColors.textPrimaryLight,
      );

  // Body & Descriptions (Plus Jakarta Sans)
  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: SariwaColors.textPrimaryLight,
      );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: SariwaColors.textSecondaryLight,
      );

  static TextStyle get heroSubtitle => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: SariwaColors.textSecondaryLight,
      );

  // Auth Headings
  static TextStyle get authTitle => GoogleFonts.fredoka(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: SariwaColors.textPrimaryLight,
      );

  static TextStyle get authSubtitle => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: SariwaColors.textSecondaryLight,
      );

  // Buttons
  static TextStyle get buttonPrimary => GoogleFonts.fredoka(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle get buttonSecondary => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: SariwaColors.textPrimaryLight,
      );

  // Nav Links
  static TextStyle get navLink => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: SariwaColors.textSecondaryLight,
      );

  static TextStyle get navLinkActive => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: SariwaColors.brandLight,
      );

  // Badges & Captions
  static TextStyle get caption => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: SariwaColors.textMutedLight,
      );

  static TextStyle get labelMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: SariwaColors.textPrimaryLight,
      );

  static TextStyle get brandLogo => GoogleFonts.fredoka(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: SariwaColors.textPrimaryLight,
      );

  // Monospace (Metrics & AI Confidence)
  static TextStyle get monoMetric => GoogleFonts.jetBrainsMono(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: SariwaColors.brandLight,
      );
}
