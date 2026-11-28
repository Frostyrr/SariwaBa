import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';

/// Unified iOS 26 Liquid Glass Startup Screen displayed while restoring
/// authentication and local cache state on both Web and Mobile.
class SariwaStartupScreen extends StatefulWidget {
  const SariwaStartupScreen({super.key});

  @override
  State<SariwaStartupScreen> createState() => _SariwaStartupScreenState();
}

class _SariwaStartupScreenState extends State<SariwaStartupScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion && _pulseController.isAnimating) {
      _pulseController.value = 0.5;
    } else if (!reduceMotion && !_pulseController.isAnimating) {
      _pulseController.repeat();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: SariwaColors.bgObsidian,
        body: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.15),
                  radius: 0.85,
                  colors: [
                    SariwaColors.brandPrimary.withValues(alpha: 0.26),
                    SariwaColors.bgObsidianElevated.withValues(alpha: 0.90),
                    SariwaColors.bgObsidian,
                  ],
                  stops: const [0.0, 0.52, 1.0],
                ),
              ),
            ),
            Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  final wave =
                      0.5 - 0.5 * math.cos(_pulseController.value * 2 * math.pi);
                  final scale = 0.98 + (wave * 0.04);

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.scale(
                        scale: scale,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              width: 80,
                              height: 80,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: SariwaColors.liquidGlassSurface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: SariwaColors.liquidGlassSpecular,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: SariwaColors.liquidGlassShadow,
                                    blurRadius: 24,
                                    offset: Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/images/SariwaBa logo.png',
                                fit: BoxFit.contain,
                                semanticLabel: 'SariwaBa logo',
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'SariwaBa',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.4,
                          color: SariwaColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Preparing scanner...',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          color: SariwaColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 140,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: const LinearProgressIndicator(
                            minHeight: 4,
                            backgroundColor: SariwaColors.liquidGlassHairline,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              SariwaColors.brandLight,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
