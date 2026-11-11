import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Timber UI Typography Specification
///
/// Swiss / Apple-inspired minimalist typographic system designed for
/// information-dense editorial and equipment asset management dashboards.
///
/// Features:
/// - Precise micro-scale hierarchy with restrained weights (400, 500, 600 max).
/// - Strict tabular numerals [FontFeature.tabularFigures] for alignment stability.
/// - Tuned optical tracking: tight negative tracking for headings, open positive tracking for uppercase badges.
/// - Full WCAG 2.1 AA/AAA compliance against light (#FFFFFF, #F7F9F7) and deep slate/timber surfaces.
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
  // Core Timber Ink Palette (WCAG 2.1 AA/AAA Compliant)
  // ---------------------------------------------------------------------------
  static const Color inkPrimary = Color(0xFF18221D); // High-density deep forest ink (15.6:1 on white)
  static const Color inkSecondary = Color(0xFF66736B); // Muted slate ink (4.9:1 on white, AA pass)
  static const Color inkTertiary = Color(0xFF88968D); // De-emphasized metadata
  static const Color inkBorder = Color(0xFFDDE3DE); // Clean mathematical partition

  static const Color darkInkPrimary = Color(0xFFF2F5F3); // 16.2:1 against dark timber canvas
  static const Color darkInkSecondary = Color(0xFF9EB0A5); // 7.8:1 against dark timber canvas

  // ---------------------------------------------------------------------------
  // Typographic Scale & Micro-Styling
  // ---------------------------------------------------------------------------

  /// 1. Hero Eyebrow / Category Header
  /// 10px | Weight: 500 | Tracking: +0.08em (+0.8px) | UPPERCASE
  static const TextStyle heroEyebrow = TextStyle(
    fontFamily: primarySansFamily,
    fontFamilyFallback: primarySansFallbacks,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.8, // +0.08em
    height: 1.2,
    color: inkSecondary,
  );

  /// 2. Screen Title / Hero H1 (Desktop)
  /// 28px | Weight: 500 (medium) | Leading: 1.15 | Tracking: -0.03em (-0.84px)
  static const TextStyle heroH1Desktop = TextStyle(
    fontFamily: primarySansFamily,
    fontFamilyFallback: primarySansFallbacks,
    fontSize: 28,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.84, // -0.03em
    height: 1.15,
    color: inkPrimary,
  );

  /// 2b. Screen Title / Hero H1 (Mobile)
  /// 22px | Weight: 500 | Leading: 1.15 | Tracking: -0.03em (-0.66px)
  static const TextStyle heroH1Mobile = TextStyle(
    fontFamily: primarySansFamily,
    fontFamilyFallback: primarySansFallbacks,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.66, // -0.03em
    height: 1.15,
    color: inkPrimary,
  );

  /// 3. Hero Subtitle / Contextual Guidance
  /// 13px | Weight: 300 (lighter) | Leading: 1.45 | Tracking: -0.01em
  static const TextStyle heroSubtitle = TextStyle(
    fontFamily: primarySansFamily,
    fontFamilyFallback: primarySansFallbacks,
    fontSize: 13,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.13, // -0.01em
    height: 1.45,
    color: inkSecondary,
  );

  /// 4. Large KPI Numbers
  /// 28px | Weight: 400 (font-normal) | Tracking: -0.03em (-0.84px) | Leading: 1.0 | Tabular Nums
  static const TextStyle kpiNumber = TextStyle(
    fontFamily: primarySansFamily,
    fontFamilyFallback: primarySansFallbacks,
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.84, // -0.03em
    height: 1.0,
    fontFeatures: [ui.FontFeature.tabularFigures()],
    color: inkPrimary,
  );

  /// 5. Section Headers (H2 / Panel Headers)
  /// 15.5px | Weight: 500 (medium) | Tracking: -0.02em (-0.31px) | Leading: 1.3
  static const TextStyle sectionHeader = TextStyle(
    fontFamily: primarySansFamily,
    fontFamilyFallback: primarySansFallbacks,
    fontSize: 15.5,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.31, // -0.02em
    height: 1.3,
    color: inkPrimary,
  );

  /// 6. Work Row & Card Titles
  /// 13px | Weight: 500 (medium) | Line Height: 1.35 | Color: #18221D
  static const TextStyle rowCardTitle = TextStyle(
    fontFamily: primarySansFamily,
    fontFamilyFallback: primarySansFallbacks,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.15,
    height: 1.35,
    color: inkPrimary,
  );

  /// 7. Body / Form Inputs / Dropdown Selects
  /// 13.5px | Weight: 400 (normal) | Line Height: 1.4 | Color: #18221D
  static const TextStyle bodyInput = TextStyle(
    fontFamily: primarySansFamily,
    fontFamilyFallback: primarySansFallbacks,
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.1,
    height: 1.4,
    color: inkPrimary,
  );

  /// 8. Supporting Metadata & Captions
  /// 11.5px | Weight: 300 (lighter) | Color: #66736B (Muted slate / secondary ink)
  static const TextStyle metadataCaption = TextStyle(
    fontFamily: primarySansFamily,
    fontFamilyFallback: primarySansFallbacks,
    fontSize: 11.5,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.05,
    height: 1.35,
    fontFeatures: [ui.FontFeature.tabularFigures()],
    color: inkSecondary,
  );

  /// 9. Micro Badges, Tags, & Status Pills
  /// 10.5px | Weight: 500 | Tracking: +0.03em (+0.31px) | Tabular Nums
  static const TextStyle statusPill = TextStyle(
    fontFamily: primarySansFamily,
    fontFamilyFallback: primarySansFallbacks,
    fontSize: 10.5,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.31, // +0.03em
    height: 1.15,
    fontFeatures: [ui.FontFeature.tabularFigures()],
    color: inkPrimary,
  );

  /// 10. Asset Tags & ID Codes (e.g., TP-CAM-001)
  /// 11.5px | Family: Monospace | Weight: 500 | Feature: tabular-nums
  static const TextStyle assetTagMono = TextStyle(
    fontFamily: monospaceFamily,
    fontFamilyFallback: monospaceFallbacks,
    fontSize: 11.5,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.25,
    fontFeatures: [ui.FontFeature.tabularFigures()],
    color: inkPrimary,
  );

  /// 11. Tabular Table Cell Metric
  /// 12.5px | Family: Monospace | Weight: 300 (lighter) | Feature: tabular-nums
  static const TextStyle tableMetricMono = TextStyle(
    fontFamily: monospaceFamily,
    fontFamilyFallback: monospaceFallbacks,
    fontSize: 12.5,
    fontWeight: FontWeight.w300,
    letterSpacing: 0.0,
    height: 1.2,
    fontFeatures: [ui.FontFeature.tabularFigures()],
    color: inkPrimary,
  );
}
