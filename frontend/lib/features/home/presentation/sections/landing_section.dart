import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ambient_glow_background.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../landing/presentation/widgets/hero_scanner_card.dart';
import '../../../landing/presentation/widgets/web_navbar.dart';

/// Landing / Hero Section
/// Features 100vh full-screen immersive underwater illustration backdrop
/// with navbar, headline, and the classification model placeholder on the right.
class LandingSection extends StatelessWidget {
  final VoidCallback onHome;
  final VoidCallback onFeatures;
  final VoidCallback onHowItWorks;
  final VoidCallback onDownloads;
  final VoidCallback onLogIn;
  final VoidCallback? onDashboard;
  final VoidCallback? onSignOut;
  final UserModel? user;
  final bool isGuest;
  final VoidCallback? onConnectGoogle;

  const LandingSection({
    super.key,
    required this.onHome,
    required this.onFeatures,
    required this.onHowItWorks,
    required this.onDownloads,
    required this.onLogIn,
    this.onDashboard,
    this.onSignOut,
    this.user,
    this.isGuest = false,
    this.onConnectGoogle,
  });

  @override
  Widget build(BuildContext context) {
    final viewportHeight = MediaQuery.sizeOf(context).height;

    return AmbientGlowBackground(
      showTopRightGlow: true,
      showBottomGlow: true,
      useBlurredAsset: true, // Crisp underwater illustration backdrop
      child: Column(
        children: [
          // Top Web Navbar
          WebNavbar(
            activeTab: 'Home',
            user: user,
            onHome: onHome,
            onFeatures: onFeatures,
            onHowItWorks: onHowItWorks,
            onDownloads: onDownloads,
            onGetStarted: onDownloads,
            onLogIn: onLogIn,
            onDashboard: onDashboard,
            onSignOut: onSignOut,
          ),

          // Guest Evaluation Mode Banner (if guest mode active)
          if (isGuest)
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1140.0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFCCEAE6),
                        width: 1.2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A0A2229),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: LayoutBuilder(
                      builder: (context, c) {
                        final isDesktop = c.maxWidth >= 680;
                        if (!isDesktop) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline_rounded,
                                    color: SariwaColors.brandPrimary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'Guest Evaluation Mode',
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0A2229),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Scan history is temporary. Connect with Google to permanently archive seafood quality audits.',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 12.5,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 12),
                              AppButton.primary(
                                label: 'Connect with Google',
                                icon: SvgPicture.asset(
                                  'assets/icons/google.svg',
                                  width: 15,
                                  height: 15,
                                ),
                                height: 38,
                                width: double.infinity,
                                borderRadius: 19,
                                onPressed: onConnectGoogle,
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: SariwaColors.brandPrimary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Guest Evaluation Mode',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0A2229),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Scan history is temporary. Connect with Google to permanently archive seafood quality audits.',
                                    style: const TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 12.5,
                                      color: Color(0xFF64748B),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            AppButton.primary(
                              label: 'Connect with Google',
                              icon: SvgPicture.asset(
                                'assets/icons/google.svg',
                                width: 15,
                                height: 15,
                              ),
                              height: 38,
                              width: 200,
                              borderRadius: 19,
                              onPressed: onConnectGoogle,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

          // 100vh Hero Container (Desktop fills full screen height accounting for navbar)
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 880;
              final heroMinHeight = isDesktop
                  ? (viewportHeight - 72.0).clamp(560.0, double.infinity)
                  : null;

              return Container(
                constraints: BoxConstraints(minHeight: heroMinHeight ?? 0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1140.0),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: isDesktop ? 32.0 : 40.0,
                      ),
                      child: isDesktop
                          ? _buildDesktopHero(context)
                          : _buildMobileHero(context),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Desktop 2-Column Hero Layout
  Widget _buildDesktopHero(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Column: Headline, Subtitle, Teal "Download App" & Glass "How it works"
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectableText(
                'SariwaBa? See for yourself.',
                style: AppTypography.heroHeadlineDesktop,
              ),
              const SizedBox(height: 18),
              SelectableText(
                'A smarter way to assess fish freshness through AI.',
                style: AppTypography.heroSubtitle.copyWith(fontSize: 17),
              ),
              const SizedBox(height: 32),
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
                    borderRadius: 24,
                    onPressed: onDownloads,
                  ),
                  const SizedBox(width: 14),
                  AppButton.secondary(
                    label: 'How it works',
                    width: 150,
                    height: 48,
                    borderRadius: 24,
                    onPressed: onHowItWorks,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 48),

        // Right Column: Dedicated Classification Placeholder
        const Expanded(flex: 5, child: HeroScannerCard()),
      ],
    );
  }

  /// Mobile Stacked Hero Layout
  Widget _buildMobileHero(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          'SariwaBa? See for yourself.',
          style: AppTypography.heroHeadlineMobile,
        ),
        const SizedBox(height: 14),
        SelectableText(
          'A smarter way to assess fish freshness through AI.',
          style: AppTypography.heroSubtitle.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 24),
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
                onPressed: onDownloads,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton.secondary(
                label: 'How it works',
                height: 48,
                borderRadius: 24,
                onPressed: onHowItWorks,
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),
        const HeroScannerCard(),
      ],
    );
  }
}
