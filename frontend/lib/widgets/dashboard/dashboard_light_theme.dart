import 'package:material_ui/material_ui.dart';

/// Keeps dashboard controls and their overlay routes on the light surface theme.
class DashboardLightTheme extends StatelessWidget {
  final Widget child;

  const DashboardLightTheme({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final inherited = Theme.of(context);
    final light = ThemeData.light(useMaterial3: true);
    const ink = Color(0xFF0F172A);
    const teal = Color(0xFF0F766E);
    const menuSurface = Color(0xFAFFFFFF);
    final menuShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: Color(0xFFDCE8E5)),
    );
    return Theme(
      data: inherited.copyWith(
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: teal,
          secondary: teal,
          secondaryContainer: teal,
          onSecondaryContainer: Colors.white,
          surface: Colors.white,
          onSurface: ink,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          outline: Color(0xFF64748B),
          outlineVariant: Color(0xFFCBD5E1),
          error: Color(0xFFB91C1C),
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return teal;
              return Colors.white;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return Colors.white;
              return ink;
            }),
            iconColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return Colors.white;
              return const Color(0xFF475569);
            }),
            side: const WidgetStatePropertyAll(
              BorderSide(color: Color(0xFFCBD5E1)),
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.white,
          selectedColor: teal,
          checkmarkColor: Colors.white,
          side: const BorderSide(color: Color(0xFFCBD5E1)),
          labelStyle: WidgetStateTextStyle.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontFamily: 'Geist',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              );
            }
            return const TextStyle(
              fontFamily: 'Geist',
              fontWeight: FontWeight.w500,
              color: ink,
            );
          }),
          secondaryLabelStyle: const TextStyle(
            fontFamily: 'Geist',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        canvasColor: menuSurface,
        textTheme: light.textTheme.apply(
          fontFamily: 'Geist',
          bodyColor: ink,
          displayColor: ink,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF475569)),
        hoverColor: const Color(0x140F766E),
        focusColor: const Color(0x240F766E),
        checkboxTheme: CheckboxThemeData(
          side: WidgetStateBorderSide.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return const BorderSide(color: Color(0xFF94A3B8), width: 1.8);
            }
            return BorderSide(
              color: states.contains(WidgetState.selected)
                  ? teal
                  : const Color(0xFF64748B),
              width: 1.8,
            );
          }),
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return const Color(0xFFE2E8F0);
            }
            return states.contains(WidgetState.selected) ? teal : Colors.white;
          }),
          checkColor: const WidgetStatePropertyAll(Colors.white),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.focused)
                ? const Color(0x330F766E)
                : const Color(0x1A0F766E);
          }),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: teal,
          selectionColor: Color(0x4014B8A6),
          selectionHandleColor: teal,
        ),
        popupMenuTheme: PopupMenuThemeData(
          color: menuSurface,
          surfaceTintColor: Colors.transparent,
          shadowColor: const Color(0x240F3732),
          elevation: 8,
          shape: menuShape,
          position: PopupMenuPosition.under,
          textStyle: const TextStyle(
            fontFamily: 'Geist',
            fontSize: 13,
            color: ink,
          ),
        ),
        scrollbarTheme: ScrollbarThemeData(
          radius: const Radius.circular(999),
          interactive: true,
          thickness: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.dragged)) {
              return 8.0;
            }
            return 6.0;
          }),
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.dragged)) {
              return teal.withValues(alpha: 0.68);
            }
            if (states.contains(WidgetState.hovered)) {
              return teal.withValues(alpha: 0.50);
            }
            return teal.withValues(alpha: 0.28);
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.dragged)) {
              return const Color(0xFFD8E7E7).withValues(alpha: 0.45);
            }
            return Colors.transparent;
          }),
          trackBorderColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      child: child,
    );
  }
}
