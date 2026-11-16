import 'dart:ui';
import 'package:flutter/material.dart';

import '../../constants/theme/app_colors.dart';

/// Atmospheric Background Stack
/// Implements our premium coastal light-mode direction:
/// - Predominantly warm ivory and off-white canvas (#FAF8F5)
/// - Soft irregular seafoam gradients near outer edges (#14B8A6, #10B981)
/// - Subtle translucent ocean-inspired wave forms (_CoastalWaveFormsPainter)
/// - Delicate water-caustic highlights in upper-right & lower-left (_WaterCausticsPainter)
/// - Natural seamless transition to subsequent section (#F0F7F6)
/// - Clean central composition for optimal typography contrast
/// - Fully static with zero continuous wave animations
class AmbientGlowBackground extends StatelessWidget {
  final Widget child;
  final bool showTopRightGlow;
  final bool showBottomGlow;
  final bool useBlurredAsset;
  final double blurSigma;
  final bool enableSeamlessTransition;
  final Color nextSectionColor;
  final bool useLightAtmospheric;

  const AmbientGlowBackground({
    super.key,
    required this.child,
    this.showTopRightGlow = true,
    this.showBottomGlow = false,
    this.useBlurredAsset = false,
    this.blurSigma = 0.0,
    this.enableSeamlessTransition = true,
    this.nextSectionColor = const Color(0xFFF0F7F6),
    this.useLightAtmospheric = false,
  });

  @override
  Widget build(BuildContext context) {
    if (useLightAtmospheric) {
      return _buildCleanAtmosphericBackground();
    }

    return _buildLegacyDarkBackground();
  }

  /// Premium Coastal Light-Mode Hero Background Composition
  Widget _buildCleanAtmosphericBackground() {
    return Stack(
      children: [
        // Layer 1: Warm Ivory Canvas with smooth transition to next section (#F0F7F6)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.35, 0.72, 1.0],
                colors: [
                  const Color(0xFFFAF8F5), // Predominantly warm coastal ivory
                  const Color(0xFFF5FAF8), // Gentle transition to soft coastal sea-mist
                  const Color(0xFFF1F8F6), // Light coastal aqua tint
                  nextSectionColor,        // 100% solid matching FeaturesSection (0xFFF0F7F6)
                ],
              ),
            ),
          ),
        ),

        // Layer 2: Subtle Translucent Ocean-Inspired Wave Forms
        Positioned.fill(
          child: CustomPaint(
            painter: _CoastalWaveFormsPainter(),
          ),
        ),

        // Layer 3: Delicate Water-Caustic Highlights (Upper-Right and Lower-Left)
        Positioned.fill(
          child: CustomPaint(
            painter: _WaterCausticsPainter(),
          ),
        ),

        // Layer 4: Upper-Right Soft Irregular Seafoam & Sunlight Flare
        if (showTopRightGlow)
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 540,
              height: 540,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x1814B8A6), // Soft seafoam
                    Color(0x0A2DD4BF),
                    Color(0x002DD4BF),
                  ],
                  stops: [0.0, 0.48, 1.0],
                ),
              ),
            ),
          ),

        // Layer 5: Lower-Left Soft Irregular Seafoam Glow
        Positioned(
          bottom: 40,
          left: -120,
          child: Container(
            width: 480,
            height: 480,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color(0x1210B981), // Muted emerald seafoam
                  Color(0x0614B8A6),
                  Color(0x0014B8A6),
                ],
                stops: [0.0, 0.50, 1.0],
              ),
            ),
          ),
        ),

        // Layer 6: Central Subtle Aqua Ambient Aura behind the dashboard
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.0, 0.32),
                radius: 0.85,
                colors: [
                  Color(0x120D9488), // Gentle coastal glow
                  Color(0x0814B8A6),
                  Color(0x0014B8A6),
                ],
                stops: [0.0, 0.40, 1.0],
              ),
            ),
          ),
        ),

        // Layer 7: Architectural Precision Dot-Matrix Grid (Subtle)
        Positioned.fill(
          child: CustomPaint(
            painter: _HeroGridPatternPainter(),
          ),
        ),

        // Layer 8: Foreground Child Content
        SafeArea(child: child),
      ],
    );
  }

  /// Legacy Dark Underwater Treatment (for secondary utility screens)
  Widget _buildLegacyDarkBackground() {
    final assetPath = useBlurredAsset
        ? 'assets/images/backgroundBlurred.jpg'
        : 'assets/images/background.jpg';

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            assetPath,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        if (blurSigma > 0.0 && !useBlurredAsset)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: const SizedBox.expand(),
            ),
          ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.45, 0.85],
                colors: [
                  SariwaColors.bgAbyssDark.withValues(alpha: 0.65),
                  SariwaColors.bgAbyssDark.withValues(alpha: 0.52),
                  SariwaColors.bgAbyssDark.withValues(alpha: 0.70),
                ],
              ),
            ),
          ),
        ),
        if (showTopRightGlow)
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 380,
              height: 380,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x2E14B8A6),
                    Color(0x0014B8A6),
                  ],
                ),
              ),
            ),
          ),
        SafeArea(child: child),
      ],
    );
  }
}

/// Subtle Translucent Ocean-Inspired Wave Forms
class _CoastalWaveFormsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    // Organic Wave Form 1: Top-Left coastal curve
    strokePaint.color = const Color(0xFF14B8A6).withValues(alpha: 0.045);
    final path1 = Path()
      ..moveTo(w * -0.05, h * 0.12)
      ..cubicTo(w * 0.15, h * 0.05, w * 0.28, h * 0.22, w * 0.45, h * 0.14)
      ..cubicTo(w * 0.60, h * 0.08, w * 0.72, h * 0.18, w * 1.05, h * 0.09);
    canvas.drawPath(path1, strokePaint);

    // Organic Wave Form 2: Upper-Right contour
    strokePaint.color = const Color(0xFF0D9488).withValues(alpha: 0.035);
    final path2 = Path()
      ..moveTo(w * 0.35, h * 0.0)
      ..cubicTo(w * 0.52, h * 0.16, w * 0.75, h * 0.04, w * 1.05, h * 0.20);
    canvas.drawPath(path2, strokePaint);

    // Organic Wave Form 3: Lower coastal contour below showcase
    strokePaint.color = const Color(0xFF2DD4BF).withValues(alpha: 0.030);
    final path3 = Path()
      ..moveTo(w * -0.05, h * 0.76)
      ..cubicTo(w * 0.22, h * 0.68, w * 0.48, h * 0.84, w * 0.80, h * 0.72)
      ..cubicTo(w * 0.92, h * 0.68, w * 1.02, h * 0.78, w * 1.08, h * 0.75);
    canvas.drawPath(path3, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Delicate Water-Caustic Highlights
/// Recreates the soft, organic light networks created by shallow water sunlight refractions.
class _WaterCausticsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Upper-Right Caustic Network (Aqua Refraction)
    final causticPaintUR = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = const Color(0xFF2DD4BF).withValues(alpha: 0.065)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);

    final urPath = Path()
      ..moveTo(w * 0.68, h * 0.04)
      ..quadraticBezierTo(w * 0.78, h * 0.14, w * 0.92, h * 0.08)
      ..quadraticBezierTo(w * 0.98, h * 0.18, w * 0.88, h * 0.26)
      ..quadraticBezierTo(w * 0.76, h * 0.20, w * 0.68, h * 0.04);
    canvas.drawPath(urPath, causticPaintUR);

    // Upper-Right Sunlit Warmth Caustic Thread
    final urWarmPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0xFFFEF3C7).withValues(alpha: 0.045)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);

    final urWarmPath = Path()
      ..moveTo(w * 0.74, h * 0.08)
      ..cubicTo(w * 0.82, h * 0.16, w * 0.90, h * 0.12, w * 0.96, h * 0.22)
      ..cubicTo(w * 0.88, h * 0.28, w * 0.80, h * 0.24, w * 0.74, h * 0.08);
    canvas.drawPath(urWarmPath, urWarmPaint);

    // Lower-Left Seafoam Caustic Shimmer
    final causticPaintLL = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = const Color(0xFF10B981).withValues(alpha: 0.055)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);

    final llPath = Path()
      ..moveTo(w * -0.05, h * 0.58)
      ..quadraticBezierTo(w * 0.12, h * 0.68, w * 0.08, h * 0.82)
      ..quadraticBezierTo(w * 0.20, h * 0.74, w * 0.26, h * 0.90);
    canvas.drawPath(llPath, causticPaintLL);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Delicate Architectural Dot-Matrix Pattern Painter for Hero Atmosphere
class _HeroGridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 36.0;
    final dotPaint = Paint()..style = PaintingStyle.fill;
    final maxFadeY = size.height * 0.44;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = 24.0; y < maxFadeY; y += spacing) {
        final fade = (1.0 - (y / maxFadeY)).clamp(0.0, 1.0);
        dotPaint.color = const Color(0xFF0F766E).withValues(alpha: 0.035 * fade);
        canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
