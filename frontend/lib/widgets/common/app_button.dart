import 'package:flutter/material.dart';

import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';

enum _AppButtonVariant { primary, secondary, outline, lightPill }

/// Reusable AppButton Widget
/// Styled for SariwaBa aquatic palette and squircle / capsule geometry:
/// - [AppButton.primary]: Sariwa teal (#168077) with white text & gentle elevation.
/// - [AppButton.secondary]: Lagoon glass container with subtle light border.
/// - [AppButton.outline]: Transparent container with light aqua border.
/// - [AppButton.lightPill]: White/light capsule button with dark text.
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
    this.borderRadius = 16,
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
    this.borderRadius = 16,
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
    this.borderRadius = 16,
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
    Border? border;

    switch (widget._variant) {
      case _AppButtonVariant.primary:
        backgroundColor = _isHovered
            ? SariwaColors.brandPrimaryHover
            : SariwaColors.brandPrimary;
        textColor = Colors.white;
        border = Border.all(
          color: SariwaColors.brandGlow.withValues(alpha: 0.35),
          width: 1.0,
        );
        break;

      case _AppButtonVariant.secondary:
        backgroundColor = _isHovered
            ? SariwaColors.bgLagoonMid
            : SariwaColors.surfaceGlass;
        textColor = SariwaColors.textPrimaryLight;
        border = Border.all(
          color: _isHovered
              ? SariwaColors.brandLight.withValues(alpha: 0.45)
              : SariwaColors.borderGlass,
          width: 1.2,
        );
        break;

      case _AppButtonVariant.outline:
        backgroundColor = _isHovered
            ? SariwaColors.surfaceGlass
            : Colors.transparent;
        textColor = SariwaColors.textPrimaryLight;
        border = Border.all(
          color: _isHovered
              ? SariwaColors.brandLight
              : SariwaColors.brandLight.withValues(alpha: 0.6),
          width: 1.2,
        );
        break;

      case _AppButtonVariant.lightPill:
        backgroundColor = _isHovered ? const Color(0xFFE8F7F5) : Colors.white;
        textColor = SariwaColors.bgAbyssDark;
        border = Border.all(color: SariwaColors.borderGlass, width: 1.0);
        break;
    }

    final isInteractive = widget.onPressed != null && !widget.isLoading;

    return SelectionContainer.disabled(
      child: MouseRegion(
        cursor: isInteractive
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: isInteractive ? widget.onPressed : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: isInteractive
                  ? backgroundColor
                  : backgroundColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: border,
              boxShadow:
                  widget._variant == _AppButtonVariant.primary && isInteractive
                  ? [
                      BoxShadow(
                        color: SariwaColors.brandPrimary.withValues(
                          alpha: _isHovered ? 0.35 : 0.22,
                        ),
                        blurRadius: _isHovered ? 14 : 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: textColor,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          widget.icon!,
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            widget.label,
                            style: AppTypography.buttonSecondary.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w600,
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
    );
  }
}
