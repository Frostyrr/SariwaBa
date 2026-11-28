import 'dart:ui' as ui;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../widgets/auth/google_auth_button.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/staggered_reveal.dart';
import '../../widgets/dashboard/dashboard_atmospheric_banner.dart';

/// Dedicated Web Sign-In Page (`kIsWeb` — Desktop, Tablet & Mobile Browsers).
/// - Desktop (`>= 960px`): Full-viewport 54/46 split screen — atmospheric marine
///   stage with a legible SariwaBa dashboard preview on the left, clean centered
///   sign-in panel on the right, with smooth 60fps staggered reveals.
/// - Tablet (`600–959px`): Centered daylight card over `backgroundBlurred.jpg`.
/// - Mobile Web (`< 600px`): Balanced marine hero + edge-aligned white sheet.
class WebSignInPage extends ConsumerWidget {
  const WebSignInPage({super.key});

  /// Matches Google GSI `GSIButtonSize.large` rendered height (40px) so both
  /// Google OAuth and Continue as Guest have identical proportions.
  static const double _webAuthButtonHeight = 40.0;

  /// Stays under Google GSI's 400px maximum width cap so both buttons always
  /// share the exact same width across all web viewports.
  static const double _maxFormWidth = 380.0;

  static const Duration _staggerStep = Duration(milliseconds: 65);
  static const Duration _staggerDuration = Duration(milliseconds: 440);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.read(authControllerProvider.notifier);
    final authState = ref.watch(authControllerProvider);
    final width = MediaQuery.sizeOf(context).width;

    if (width >= 960) {
      return _buildDesktopSplitLayout(authController, authState, width);
    }
    if (width >= 600) {
      return _buildTabletCardLayout(authController, authState);
    }
    return _buildMobileWebLayout(authController, authState);
  }

  /// Desktop Web (`>= 960px`): Full-screen 54/46 asymmetric split layout.
  Widget _buildDesktopSplitLayout(
    AuthController authController,
    dynamic authState,
    double viewportWidth,
  ) {
    final isWideDesktop = viewportWidth >= 1200;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: SariwaColors.cardSurfaceLight,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left 54%: Full-bleed Marine Stage + Legible Dashboard Preview
            Expanded(
              flex: 11,
              child: _buildDesktopEditorialPanel(
                authController,
                isWideDesktop: isWideDesktop,
              ),
            ),

            // Right 46%: Full-height Crisp Daylight Sign-In Surface
            Expanded(
              flex: 9,
              child: Container(
                color: SariwaColors.cardSurfaceLight,
                child: SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWideDesktop ? 48 : 32,
                        vertical: 32,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: _maxFormWidth,
                        ),
                        child: _buildSignInForm(
                          authController,
                          authState,
                          baseStaggerIndex: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopEditorialPanel(
    AuthController authController, {
    required bool isWideDesktop,
  }) {
    final horizontalPad = isWideDesktop ? 48.0 : 32.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/backgroundBlurred.jpg',
          fit: BoxFit.cover,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                SariwaColors.bgAbyssDark.withValues(alpha: 0.78),
                SariwaColors.bgLagoonMid.withValues(alpha: 0.70),
                SariwaColors.bgAbyssDark.withValues(alpha: 0.90),
              ],
            ),
          ),
        ),
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPad,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: (constraints.maxHeight - 64).clamp(0.0, 1200.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Row: Brand Lockup + Back to Home Pill
                      StaggeredReveal(
                        staggerIndex: 0,
                        staggerStep: _staggerStep,
                        duration: _staggerDuration,
                        slideOffset: const Offset(0, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildBrandLockup(
                              onTap: authController.goToLanding,
                            ),
                            _buildFrostedHomePill(
                              label: 'Back to Home',
                              onTap: authController.goToLanding,
                            ),
                          ],
                        ),
                      ),

                      // Center Editorial Copy + Legible Dashboard Preview
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 480),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const StaggeredReveal(
                                  staggerIndex: 1,
                                  staggerStep: _staggerStep,
                                  duration: _staggerDuration,
                                  slideOffset: Offset(0, 16),
                                  child: Text(
                                    'Fish freshness checks,\nin one place.',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 36,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: -0.9,
                                      height: 1.14,
                                      color: SariwaColors.textPrimaryLight,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const StaggeredReveal(
                                  staggerIndex: 2,
                                  staggerStep: _staggerStep,
                                  duration: _staggerDuration,
                                  slideOffset: Offset(0, 12),
                                  child: Text(
                                    'Inspect Tilapia eyes and gills in seconds, with scan history synced across phone and desktop.',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300,
                                      height: 1.5,
                                      color: SariwaColors.textSecondaryLight,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                StaggeredReveal(
                                  staggerIndex: 3,
                                  staggerStep: _staggerStep,
                                  duration: _staggerDuration,
                                  slideOffset: const Offset(0, 20),
                                  child: _buildDesktopDashboardPreview(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Quiet Footer Row
                      StaggeredReveal(
                        staggerIndex: 4,
                        staggerStep: _staggerStep,
                        duration: _staggerDuration,
                        slideOffset: const Offset(0, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '© ${DateTime.now().year} SariwaBa',
                              style: const TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                color: SariwaColors.textSecondaryLight,
                              ),
                            ),
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CupertinoIcons.checkmark_shield,
                                  size: 14,
                                  color: SariwaColors.brandLight,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Synced history · Guest mode available',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                    color: SariwaColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Legible desktop dashboard preview (`>= 12px` type, 4 px grid, `{8, 12, 20, 999}` radii).
  /// Mirrors the real DashboardAtmosphericBanner (`backgroundBlurred.jpg`),
  /// Freshness Scanner, and Fresh result card.
  Widget _buildDesktopDashboardPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SariwaColors.surfaceSlateTint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SariwaColors.cardSurfaceLight.withValues(alpha: 0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: SariwaColors.bgAbyssDark.withValues(alpha: 0.45),
            blurRadius: 28,
            offset: const Offset(0, 12),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Real DashboardAtmosphericBanner using backgroundBlurred.jpg
          DashboardAtmosphericBanner(
            borderRadius: 12,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Freshness Inspection',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.2,
                          color: SariwaColors.cardSurfaceLight,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Eye, gill, or whole fish photo.',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          color: SariwaColors.brandLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: SariwaColors.colorPale,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: SariwaColors.brandLight),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 6,
                        color: SariwaColors.brandPrimary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Synced',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: SariwaColors.brandPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Clean 2-column workspace: Scanner photo (left) + Result readout (right)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 6,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SariwaColors.cardSurfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: SariwaColors.borderLightTeal),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              CupertinoIcons.viewfinder,
                              size: 14,
                              color: SariwaColors.brandPrimary,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Freshness Scanner',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: SariwaColors.textPrimaryDark,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 108,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  'assets/images/sample_tilapia2.jpg',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
                                    color: const Color(0xFF0F2933),
                                  ),
                                ),
                                Positioned(
                                  left: 28,
                                  top: 20,
                                  width: 40,
                                  height: 40,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: SariwaColors.brandGlow,
                                        width: 2.0,
                                      ),
                                      color: SariwaColors.brandGlow
                                          .withValues(alpha: 0.16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SariwaColors.freshIconBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: SariwaColors.freshBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              CupertinoIcons.checkmark_seal_fill,
                              size: 16,
                              color: SariwaColors.statusFresh,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Fresh',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: SariwaColors.statusFresh,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Confidence · 94.7%',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: SariwaColors.textPrimaryDark,
                          ),
                        ),
                        const SizedBox(height: 12),
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
                        const Spacer(),
                        const SizedBox(height: 12),
                        Container(
                          height: 32,
                          decoration: BoxDecoration(
                            color: SariwaColors.brandPrimary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Center(
                            child: Text(
                              'Scan Another',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: SariwaColors.cardSurfaceLight,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tablet Web (`600–959px`): Centered floating daylight card over blurred lagoon.
  Widget _buildTabletCardLayout(
    AuthController authController,
    dynamic authState,
  ) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: SariwaColors.bgAbyssDark,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/backgroundBlurred.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      SariwaColors.bgAbyssDark.withValues(alpha: 0.45),
                      SariwaColors.bgAbyssDark.withValues(alpha: 0.78),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 24,
                    ),
                    child: StaggeredReveal(
                      staggerIndex: 0,
                      staggerStep: _staggerStep,
                      duration: _staggerDuration,
                      slideOffset: const Offset(0, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildBrandLockup(onTap: authController.goToLanding),
                          _buildFrostedHomePill(
                            label: 'Back to Home',
                            onTap: authController.goToLanding,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: SariwaColors.cardSurfaceLight,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: SariwaColors.colorLine),
                              boxShadow: const [
                                BoxShadow(
                                  color: SariwaColors.liquidGlassShadow,
                                  blurRadius: 32,
                                  offset: Offset(0, 12),
                                ),
                              ],
                            ),
                            child: _buildSignInForm(
                              authController,
                              authState,
                              baseStaggerIndex: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mobile Web (`< 600px`): Proportionate marine hero + edge-aligned white sheet.
  /// No fake static grabber bar; unified 24px horizontal rhythm across hero & sheet.
  Widget _buildMobileWebLayout(
    AuthController authController,
    dynamic authState,
  ) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: SariwaColors.bgAbyssDark,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/backgroundBlurred.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.55, 1.0],
                    colors: [
                      SariwaColors.bgAbyssDark.withValues(alpha: 0.36),
                      SariwaColors.bgAbyssDark.withValues(alpha: 0.58),
                      SariwaColors.bgAbyssDark.withValues(alpha: 0.84),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Upper Marine Hero (~44% visual balance)
                Expanded(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StaggeredReveal(
                            staggerIndex: 0,
                            staggerStep: _staggerStep,
                            duration: _staggerDuration,
                            slideOffset: const Offset(0, 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildBrandLockup(
                                  onTap: authController.goToLanding,
                                ),
                                _buildFrostedHomePill(
                                  label: 'Home',
                                  onTap: authController.goToLanding,
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          const StaggeredReveal(
                            staggerIndex: 1,
                            staggerStep: _staggerStep,
                            duration: _staggerDuration,
                            slideOffset: Offset(0, 12),
                            child: Text(
                              'Check fish freshness\nin a snap.',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 28,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.7,
                                height: 1.14,
                                color: SariwaColors.textPrimaryLight,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          StaggeredReveal(
                            staggerIndex: 2,
                            staggerStep: _staggerStep,
                            duration: _staggerDuration,
                            slideOffset: const Offset(0, 12),
                            child: _buildMobileScanChip(),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),

                // Anchored Solid White Sheet (aligned to exact 24px horizontal padding)
                Container(
                  decoration: const BoxDecoration(
                    color: SariwaColors.cardSurfaceLight,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: SariwaColors.liquidGlassShadow,
                        blurRadius: 24,
                        offset: Offset(0, -8),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: _maxFormWidth,
                          ),
                          child: _buildSignInForm(
                            authController,
                            authState,
                            baseStaggerIndex: 3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Compact frosted mobile preview card grounding the upper marine hero.
  Widget _buildMobileScanChip() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: SariwaColors.bgAbyssDark.withValues(alpha: 0.44),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: SariwaColors.cardSurfaceLight.withValues(alpha: 0.16),
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/sample_tilapia2.jpg',
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 44,
                    height: 44,
                    color: SariwaColors.bgLagoonMid,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fresh · Eye Scan',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: SariwaColors.textPrimaryLight,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Instant visual freshness check',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: SariwaColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: SariwaColors.brandGlow.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: SariwaColors.brandGlow.withValues(alpha: 0.35),
                  ),
                ),
                child: const Text(
                  '94.7%',
                  style: TextStyle(
                    fontFamily: 'Geist Mono',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: SariwaColors.brandLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandLockup({required VoidCallback onTap}) {
    return Semantics(
      button: true,
      label: 'SariwaBa Home',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/SariwaBa logo.png',
                    width: 28,
                    height: 28,
                    fit: BoxFit.cover,
                    semanticLabel: 'SariwaBa logo',
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'SariwaBa',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                    color: SariwaColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrostedHomePill({
    required String label,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Material(
          color: SariwaColors.liquidGlassSurface,
          shape: const StadiumBorder(
            side: BorderSide(color: SariwaColors.liquidGlassHairline),
          ),
          child: InkWell(
            onTap: onTap,
            customBorder: const StadiumBorder(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    CupertinoIcons.arrow_left,
                    size: 14,
                    color: SariwaColors.textPrimaryLight,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: SariwaColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm(
    AuthController authController,
    dynamic authState, {
    required int baseStaggerIndex,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StaggeredReveal(
          staggerIndex: baseStaggerIndex,
          staggerStep: _staggerStep,
          duration: _staggerDuration,
          slideOffset: const Offset(0, 12),
          child: const Text(
            'Sign in to SariwaBa',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 28,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.7,
              height: 1.18,
              color: SariwaColors.textPrimaryDark,
            ),
          ),
        ),
        const SizedBox(height: 8),
        StaggeredReveal(
          staggerIndex: baseStaggerIndex + 1,
          staggerStep: _staggerStep,
          duration: _staggerDuration,
          slideOffset: const Offset(0, 12),
          child: const Text(
            'Sync your scan history across devices, or inspect right away as a guest.',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w300,
              height: 1.45,
              color: SariwaColors.inkSlateSecondary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (authState.errorMessage != null) ...[
          _buildErrorBanner(authState.errorMessage as String),
          const SizedBox(height: 16),
        ],
        StaggeredReveal(
          staggerIndex: baseStaggerIndex + 2,
          staggerStep: _staggerStep,
          duration: _staggerDuration,
          slideOffset: const Offset(0, 12),
          child: SizedBox(
            width: double.infinity,
            height: _webAuthButtonHeight,
            child: GoogleAuthButton(
              label: 'Sign in with Google',
              isLoading: authState.isLoading == true,
              onPressed: authController.continueWithGoogle,
            ),
          ),
        ),
        const SizedBox(height: 16),
        StaggeredReveal(
          staggerIndex: baseStaggerIndex + 3,
          staggerStep: _staggerStep,
          duration: _staggerDuration,
          slideOffset: const Offset(0, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Expanded(
                    child: Divider(
                      height: 1,
                      color: SariwaColors.colorLineSubtle,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: SariwaColors.inkSlateSubtle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      height: 1,
                      color: SariwaColors.colorLineSubtle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppButton.primary(
                label: 'Continue as Guest',
                trailing: const Icon(
                  CupertinoIcons.arrow_right,
                  size: 16,
                  color: Colors.white,
                ),
                width: double.infinity,
                height: _webAuthButtonHeight,
                borderRadius: 999,
                onPressed: authController.continueAsGuest,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        StaggeredReveal(
          staggerIndex: baseStaggerIndex + 4,
          staggerStep: _staggerStep,
          duration: _staggerDuration,
          slideOffset: const Offset(0, 8),
          child: const Text(
            'Guest scans stay in this browser. Sign in anytime to sync.',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w300,
              color: SariwaColors.inkSlateMuted,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
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
