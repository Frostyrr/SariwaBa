import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ambient_glow_background.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../widgets/hero_scanner_card.dart';
import '../widgets/web_navbar.dart';

class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.read(authControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AmbientGlowBackground(
        showTopRightGlow: true,
        showBottomGlow: false,
        child: Column(
          children: [
            // Top Web Navbar
            WebNavbar(
              onGetStarted: () => authController.goToLogin(),
              onLogIn: () => authController.goToLogin(),
            ),

            // Hero Body
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 840;

                  return Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 48.0 : 20.0,
                          vertical: isDesktop ? 48.0 : 24.0,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isDesktop ? 1120.0 : 440.0,
                          ),
                          child: isDesktop
                              ? _buildDesktopHero(context, authController)
                              : _buildMobileHero(context, authController),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Desktop 2-Column Hero Layout
  Widget _buildDesktopHero(BuildContext context, AuthController authController) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Column: Headline, Subtitle, White "Get Started" & Dark "How it works"
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Clean Headline
              const Text(
                'Seafood freshness grading.\nStandardized with AI.',
                style: AppTypography.heroHeadlineDesktop,
              ),

              const SizedBox(height: 18),

              // Concise Subtitle
              const Text(
                'Instant quality assessment analyzing cornea clarity, branchial gill pigmentation, and surface texture.',
                style: AppTypography.heroSubtitle,
              ),

              const SizedBox(height: 32),

              // Action Buttons: White "Get Started" + Dark "How it works"
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton.primary(
                    label: 'Get Started',
                    width: 140,
                    height: 44,
                    borderRadius: 8,
                    onPressed: () => authController.goToLogin(),
                  ),
                  const SizedBox(width: 14),
                  AppButton.secondary(
                    label: 'How it works',
                    width: 140,
                    height: 44,
                    borderRadius: 8,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Methodology and camera inspection guide.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 56),

        // Right Column: Clean Telemetry Showcase
        const Expanded(
          flex: 5,
          child: HeroScannerCard(),
        ),
      ],
    );
  }

  /// Mobile Stacked Hero Layout
  Widget _buildMobileHero(BuildContext context, AuthController authController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Headline
        const Text(
          'Seafood freshness grading.\nStandardized with AI.',
          style: AppTypography.heroHeadlineMobile,
        ),

        const SizedBox(height: 14),

        // Subtitle
        const Text(
          'Instant quality assessment analyzing cornea clarity, gill redness, and texture.',
          style: AppTypography.heroSubtitle,
        ),

        const SizedBox(height: 24),

        // Action Buttons Row
        Row(
          children: [
            Expanded(
              child: AppButton.primary(
                label: 'Get Started',
                height: 46,
                borderRadius: 8,
                onPressed: () => authController.goToLogin(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton.secondary(
                label: 'How it works',
                height: 46,
                borderRadius: 8,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Methodology and camera inspection guide.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 36),

        // Telemetry Card
        const HeroScannerCard(),
      ],
    );
  }
}
