import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Reusable glassmorphic card container with Gaussian blur and subtle unclipped dual-layer drop shadows.
class FrostedGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final double blurSigma;

  const FrostedGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 24,
    this.fillColor = const Color(0xB0FFFFFF),
    this.borderColor = const Color(0xD9FFFFFF),
    this.borderWidth = 1.2,
    this.blurSigma = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A), // 4% subtle contact drop shadow
            blurRadius: 18,
            offset: Offset(0, 4),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Color(0x060F172A), // 2.5% soft ambient elevation
            blurRadius: 36,
            offset: Offset(0, 12),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Color(0x0814B8A6), // 3% ambient aquatic sheen
            blurRadius: 28,
            offset: Offset(0, 6),
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            width: double.infinity,
            padding: padding,
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
