import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Underwater Background Stack with Dynamic Frosted Glass overlay
/// Uses background.jpg (or backgroundBlurred.jpg) with gentle radial gradient sheen.
class AmbientGlowBackground extends StatelessWidget {
  final Widget child;
  final bool showTopRightGlow;
  final bool showBottomGlow;
  final bool useBlurredAsset;
  final double blurSigma;

  const AmbientGlowBackground({
    super.key,
    required this.child,
    this.showTopRightGlow = true,
    this.showBottomGlow = false,
    this.useBlurredAsset = false,
    this.blurSigma = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = useBlurredAsset
        ? 'assets/images/backgroundBlurred.jpg'
        : 'assets/images/background.jpg';

    return Stack(
      children: [
        // Layer 1: Underwater Illustration Asset
        Positioned.fill(
          child: Image.asset(
            assetPath,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),

        // Layer 2: Optional Dynamic ImageFilter blur if using unblurred asset
        if (blurSigma > 0.0 && !useBlurredAsset)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: const SizedBox.expand(),
            ),
          ),

        // Layer 3: Contrast Protection Gradient (Deep ocean tint over background)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  SariwaColors.bgAbyssDark.withValues(alpha: 0.72),
                  SariwaColors.bgAbyssDark.withValues(alpha: 0.88),
                ],
              ),
            ),
          ),
        ),

        // Layer 4: Subtle Cyan Bioluminescent Ambient Glow
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

        if (showBottomGlow)
          Positioned(
            bottom: -150,
            left: -80,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    SariwaColors.brandLight.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

        // Layer 5: Foreground Child (Sizes the Stack in any layout context)
        SafeArea(
          child: child,
        ),
      ],
    );
  }
}
