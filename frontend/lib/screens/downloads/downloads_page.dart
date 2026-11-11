import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/theme/app_colors.dart';
import '../../constants/theme/timber_typography.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../widgets/common/ambient_glow_background.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/staggered_reveal.dart';
import '../../widgets/navigation/web_footer.dart';
import '../../widgets/navigation/web_navbar.dart';

/// Downloads Page
/// Cohesive with the Home Page & Dashboard aesthetic:
/// Features the atmospheric ocean-mint gradient background, sticky floating glass pill navbar,
/// Timber UI minimalist typography, and frosted glass platform cards (iOS, Android, Web).
class DownloadsPage extends ConsumerWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F6),
      body: Stack(
        children: [
          // Content Area with Ambient Gradient Background
          Positioned.fill(
            child: AmbientGlowBackground(
              showTopRightGlow: true,
              showBottomGlow: false,
              useLightAtmospheric: true,
              nextSectionColor: const Color(0xFFF0F7F6),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Top spacer compensating for sticky floating glass pill WebNavbar
                    const SizedBox(height: 84),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 48.0,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1120.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Eyebrow Tag: "DOWNLOAD" (Frosted Glass Pill)
                              StaggeredReveal(
                                staggerIndex: 0,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(99),
                                  child: BackdropFilter(
                                    filter: ui.ImageFilter.blur(
                                      sigmaX: 10,
                                      sigmaY: 10,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0x99E6F7F5),
                                        borderRadius: BorderRadius.circular(99),
                                        border: Border.all(
                                          color: const Color(0xFFCCEAE6),
                                          width: 1.0,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x080F172A),
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Text(
                                        'DOWNLOAD',
                                        style: TextStyle(
                                          fontFamily:
                                              TimberTypography.primarySansFamily,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.8,
                                          color: SariwaColors.brandPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 18),

                              // Heading: "Get SariwaBa."
                              StaggeredReveal(
                                staggerIndex: 1,
                                child: Text(
                                  'Get SariwaBa.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily:
                                        TimberTypography.primarySansFamily,
                                    fontSize: isDesktop ? 46 : 34,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing:
                                        -0.03 * (isDesktop ? 46 : 34),
                                    height: 1.15,
                                    color: const Color(0xFF0A2229),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Subtitle
                              StaggeredReveal(
                                staggerIndex: 2,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 620,
                                  ),
                                  child: const Text(
                                    'Free on Android and iOS. Evaluate seafood freshness on your phone with zero delay. Or launch directly in your browser without installing anything.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily:
                                          TimberTypography.primarySansFamily,
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w300,
                                      color: Color(0xFF475569),
                                      height: 1.55,
                                      letterSpacing: -0.15,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 48),

                              // Platform Cards Grid (iOS, Android, Web)
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final isWide = constraints.maxWidth >= 900;

                                  if (isWide) {
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: StaggeredReveal(
                                            staggerIndex: 3,
                                            child: _buildIosCard(context),
                                          ),
                                        ),
                                        const SizedBox(width: 24),
                                        Expanded(
                                          child: StaggeredReveal(
                                            staggerIndex: 4,
                                            child: _buildAndroidCard(context),
                                          ),
                                        ),
                                        const SizedBox(width: 24),
                                        Expanded(
                                          child: StaggeredReveal(
                                            staggerIndex: 5,
                                            child: _buildWebCard(
                                              context,
                                              authController,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Column(
                                      children: [
                                        StaggeredReveal(
                                          staggerIndex: 3,
                                          child: _buildIosCard(context),
                                        ),
                                        const SizedBox(height: 20),
                                        StaggeredReveal(
                                          staggerIndex: 4,
                                          child: _buildAndroidCard(context),
                                        ),
                                        const SizedBox(height: 20),
                                        StaggeredReveal(
                                          staggerIndex: 5,
                                          child: _buildWebCard(
                                            context,
                                            authController,
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),

                              const SizedBox(height: 52),

                              // Bottom Disclaimer Capsule (Frosted Glass Pill)
                              StaggeredReveal(
                                staggerIndex: 6,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(99),
                                  child: BackdropFilter(
                                    filter: ui.ImageFilter.blur(
                                      sigmaX: 12,
                                      sigmaY: 12,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.55,
                                        ),
                                        borderRadius: BorderRadius.circular(99),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.85,
                                          ),
                                          width: 1.0,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x060F172A),
                                            blurRadius: 12,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            CupertinoIcons.info_circle,
                                            size: 15,
                                            color: SariwaColors.brandPrimary,
                                          ),
                                          SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              'SariwaBa scans fish freshness directly on your device. An internet connection is only needed to sync saved scan history.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily:
                                                    TimberTypography
                                                        .primarySansFamily,
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w300,
                                                letterSpacing: -0.1,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 64),
                            ],
                          ),
                        ),
                      ),
                    ),
                    WebFooter(
                      onHome: () => authController.goToLanding(),
                      onFeatures: () => authController.goToLanding(),
                      onHowItWorks: () => authController.goToLanding(),
                      onDownloads: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Sticky Top Floating Glass Pill Web Navbar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: WebNavbar(
              activeTab: 'Downloads',
              isLight: true,
              user: authState.user,
              onHome: () => authController.goToLanding(),
              onFeatures: () => authController.goToFeatures(),
              onHowItWorks: () => authController.goToHowItWorks(),
              onDashboard: () => authController.goToDashboard(),
              onSignOut: () => authController.signOut(),
              onDownloads: () {},
              onGetStarted: () {},
              onLogIn: () => authController.goToLogin(),
            ),
          ),
        ],
      ),
    );
  }

  /// Platform 1: iPhone & iPad
  Widget _buildIosCard(BuildContext context) {
    return _PlatformCard(
      icon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F9FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFBAE6FD),
            width: 1.0,
          ),
        ),
        child: const Icon(
          Icons.apple_rounded,
          color: Color(0xFF0284C7),
          size: 28,
        ),
      ),
      title: 'iPhone & iPad',
      description:
          'One universal app with a live camera scanner and offline freshness checking.',
      features: const [
        'iOS 16.0 or later',
        'iPhone and iPad supported',
        'Camera live scanner mode',
      ],
      buttonLabel: 'Get it on App Store',
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('iOS build coming soon to TestFlight & App Store!'),
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }

  /// Platform 2: Android (Primary Release)
  Widget _buildAndroidCard(BuildContext context) {
    return _PlatformCard(
      icon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFA7F3D0),
            width: 1.0,
          ),
        ),
        child: const Icon(
          Icons.android_rounded,
          color: Color(0xFF059669),
          size: 28,
        ),
      ),
      title: 'Android',
      description:
          'Phones and tablets with instant AI freshness grading and Google Sign-in.',
      features: const [
        'Android 8.0 or later',
        'Google Play Services',
        'Google Sign-in integrated',
      ],
      buttonLabel: 'Get it on Google Play',
      isPrimaryPlatform: true,
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Android APK available in release artifacts & Google Play.',
            ),
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }

  /// Platform 3: Web
  Widget _buildWebCard(BuildContext context, AuthController authController) {
    return _PlatformCard(
      icon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFE6F7F5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFCCEAE6),
            width: 1.0,
          ),
        ),
        child: const Icon(
          Icons.laptop_chromebook_rounded,
          color: SariwaColors.brandPrimary,
          size: 26,
        ),
      ),
      title: 'Web',
      description:
          'Instant quality audits in any desktop or mobile browser. Nothing to install.',
      features: const [
        'Any modern browser (Chrome, Safari, Edge)',
        'Zero installation required',
        'Responsive inspection dashboard',
      ],
      buttonLabel: 'Open the web app',
      onPressed: () => authController.goToLogin(),
    );
  }
}

/// Frosted Glass Platform Card Widget
class _PlatformCard extends StatefulWidget {
  final Widget icon;
  final String title;
  final String description;
  final List<String> features;
  final String buttonLabel;
  final VoidCallback onPressed;
  final bool isPrimaryPlatform;

  const _PlatformCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.features,
    required this.buttonLabel,
    required this.onPressed,
    this.isPrimaryPlatform = false,
  });

  @override
  State<_PlatformCard> createState() => _PlatformCardState();
}

class _PlatformCardState extends State<_PlatformCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const double borderRadius = 24.0;
    final isPrimary = widget.isPrimaryPlatform;

    // Outer unclipped drop shadow multi-layer stack
    final List<BoxShadow> shadows = [
      BoxShadow(
        color: isPrimary
            ? const Color(0x1814B8A6)
            : const Color(0x0A0F172A), // 4% subtle contact drop shadow
        blurRadius: _isHovered ? 24 : 18,
        offset: const Offset(0, 4),
        spreadRadius: -2,
      ),
      BoxShadow(
        color: isPrimary
            ? const Color(0x1214B8A6)
            : const Color(0x060F172A), // 2.5% soft ambient elevation
        blurRadius: _isHovered ? 44 : 36,
        offset: Offset(0, _isHovered ? 16 : 12),
        spreadRadius: -4,
      ),
      if (isPrimary)
        BoxShadow(
          color: const Color(0x100F766E), // Teal glow for primary release card
          blurRadius: _isHovered ? 36 : 28,
          offset: const Offset(0, 6),
          spreadRadius: -4,
        ),
    ];

    final Color fillColor = isPrimary
        ? (_isHovered
            ? Colors.white.withValues(alpha: 0.82)
            : Colors.white.withValues(alpha: 0.74))
        : (_isHovered
            ? Colors.white.withValues(alpha: 0.76)
            : Colors.white.withValues(alpha: 0.65));

    final Color borderColor = isPrimary
        ? (_isHovered
            ? SariwaColors.brandPrimary.withValues(alpha: 0.60)
            : SariwaColors.brandPrimary.withValues(alpha: 0.40))
        : (_isHovered
            ? SariwaColors.brandPrimary.withValues(alpha: 0.35)
            : Colors.white.withValues(alpha: 0.85));

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: shadows,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: borderColor,
                  width: isPrimary ? 1.5 : 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: Platform Icon + Recommended Badge (for primary)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      widget.icon,
                      if (isPrimary)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F7F5),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                              color: const Color(0xFFBBE5DF),
                              width: 1.0,
                            ),
                          ),
                          child: const Text(
                            'RECOMMENDED',
                            style: TextStyle(
                              fontFamily: TimberTypography.primarySansFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                              color: SariwaColors.brandPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Title
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontFamily: TimberTypography.primarySansFamily,
                      fontSize: 21,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.25,
                      color: Color(0xFF0A2229),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    widget.description,
                    style: const TextStyle(
                      fontFamily: TimberTypography.primarySansFamily,
                      fontSize: 13.5,
                      height: 1.5,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -0.15,
                      color: Color(0xFF64748B),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Features Checklist
                  ...widget.features.map(
                    (feat) => Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: Color(0xFF168077),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              feat,
                              style: const TextStyle(
                                fontFamily: TimberTypography.primarySansFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.15,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Button
                  AppButton.primary(
                    label: widget.buttonLabel,
                    width: double.infinity,
                    height: 48,
                    borderRadius: 24,
                    onPressed: widget.onPressed,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
