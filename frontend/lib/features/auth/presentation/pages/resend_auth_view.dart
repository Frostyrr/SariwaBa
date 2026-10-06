import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/auth_controller.dart';

class ResendAuthView extends ConsumerStatefulWidget {
  const ResendAuthView({super.key});

  @override
  ConsumerState<ResendAuthView> createState() => _ResendAuthViewState();
}

class _ResendAuthViewState extends ConsumerState<ResendAuthView> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360.0),
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
                          'Log in to SariwaBa',
                          style: AppTypography.authTitle,
                        ),

                        const SizedBox(height: 8),

                        // Subtitle: "Don't have an account? Sign up."
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: AppTypography.authSubtitle,
                            ),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => authController.continueWithGoogle(),
                                child: const Text(
                                  'Sign up.',
                                  style: AppTypography.authSubtitleLink,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // Button 1: "Log in with Google" with "Last used" pill badge
                        AppButton.secondary(
                          label: 'Log in with Google',
                          isLoading: authState.isLoading,
                          icon: SvgPicture.asset(
                            'assets/icons/google.svg',
                            width: 18,
                            height: 18,
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.badgeBg,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                            ),
                            child: const Text(
                              'Last used',
                              style: AppTypography.badgeText,
                            ),
                          ),
                          width: double.infinity,
                          height: 46,
                          borderRadius: 10,
                          onPressed: () => authController.continueWithGoogle(),
                        ),

                        const SizedBox(height: 10),

                        // Button 2: "Continue as Guest"
                        AppButton.secondary(
                          label: 'Continue as Guest',
                          icon: const Icon(
                            Icons.person_outline_rounded,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          width: double.infinity,
                          height: 46,
                          borderRadius: 10,
                          onPressed: () => authController.continueAsGuest(),
                        ),

                        const SizedBox(height: 20),

                        // "or" Divider
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: AppColors.border,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14),
                              child: Text(
                                'or',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: AppColors.border,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Email Field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Email',
                              style: AppTypography.inputLabel,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 46,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 1.0,
                                ),
                              ),
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: AppTypography.inputField,
                                cursorColor: Colors.white,
                                decoration: const InputDecoration(
                                  hintText: 'fisherman@sariwaba.ph',
                                  hintStyle: AppTypography.inputHint,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // White Primary "Log In" Button
                        AppButton.primary(
                          label: 'Log In',
                          isLoading: authState.isLoading,
                          width: double.infinity,
                          height: 46,
                          borderRadius: 10,
                          onPressed: () => authController.continueWithGoogle(),
                        ),

                        const SizedBox(height: 32),

                        // Footer: "By signing in, you agree to our Terms and Privacy Policy."
                        Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            const Text(
                              'By signing in, you agree to our ',
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
