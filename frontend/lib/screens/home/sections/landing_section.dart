import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants/theme/app_colors.dart';
import '../../../constants/theme/app_typography.dart';
import '../../../models/auth/user_model.dart';
import '../../../widgets/common/ambient_glow_background.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/staggered_reveal.dart';
import '../../../widgets/landing/walkthrough/cinematic_inspection_walkthrough.dart';

/// Cinematic Public Landing / Hero Section
/// Features an atmospheric underwater backdrop, centered editorial typography,
/// an automatically playing cursor-driven product walkthrough, and a seamless
/// gradient transition into the next section.
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
      showBottomGlow: true,
      useLightAtmospheric: true,
      enableSeamlessTransition: true,
      nextSectionColor: const Color(0xFFF0F7F6),
      child: Column(
        children: [
          // Top spacer compensating for sticky 72px WebNavbar
          const SizedBox(height: 72),

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
                                        fontWeight: FontWeight.w600,
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
                                      fontWeight: FontWeight.w600,
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

          // Centered Cinematic Hero Content
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
                    // Eyebrow Badge (Light Mode SaaS Pill)
                    StaggeredReveal(
                      staggerIndex: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F7F5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFCCEAE6),
                            width: 1.0,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A0A2229),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF0F766E),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Flexible(
                              child: Text(
                                'SariwaBa? See for yourself.',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.25,
                                  color: Color(0xFF0F766E),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Cinematic Headline
                    StaggeredReveal(
                      staggerIndex: 1,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 820),
                        child: Text(
                          'A clearer perspective on fish freshness.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: isDesktop ? 54 : 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.25,
                            height: 1.14,
                            color: const Color(0xFF0A2229),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Supporting Copy
                    StaggeredReveal(
                      staggerIndex: 2,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 680),
                        child: Column(
                          children: [
                            Text(
                              'A smarter way to assess fish freshness through AI.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: isDesktop ? 18 : 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.25,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Explore AI-assisted fish freshness assessment through a simple, image-based inspection experience.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: isDesktop ? 15.5 : 14,
                                height: 1.5,
                                letterSpacing: -0.25,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Primary & Secondary Action CTAs
                    StaggeredReveal(
                      staggerIndex: 3,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 14,
                        runSpacing: 12,
                        children: [
                          // Primary CTA: Try Inspection
                          AppButton.primary(
                            label: 'Try Inspection',
                            icon: const Icon(
                              Icons.auto_awesome,
                              size: 18,
                              color: Colors.white,
                            ),
                            width: isDesktop ? 180 : null,
                            height: 48,
                            borderRadius: 24,
                            onPressed: onDashboard ?? onDownloads,
                          ),

                          // Secondary CTA: How It Works
                          AppButton.secondary(
                            label: 'How it works',
                            width: isDesktop ? 160 : null,
                            height: 48,
                            borderRadius: 24,
                            onPressed: onHowItWorks,
                          ),

                          // Mobile App Download Button
                          OutlinedButton.icon(
                            onPressed: onDownloads,
                            icon: const Icon(
                              Icons.download_rounded,
                              size: 18,
                              color: SariwaColors.brandPrimary,
                            ),
                            label: const Text(
                              'Download App',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.25,
                                color: Color(0xFF0A2229),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(
                                color: Color(0xFFE2E8F0),
                                width: 1.2,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Social Proof / Trust Badge (Mirroring modern SaaS hero reference)
                    StaggeredReveal(
                      staggerIndex: 4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 3 Overlapping Avatar Circles
                          SizedBox(
                            width: 68,
                            height: 26,
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 0,
                                  child: CircleAvatar(
                                    radius: 13,
                                    backgroundColor: const Color(0xFF14B8A6),
                                    child: const Text('M', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
                                  ),
                                ),
                                Positioned(
                                  left: 18,
                                  child: CircleAvatar(
                                    radius: 13,
                                    backgroundColor: const Color(0xFF0EA5E9),
                                    child: const Text('J', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
                                  ),
                                ),
                                Positioned(
                                  left: 36,
                                  child: CircleAvatar(
                                    radius: 13,
                                    backgroundColor: const Color(0xFF10B981),
                                    child: const Text('R', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Flexible(
                            child: Text(
                              '2,400+ Inspections • Trusted by seafood evaluators & markets',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.25,
                                color: Color(0xFF64748B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Middle Centerpiece: Programmatic Cursor-Driven Demonstration
                    StaggeredReveal(
                      staggerIndex: 4,
                      slideOffset: const Offset(0, 36),
                      child: CinematicInspectionWalkthrough(
                        width: isDesktop ? 840 : screenWidth - 32,
                      ),
                    ),

                    const SizedBox(height: 56),
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
