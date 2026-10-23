import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// SariwaBa Glassmorphism & Squircle Theme
class AppTheme {
  static ThemeData get darkOceanTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: SariwaColors.bgAbyssDark,
      colorScheme: const ColorScheme.dark(
        primary: SariwaColors.brandPrimary,
        secondary: SariwaColors.brandGlow,
        surface: SariwaColors.bgLagoonMid,
        error: SariwaColors.statusSpoiled,
        onPrimary: Colors.white,
        onSecondary: SariwaColors.bgAbyssDark,
        onSurface: SariwaColors.textPrimaryLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: SariwaColors.brandPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: AppTypography.buttonPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: SariwaColors.surfaceGlass,
        elevation: 0,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(40), // Smooth squircle
          side: const BorderSide(color: SariwaColors.borderGlass, width: 1.5),
        ),
      ),
    );
  }

  // Alias for backward compatibility
  static ThemeData get darkTheme => darkOceanTheme;
}

/// Reusable Frosted Sea-Glass Container for SariwaBa Web & Mobile
class SariwaGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? surfaceColor;
  final Color? borderColor;
  final double borderWidth;
  final double blurSigma;

  const SariwaGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24.0,
    this.surfaceColor,
    this.borderColor,
    this.borderWidth = 1.5,
    this.blurSigma = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: surfaceColor ?? SariwaColors.surfaceGlass,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? SariwaColors.borderGlass,
              width: borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: SariwaColors.bgAbyssDark.withValues(alpha: 0.28),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
