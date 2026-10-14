import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
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
      backgroundColor: SariwaColors.bgAbyssDark,
      body: AmbientGlowBackground(
        showTopRightGlow: true,
        showBottomGlow: true,
        useBlurredAsset: true, // Frosted dynamic sea glass backdrop
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 800;

            return Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
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
                                Image.asset(
                                  'assets/images/SariwaBa with Text.png',
                                  height: 38,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => Image.asset(
                                    'assets/images/SariwaBa logo.png',
                                    height: 32,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.logout_rounded,
                                color: SariwaColors.textSecondaryLight,
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
                          SariwaGlassCard(
                            padding: const EdgeInsets.all(20),
                            borderRadius: 20,
                            surfaceColor: SariwaColors.bgLagoonMid.withValues(alpha: 0.8),
                            borderColor: SariwaColors.brandLight.withValues(alpha: 0.4),
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
                                            color: SariwaColors.brandLight,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Guest Evaluation Mode',
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTypography.titleMedium.copyWith(
                                                fontSize: 15,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Scan history is temporary. Connect with Google to permanently archive seafood quality audits.',
                                        style: AppTypography.caption.copyWith(
                                          fontSize: 12.5,
                                          color: SariwaColors.textSecondaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isDesktop) const SizedBox(width: 20),
                                if (isDesktop)
                                  AppButton.primary(
                                    label: 'Connect with Google',
                                    icon: Container(
                                      width: 20,
                                      height: 20,
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: SvgPicture.asset(
                                        'assets/icons/google.svg',
                                        width: 16,
                                        height: 16,
                                      ),
                                    ),
                                    height: 44,
                                    width: 230,
                                    borderRadius: 22,
                                    onPressed: () => authController.continueWithGoogle(),
                                  ),
                              ],
                            ),
                          ),
                          if (!isDesktop) const SizedBox(height: 12),
                          if (!isDesktop)
                            AppButton.primary(
                              label: 'Connect with Google',
                              icon: Container(
                                width: 20,
                                height: 20,
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: SvgPicture.asset(
                                  'assets/icons/google.svg',
                                  width: 16,
                                  height: 16,
                                ),
                              ),
                              height: 48,
                              width: double.infinity,
                              borderRadius: 24,
                              onPressed: () => authController.continueWithGoogle(),
                            ),
                          const SizedBox(height: 24),
                        ],

                        // Greeting
                        Text(
                          'Hello, ${user?.displayName ?? 'Guest'} ðŸ‘‹',
                          style: AppTypography.headlineLarge.copyWith(
                            fontSize: 26,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isGuest
                              ? 'Run a trial computer vision evaluation below.'
                              : 'Sensory classification telemetry ready.',
                          style: AppTypography.heroSubtitle,
                        ),

                        const SizedBox(height: 28),

                        // Instant AI Seafood Scan Card
                        SariwaGlassCard(
                          padding: const EdgeInsets.all(28),
                          borderRadius: 28,
                          child: Column(
                            children: [
                              Container(
                                width: 84,
                                height: 84,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: SariwaColors.bgAbyssDark.withValues(alpha: 0.5),
                                  border: Border.all(
                                    color: SariwaColors.brandLight.withValues(alpha: 0.4),
                                    width: 1.5,
                                  ),
                                ),
                                child: Image.asset(
                                  'assets/images/SariwaBa logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'Instant AI Seafood Scan',
                                style: AppTypography.titleMedium.copyWith(
                                  fontSize: 18,
                                  color: SariwaColors.textPrimaryLight,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Capture eye cornea or gill area to get instant Grade A/B/C freshness classification.',
                                textAlign: TextAlign.center,
                                style: AppTypography.caption.copyWith(
                                  fontSize: 13,
                                  color: SariwaColors.textSecondaryLight,
                                ),
                              ),
                              const SizedBox(height: 24),
                              AppButton.primary(
                                label: 'Start Camera Scan',
                                height: 50,
                                width: isDesktop ? 260 : double.infinity,
                                borderRadius: 25,
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

                        const SizedBox(height: 32),

                        // Return to Landing Screen
                        Center(
                          child: TextButton.icon(
                            onPressed: () => authController.goToLanding(),
                            icon: const Icon(Icons.arrow_back, size: 16, color: SariwaColors.textMutedLight),
                            label: Text(
                              'Return to Landing Screen',
                              style: AppTypography.caption.copyWith(color: SariwaColors.textMutedLight),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
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
