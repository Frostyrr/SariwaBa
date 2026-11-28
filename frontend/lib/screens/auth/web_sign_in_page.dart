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

/// Dedicated Web Sign-In Page (`kIsWeb` — Desktop, Tablet & Mobile Browsers).
/// Resend-inspired full-bleed Deep Lagoon layout: darkened `backgroundBlurred.jpg`
/// backdrop, whisper-quiet `< Home` link top-left, and a focused borderless
/// center column with smooth 60fps staggered reveals.
class WebSignInPage extends ConsumerWidget {
  const WebSignInPage({super.key});

  /// Matches Google GSI `GSIButtonSize.large` rendered height (40px) so both
  /// Google OAuth and Continue as Guest have identical proportions.
  static const double _webAuthButtonHeight = 40.0;

  /// Stays under Google GSI's 400px maximum width cap so both buttons share
  /// the exact same width across desktop, tablet, and mobile viewports.
  static const double _maxFormWidth = 360.0;

  static const Duration _staggerStep = Duration(milliseconds: 60);
  static const Duration _staggerDuration = Duration(milliseconds: 420);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.read(authControllerProvider.notifier);
    final authState = ref.watch(authControllerProvider);
    final isCompact = MediaQuery.sizeOf(context).width < 600;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: SariwaColors.bgAbyssDark,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Full-bleed underwater backdrop
            Positioned.fill(
              child: Image.asset(
                'assets/images/backgroundBlurred.jpg',
                fit: BoxFit.cover,
              ),
            ),

            // Deep lagoon atmospheric vignette for crisp contrast
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.50, 1.0],
                    colors: [
                      SariwaColors.bgAbyssDark.withValues(alpha: 0.68),
                      SariwaColors.bgAbyssDark.withValues(alpha: 0.78),
                      SariwaColors.bgAbyssDark.withValues(alpha: 0.90),
                    ],
                  ),
                ),
              ),
            ),

            // Centered Borderless Auth Column (unified across desktop & mobile)
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: isCompact ? 64 : 48,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _maxFormWidth),
                    child: _buildCenteredAuthColumn(authController, authState),
                  ),
                ),
              ),
            ),

            // Top-left whisper-quiet `< Home` navigation
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isCompact ? 12 : 24,
                    isCompact ? 12 : 20,
                    12,
                    0,
                  ),
                  child: StaggeredReveal(
                    staggerIndex: 0,
                    staggerStep: _staggerStep,
                    duration: _staggerDuration,
                    slideOffset: const Offset(0, 8),
                    child: _QuietHomeLink(onTap: authController.goToLanding),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenteredAuthColumn(
    AuthController authController,
    dynamic authState,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Centered 48x48 App Mark
        StaggeredReveal(
          staggerIndex: 0,
          staggerStep: _staggerStep,
          duration: _staggerDuration,
          slideOffset: const Offset(0, 12),
          child: Center(
            child: Image.asset(
              'assets/images/SariwaBa logo.png',
              width: 52,
              height: 52,
              fit: BoxFit.contain,
              semanticLabel: 'SariwaBa logo',
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Headline
        const StaggeredReveal(
          staggerIndex: 1,
          staggerStep: _staggerStep,
          duration: _staggerDuration,
          slideOffset: Offset(0, 12),
          child: Text(
            'Sign in to SariwaBa',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 28,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.7,
              height: 1.18,
              color: SariwaColors.textPrimaryLight,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Concise 1-line subtitle
        const StaggeredReveal(
          staggerIndex: 2,
          staggerStep: _staggerStep,
          duration: _staggerDuration,
          slideOffset: Offset(0, 12),
          child: Text(
            'Sync your scan history across devices, or inspect right away as a guest.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w300,
              height: 1.48,
              color: SariwaColors.textSecondaryLight,
            ),
          ),
        ),

        const SizedBox(height: 32),

        if (authState.errorMessage != null) ...[
          _buildErrorBanner(authState.errorMessage as String),
          const SizedBox(height: 16),
        ],

        // Google OAuth Button (40px height, 360px max width)
        StaggeredReveal(
          staggerIndex: 3,
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

        const SizedBox(height: 12),

        // Primary Teal Continue as Guest button (stacked directly, no OR divider)
        StaggeredReveal(
          staggerIndex: 4,
          staggerStep: _staggerStep,
          duration: _staggerDuration,
          slideOffset: const Offset(0, 12),
          child: AppButton.primary(
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
        ),

        const SizedBox(height: 24),

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
              fontWeight: FontWeight.w300,
              color: SariwaColors.textSecondaryLight,
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
        color: SariwaColors.notFreshIconBgDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SariwaColors.notFreshBorderDark),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_circle,
            color: SariwaColors.notFreshPrimaryDark,
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
                color: SariwaColors.notFreshTextDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Whisper-quiet `< Home` link with hover highlight, inspired by Resend.
class _QuietHomeLink extends StatefulWidget {
  final VoidCallback onTap;

  const _QuietHomeLink({required this.onTap});

  @override
  State<_QuietHomeLink> createState() => _QuietHomeLinkState();
}

class _QuietHomeLinkState extends State<_QuietHomeLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = _hovered
        ? SariwaColors.textPrimaryLight
        : SariwaColors.textSecondaryLight;

    return Semantics(
      button: true,
      label: 'Back to Home',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.chevron_left, size: 16, color: color),
                  const SizedBox(width: 4),
                  Text(
                    'Home',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: color,
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
