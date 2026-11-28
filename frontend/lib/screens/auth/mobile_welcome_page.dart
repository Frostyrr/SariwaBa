import 'dart:ui' as ui;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../widgets/auth/google_auth_button.dart';
import '../../widgets/common/app_button.dart';

/// Native Mobile Welcome & Sign-In Screen (`!kIsWeb` — Android & iOS).
/// Unforced single-screen composition: atmospheric underwater hero at top +
/// anchored light iOS sheet at bottom with Google & Guest actions ready on frame 1.
class MobileWelcomePage extends ConsumerWidget {
  const MobileWelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.read(authControllerProvider.notifier);
    final authState = ref.watch(authControllerProvider);
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: SariwaColors.bgAbyssDark,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Upper Atmospheric Marine Hero
            Positioned.fill(
              child: Image.asset(
                'assets/images/backgroundBlurred.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.45, 0.72, 1.0],
                    colors: [
                      SariwaColors.bgAbyssDark.withValues(alpha: 0.32),
                      SariwaColors.bgAbyssDark.withValues(alpha: 0.56),
                      SariwaColors.bgAbyssDark.withValues(alpha: 0.84),
                      SariwaColors.bgAbyssDark,
                    ],
                  ),
                ),
              ),
            ),

            // Foreground: Left-Aligned Hero Copy + Anchored Light iOS Sheet
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top-left frosted brand pill
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: BackdropFilter(
                              filter: ui.ImageFilter.blur(
                                sigmaX: 14,
                                sigmaY: 14,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: SariwaColors.liquidGlassSurface,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: SariwaColors.liquidGlassHairline,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      'assets/images/SariwaBa logo.png',
                                      width: 20,
                                      height: 20,
                                      fit: BoxFit.contain,
                                      semanticLabel: 'SariwaBa logo',
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'SariwaBa',
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: -0.2,
                                        color: SariwaColors.textPrimaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Left-aligned editorial statement (zero centered AI slop)
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: disableAnimations ? 1.0 : 0.0,
                              end: 1.0,
                            ),
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, (1 - value) * 12),
                                  child: child,
                                ),
                              );
                            },
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Check fish freshness\nin a snap.',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -0.8,
                                    height: 1.12,
                                    color: SariwaColors.textPrimaryLight,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Snap a close-up eye or gill photo for an instant freshness reading.',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300,
                                    height: 1.45,
                                    color: SariwaColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Anchored Light iOS Sheet matching the Dashboard surface
                Container(
                  decoration: const BoxDecoration(
                    color: SariwaColors.cardSurfaceLight,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: SariwaColors.liquidGlassShadow,
                        blurRadius: 24,
                        offset: Offset(0, -8),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container(
                              width: 36,
                              height: 4,
                              decoration: BoxDecoration(
                                color: SariwaColors.colorLine,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (authState.errorMessage != null) ...[
                            _buildErrorBanner(
                              authState.errorMessage as String,
                            ),
                            const SizedBox(height: 16),
                          ],
                          GoogleAuthButton(
                            label: 'Continue with Google',
                            isLoading: authState.isLoading == true,
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              authController.continueWithGoogle();
                            },
                          ),
                          const SizedBox(height: 12),
                          AppButton.secondary(
                            label: 'Continue as Guest',
                            icon: const Icon(
                              CupertinoIcons.viewfinder,
                              size: 18,
                              color: SariwaColors.textPrimaryDark,
                            ),
                            width: double.infinity,
                            height: 52,
                            borderRadius: 999,
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              authController.continueAsGuest();
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Sign in to sync across devices, or scan locally as a guest.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              color: SariwaColors.inkSlateMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: SariwaColors.notFreshIconBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SariwaColors.notFreshBorder),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_circle,
            color: SariwaColors.statusSpoiled,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: SariwaColors.notFreshText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
