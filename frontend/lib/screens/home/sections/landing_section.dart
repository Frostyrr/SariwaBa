import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants/theme/app_colors.dart';
import '../../../constants/theme/app_typography.dart';
import '../../../models/auth/user_model.dart';
import '../../../widgets/common/ambient_glow_background.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/staggered_reveal.dart';
import '../../../widgets/landing/dashboard_showcase.dart';

/// Coastal Light-Mode Hero / Landing Section
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
      nextSectionColor: SariwaColors.cardSurfaceLight,
      child: Column(
        children: [
          // Top spacer compensating for sticky 56px + 20px padding WebNavbar
          const SizedBox(height: 80),

          // Guest Evaluation Mode Banner
          if (isGuest)
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1140.0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: SariwaColors.cardSurfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: SariwaColors.colorLine,
                        width: 1.0,
                      ),
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
                                    CupertinoIcons.info_circle,
                                    color: SariwaColors.brandPrimary,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Guest Evaluation Mode',
                                      style: TextStyle(
                                        letterSpacing: -0.2,
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: SariwaColors.textPrimaryDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Scan history is temporary. Connect with Google to archive seafood quality audits.',
                                style: TextStyle(
                                  letterSpacing: -0.1,
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                  color: SariwaColors.inkSlateMuted,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (onDashboard != null) ...[
                                OutlinedButton.icon(
                                  key: const Key('guest_open_scanner_button'),
                                  onPressed: onDashboard,
                                  icon: const Icon(
                                    CupertinoIcons.camera_viewfinder,
                                    size: 16,
                                  ),
                                  label: const Text('Open Live Scanner'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: SariwaColors.brandPrimary,
                                    side: const BorderSide(
                                      color: SariwaColors.brandPrimary,
                                    ),
                                    minimumSize: const Size(
                                      double.infinity,
                                      44,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                              AppButton.primary(
                                label: 'Connect with Google',
                                icon: SvgPicture.asset(
                                  'assets/icons/google.svg',
                                  width: 16,
                                  height: 16,
                                ),
                                height: 44,
                                width: double.infinity,
                                borderRadius: 12,
                                onPressed: onConnectGoogle,
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            const Icon(
                              CupertinoIcons.info_circle,
                              color: SariwaColors.brandPrimary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Guest Evaluation Mode',
                                    style: TextStyle(
                                      letterSpacing: -0.2,
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: SariwaColors.textPrimaryDark,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Scan history is temporary. Connect with Google to archive seafood quality audits.',
                                    style: TextStyle(
                                      letterSpacing: -0.1,
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300,
                                      color: SariwaColors.inkSlateMuted,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (onDashboard != null) ...[
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                key: const Key('guest_open_scanner_button'),
                                onPressed: onDashboard,
                                icon: const Icon(
                                  CupertinoIcons.camera_viewfinder,
                                  size: 16,
                                ),
                                label: const Text('Open Live Scanner'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: SariwaColors.brandPrimary,
                                  side: const BorderSide(
                                    color: SariwaColors.brandPrimary,
                                  ),
                                  minimumSize: const Size(160, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(width: 12),
                            AppButton.primary(
                              label: 'Connect with Google',
                              icon: SvgPicture.asset(
                                'assets/icons/google.svg',
                                width: 16,
                                height: 16,
                              ),
                              height: 40,
                              width: 200,
                              borderRadius: 12,
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

          // Centered Editorial Hero Content
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1140.0),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24.0,
                  isDesktop ? 48.0 : 36.0,
                  24.0,
                  40.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Semantics(
                      header: true,
                      child: StaggeredReveal(
                        staggerIndex: 0,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 820),
                          child: Text(
                            'A clearer perspective on fish freshness.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: isDesktop ? 48 : 36,
                              fontWeight: FontWeight.w500,
                              letterSpacing: isDesktop ? -1.2 : -0.8,
                              height: 1.12,
                              color: SariwaColors.textPrimaryDark,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    StaggeredReveal(
                      staggerIndex: 1,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: const Text(
                          'Check Tilapia freshness from a close-up eye or gill photo, on web or mobile.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            height: 1.5,
                            letterSpacing: -0.15,
                            color: SariwaColors.inkSlateSecondary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Primary & Secondary Action CTAs
                    StaggeredReveal(
                      staggerIndex: 2,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          AppButton.primary(
                            label: 'Start assessing',
                            trailing: const Icon(
                              CupertinoIcons.arrow_right,
                              size: 16,
                              color: Colors.white,
                            ),
                            width: isDesktop ? 184 : null,
                            height: 48,
                            borderRadius: 999,
                            onPressed: onDashboard ?? onDownloads,
                          ),
                          AppButton.secondary(
                            label: 'Explore how it works',
                            width: isDesktop ? 196 : null,
                            height: 48,
                            borderRadius: 999,
                            onPressed: onHowItWorks,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Smooth Gradient Dissolve Bridge: Dashboard Preview straddling Hero -> Features (#FFFFFF)
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.35, 0.72, 1.0],
                      colors: [
                        Colors.transparent,
                        SariwaColors.cardSurfaceLight.withValues(alpha: 0.45),
                        SariwaColors.cardSurfaceLight.withValues(alpha: 0.92),
                        SariwaColors.cardSurfaceLight,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  24.0,
                  0.0,
                  24.0,
                  isDesktop ? 24.0 : 16.0,
                ),
                child: StaggeredReveal(
                  staggerIndex: 3,
                  slideOffset: const Offset(0, 24),
                  child: isDesktop
                      ? DashboardShowcase(
                          width: (screenWidth * 0.82).clamp(840.0, 1080.0),
                        )
                      : _buildMobileAppPreviewCard(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Native-scale mobile preview card aligned with the real CurrentScanPanel.
  Widget _buildMobileAppPreviewCard() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: SariwaColors.freshIconBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: SariwaColors.freshBorder, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: SariwaColors.shadowSubtle,
              blurRadius: 20,
              offset: Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/sample_tilapia2.jpg',
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 48,
                      height: 48,
                      color: SariwaColors.freshTrack,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fresh',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: SariwaColors.statusFresh,
                        ),
                      ),
                      Text(
                        'Confidence · 94.7%',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: SariwaColors.textPrimaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: const LinearProgressIndicator(
                value: 0.947,
                minHeight: 8,
                backgroundColor: SariwaColors.cardSurfaceLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  SariwaColors.statusFresh,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Visual freshness estimate — not a food-safety guarantee.',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w300,
                height: 1.4,
                color: SariwaColors.inkSlateSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
