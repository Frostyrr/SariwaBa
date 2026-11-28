import 'dart:ui' as ui;
import 'package:material_ui/material_ui.dart';
import 'app_colors.dart';

/// Timber UI Typography Specification
///
/// Swiss / Apple-inspired minimalist typographic system designed for
/// information-dense editorial and equipment asset management dashboards.
///
/// Features:
/// - Clean integer scale (12, 14, 16, 20, 28) with restrained weights (400, 500, 600 max).
/// - Strict tabular numerals [FontFeature.tabularFigures] for alignment stability.
/// - Tuned optical tracking: tight negative tracking for headings, open positive tracking for uppercase badges.
/// - Full WCAG 2.1 AA/AAA compliance against light and deep slate/timber surfaces.
class TimberTypography {
  TimberTypography._();

  // ---------------------------------------------------------------------------
  // Font Family Stacks & Fallbacks
  // ---------------------------------------------------------------------------
  static const String primarySansFamily = 'Geist';
  static const List<String> primarySansFallbacks = [
    'Inter',
    '-apple-system',
    'BlinkMacSystemFont',
    'Segoe UI',
    'Roboto',
    'sans-serif',
  ];

  static const String monospaceFamily = 'Geist Mono';
  static const List<String> monospaceFallbacks = [
    'ui-monospace',
    'SFMono-Regular',
    'Menlo',
    'monospace',
  ];

  // ---------------------------------------------------------------------------
  // Core Timber Ink Palette (referenced from SariwaColors)
  // ---------------------------------------------------------------------------
  static const Color inkPrimary = SariwaColors.timberInkPrimary;
  static const Color inkSecondary = SariwaColors.timberInkSecondary;
  static const Color inkTertiary = SariwaColors.timberInkTertiary;
  static const Color inkBorder = SariwaColors.timberInkBorder;

  static const Color darkInkPrimary = SariwaColors.timberDarkInkPrimary;
  static const Color darkInkSecondary = SariwaColors.timberDarkInkSecondary;

  // ---------------------------------------------------------------------------
  // Typographic Scale & Micro-Styling (Unified 12 / 14 / 16 / 20 / 28 scale)
  // ---------------------------------------------------------------------------

  static const TextStyle heroEyebrow = TextStyle(
    fontFamily: primarySansFamily,
    fontFamilyFallback: primarySansFallbacks,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.8,
    height: 1.2,
    color: inkSecondary,
  );

  static const TextStyle heroH1Desktop = TextStyle(
    fontFamily: primarySansFamily,
    fontFamilyFallback: primarySansFallbacks,
    fontSize: 28,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.84,
    height: 1.15,
    color: inkPrimary,
  );

  static const TextStyle heroH1Mobile = TextStyle(
    fontFamily: primarySansFamily,
    fontFamilyFallback: primarySansFallbacks,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.5,
    height: 1.2,
    color: inkPrimary,
  );

  static const TextStyle heroSubtitle = TextStyle(
    fontFamily: primarySansFamily,
    fontFamilyFallback: primarySansFallbacks,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.14,
    height: 1.45,
    color: inkSecondary,
  );

  static const TextStyle kpiNumber = TextStyle(
    fontFamily: primarySansFamily,
    fontFamilyFallback: primarySansFallbacks,
    fontSize: 28,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.84,
    height: 1.0,
    fontFeatures: [ui.FontFeature.tabularFigures()],
    color: inkPrimary,
  );

  static const TextStyle sectionHeader = TextStyle(
    fontFamily: primarySansFamily,
    fontFamilyFallback: primarySansFallbacks,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.32,
    height: 1.3,
    color: inkPrimary,
  );

  static const TextStyle rowCardTitle = TextStyle(
    fontFamily: primarySansFamily,
    fontFamilyFallback: primarySansFallbacks,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.15,
    height: 1.35,
    color: inkPrimary,
  );

  static const TextStyle bodyInput = TextStyle(
    fontFamily: primarySansFamily,
    fontFamilyFallback: primarySansFallbacks,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.1,
    height: 1.45,
    color: inkPrimary,
  );

  static const TextStyle metadataCaption = TextStyle(
    fontFamily: primarySansFamily,
    fontFamilyFallback: primarySansFallbacks,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.05,
    height: 1.35,
    fontFeatures: [ui.FontFeature.tabularFigures()],
    color: inkSecondary,
  );

  static const TextStyle statusPill = TextStyle(
    fontFamily: primarySansFamily,
    fontFamilyFallback: primarySansFallbacks,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.25,
    height: 1.2,
    fontFeatures: [ui.FontFeature.tabularFigures()],
    color: inkPrimary,
  );

  static const TextStyle assetTagMono = TextStyle(
    fontFamily: monospaceFamily,
    fontFamilyFallback: monospaceFallbacks,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.25,
    fontFeatures: [ui.FontFeature.tabularFigures()],
    color: inkPrimary,
  );

  static const TextStyle tableMetricMono = TextStyle(
    fontFamily: monospaceFamily,
    fontFamilyFallback: monospaceFallbacks,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.25,
    fontFeatures: [ui.FontFeature.tabularFigures()],
    color: inkPrimary,
  );
}
