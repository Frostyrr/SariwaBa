import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/theme/app_colors.dart';
import '../../constants/theme/timber_typography.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../widgets/common/ambient_glow_background.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/sariwa_scrollbar.dart';
import '../../widgets/common/staggered_reveal.dart';
import '../../widgets/navigation/web_footer.dart';
import '../../widgets/navigation/web_navbar.dart';

/// Downloads Page
/// Clean bordered platform cards with stable hover states and accurate architecture copy.
class DownloadsPage extends ConsumerWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      backgroundColor: SariwaColors.colorWorkspace,
      body: Stack(
        children: [
          Positioned.fill(
            child: AmbientGlowBackground(
              showTopRightGlow: true,
              showBottomGlow: false,
              useLightAtmospheric: true,
              nextSectionColor: SariwaColors.colorWorkspace,
              child: SariwaScrollbar(
                builder: (context, controller) => SingleChildScrollView(
                  controller: controller,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 80),
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
                                StaggeredReveal(
                                  staggerIndex: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: SariwaColors.colorPale,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: SariwaColors.colorLine,
                                      ),
                                    ),
                                    child: const Text(
                                      'DOWNLOAD',
                                      style: TextStyle(
                                        fontFamily:
                                            TimberTypography.primarySansFamily,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.6,
                                        color: SariwaColors.brandPrimary,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                Semantics(
                                  header: true,
                                  child: StaggeredReveal(
                                    staggerIndex: 1,
                                    child: Text(
                                      'Get SariwaBa.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily:
                                            TimberTypography.primarySansFamily,
                                        fontSize: isDesktop ? 48 : 36,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: isDesktop ? -1.2 : -0.8,
                                        height: 1.12,
                                        color: SariwaColors.textPrimaryDark,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                StaggeredReveal(
                                  staggerIndex: 2,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 540,
                                    ),
                                    child: const Text(
                                      'Inspect fish freshness on Android, iOS, or any modern browser.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily:
                                            TimberTypography.primarySansFamily,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w300,
                                        color: SariwaColors.inkSlateSecondary,
                                        height: 1.5,
                                        letterSpacing: -0.15,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 48),

                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final isWide = constraints.maxWidth >= 900;

                                    if (isWide) {
                                      return IntrinsicHeight(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
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
                                                child: _buildAndroidCard(
                                                  context,
                                                ),
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
                                        ),
                                      );
                                    }
                                    return Column(
                                      children: [
                                        StaggeredReveal(
                                          staggerIndex: 3,
                                          child: _buildIosCard(context),
                                        ),
                                        const SizedBox(height: 16),
                                        StaggeredReveal(
                                          staggerIndex: 4,
                                          child: _buildAndroidCard(context),
                                        ),
                                        const SizedBox(height: 16),
                                        StaggeredReveal(
                                          staggerIndex: 5,
                                          child: _buildWebCard(
                                            context,
                                            authController,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),

                                const SizedBox(height: 48),

                                StaggeredReveal(
                                  staggerIndex: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: SariwaColors.cardSurfaceLight,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: SariwaColors.colorLine,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          CupertinoIcons.info_circle,
                                          size: 16,
                                          color: SariwaColors.brandPrimary,
                                        ),
                                        SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            'Internet connection required to scan photos and sync history.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: TimberTypography
                                                  .primarySansFamily,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w300,
                                              color: SariwaColors.inkSlateMuted,
                                            ),
                                          ),
                                        ),
                                      ],
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
          ),

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

  Widget _buildIosCard(BuildContext context) {
    return _PlatformCard(
      icon: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: SariwaColors.infoBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SariwaColors.infoBorder),
        ),
        child: const Icon(
          Icons.apple_rounded,
          color: SariwaColors.infoText,
          size: 24,
        ),
      ),
      title: 'iPhone & iPad',
      description: 'Snap or upload photos and sync your scan log.',
      features: const [
        'iOS 16 or later',
        'iPhone and iPad',
        'Camera and gallery upload',
      ],
      buttonLabel: 'Get it on App Store',
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('iOS build coming soon to TestFlight & App Store.'),
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }

  Widget _buildAndroidCard(BuildContext context) {
    return _PlatformCard(
      icon: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: SariwaColors.freshIconBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SariwaColors.freshBorder),
        ),
        child: const Icon(
          Icons.android_rounded,
          color: SariwaColors.freshText,
          size: 24,
        ),
      ),
      title: 'Android',
      description: 'Quick camera capture, cropping, and Google Sign-In.',
      features: const [
        'Android 8 or later',
        'Camera and gallery upload',
        'Google Sign-In',
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

  Widget _buildWebCard(BuildContext context, AuthController authController) {
    return _PlatformCard(
      icon: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: SariwaColors.colorPale,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SariwaColors.colorLine),
        ),
        child: const Icon(
          CupertinoIcons.desktopcomputer,
          color: SariwaColors.brandPrimary,
          size: 20,
        ),
      ),
      title: 'Web',
      description: 'Scan single photos or batches right in your browser.',
      features: const [
        'Chrome, Safari, Edge, Firefox',
        'No install needed',
        'History & CSV export',
      ],
      buttonLabel: 'Open the web app',
      onPressed: () => authController.goToLogin(),
    );
  }
}

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
    final isPrimary = widget.isPrimaryPlatform;
    final borderColor = isPrimary
        ? (_isHovered
              ? SariwaColors.brandPrimary
              : SariwaColors.brandPrimary.withValues(alpha: 0.55))
        : (_isHovered
              ? SariwaColors.brandPrimary.withValues(alpha: 0.40)
              : SariwaColors.colorLine);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: SariwaColors.cardSurfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: isPrimary ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widget.icon,
                if (isPrimary)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: SariwaColors.colorPale,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'RECOMMENDED',
                      style: TextStyle(
                        fontFamily: TimberTypography.primarySansFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        color: SariwaColors.brandPrimary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              widget.title,
              style: const TextStyle(
                fontFamily: TimberTypography.primarySansFamily,
                fontSize: 20,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.25,
                color: SariwaColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.description,
              style: const TextStyle(
                fontFamily: TimberTypography.primarySansFamily,
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w300,
                color: SariwaColors.inkSlateMuted,
              ),
            ),
            const SizedBox(height: 20),
            for (final feat in widget.features)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        CupertinoIcons.checkmark_alt_circle_fill,
                        size: 16,
                        color: SariwaColors.brandPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feat,
                        style: const TextStyle(
                          fontFamily: TimberTypography.primarySansFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: SariwaColors.inkSlateSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const Spacer(),
            const SizedBox(height: 12),
            if (isPrimary)
              AppButton.primary(
                label: widget.buttonLabel,
                width: double.infinity,
                height: 48,
                borderRadius: 999,
                onPressed: widget.onPressed,
              )
            else
              AppButton.secondary(
                label: widget.buttonLabel,
                width: double.infinity,
                height: 48,
                borderRadius: 999,
                onPressed: widget.onPressed,
              ),
          ],
        ),
      ),
    );
  }
}
