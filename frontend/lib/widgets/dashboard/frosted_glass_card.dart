import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import '../../constants/theme/app_colors.dart';

/// Clean clinical surface card with crisp 1px border and single hairline shadow.
class FrostedGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final double blurSigma;
  final bool enableBlur;

  const FrostedGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 12,
    this.fillColor = SariwaColors.cardSurfaceLight,
    this.borderColor = SariwaColors.colorLine,
    this.borderWidth = 1.0,
    this.blurSigma = 16,
    this.enableBlur = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: const [
          BoxShadow(
            color: SariwaColors.shadowHairline,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

    if (enableBlur && !kIsWeb) {
      return RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: content,
          ),
        ),
      );
    }

    return RepaintBoundary(child: content);
  }
}
