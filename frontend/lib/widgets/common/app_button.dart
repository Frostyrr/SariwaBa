import 'package:material_ui/material_ui.dart';

import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';

enum _AppButtonVariant { primary, secondary, outline, lightPill }

/// Accessible, keyboard-focusable AppButton built on Material + InkWell.
/// Uses flat/crisp border and color transitions (150ms) with zero layout shift.
class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final Widget? trailing;
  final bool isLoading;
  final double? width;
  final double height;
  final double borderRadius;
  final _AppButtonVariant _variant;

  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailing,
    this.isLoading = false,
    this.width,
    this.height = 48,
    this.borderRadius = 999,
  }) : _variant = _AppButtonVariant.primary;

  const AppButton.primaryV2({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailing,
    this.isLoading = false,
    this.width,
    this.height = 48,
    this.borderRadius = 999,
  }) : _variant = _AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailing,
    this.isLoading = false,
    this.width,
    this.height = 48,
    this.borderRadius = 999,
  }) : _variant = _AppButtonVariant.secondary;

  const AppButton.outline({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailing,
    this.isLoading = false,
    this.width,
    this.height = 48,
    this.borderRadius = 999,
  }) : _variant = _AppButtonVariant.outline;

  const AppButton.lightPill({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailing,
    this.isLoading = false,
    this.width,
    this.height = 48,
    this.borderRadius = 999,
  }) : _variant = _AppButtonVariant.lightPill;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    BorderSide borderSide;

    switch (widget._variant) {
      case _AppButtonVariant.primary:
        backgroundColor = _isHovered
            ? SariwaColors.brandPrimaryHover
            : SariwaColors.brandPrimary;
        textColor = Colors.white;
        borderSide = BorderSide(
          color: SariwaColors.brandPrimaryDark.withValues(alpha: 0.4),
          width: 1.0,
        );
        break;

      case _AppButtonVariant.secondary:
        backgroundColor = _isHovered
            ? SariwaColors.colorSurface
            : SariwaColors.cardSurfaceLight;
        textColor = SariwaColors.textPrimaryDark;
        borderSide = BorderSide(
          color: _isHovered
              ? SariwaColors.brandPrimary.withValues(alpha: 0.45)
              : SariwaColors.colorLine,
          width: 1.0,
        );
        break;

      case _AppButtonVariant.outline:
        backgroundColor = _isHovered
            ? SariwaColors.surfaceGlass
            : Colors.transparent;
        textColor = SariwaColors.textPrimaryLight;
        borderSide = BorderSide(
          color: _isHovered
              ? SariwaColors.brandLight
              : SariwaColors.brandLight.withValues(alpha: 0.55),
          width: 1.0,
        );
        break;

      case _AppButtonVariant.lightPill:
        backgroundColor = _isHovered
            ? SariwaColors.colorPale
            : SariwaColors.cardSurfaceLight;
        textColor = SariwaColors.bgAbyssDark;
        borderSide = const BorderSide(
          color: SariwaColors.borderGlass,
          width: 1.0,
        );
        break;
    }

    final isInteractive = widget.onPressed != null && !widget.isLoading;
    final radius = BorderRadius.circular(widget.borderRadius);

    return SelectionContainer.disabled(
      child: Semantics(
        button: true,
        enabled: isInteractive,
        label: widget.label,
        child: MouseRegion(
          cursor: isInteractive
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: isInteractive
                  ? backgroundColor
                  : backgroundColor.withValues(alpha: 0.5),
              borderRadius: radius,
              border: Border.fromBorderSide(borderSide),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isInteractive ? widget.onPressed : null,
                borderRadius: radius,
                focusColor: SariwaColors.brandGlow.withValues(alpha: 0.18),
                hoverColor: Colors.transparent,
                splashColor: textColor.withValues(alpha: 0.10),
                highlightColor: textColor.withValues(alpha: 0.05),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: widget.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              color: textColor,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (widget.icon != null) ...[
                                widget.icon!,
                                const SizedBox(width: 8),
                              ],
                              Flexible(
                                child: Text(
                                  widget.label,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.buttonSecondary.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.trailing != null) ...[
                                const SizedBox(width: 8),
                                widget.trailing!,
                              ],
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
