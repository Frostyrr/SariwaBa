import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Reusable glassmorphic card container with Gaussian blur and dual-layer ambient shadows.
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
    return ClipRRect(
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
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                blurRadius: 24,
                offset: const Offset(0, 6),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: const Color(0xFF14B8A6).withValues(alpha: 0.05),
                blurRadius: 32,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
