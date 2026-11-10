import 'dart:ui';
import 'package:flutter/material.dart';

import '../../constants/theme/app_colors.dart';

/// Atmospheric Background Stack
/// Supports both the new light-themed gradient composition (pure white/off-white with
/// soft aqua, turquoise, mint ambient lighting, daylight caustics, and seamless section fade)
/// and the legacy dark underwater treatment for secondary utility pages.
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
      return _buildLightAtmosphericBackground();
    }

    return _buildLegacyDarkBackground();
  }

  /// New Visual Direction: Pure Flutter Light Atmospheric Gradient & Caustics
  Widget _buildLightAtmosphericBackground() {
    return Stack(
      children: [
        // Layer 1: Clean Off-White Foundation
        Positioned.fill(
          child: Container(
            color: const Color(0xFFFAFCFB),
          ),
        ),

        // Layer 2: Ethereal Vertical Linear Gradient
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.45, 1.0],
                colors: [
                  Color(0xFFFFFFFF),
                  Color(0xFFF7FCFB),
                  Color(0xFFEFF8F6),
                ],
              ),
            ),
          ),
        ),

        // Layer 3: Architectural Daylight Caustics & Shadow Streaks (matching modern SaaS hero)
        Positioned.fill(
          child: CustomPaint(
            painter: _DaylightCausticsPainter(),
          ),
        ),

        // Layer 4: Central Turquoise/Aqua Bioluminescent Glow behind Dashboard
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.0, 0.30),
                radius: 0.95,
                colors: [
                  const Color(0xFF14B8A6).withValues(alpha: 0.18),
                  const Color(0xFF2DD4BF).withValues(alpha: 0.08),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.50, 1.0],
              ),
            ),
          ),
        ),

        // Layer 5: Top-Right Mint Ambient Light
        if (showTopRightGlow)
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 480,
              height: 480,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF2DD4BF).withValues(alpha: 0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

        // Layer 6: Top-Left Subtle Cyan Tint
        Positioned(
          top: -120,
          left: -100,
          child: Container(
            width: 420,
            height: 420,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF38BDF8).withValues(alpha: 0.10),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Layer 7: Seamless Section Transition (Gradually resolves to exact nextSectionColor)
        if (enableSeamlessTransition)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 320,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 0.80, 1.0],
                  colors: [
                    Colors.transparent,
                    Color(0x33CCEAE6),
                    Color(0x88E2F3F0),
                    nextSectionColor, // 100% solid matching FeaturesSection exactly
                  ],
                ),
              ),
            ),
          ),

        // Layer 8: Foreground Child
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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    SariwaColors.brandGlow.withValues(alpha: 0.18),
                    Colors.transparent,
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

/// Custom painter for soft, architectural daylight streaks across the light hero
class _DaylightCausticsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F766E).withValues(alpha: 0.025)
      ..style = PaintingStyle.fill;

    // Diagonal soft daylight band 1
    final path1 = Path()
      ..moveTo(size.width * 0.15, 0)
      ..lineTo(size.width * 0.40, 0)
      ..lineTo(size.width * 0.15, size.height)
      ..lineTo(size.width * -0.10, size.height)
      ..close();
    canvas.drawPath(path1, paint);

    // Diagonal soft daylight band 2
    final path2 = Path()
      ..moveTo(size.width * 0.65, 0)
      ..lineTo(size.width * 0.90, 0)
      ..lineTo(size.width * 0.65, size.height)
      ..lineTo(size.width * 0.40, size.height)
      ..close();
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
