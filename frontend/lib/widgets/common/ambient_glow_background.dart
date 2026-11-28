import 'package:material_ui/material_ui.dart';

import '../../constants/theme/app_colors.dart';

/// Atmospheric Background Stack
/// Single restrained coastal motif: soft top-edge wash of `backgroundBlurred.jpg`
/// masked smoothly into a luminous seafoam-to-white daylight gradient.
/// Zero competing multi-layer wallpaper painters, zero continuous animations.
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
    this.nextSectionColor = SariwaColors.colorWorkspace,
    this.useLightAtmospheric = false,
  });

  @override
  Widget build(BuildContext context) {
    if (useLightAtmospheric) {
      return _buildCleanAtmosphericBackground();
    }

    return _buildLegacyDarkBackground();
  }

  /// Restrained Coastal Light-Mode Hero Backdrop:
  /// One soft top-edge `backgroundBlurred.jpg` canopy wash dissolving cleanly
  /// into daylight seafoam -> `nextSectionColor` (#FFFFFF) with zero hard seam.
  Widget _buildCleanAtmosphericBackground() {
    return Stack(
      children: [
        // Layer 1: Smooth vertical daylight gradient into nextSectionColor
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.45, 0.78, 1.0],
                colors: [
                  SariwaColors.colorPale,
                  SariwaColors.colorWorkspace,
                  SariwaColors.cardSurfaceLight,
                  nextSectionColor,
                ],
              ),
            ),
          ),
        ),

        // Layer 2: Soft top-edge canopy wash using backgroundBlurred.jpg
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 440,
          child: RepaintBoundary(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.55, 1.0],
                colors: [
                  Colors.white,
                  Color(0x55FFFFFF),
                  Colors.transparent,
                ],
              ).createShader(bounds),
              blendMode: BlendMode.dstIn,
              child: Opacity(
                opacity: 0.16,
                child: Image.asset(
                  'assets/images/backgroundBlurred.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ),

        // Layer 3: Foreground content
        SafeArea(child: child),
      ],
    );
  }

  /// Legacy Dark Underwater Treatment (for secondary dark utility screens)
  Widget _buildLegacyDarkBackground() {
    final assetPath = useBlurredAsset
        ? 'assets/images/backgroundBlurred.jpg'
        : 'assets/images/background.png';

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            assetPath,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                const ColoredBox(color: SariwaColors.bgAbyssDark),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
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
        SafeArea(child: child),
      ],
    );
  }
}
