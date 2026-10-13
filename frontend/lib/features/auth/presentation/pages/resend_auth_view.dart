import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/auth_controller.dart';
import '../widgets/google_auth_button.dart';

class ResendAuthView extends ConsumerWidget {
  const ResendAuthView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.read(authControllerProvider.notifier);
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.chevron_left_rounded,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Home',
                        style: AppTypography.navLink.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Center: Resend-Styled Auth Card
            Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 32.0,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Centered Logo Container Tile
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.border,
                              width: 1.0,
                            ),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: SvgPicture.asset(
                            'assets/icons/logo.svg',
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Title
                        const Text(
                          'Sign in to SariwaBa',
                          style: AppTypography.authTitle,
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Continue with your Google account to access fish grading and scan histories.',
                          textAlign: TextAlign.center,
                          style: AppTypography.authSubtitle,
                        ),

                        const SizedBox(height: 24),

                        // Error Banner if present
                        if (authState.errorMessage != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade900.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.red.shade700,
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: Colors.redAccent,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    authState.errorMessage!,
                                    style: const TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Google Authentication Button (adaptive web / native)
                        GoogleAuthButton(
                          label: 'Continue with Google',
                          isLoading: authState.isLoading,
                          onPressed: () => authController.continueWithGoogle(),
                        ),

                        const SizedBox(height: 12),

                        // Button 2: "Continue as Guest"
                        AppButton.secondary(
                          label: 'Continue as Guest',
                          icon: const Icon(
                            Icons.person_outline_rounded,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          width: double.infinity,
                          height: 48,
                          borderRadius: 10,
                          onPressed: () => authController.continueAsGuest(),
                        ),

                        const SizedBox(height: 32),

                        // Footer: Terms & Privacy
                        Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            const Text(
                              'By continuing, you agree to our ',
                              style: AppTypography.caption,
                            ),
                            Text(
                              'Terms',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const Text(
                              ' and ',
                              style: AppTypography.caption,
                            ),
                            Text(
                              'Privacy Policy',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const Text(
                              '.',
                              style: AppTypography.caption,
                            ),
                          ],
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
