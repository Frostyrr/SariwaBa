import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ambient_glow_background.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../widgets/hero_scanner_card.dart';
import '../widgets/landing_sections.dart';
import '../widgets/web_footer.dart';
import '../widgets/web_navbar.dart';

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _howItWorksKey = GlobalKey();

  void _scrollToKey(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = ref.read(authControllerProvider.notifier);

    return Scaffold(
      backgroundColor: SariwaColors.bgAbyssDark,
      body: AmbientGlowBackground(
        showTopRightGlow: true,
        showBottomGlow: true,
        useBlurredAsset: false, // Crystal-clear underwater illustration backdrop
        child: Column(
          children: [
            // Top Web Navbar with Smooth Scroll callbacks
            WebNavbar(
              activeTab: 'Home',
              onHome: () => _scrollToKey(_homeKey),
              onFeatures: () => _scrollToKey(_featuresKey),
              onHowItWorks: () => _scrollToKey(_howItWorksKey),
              onDownloads: () => authController.goToDownloads(),
              onGetStarted: () => authController.goToDownloads(),
              onLogIn: () => authController.goToLogin(),
            ),

            // Scrollable Body containing Hero, Features, How it Works, and Footer
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Section 1: Hero Showcase
                    Container(
                      key: _homeKey,
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1120.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final isDesktop = constraints.maxWidth >= 840;
                                return isDesktop
                                    ? _buildDesktopHero(context, authController)
                                    : _buildMobileHero(context, authController);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Section 2: Features Section
                    Container(
                      key: _featuresKey,
                      padding: const EdgeInsets.symmetric(vertical: 48.0),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1120.0),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.0),
                            child: FeaturesSection(),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Section 3: How It Works Section
                    Container(
                      key: _howItWorksKey,
                      padding: const EdgeInsets.symmetric(vertical: 48.0),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1040.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: HowItWorksSection(
                              onDownload: () => authController.goToDownloads(),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 72),

                    // Section 4: Web Footer
                    WebFooter(
                      onHome: () => _scrollToKey(_homeKey),
                      onFeatures: () => _scrollToKey(_featuresKey),
                      onHowItWorks: () => _scrollToKey(_howItWorksKey),
                      onDownloads: () => authController.goToDownloads(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Desktop 2-Column Hero Layout (pill badge removed)
  Widget _buildDesktopHero(BuildContext context, AuthController authController) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Column: Headline, Subtitle, Teal "Download App" & Aquatic "How it works"
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Requested Headline
              SelectableText(
                'SariwaBa? See for yourself.',
                style: AppTypography.heroHeadlineDesktop,
              ),

              const SizedBox(height: 18),

              // Requested Subtitle
              SelectableText(
                'A smarter way to assess fish freshness through AI.',
                style: AppTypography.heroSubtitle.copyWith(fontSize: 17),
              ),

              const SizedBox(height: 32),

              // Action Buttons: Teal "Download App" + Glass "How it works"
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton.primary(
                    label: 'Download App',
                    icon: const Icon(
                      Icons.download_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    width: 170,
                    height: 48,
                    borderRadius: 24, // Squircle pill
                    onPressed: () => authController.goToDownloads(),
                  ),
                  const SizedBox(width: 14),
                  AppButton.secondary(
                    label: 'How it works',
                    width: 150,
                    height: 48,
                    borderRadius: 24,
                    onPressed: () => _scrollToKey(_howItWorksKey),
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

  /// Mobile Stacked Hero Layout (pill badge removed)
  Widget _buildMobileHero(BuildContext context, AuthController authController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Headline
        SelectableText(
          'SariwaBa? See for yourself.',
          style: AppTypography.heroHeadlineMobile,
        ),

        const SizedBox(height: 14),

        // Subtitle
        SelectableText(
          'A smarter way to assess fish freshness through AI.',
          style: AppTypography.heroSubtitle.copyWith(fontSize: 16),
        ),

        const SizedBox(height: 24),

        // Action Buttons Row
        Row(
          children: [
            Expanded(
              child: AppButton.primary(
                label: 'Download App',
                icon: const Icon(
                  Icons.download_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                height: 48,
                borderRadius: 24,
                onPressed: () => authController.goToDownloads(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton.secondary(
                label: 'How it works',
                height: 48,
                borderRadius: 24,
                onPressed: () => _scrollToKey(_howItWorksKey),
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
