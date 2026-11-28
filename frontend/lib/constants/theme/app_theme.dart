import 'dart:ui';
import 'package:material_ui/material_ui.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'sariwa_tokens.dart';

/// SariwaBa Unified Clinical Marine Theme (Light & Dark from the same brand seed).
class AppTheme {
  static TextTheme _buildTextTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final ink = isDark
        ? SariwaColors.textPrimaryLight
        : SariwaColors.textPrimaryDark;
    final secondaryInk = isDark
        ? SariwaColors.textSecondaryLight
        : SariwaColors.textSecondaryDark;
    final base = (isDark ? ThemeData.dark() : ThemeData.light()).textTheme.apply(
      fontFamily: AppTypography.fontFamily,
      bodyColor: ink,
      displayColor: ink,
    );
    return base.copyWith(
      displayLarge: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 36,
        fontWeight: FontWeight.w500,
        height: 1.15,
        letterSpacing: -0.7,
        color: ink,
      ),
      headlineLarge: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w500,
        height: 1.2,
        letterSpacing: -0.5,
        color: ink,
      ),
      headlineMedium: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 1.25,
        letterSpacing: -0.3,
        color: ink,
      ),
      titleLarge: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 1.3,
        letterSpacing: -0.25,
        color: ink,
      ),
      titleMedium: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.35,
        letterSpacing: -0.2,
        color: ink,
      ),
      titleSmall: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.35,
        letterSpacing: -0.1,
        color: ink,
      ),
      bodyLarge: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: -0.1,
        color: ink,
      ),
      bodyMedium: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w300,
        height: 1.45,
        letterSpacing: -0.1,
        color: secondaryInk,
      ),
      bodySmall: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: secondaryInk,
      ),
      labelLarge: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.25,
        letterSpacing: -0.1,
        color: ink,
      ),
      labelMedium: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.25,
        letterSpacing: 0.1,
        color: ink,
      ),
      labelSmall: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.2,
        letterSpacing: 0.25,
        color: secondaryInk,
      ),
    );
  }

  static ThemeData buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final seeded = ColorScheme.fromSeed(
      seedColor: SariwaColors.brandPrimary,
      brightness: brightness,
    );
    final colorScheme = isDark
        ? seeded.copyWith(
            primary: SariwaColors.brandPrimary,
            secondary: SariwaColors.brandGlow,
            surface: SariwaColors.bgLagoonMid,
            surfaceContainerHighest: SariwaColors.surfaceElevated,
            error: SariwaColors.notFreshPrimaryDark,
            onPrimary: Colors.white,
            onSecondary: SariwaColors.bgAbyssDark,
            onSurface: SariwaColors.textPrimaryLight,
            onSurfaceVariant: SariwaColors.textSecondaryLight,
            outline: SariwaColors.borderGlass,
            outlineVariant: SariwaColors.surfaceElevated,
          )
        : seeded.copyWith(
            primary: SariwaColors.brandPrimary,
            secondary: SariwaColors.brandGlow,
            secondaryContainer: SariwaColors.colorPale,
            onSecondaryContainer: SariwaColors.brandPrimaryDark,
            surface: SariwaColors.cardSurfaceLight,
            surfaceContainerLowest: SariwaColors.cardSurfaceLight,
            surfaceContainerLow: SariwaColors.colorSurface,
            surfaceContainer: SariwaColors.colorWorkspace,
            surfaceContainerHigh: SariwaColors.bgDashboardSubtle,
            surfaceContainerHighest: SariwaColors.surfaceSlateWash,
            error: SariwaColors.statusSpoiled,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: SariwaColors.textPrimaryDark,
            onSurfaceVariant: SariwaColors.textSecondaryDark,
            outline: SariwaColors.colorLine,
            outlineVariant: SariwaColors.colorLineSubtle,
          );

    final textTheme = _buildTextTheme(brightness);
    final menuShape = RoundedRectangleBorder(
      borderRadius: SariwaRadius.mdAll,
      side: BorderSide(color: colorScheme.outline),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: AppTypography.fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark
          ? SariwaColors.bgAbyssDark
          : SariwaColors.colorWorkspace,
      canvasColor: colorScheme.surface,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      extensions: [isDark ? SariwaTokens.dark : SariwaTokens.light],
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: SariwaSpace.xl,
            vertical: SariwaSpace.lg,
          ),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outline),
          padding: const EdgeInsets.symmetric(
            horizontal: SariwaSpace.lg,
            vertical: SariwaSpace.md,
          ),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: textTheme.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: textTheme.labelLarge,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark
            ? SariwaColors.bgLagoonMid
            : colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(colorScheme.surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDark
                    ? SariwaColors.borderGlass
                    : Colors.black.withValues(alpha: 0.08),
              ),
            ),
          ),
        ),
      ),
      menuButtonTheme: MenuButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(
            textTheme.bodyMedium?.copyWith(
              fontFamily: AppTypography.fontFamily,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: textTheme.bodyMedium?.copyWith(
          fontFamily: AppTypography.fontFamily,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? SariwaColors.surfaceGlass : colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: SariwaRadius.lgAll,
          side: BorderSide(
            color: isDark ? SariwaColors.borderGlass : colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark
            ? SariwaColors.bgLagoonMid
            : colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: SariwaRadius.lgAll,
          side: BorderSide(color: colorScheme.outline),
        ),
        titleTextStyle: textTheme.titleMedium,
        contentTextStyle: textTheme.bodyMedium,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? SariwaColors.bgAbyssDark.withValues(alpha: 0.4)
            : colorScheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SariwaSpace.lg,
          vertical: SariwaSpace.md,
        ),
        border: OutlineInputBorder(
          borderRadius: SariwaRadius.mdAll,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: SariwaRadius.mdAll,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: SariwaRadius.mdAll,
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primary;
            }
            return colorScheme.surface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.onPrimary;
            }
            return colorScheme.onSurface;
          }),
          iconColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.onPrimary;
            }
            return colorScheme.onSurfaceVariant;
          }),
          side: WidgetStatePropertyAll(BorderSide(color: colorScheme.outline)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surface,
        selectedColor: colorScheme.primary,
        checkmarkColor: colorScheme.onPrimary,
        side: BorderSide(color: colorScheme.outline),
        shape: RoundedRectangleBorder(borderRadius: SariwaRadius.smAll),
        labelStyle: WidgetStateTextStyle.resolveWith((states) {
          return textTheme.labelMedium!.copyWith(
            color: states.contains(WidgetState.selected)
                ? colorScheme.onPrimary
                : colorScheme.onSurface,
          );
        }),
        secondaryLabelStyle: textTheme.labelMedium!.copyWith(
          color: colorScheme.onPrimary,
        ),
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      hoverColor: colorScheme.primary.withValues(alpha: 0.08),
      focusColor: colorScheme.primary.withValues(alpha: 0.14),
      checkboxTheme: CheckboxThemeData(
        side: WidgetStateBorderSide.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(color: colorScheme.outline, width: 1.5);
          }
          return BorderSide(
            color: states.contains(WidgetState.selected)
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            width: 1.5,
          );
        }),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.surfaceContainerHighest;
          }
          return states.contains(WidgetState.selected)
              ? colorScheme.primary
              : colorScheme.surface;
        }),
        checkColor: WidgetStatePropertyAll(colorScheme.onPrimary),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.focused)
              ? colorScheme.primary.withValues(alpha: 0.2)
              : colorScheme.primary.withValues(alpha: 0.1);
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SariwaSpace.xs),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colorScheme.primary,
        selectionColor: SariwaColors.brandGlow.withValues(alpha: 0.25),
        selectionHandleColor: colorScheme.primary,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: SariwaColors.bgAbyssDark.withValues(alpha: 0.14),
        elevation: 6,
        shape: menuShape,
        position: PopupMenuPosition.under,
        textStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
      ),
      scrollbarTheme: ScrollbarThemeData(
        radius: const Radius.circular(999),
        interactive: true,
        thickness: const WidgetStatePropertyAll(6.0),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.dragged)) {
            return const Color(0xFFA1A1AA);
          }
          return const Color(0xFFD4D4D8);
        }),
        trackColor: const WidgetStatePropertyAll(Colors.transparent),
        trackBorderColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    );
  }

  static ThemeData get lightTheme => buildTheme(Brightness.light);
  static ThemeData get darkOceanTheme => buildTheme(Brightness.dark);
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
