import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:material_ui/material_ui.dart';

import '../../constants/config/app_breakpoints.dart';
import '../../constants/config/platform_env.dart';
import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../widgets/auth/google_auth_button.dart';

/// iOS 26 Liquid Glass Onboarding & Sign-In Studio.
/// - Mobile First-Time: 3-step choreographed live scanner animations over an
///   obsidian-marine Liquid Glass stage (`fitonist` segmented top bar + dual pill CTAs).
/// - Mobile Returning: Skips onboarding straight to the iOS 26 Sign-In screen.
/// - Web / Desktop: Asymmetric editorial split screen (interactive live scanner
///   showcase on the left, clean left-aligned Sign-In studio on the right).
class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage>
    with SingleTickerProviderStateMixin {
  static const String _onboardingSeenKey = 'sariwaba_onboarding_seen_v1';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static bool? _cachedOnboardingSeen;

  final PageController _pageController = PageController();
  late final AnimationController _stageAnimController;

  int _currentPage = 0;
  int _desktopShowcaseIndex = 0;
  bool _hasSeenOnboarding = _cachedOnboardingSeen ?? false;
  bool _onboardingResolved = _cachedOnboardingSeen != null;

  static const _slides = [
    (
      stepLabel: '01 · Capture',
      title: 'Lock Onto the Eye or Gill',
      subtitle:
          'Point at a close-up eye or exposed gill — SariwaBa isolates the region automatically.',
    ),
    (
      stepLabel: '02 · Analyze',
      title: 'Instant Freshness Reading',
      subtitle:
          'Evaluates corneal clarity and gill color in seconds with a clear confidence score.',
    ),
    (
      stepLabel: '03 · Audit',
      title: 'Synced Inspection Log',
      subtitle:
          'Filter past scans by region, review crops, and export clean CSV reports.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _stageAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();

    if (!_onboardingResolved) {
      _loadOnboardingSeen();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion && _stageAnimController.isAnimating) {
      _stageAnimController.value = 0.65;
    } else if (!reduceMotion && !_stageAnimController.isAnimating) {
      _stageAnimController.repeat();
    }
  }

  Future<void> _loadOnboardingSeen() async {
    bool seen = false;
    try {
      final raw = await _storage
          .read(key: _onboardingSeenKey)
          .timeout(const Duration(milliseconds: 120), onTimeout: () => null);
      seen = raw == 'true';
    } catch (_) {
      seen = false;
    }
    _cachedOnboardingSeen = seen;
    if (mounted) {
      setState(() {
        _hasSeenOnboarding = seen;
        _onboardingResolved = true;
      });
    }
  }

  Future<void> _markOnboardingSeen() async {
    _cachedOnboardingSeen = true;
    try {
      await _storage
          .write(key: _onboardingSeenKey, value: 'true')
          .timeout(const Duration(milliseconds: 120), onTimeout: () {});
    } catch (_) {
      // Ignore storage failures in test/restricted environments.
    }
  }

  @override
  void dispose() {
    _stageAnimController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    HapticFeedback.selectionClick();
    if (index >= _slides.length - 1) {
      _markOnboardingSeen();
    }
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _skipToSignIn() {
    HapticFeedback.selectionClick();
    _markOnboardingSeen();
    setState(() => _hasSeenOnboarding = true);
  }

  Future<void> _handleGoogleSignIn(AuthController authController) async {
    await _markOnboardingSeen();
    await authController.continueWithGoogle();
  }

  void _handleGuestContinue(AuthController authController) {
    _markOnboardingSeen();
    authController.continueAsGuest();
  }

  @override
  Widget build(BuildContext context) {
    final authController = ref.read(authControllerProvider.notifier);
    final authState = ref.watch(authControllerProvider);
    final isMobile = AppBreakpoints.isMobile(MediaQuery.sizeOf(context).width);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: SariwaColors.bgObsidian,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Subtle organic marine depth behind iOS 26 obsidian-glass stage
            Opacity(
              opacity: 0.16,
              child: Image.asset(
                'assets/images/backgroundBlurred.jpg',
                fit: BoxFit.cover,
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.25),
                  radius: 0.95,
                  colors: [
                    SariwaColors.brandPrimary.withValues(alpha: 0.28),
                    SariwaColors.bgObsidianElevated.withValues(alpha: 0.88),
                    SariwaColors.bgObsidian,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
            SafeArea(
              child: isMobile
                  ? (!_onboardingResolved
                      ? const SizedBox.expand()
                      : (_hasSeenOnboarding
                          ? _buildMobileDirectSignIn(authController, authState)
                          : _buildMobileOnboarding(authController, authState)))
                  : _buildWebSplitAuth(authController, authState),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Mobile First-Time Onboarding (iOS 26 Segmented Top Bar + Live Animations)
  // ---------------------------------------------------------------------------
  Widget _buildMobileOnboarding(
    AuthController authController,
    dynamic authState,
  ) {
    final isLastSlide = _currentPage == _slides.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top bar: Back chevron + Segmented Story Progress + Skip pill
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            children: [
              SizedBox(
                height: 40,
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      _buildLiquidCircleButton(
                        icon: CupertinoIcons.chevron_left,
                        tooltip: 'Previous step',
                        onTap: () => _goToPage(_currentPage - 1),
                      )
                    else if (!isNativeMobileDevice)
                      _buildLiquidPillChip(
                        icon: CupertinoIcons.chevron_left,
                        label: 'Home',
                        onTap: () => authController.goToLanding(),
                      )
                    else
                      const SizedBox(width: 40),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/SariwaBa logo.png',
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                            semanticLabel: 'SariwaBa logo',
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'SariwaBa',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.3,
                              color: SariwaColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLastSlide)
                      _buildLiquidPillChip(
                        label: 'Skip',
                        onTap: _skipToSignIn,
                      )
                    else
                      const SizedBox(width: 40),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Segmented progress bars (fitonist / iOS 26 style)
              Row(
                children: List.generate(_slides.length, (i) {
                  final active = i <= _currentPage;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: i < _slides.length - 1 ? 8 : 0,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        height: 4,
                        decoration: BoxDecoration(
                          color: active
                              ? SariwaColors.brandLight
                              : SariwaColors.liquidGlassHairline,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),

        // Live Animated Scanner Showcase + Slide Headline
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (index) {
              if (index == _slides.length - 1) {
                _markOnboardingSeen();
              }
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: _buildAnimatedStage(index),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      slide.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.6,
                        height: 1.15,
                        color: SariwaColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: Text(
                        slide.subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          height: 1.45,
                          color: SariwaColors.textSecondaryLight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),

        // Bottom iOS 26 Dual-Pill Action Stack
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (authState.errorMessage != null) ...[
                _buildErrorBanner(authState.errorMessage as String),
                const SizedBox(height: 12),
              ],
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                child: isLastSlide
                    ? _buildSignInActionStack(authController, authState)
                    : Column(
                        key: const ValueKey('step_actions'),
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSmokedGlassPillButton(
                            label: 'Sign In',
                            onTap: _skipToSignIn,
                          ),
                          const SizedBox(height: 12),
                          _buildLuminousPrimaryPillButton(
                            label: 'Continue',
                            onTap: () => _goToPage(_currentPage + 1),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Returning Mobile User: Direct iOS 26 Liquid Glass Sign-In
  // ---------------------------------------------------------------------------
  Widget _buildMobileDirectSignIn(
    AuthController authController,
    dynamic authState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isNativeMobileDevice)
                  _buildLiquidPillChip(
                    icon: CupertinoIcons.chevron_left,
                    label: 'Home',
                    onTap: () => authController.goToLanding(),
                  )
                else
                  const SizedBox(width: 40),
                _buildLiquidPillChip(
                  label: 'Preview Tour',
                  onTap: () => setState(() {
                    _currentPage = 0;
                    _hasSeenOnboarding = false;
                  }),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildLiveScannerStage(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/SariwaBa logo.png',
                    width: 28,
                    height: 28,
                    fit: BoxFit.contain,
                    semanticLabel: 'SariwaBa logo',
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'SariwaBa',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.6,
                      color: SariwaColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to sync scans, or inspect locally as a guest.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: SariwaColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),
              if (authState.errorMessage != null) ...[
                _buildErrorBanner(authState.errorMessage as String),
                const SizedBox(height: 12),
              ],
              _buildSignInActionStack(authController, authState),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Web / Desktop: Asymmetric Editorial Split Screen (Zero Centered AI Box)
  // ---------------------------------------------------------------------------
  Widget _buildWebSplitAuth(AuthController authController, dynamic authState) {
    final activeSlide = _slides[_desktopShowcaseIndex];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1160),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left 55%: Interactive iOS 26 Liquid Glass Live Scanner Stage
              Expanded(
                flex: 11,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: SariwaColors.liquidGlassDark,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: SariwaColors.liquidGlassHairline,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (!isNativeMobileDevice)
                                _buildLiquidPillChip(
                                  icon: CupertinoIcons.arrow_left,
                                  label: 'Overview',
                                  onTap: () => authController.goToLanding(),
                                )
                              else
                                const SizedBox.shrink(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: SariwaColors.liquidGlassSurface,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: SariwaColors.liquidGlassHairline,
                                  ),
                                ),
                                child: Text(
                                  activeSlide.stepLabel,
                                  style: const TextStyle(
                                    fontFamily: 'Geist Mono',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: SariwaColors.brandLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 280),
                                switchInCurve: Curves.easeOutCubic,
                                child: KeyedSubtree(
                                  key: ValueKey(_desktopShowcaseIndex),
                                  child: _buildAnimatedStage(
                                    _desktopShowcaseIndex,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Text(
                            activeSlide.title,
                            style: const TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 28,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.5,
                              color: SariwaColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            child: Text(
                              activeSlide.subtitle,
                              style: const TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                                height: 1.45,
                                color: SariwaColors.textSecondaryLight,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Interactive Stage Switcher Pills
                          Row(
                            children: List.generate(_slides.length, (i) {
                              final selected = i == _desktopShowcaseIndex;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Material(
                                  color: selected
                                      ? SariwaColors.liquidGlassStrong
                                      : SariwaColors.liquidGlassSurface,
                                  shape: StadiumBorder(
                                    side: BorderSide(
                                      color: selected
                                          ? SariwaColors.brandLight
                                          : SariwaColors.liquidGlassHairline,
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: () => setState(
                                      () => _desktopShowcaseIndex = i,
                                    ),
                                    customBorder: const StadiumBorder(),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      child: Text(
                                        _slides[i].stepLabel,
                                        style: TextStyle(
                                          fontFamily: AppTypography.fontFamily,
                                          fontSize: 12,
                                          fontWeight: selected
                                              ? FontWeight.w500
                                              : FontWeight.w400,
                                          color: selected
                                              ? SariwaColors.textPrimaryLight
                                              : SariwaColors.textSecondaryLight,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48),

              // Right 45%: Clean Editorial Left-Aligned Sign-In Column
              Expanded(
                flex: 9,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 380),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/SariwaBa logo.png',
                                width: 36,
                                height: 36,
                                fit: BoxFit.contain,
                                semanticLabel: 'SariwaBa logo',
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'SariwaBa',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -0.3,
                                  color: SariwaColors.textPrimaryLight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Inspect freshness in seconds.',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 28,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.6,
                              height: 1.15,
                              color: SariwaColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Sign in to keep your scan history synced across web and mobile, or start inspecting immediately as a guest.',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              height: 1.5,
                              color: SariwaColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 32),
                          if (authState.errorMessage != null) ...[
                            _buildErrorBanner(authState.errorMessage as String),
                            const SizedBox(height: 16),
                          ],
                          _buildSignInActionStack(authController, authState),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInActionStack(
    AuthController authController,
    dynamic authState,
  ) {
    return Column(
      key: const ValueKey('auth_actions'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GoogleAuthButton(
          label: 'Sign in with Google',
          isLoading: authState.isLoading == true,
          onPressed: () => _handleGoogleSignIn(authController),
        ),
        const SizedBox(height: 12),
        _buildSmokedGlassPillButton(
          label: 'Continue as Guest',
          icon: CupertinoIcons.person,
          onTap: () => _handleGuestContinue(authController),
        ),
        const SizedBox(height: 12),
        const Text(
          'Guest scans stay on this device only.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w300,
            color: SariwaColors.textMutedLight,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 3 Live Choreographed Scanner Stages (Real Specimen + 60fps Motion)
  // ---------------------------------------------------------------------------
  Widget _buildAnimatedStage(int index) {
    switch (index) {
      case 0:
        return _buildLiveScannerStage();
      case 1:
        return _buildLiveGaugeStage();
      default:
        return _buildLiveLogStage();
    }
  }

  /// Stage 1: Real Tilapia Eye Close-Up with Sweeping Laser Beam & Breathing Focus Brackets
  Widget _buildLiveScannerStage() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: AnimatedBuilder(
        animation: _stageAnimController,
        builder: (context, _) {
          final t = _stageAnimController.value;
          // Smooth ping-pong scan sweep 0 -> 1 -> 0
          final sweep = 0.5 - 0.5 * math.cos(t * 2 * math.pi);
          // Lock pulse tightens when sweep crosses center
          final locked = sweep > 0.35 && sweep < 0.78;
          final bracketScale = locked ? 0.94 : 1.04;

          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SariwaColors.liquidGlassSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: SariwaColors.liquidGlassSpecular),
                  boxShadow: const [
                    BoxShadow(
                      color: SariwaColors.liquidGlassShadow,
                      blurRadius: 32,
                      offset: Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Optical Specimen Viewport
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 184,
                        width: double.infinity,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              'assets/images/sample_tilapia2.jpg',
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                            ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    SariwaColors.bgObsidian.withValues(
                                      alpha: 0.35,
                                    ),
                                    Colors.transparent,
                                    SariwaColors.bgObsidian.withValues(
                                      alpha: 0.55,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Sweeping bioluminescent scan line
                            Positioned(
                              top: 16 + sweep * 148,
                              left: 12,
                              right: 12,
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  color: SariwaColors.brandLight,
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: SariwaColors.brandGlow,
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Breathing iOS focus reticle around the cornea
                            Center(
                              child: Transform.scale(
                                scale: bracketScale,
                                child: CustomPaint(
                                  size: const Size(104, 104),
                                  painter: _IosFocusReticlePainter(
                                    color: locked
                                        ? SariwaColors.brandLight
                                        : SariwaColors.liquidGlassSpecular,
                                  ),
                                ),
                              ),
                            ),
                            // Top-left live status pill
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: SariwaColors.liquidGlassDark,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: locked
                                        ? SariwaColors.brandLight
                                        : SariwaColors.liquidGlassHairline,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: locked
                                            ? SariwaColors.statusFresh
                                            : SariwaColors.brandGlow,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      locked ? 'Eye ROI Locked' : 'Scanning...',
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
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Liquid Glass Region Selector Preview
                    Row(
                      children: [
                        for (final (idx, label) in [
                          'Auto',
                          'Eye',
                          'Gill',
                        ].indexed) ...[
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: idx == 1
                                    ? SariwaColors.brandPrimary
                                    : SariwaColors.liquidGlassSurface,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: idx == 1
                                      ? SariwaColors.brandLight
                                      : SariwaColors.liquidGlassHairline,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 12,
                                  fontWeight: idx == 1
                                      ? FontWeight.w500
                                      : FontWeight.w400,
                                  color: SariwaColors.textPrimaryLight,
                                ),
                              ),
                            ),
                          ),
                          if (idx < 2) const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Stage 2: Animated Circular Freshness Gauge + Sensory Signal Chips
  Widget _buildLiveGaugeStage() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: AnimatedBuilder(
        animation: _stageAnimController,
        builder: (context, _) {
          final raw = _stageAnimController.value;
          // Ease quickly up to 0.94 and hold with subtle shimmer
          final progress = Curves.easeOutCubic.transform(
            (raw * 1.4).clamp(0.0, 1.0),
          );
          final score = (progress * 94).round();

          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: SariwaColors.liquidGlassSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: SariwaColors.liquidGlassSpecular),
                  boxShadow: const [
                    BoxShadow(
                      color: SariwaColors.liquidGlassShadow,
                      blurRadius: 32,
                      offset: Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 144,
                      height: 144,
                      child: CustomPaint(
                        painter: _FreshnessArcPainter(
                          progress: progress * 0.94,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$score%',
                                style: const TextStyle(
                                  fontFamily: 'Geist Mono',
                                  fontSize: 28,
                                  fontWeight: FontWeight.w500,
                                  fontFeatures: [
                                    ui.FontFeature.tabularFigures(),
                                  ],
                                  color: SariwaColors.textPrimaryLight,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: SariwaColors.freshIconBgDark,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: SariwaColors.freshBorderDark,
                                  ),
                                ),
                                child: const Text(
                                  'Fresh',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
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
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSignalChip('Clear cornea'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSignalChip('Bright pupil'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSignalChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: SariwaColors.liquidGlassDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SariwaColors.liquidGlassHairline),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.checkmark_circle_fill,
            size: 14,
            color: SariwaColors.statusFresh,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: SariwaColors.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Stage 3: Floating Layered iOS 26 Liquid Glass Inspection Log
  Widget _buildLiveLogStage() {
    const logs = [
      (title: 'Eye · #104', time: 'Just now', pct: '94%', fresh: true),
      (title: 'Gill · #103', time: '2m ago', pct: '89%', fresh: true),
      (title: 'Eye · #102', time: 'Yesterday', pct: '36%', fresh: false),
    ];

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: AnimatedBuilder(
        animation: _stageAnimController,
        builder: (context, _) {
          final phase = _stageAnimController.value * 2 * math.pi;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < logs.length; i++) ...[
                Transform.translate(
                  offset: Offset(0, math.sin(phase + i * 0.9) * 3.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: SariwaColors.liquidGlassSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: i == 0
                                ? SariwaColors.liquidGlassSpecular
                                : SariwaColors.liquidGlassHairline,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: logs[i].fresh
                                    ? SariwaColors.freshIconBgDark
                                    : SariwaColors.notFreshIconBgDark,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                logs[i].fresh
                                    ? CupertinoIcons.checkmark_seal_fill
                                    : CupertinoIcons.exclamationmark_circle_fill,
                                size: 16,
                                color: logs[i].fresh
                                    ? SariwaColors.statusFresh
                                    : SariwaColors.notFreshPrimaryDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    logs[i].title,
                                    style: const TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: SariwaColors.textPrimaryLight,
                                    ),
                                  ),
                                  Text(
                                    logs[i].time,
                                    style: const TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300,
                                      color: SariwaColors.textMutedLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: logs[i].fresh
                                    ? SariwaColors.freshIconBgDark
                                    : SariwaColors.notFreshIconBgDark,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                logs[i].pct,
                                style: TextStyle(
                                  fontFamily: 'Geist Mono',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: logs[i].fresh
                                      ? SariwaColors.brandLight
                                      : SariwaColors.notFreshTextDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (i < logs.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // iOS 26 Liquid Glass Pill Controls
  // ---------------------------------------------------------------------------
  Widget _buildLuminousPrimaryPillButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: SariwaColors.brandPrimary,
        foregroundColor: SariwaColors.textPrimaryLight,
        minimumSize: const Size(double.infinity, 52),
        shape: const StadiumBorder(
          side: BorderSide(color: SariwaColors.brandGlow),
        ),
        textStyle: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
      ),
      child: Text(label),
    );
  }

  Widget _buildSmokedGlassPillButton({
    required String label,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Material(
          color: SariwaColors.liquidGlassSurface,
          shape: const StadiumBorder(
            side: BorderSide(color: SariwaColors.liquidGlassSpecular),
          ),
          child: InkWell(
            onTap: onTap,
            customBorder: const StadiumBorder(),
            child: SizedBox(
              height: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 16,
                      color: SariwaColors.textPrimaryLight,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14,
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

  Widget _buildLiquidPillChip({
    IconData? icon,
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
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 14,
                      color: SariwaColors.textPrimaryLight,
                    ),
                    const SizedBox(width: 4),
                  ],
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

  Widget _buildLiquidCircleButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: ClipOval(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Material(
            color: SariwaColors.liquidGlassSurface,
            shape: const CircleBorder(
              side: BorderSide(color: SariwaColors.liquidGlassHairline),
            ),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  icon,
                  size: 16,
                  color: SariwaColors.textPrimaryLight,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: SariwaColors.notFreshIconBgDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SariwaColors.notFreshBorderDark),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_circle,
            color: SariwaColors.notFreshPrimaryDark,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: SariwaColors.notFreshTextDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IosFocusReticlePainter extends CustomPainter {
  final Color color;

  const _IosFocusReticlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const arm = 18.0;
    const r = 12.0;
    final w = size.width;
    final h = size.height;

    // Top-left bracket
    canvas.drawPath(
      Path()
        ..moveTo(0, arm)
        ..lineTo(0, r)
        ..quadraticBezierTo(0, 0, r, 0)
        ..lineTo(arm, 0),
      paint,
    );
    // Top-right bracket
    canvas.drawPath(
      Path()
        ..moveTo(w - arm, 0)
        ..lineTo(w - r, 0)
        ..quadraticBezierTo(w, 0, w, r)
        ..lineTo(w, arm),
      paint,
    );
    // Bottom-left bracket
    canvas.drawPath(
      Path()
        ..moveTo(0, h - arm)
        ..lineTo(0, h - r)
        ..quadraticBezierTo(0, h, r, h)
        ..lineTo(arm, h),
      paint,
    );
    // Bottom-right bracket
    canvas.drawPath(
      Path()
        ..moveTo(w - arm, h)
        ..lineTo(w - r, h)
        ..quadraticBezierTo(w, h, w, h - r)
        ..lineTo(w, h - arm),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _IosFocusReticlePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _FreshnessArcPainter extends CustomPainter {
  final double progress;

  const _FreshnessArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 8;
    const startAngle = 0.75 * math.pi;
    const sweepMax = 1.5 * math.pi;

    final trackPaint = Paint()
      ..color = SariwaColors.liquidGlassHairline
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepMax,
      false,
      trackPaint,
    );

    final activePaint = Paint()
      ..shader = const SweepGradient(
        colors: [
          SariwaColors.brandPrimary,
          SariwaColors.statusFresh,
          SariwaColors.brandLight,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepMax * progress.clamp(0.0, 1.0),
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FreshnessArcPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
