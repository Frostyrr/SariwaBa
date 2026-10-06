import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ambient_glow_background.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final user = authState.user;
    final isGuest = authState.isGuest;

    return Scaffold(
      backgroundColor: AppColors.oceanAbyss,
      body: AmbientGlowBackground(
        showTopRightGlow: true,
        showBottomGlow: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 800;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 1080.0 : 440.0,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 36.0 : 22.0,
                    vertical: isDesktop ? 24.0 : 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top App Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/logo.svg',
                                width: 28,
                                height: 28,
                              ),
                              const SizedBox(width: 8),
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Sariwa',
                                      style: AppTypography.brandLogo,
                                    ),
                                    TextSpan(
                                      text: 'Ba?',
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.6,
                                        color: AppColors.bioluminescentCyan,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.logout_rounded,
                              color: AppColors.textSecondary,
                              size: 22,
                            ),
                            tooltip: 'Sign Out',
                            onPressed: () => authController.signOut(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Guest Upgrade Banner (if guest mode)
                      if (isGuest) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.oceanSurfaceLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.bioluminescentCyan.withValues(alpha: 0.4),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.bioluminescentCyan.withValues(alpha: 0.12),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.info_outline_rounded,
                                          color: AppColors.bioluminescentCyan,
                                          size: 19,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Guest Evaluation Mode',
                                          style: AppTypography.buttonSecondary.copyWith(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Scan history is temporary. Connect with Google to permanently archive seafood quality audits.',
                                      style: AppTypography.caption.copyWith(
                                        fontSize: 12.5,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isDesktop) const SizedBox(width: 20),
                              if (isDesktop)
                                AppButton.primary(
                                  label: 'Connect with Google',
                                  icon: SvgPicture.asset(
                                    'assets/icons/google.svg',
                                    width: 18,
                                    height: 18,
                                  ),
                                  height: 44,
                                  width: 210,
                                  onPressed: () => authController.continueWithGoogle(),
                                ),
                            ],
                          ),
                        ),
                        if (!isDesktop) const SizedBox(height: 12),
                        if (!isDesktop)
                          AppButton.primary(
                            label: 'Connect with Google',
                            icon: SvgPicture.asset(
                              'assets/icons/google.svg',
                              width: 18,
                              height: 18,
                            ),
                            height: 46,
                            width: double.infinity,
                            onPressed: () => authController.continueWithGoogle(),
                          ),
                        const SizedBox(height: 24),
                      ],

                      // Greeting
                      Text(
                        'Hello, ${user?.displayName ?? 'Guest'} 👋',
                        style: AppTypography.authTitle.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isGuest
                            ? 'Run a trial computer vision evaluation below.'
                            : 'Sensory classification telemetry ready.',
                        style: AppTypography.heroSubtitle,
                      ),

                      const SizedBox(height: 28),

                      // Instant AI Seafood Scan Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.oceanSurface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.bioluminescentCyan.withValues(alpha: 0.15),
                                border: Border.all(
                                  color: AppColors.bioluminescentCyan.withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                color: AppColors.bioluminescentCyan,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'Instant AI Seafood Scan',
                              style: AppTypography.buttonSecondary,
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Capture eye cornea or gill area to get instant Grade A/B/C freshness classification.',
                              textAlign: TextAlign.center,
                              style: AppTypography.caption,
                            ),
                            const SizedBox(height: 22),
                            AppButton.primary(
                              label: 'Start Camera Scan',
                              height: 48,
                              width: isDesktop ? 260 : double.infinity,
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Camera scanner ready for classification.'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Return to Landing Screen
                      Center(
                        child: TextButton.icon(
                          onPressed: () => authController.goToLanding(),
                          icon: const Icon(Icons.arrow_back, size: 16, color: AppColors.textMuted),
                          label: Text(
                            'Return to Landing Screen',
                            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
