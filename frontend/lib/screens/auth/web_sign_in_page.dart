import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../widgets/auth/google_auth_button.dart';
import '../../widgets/common/staggered_reveal.dart';

/// Monochrome Sign-In Page ("95% Monochrome + 5% Surgical Teal"):
/// - Desktop (`>= 768px`): Left showcase (`flex: 6`) with large interactive 3D laptop,
///   concentric surgical-teal ripple backdrop, and web context copy; Right column (`flex: 4`)
///   with the white `rounded-3xl` Sign In card (`maxWidth: 420`).
/// - Mobile (`< 768px`): Compact web badge/phrase stacked cleanly above the Sign In card.
class WebSignInPage extends ConsumerWidget {
  const WebSignInPage({super.key});

  static const Color _canvas = Color(0xFFF5F5F7);
  static const Color _inkPrimary = Color(0xFF111111);
  static const Color _inkMuted = Color(0xFF737373);

  static const double _maxCardWidth = 420.0;
  static const Duration _staggerStep = Duration(milliseconds: 55);
  static const Duration _staggerDuration = Duration(milliseconds: 380);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.read(authControllerProvider.notifier);
    final authState = ref.watch(authControllerProvider);
    final size = MediaQuery.sizeOf(context);
    final vh = size.height;
    final isDesktopSplit = size.width >= 768;
    final isCompact = size.width < 520;

    final signInCard = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxCardWidth),
      child: Container(
        padding: EdgeInsets.all(isCompact ? 24 : 36),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: _buildCenteredAuthColumn(
          vh: vh,
          authController: authController,
          authState: authState,
        ),
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _canvas,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Subtle radial-masked monochrome dot-grid stage
            Positioned.fill(
              child: IgnorePointer(
                child: ShaderMask(
                  shaderCallback: (bounds) => const RadialGradient(
                    center: Alignment.center,
                    radius: 0.68,
                    colors: [
                      Colors.white,
                      Colors.white,
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.54, 1.0],
                  ).createShader(bounds),
                  blendMode: BlendMode.dstIn,
                  child: const CustomPaint(
                    painter: _SignInDotGridPainter(
                      spacing: 20.0,
                      dotRadius: 1.15,
                      color: Color(0x09000000), // Colors.black.withOpacity(0.035)
                    ),
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktopSplit ? 40 : 20,
                    vertical: isCompact ? 76 : 48,
                  ),
                  child: isDesktopSplit
                      ? ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1240),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Left Column (~58-60%): Larger 3D Laptop + Concentric Ripples + Web Copy
                              Expanded(
                                flex: 6,
                                child: _buildLeftWebShowcase(
                                  vh: vh,
                                  viewportWidth: size.width,
                                ),
                              ),
                              SizedBox(
                                width: size.width >= 1100 ? 48 : 28,
                              ),
                              // Right Column (~40-42%): Sign In Card
                              Expanded(
                                flex: 4,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: signInCard,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildMobileWebIntro(vh),
                            const SizedBox(height: 20),
                            signInCard,
                          ],
                        ),
                ),
              ),
            ),

            // Top-left crisp white `< Home` pill button (24px padding inside SafeArea)
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: StaggeredReveal(
                    staggerIndex: 0,
                    staggerStep: _staggerStep,
                    duration: _staggerDuration,
                    slideOffset: const Offset(0, 8),
                    child: _HomePillButton(onTap: authController.goToLanding),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftWebShowcase({
    required double vh,
    required double viewportWidth,
  }) {
    final phraseSize = (vh * 0.036).clamp(24.0, 34.0);
    final supportSize = (vh * 0.018).clamp(14.0, 16.5);
    final laptopMaxWidth = viewportWidth >= 1180 ? 720.0 : 660.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        StaggeredReveal(
          staggerIndex: 1,
          staggerStep: _staggerStep,
          duration: _staggerDuration,
          slideOffset: const Offset(0, 14),
          child: _Interactive3DLaptop(
            assetPath: 'assets/images/3d_laptop.png',
            maxWidth: laptopMaxWidth,
          ),
        ),
        const SizedBox(height: 16),
        StaggeredReveal(
          staggerIndex: 2,
          staggerStep: _staggerStep,
          duration: _staggerDuration,
          slideOffset: const Offset(0, 10),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                Text(
                  "You're currently on the web.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: phraseSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.65,
                    height: 1.15,
                    color: _inkPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to sync your scan history across devices, or continue as a guest.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: supportSize,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: _inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileWebIntro(double vh) {
    final phraseSize = (vh * 0.028).clamp(20.0, 26.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 6,
              height: 6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: SariwaColors.brandPrimary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SizedBox(width: 6),
            Text(
              'WEB WORKSPACE',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.1,
                color: Color(0xFF71717A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "You're currently on the web.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: phraseSize,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: _inkPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCenteredAuthColumn({
    required double vh,
    required AuthController authController,
    required dynamic authState,
  }) {
    final headingSize = (vh * 0.036).clamp(24.0, 30.0);
    final subtitleSize = (vh * 0.0175).clamp(13.5, 15.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Centered App Mark
        StaggeredReveal(
          staggerIndex: 0,
          staggerStep: _staggerStep,
          duration: _staggerDuration,
          slideOffset: const Offset(0, 12),
          child: Center(
            child: Image.asset(
              'assets/images/SariwaBa logo.png',
              width: 44,
              height: 44,
              fit: BoxFit.contain,
              semanticLabel: 'SariwaBa logo',
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Headline
        StaggeredReveal(
          staggerIndex: 1,
          staggerStep: _staggerStep,
          duration: _staggerDuration,
          slideOffset: const Offset(0, 12),
          child: Text(
            'Sign in to SariwaBa',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: headingSize,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.65,
              height: 1.15,
              color: _inkPrimary,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle
        StaggeredReveal(
          staggerIndex: 2,
          staggerStep: _staggerStep,
          duration: _staggerDuration,
          slideOffset: const Offset(0, 12),
          child: Text(
            'Sync your scan history across web and mobile, or inspect right away as a guest.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: subtitleSize,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: _inkMuted,
            ),
          ),
        ),

        const SizedBox(height: 26),

        if (authState.errorMessage != null) ...[
          _buildErrorBanner(authState.errorMessage as String),
          const SizedBox(height: 16),
        ],

        // Primary: Google Sign-In (filledBlack pill, full inner width, centered)
        StaggeredReveal(
          staggerIndex: 3,
          staggerStep: _staggerStep,
          duration: _staggerDuration,
          slideOffset: const Offset(0, 12),
          child: SizedBox(
            width: double.infinity,
            height: 44,
            child: Center(
              child: GoogleAuthButton(
                label: 'Continue with Google',
                isLoading: authState.isLoading == true,
                onPressed: authController.continueWithGoogle,
              ),
            ),
          ),
        ),

        // Subtle `or` divider (16px vertical spacing)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.black.withValues(alpha: 0.08),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF71717A),
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.black.withValues(alpha: 0.08),
                ),
              ),
            ],
          ),
        ),

        // Secondary: Crisp white pill Continue as Guest (height: 44)
        StaggeredReveal(
          staggerIndex: 4,
          staggerStep: _staggerStep,
          duration: _staggerDuration,
          slideOffset: const Offset(0, 12),
          child: OutlinedButton(
            onPressed: authController.continueAsGuest,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _inkPrimary,
              side: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
              elevation: 0,
              minimumSize: const Size(double.infinity, 44),
              shape: const StadiumBorder(),
              textStyle: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.1,
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Continue as Guest'),
                SizedBox(width: 8),
                Icon(
                  CupertinoIcons.arrow_right,
                  size: 15,
                  color: _inkPrimary,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Quiet footer note
        const StaggeredReveal(
          staggerIndex: 5,
          staggerStep: _staggerStep,
          duration: _staggerDuration,
          slideOffset: Offset(0, 8),
          child: Text(
            'Guest scans stay in this browser. Sign in anytime to sync.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: _inkMuted,
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
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_circle,
            color: Color(0xFFDC2626),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                color: Color(0xFF991B1B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Large transparent 3D laptop mockup with concentric surgical-teal ripple backdrop,
/// smooth rotate + 3D cursor-tracking tilt (`±0.06` rad + subtle `rotateZ` + `1.02` lift),
/// and opposite-moving grounded shadow.
class _Interactive3DLaptop extends StatefulWidget {
  final String assetPath;
  final double maxWidth;

  const _Interactive3DLaptop({
    required this.assetPath,
    this.maxWidth = 720,
  });

  @override
  State<_Interactive3DLaptop> createState() => _Interactive3DLaptopState();
}

class _Interactive3DLaptopState extends State<_Interactive3DLaptop> {
  static const Cubic _glideCurve = Cubic(0.22, 1, 0.36, 1);
  static const Duration _glideDuration = Duration(milliseconds: 280);
  static const double _maxTiltRad = 0.06;
  static const double _restingRotateZ = -0.025;
  static const double _hoverScale = 1.02;

  bool _isHovering = false;
  double _targetX = 0.0;
  double _targetY = 0.0;

  void _handleHover(PointerEvent event) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;
    final size = renderBox.size;
    if (size.width <= 0 || size.height <= 0) return;

    final local = renderBox.globalToLocal(event.position);
    final nx = ((local.dx / size.width) * 2.0 - 1.0).clamp(-1.0, 1.0);
    final ny = ((local.dy / size.height) * 2.0 - 1.0).clamp(-1.0, 1.0);

    if (!_isHovering ||
        (nx - _targetX).abs() > 0.004 ||
        (ny - _targetY).abs() > 0.004) {
      setState(() {
        _isHovering = true;
        _targetX = nx;
        _targetY = ny;
      });
    }
  }

  void _handleExit(PointerEvent _) {
    if (_isHovering || _targetX != 0.0 || _targetY != 0.0) {
      setState(() {
        _isHovering = false;
        _targetX = 0.0;
        _targetY = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    final laptopImage = Semantics(
      image: true,
      label: 'SariwaBa web workspace on laptop',
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.maxWidth),
        child: Image.asset(
          widget.assetPath,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );

    if (disableAnimations) {
      return RepaintBoundary(
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            _buildConcentricTealRipples(hoverT: 0.0, smoothNorm: Offset.zero),
            Positioned(bottom: 10, child: _buildGroundedShadow()),
            laptopImage,
          ],
        ),
      );
    }

    return RepaintBoundary(
      child: MouseRegion(
        onHover: _handleHover,
        onExit: _handleExit,
        child: TweenAnimationBuilder<Offset>(
          tween: Tween<Offset>(end: Offset(_targetX, _targetY)),
          duration: _glideDuration,
          curve: _glideCurve,
          builder: (context, smoothNorm, _) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(end: _isHovering ? 1.0 : 0.0),
              duration: _glideDuration,
              curve: _glideCurve,
              builder: (context, hoverT, _) {
                final tiltX = (-smoothNorm.dy * _maxTiltRad)
                    .clamp(-_maxTiltRad, _maxTiltRad);
                final tiltY = (smoothNorm.dx * _maxTiltRad)
                    .clamp(-_maxTiltRad, _maxTiltRad);
                final rotZ = _restingRotateZ * (1.0 - hoverT) +
                    (smoothNorm.dx * 0.018 * hoverT);
                final scale = 1.0 + (_hoverScale - 1.0) * hoverT;

                final matrix = Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(tiltX)
                  ..rotateY(tiltY)
                  ..rotateZ(rotZ)
                  ..scaleByDouble(scale, scale, 1.0, 1.0);

                return Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    _buildConcentricTealRipples(
                      hoverT: hoverT,
                      smoothNorm: smoothNorm,
                    ),
                    Positioned(
                      bottom: 10,
                      child: Transform.translate(
                        offset: Offset(
                          -smoothNorm.dx * 8.0,
                          -smoothNorm.dy * 5.0,
                        ),
                        child: _buildGroundedShadow(),
                      ),
                    ),
                    Transform(
                      alignment: Alignment.center,
                      transform: matrix,
                      child: laptopImage,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildConcentricTealRipples({
    required double hoverT,
    required Offset smoothNorm,
  }) {
    final scaleFactor = (widget.maxWidth / 700.0).clamp(0.75, 1.1);
    final outerSize = 480.0 * scaleFactor;
    final middleSize = 365.0 * scaleFactor;
    final innerSize = 250.0 * scaleFactor;
    final outerHoverScale = 1.0 + (0.04 * hoverT);

    return IgnorePointer(
      child: Transform.translate(
        offset: Offset(-smoothNorm.dx * 8.0, -smoothNorm.dy * 8.0),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Transform.scale(
              scale: outerHoverScale,
              child: Container(
                width: outerSize,
                height: outerSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SariwaColors.brandPrimary.withValues(alpha: 0.05),
                ),
              ),
            ),
            Container(
              width: middleSize,
              height: middleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SariwaColors.brandPrimary.withValues(alpha: 0.09),
              ),
            ),
            Container(
              width: innerSize,
              height: innerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SariwaColors.brandPrimary.withValues(alpha: 0.14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroundedShadow() {
    return IgnorePointer(
      child: Container(
        width: widget.maxWidth * 0.66,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 48,
              spreadRadius: -8,
              offset: const Offset(0, 10),
            ),
          ],
        ),
      ),
    );
  }
}

/// Crisp white `< Home` pill button in top-left corner.
class _HomePillButton extends StatefulWidget {
  final VoidCallback onTap;

  const _HomePillButton({required this.onTap});

  @override
  State<_HomePillButton> createState() => _HomePillButtonState();
}

class _HomePillButtonState extends State<_HomePillButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back to Home',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Material(
          color: _hovered ? const Color(0xFFFAFAFA) : Colors.white,
          shape: StadiumBorder(
            side: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
          ),
          child: InkWell(
            onTap: widget.onTap,
            customBorder: const StadiumBorder(),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.chevron_left,
                    size: 15,
                    color: Color(0xFF111111),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Home',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111111),
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
}

class _SignInDotGridPainter extends CustomPainter {
  final double spacing;
  final double dotRadius;
  final Color color;

  const _SignInDotGridPainter({
    required this.spacing,
    required this.dotRadius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignInDotGridPainter oldDelegate) =>
      oldDelegate.spacing != spacing ||
      oldDelegate.dotRadius != dotRadius ||
      oldDelegate.color != color;
}
