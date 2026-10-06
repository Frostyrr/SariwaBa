import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum _AppButtonVariant { primary, secondary }

/// Reusable AppButton Widget
/// Clean, minimalist button modeled after Resend & Vercel design systems:
/// - [AppButton.primary]: Solid White background with Black text.
/// - [AppButton.secondary]: Dark charcoal background with subtle border and White text.
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
    this.borderRadius = 10,
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
    this.borderRadius = 10,
  }) : _variant = _AppButtonVariant.secondary;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isPrimary = widget._variant == _AppButtonVariant.primary;

    Color getBackgroundColor() {
      if (widget.onPressed == null) {
        return isPrimary
            ? AppColors.buttonPrimaryBg.withValues(alpha: 0.4)
            : AppColors.buttonSecondaryBg.withValues(alpha: 0.4);
      }
      if (isPrimary) {
        return _isHovered ? AppColors.buttonPrimaryHover : AppColors.buttonPrimaryBg;
      } else {
        return _isHovered ? AppColors.buttonSecondaryHover : AppColors.buttonSecondaryBg;
      }
    }

    Border? getBorder() {
      if (isPrimary) return null;
      return Border.all(
        color: _isHovered ? AppColors.borderLight : AppColors.buttonSecondaryBorder,
        width: 1.0,
      );
    }

    return MouseRegion(
      cursor: widget.onPressed != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.isLoading ? null : widget.onPressed,
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 90),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: getBackgroundColor(),
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: getBorder(),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: widget.isLoading
                  ? Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isPrimary ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        if (widget.icon != null) ...[
                          widget.icon!,
                          const SizedBox(width: 12),
                        ],
                        Flexible(
                          child: Text(
                            widget.label,
                            style: isPrimary
                                ? AppTypography.buttonPrimary
                                : AppTypography.buttonSecondary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (widget.trailing != null) ...[
                          const SizedBox(width: 10),
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
