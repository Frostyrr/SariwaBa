import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants/theme/app_colors.dart';
import '../../../constants/theme/app_typography.dart';
import '../../../models/auth/user_model.dart';
import '../../../widgets/common/ambient_glow_background.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/staggered_reveal.dart';
import '../../../widgets/landing/dashboard_showcase.dart';

/// Coastal Light-Mode Hero / Landing Section
/// Features a warm ivory and soft seafoam atmospheric background,
/// deep forest-green typography, centered editorial hierarchy,
/// and a prominent static showcase of the actual SariwaBa? dashboard.
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 880;

    return AmbientGlowBackground(
      showTopRightGlow: true,
      showBottomGlow: false,
      useLightAtmospheric: true,
      nextSectionColor: const Color(0xFFF0F7F6),
      child: Column(
        children: [
          // Top spacer compensating for sticky 72px WebNavbar
          const SizedBox(height: 80),

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
                        final isWide = c.maxWidth >= 680;
                        if (!isWide) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: SariwaColors.brandPrimary,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Guest Evaluation Mode',
                                      style: TextStyle(
                                        letterSpacing: -0.25,
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
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
                                  letterSpacing: -0.25,
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w300,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (onDashboard != null) ...[
                                OutlinedButton.icon(
                                  key: const Key('guest_open_scanner_button'),
                                  onPressed: onDashboard,
                                  icon: const Icon(
                                    Icons.camera_alt_outlined,
                                    size: 16,
                                  ),
                                  label: const Text('Open Live Scanner'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: SariwaColors.brandPrimary,
                                    side: const BorderSide(
                                      color: SariwaColors.brandPrimary,
                                    ),
                                    minimumSize:
                                        const Size(double.infinity, 38),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(19),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
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
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Guest Evaluation Mode',
                                    style: TextStyle(
                                      letterSpacing: -0.25,
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF0A2229),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Scan history is temporary. Connect with Google to permanently archive seafood quality audits.',
                                    style: TextStyle(
                                      letterSpacing: -0.25,
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
                            if (onDashboard != null) ...[
                              const SizedBox(width: 10),
                              OutlinedButton.icon(
                                key: const Key('guest_open_scanner_button'),
                                onPressed: onDashboard,
                                icon: const Icon(
                                  Icons.camera_alt_outlined,
                                  size: 16,
                                ),
                                label: const Text('Open Live Scanner'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: SariwaColors.brandPrimary,
                                  side: const BorderSide(
                                    color: SariwaColors.brandPrimary,
                                  ),
                                  minimumSize: const Size(160, 38),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(19),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(width: 10),
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

          // Centered Coastal Hero Content
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1140.0),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: isDesktop ? 48.0 : 36.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Deep Forest-Green Headline
                    StaggeredReveal(
                      staggerIndex: 0,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 820),
                        child: Text(
                          'A clearer perspective on fish freshness.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: isDesktop ? 54 : 36,
                            fontWeight: FontWeight.w500, // Medium
                            letterSpacing: -0.25,
                            height: 1.14,
                            color: const Color(0xFF0A2B24), // Deep forest-green
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Concise Supporting Copy
                    StaggeredReveal(
                      staggerIndex: 1,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 680),
                        child: Text(
                          'Assess fish freshness through image-based machine learning, with results designed to support more informed decisions.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: isDesktop ? 17.5 : 15,
                            fontWeight: FontWeight.w300,
                            height: 1.55,
                            letterSpacing: -0.25,
                            color: const Color(0xFF334E48), // Muted coastal forest-slate
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Primary & Secondary Action CTAs
                    StaggeredReveal(
                      staggerIndex: 2,
                      child: SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 16,
                            runSpacing: 12,
                            children: [
                              // Primary CTA: Start assessing (Preserving established primary button styling)
                              AppButton.primary(
                                label: 'Start assessing',
                                icon: const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                width: isDesktop ? 180 : null,
                                height: 48,
                                borderRadius: 24,
                                onPressed: onDashboard ?? onDownloads,
                              ),

                              // Secondary CTA: Explore how it works
                              AppButton.secondary(
                                label: 'Explore how it works',
                                width: isDesktop ? 190 : null,
                                height: 48,
                                borderRadius: 24,
                                onPressed: onHowItWorks,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 52),

                    // Middle Centerpiece: Static Showcase of the Actual SariwaBa? Dashboard
                    StaggeredReveal(
                      staggerIndex: 3,
                      slideOffset: const Offset(0, 32),
                      child: DashboardShowcase(
                        width: isDesktop
                            ? (screenWidth * 0.82).clamp(840.0, 1080.0)
                            : screenWidth - 32,
                      ),
                    ),

                    const SizedBox(height: 64),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
