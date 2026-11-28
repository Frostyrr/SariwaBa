import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../widgets/auth/google_auth_button.dart';

/// Native Mobile Welcome & Sign-In Screen (`!kIsWeb` — Android & iOS).
/// Follows SariwaBa's "95% Monochrome + 5% Surgical Teal" system:
/// - Flat `#F5F5F7` canvas with top-left crisp white brand pill
/// - Centered 3D phone mockup stage over concentric surgical-teal ripples
/// - Bold Geist editorial headline & anchored white bottom action sheet
class MobileWelcomePage extends ConsumerWidget {
  const MobileWelcomePage({super.key});

  static const Color _canvasColor = Color(0xFFF5F5F7);
  static const Color _surfaceWhite = Color(0xFFFFFFFF);
  static const Color _inkPrimary = Color(0xFF111111);
  static const Color _inkMuted = Color(0xFF71717A);
  static const Color _surgicalTeal = Color(0xFF0D9488);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.read(authControllerProvider.notifier);
    final authState = ref.watch(authControllerProvider);
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final isCompactHeight = screenHeight < 700;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: _surfaceWhite,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _canvasColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Upper Monochrome Canvas: Brand Pill + 3D Phone Stage + Editorial Copy
            Expanded(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    isCompactHeight ? 12 : 16,
                    24,
                    isCompactHeight ? 18 : 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Top-left crisp white brand pill
                      _buildBrandPill(),

                      // 2. Centered 3D Phone Mockup & Concentric Ripple Stage
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: isCompactHeight ? 8 : 14,
                          ),
                          child: const Center(
                            child: _MobilePhoneShowcase(),
                          ),
                        ),
                      ),

                      // 3. Monochrome Editorial Headline & Subtitle
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: disableAnimations ? 1.0 : 0.0,
                          end: 1.0,
                        ),
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, (1 - value) * 10),
                              child: child,
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Check fish freshness\nin a snap.',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: isCompactHeight ? 30 : 32,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.8,
                                height: 1.08,
                                color: _inkPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Snap a close-up eye or gill photo for an instant freshness reading.',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: isCompactHeight ? 14.5 : 15,
                                fontWeight: FontWeight.w400,
                                height: 1.45,
                                color: _inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Anchored White Bottom Action Sheet
            Container(
              decoration: BoxDecoration(
                color: _surfaceWhite,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.06),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    12,
                    24,
                    isCompactHeight ? 18 : 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (authState.errorMessage != null) ...[
                        _buildErrorBanner(authState.errorMessage as String),
                        const SizedBox(height: 16),
                      ],
                      // Primary: Near-black tactile pill
                      SizedBox(
                        height: 52,
                        child: GoogleAuthButton(
                          label: 'Continue with Google',
                          isLoading: authState.isLoading == true,
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            authController.continueWithGoogle();
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Secondary: Crisp white bordered pill
                      OutlinedButton(
                        onPressed: authState.isLoading == true
                            ? null
                            : () {
                                HapticFeedback.selectionClick();
                                authController.continueAsGuest();
                              },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _surfaceWhite,
                          foregroundColor: _inkPrimary,
                          side: BorderSide(
                            color: Colors.black.withValues(alpha: 0.12),
                            width: 1,
                          ),
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 52),
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.viewfinder,
                              size: 18,
                              color: _inkPrimary,
                            ),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Continue as Guest',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Sign in to sync across devices, or scan locally as a guest.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                          color: _inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _surfaceWhite,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/SariwaBa logo.png',
            width: 20,
            height: 20,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            semanticLabel: 'SariwaBa logo',
          ),
          const SizedBox(width: 8),
          const Text(
            'SariwaBa',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.25,
              color: _inkPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: SariwaColors.notFreshIconBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SariwaColors.notFreshBorder),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_circle,
            color: SariwaColors.statusSpoiled,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: SariwaColors.notFreshText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Centered mobile showcase stage displaying the transparent 3D phone mockup
/// over 3 concentric surgical-teal ripple circles, a soft grounded shadow,
/// and the floating `• Fresh · 75.8%` verdict chip.
class _MobilePhoneShowcase extends StatefulWidget {
  const _MobilePhoneShowcase();

  @override
  State<_MobilePhoneShowcase> createState() => _MobilePhoneShowcaseState();
}

class _MobilePhoneShowcaseState extends State<_MobilePhoneShowcase>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  late final Animation<double> _floatOffset;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _floatOffset = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (disableAnimations) {
      if (_floatController.isAnimating) {
        _floatController.stop();
      }
    } else if (!_floatController.isAnimating) {
      _floatController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 320.0;
        final availableH = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 300.0;

        // Concentric ripple outer diameter (~280px-320px on standard phones)
        final outerDiameter = math
            .min(availableW, math.max(availableH * 1.05, 240.0))
            .clamp(220.0, 320.0);
        final middleDiameter = outerDiameter * 0.76;
        final innerDiameter = outerDiameter * 0.52;

        // Phone mockup dimensions scaled cleanly inside the available stage
        final phoneHeight = (availableH * 0.92).clamp(180.0, 310.0);
        final stageWidth = math.min(availableW, outerDiameter);
        final shadowWidth = (phoneHeight * 0.54).clamp(110.0, 180.0);

        final phoneMockup = Semantics(
          image: true,
          label: 'SariwaBa mobile freshness scanner preview',
          child: Image.asset(
            'assets/images/hero_phone_mockup.png',
            height: phoneHeight,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        );

        final floatingPhoneWithChip = SizedBox(
          width: stageWidth,
          height: phoneHeight,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Soft grounded drop shadow
              Positioned(
                bottom: 4,
                child: IgnorePointer(
                  child: Container(
                    width: shadowWidth,
                    height: 22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.16),
                          blurRadius: 34,
                          spreadRadius: -6,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Transparent 3D phone mockup
              if (disableAnimations)
                phoneMockup
              else
                AnimatedBuilder(
                  animation: _floatOffset,
                  child: phoneMockup,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatOffset.value),
                      child: child,
                    );
                  },
                ),

              // Floating white `• Fresh · 75.8%` verdict chip overlapping bottom-left
              Positioned(
                left: math.max(4.0, (stageWidth - phoneHeight * 0.78) * 0.35),
                bottom: phoneHeight * 0.12,
                child: _buildVerdictChip(),
              ),
            ],
          ),
        );

        return RepaintBoundary(
          child: SizedBox(
            width: stageWidth,
            height: availableH,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Concentric Surgical Teal (#0D9488) Ripple Backdrop
                IgnorePointer(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: outerDiameter,
                        height: outerDiameter,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: MobileWelcomePage._surgicalTeal
                              .withValues(alpha: 0.05),
                        ),
                      ),
                      Container(
                        width: middleDiameter,
                        height: middleDiameter,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: MobileWelcomePage._surgicalTeal
                              .withValues(alpha: 0.09),
                        ),
                      ),
                      Container(
                        width: innerDiameter,
                        height: innerDiameter,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: MobileWelcomePage._surgicalTeal
                              .withValues(alpha: 0.14),
                        ),
                      ),
                    ],
                  ),
                ),

                // Phone Mockup + Grounded Shadow + Verdict Chip
                floatingPhoneWithChip,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerdictChip() {
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: MobileWelcomePage._surgicalTeal,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 7),
            const Text(
              'Fresh · 75.8%',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.15,
                color: MobileWelcomePage._inkPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
