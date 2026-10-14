import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ambient_glow_background.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/auth_controller.dart';
import '../widgets/google_auth_button.dart';

/// SariwaBa Auth Screen
/// Implements wireframe layout with underwater illustration background,
/// peeking fish logo mascot, hero texts, and stadium pills for authentication.
class AuthPage extends ConsumerWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.read(authControllerProvider.notifier);
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: SariwaColors.bgAbyssDark,
      body: AmbientGlowBackground(
        showTopRightGlow: true,
        showBottomGlow: true,
        useBlurredAsset:
            true, // Soft cinematic depth over underwater background
        child: Stack(
          children: [
            // Top Left: "< Home" Navigation Link
            Positioned(
              top: 16,
              left: 20,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => authController.goToLanding(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: SariwaColors.surfaceGlass,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: SariwaColors.borderGlass,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.chevron_left_rounded,
                          size: 20,
                          color: SariwaColors.brandLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Home',
                          style: AppTypography.navLink.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: SariwaColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Main Content: Aligned with the wireframe layout
            Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28.0,
                    vertical: 36.0,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 390.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),

                        // Center: Version 1 Mascot Logo
                        Hero(
                          tag: 'sariwaba_logo',
                          child: Image.asset(
                            'assets/images/SariwaBa logo.png',
                            width: 160,
                            height: 160,
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Brand Wordmark / Hero texts matching wireframe
                        Text(
                          'SariwaBa',
                          style: AppTypography.displayLarge.copyWith(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'AI-Powered Seafood Freshness Grading',
                          textAlign: TextAlign.center,
                          style: AppTypography.heroSubtitle.copyWith(
                            fontSize: 15,
                            color: SariwaColors.textSecondaryLight,
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Error Banner if present
                        if (authState.errorMessage != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: SariwaColors.statusSpoiled.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: SariwaColors.statusSpoiled,
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: SariwaColors.statusSpoiled,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    authState.errorMessage!,
                                    style: AppTypography.caption.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Wireframe Button 1: "Continue as Guest" (White Pill with dark text)
                        AppButton.lightPill(
                          label: 'Continue as Guest',
                          icon: const Icon(
                            Icons.person_outline_rounded,
                            size: 20,
                            color: SariwaColors.bgAbyssDark,
                          ),
                          width: double.infinity,
                          height: 52,
                          onPressed: () => authController.continueAsGuest(),
                        ),

                        const SizedBox(height: 14),

                        // Wireframe Button 2: "Sign in With Google" (Teal / Dark Pill)
                        GoogleAuthButton(
                          label: 'Sign in with Google',
                          isLoading: authState.isLoading,
                          onPressed: () => authController.continueWithGoogle(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
