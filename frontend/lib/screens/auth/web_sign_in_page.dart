import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../constants/theme/app_typography.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../widgets/auth/google_auth_button.dart';
import '../../widgets/common/staggered_reveal.dart';

/// Monochrome Sign-In Page ("95% Monochrome + 5% Surgical Teal") with
/// primary Google Sign-In, subtle `or` divider, secondary white Guest pill,
/// and radial-masked monochrome dot-grid stage.
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
    final isCompact = size.width < 520;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _canvas,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Subtle radial-masked monochrome dot-grid stage behind the card
            Positioned.fill(
              child: IgnorePointer(
                child: ShaderMask(
                  shaderCallback: (bounds) => const RadialGradient(
                    center: Alignment.center,
                    radius: 0.62,
                    colors: [
                      Colors.white,
                      Colors.white,
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.52, 1.0],
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
                    horizontal: 20,
                    vertical: isCompact ? 72 : 48,
                  ),
                  child: ConstrainedBox(
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

  Widget _buildCenteredAuthColumn({
    required double vh,
    required AuthController authController,
    required dynamic authState,
  }) {
    final headingSize = (vh * 0.040).clamp(26.0, 34.0);
    final subtitleSize = (vh * 0.018).clamp(14.0, 16.0);

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
              width: 48,
              height: 48,
              fit: BoxFit.contain,
              semanticLabel: 'SariwaBa logo',
            ),
          ),
        ),

        const SizedBox(height: 20),

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
              letterSpacing: -0.7,
              height: 1.14,
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
            'Sync your scan history across devices, or inspect right away as a guest.',
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

        const SizedBox(height: 28),

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
