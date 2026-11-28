import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../../../constants/theme/app_colors.dart';
import '../../../constants/theme/app_typography.dart';
import '../../../models/auth/user_model.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/blur_fade.dart';
import '../../../widgets/interactive_3d_phone.dart';

/// 2-Column Split Hero Section ("95% Monochrome + 5% Surgical Teal")
/// - Left: Clean Geist typography + borderless status dot + tactile CTAs
/// - Right: Sleek 3D angled smartphone mockup displaying the SariwaBa Mobile Inspection UI
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

  static const Color _canvasColor = Color(0xFFF5F5F7);
  static const Color _inkPrimary = Color(0xFF111111);
  static const Color _inkMuted = Color(0xFF737373);
  static const Color _hairline = Color(0x0D171717);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final vh = size.height;
    final isLargeDesktop = size.width >= 1024;
    final isTablet = size.width >= 640 && size.width < 1024;
    final minHeroHeight = isLargeDesktop
        ? (vh - 88).clamp(600.0, 860.0)
        : 0.0;
    final desktopPhoneHeight = (vh * 0.68).clamp(560.0, 620.0);

    return Container(
      width: double.infinity,
      color: _canvasColor,
      child: Column(
        children: [
          // Top spacer compensating for sticky containerless WebNavbar
          const SizedBox(height: 88),

          if (isGuest) _buildGuestBanner(),

          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 1152.0, // max-w-6xl
                minHeight: minHeroHeight,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: isLargeDesktop ? 48.0 : 40.0,
                ),
                child: isLargeDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 6,
                            child: _buildLeftEditorialColumn(
                              vh: vh,
                              isDesktop: true,
                              isTablet: false,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 6,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: BlurFade(
                                triggerOnVisible: false,
                                delay: const Duration(milliseconds: 220),
                                yOffset: 14,
                                blurSigma: 8,
                                child: Interactive3DPhone(
                                  assetPath:
                                      'assets/images/hero_phone_mockup.png',
                                  height: desktopPhoneHeight,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildLeftEditorialColumn(
                            vh: vh,
                            isDesktop: false,
                            isTablet: isTablet,
                          ),
                          const SizedBox(height: 44),
                          BlurFade(
                            triggerOnVisible: false,
                            delay: const Duration(milliseconds: 220),
                            yOffset: 14,
                            blurSigma: 8,
                            child: Interactive3DPhone(
                              assetPath: 'assets/images/hero_phone_mockup.png',
                              height: isTablet ? 460 : 380,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftEditorialColumn({
    required double vh,
    required bool isDesktop,
    required bool isTablet,
  }) {
    final h1Size = (vh * 0.068).clamp(38.0, 68.0);
    final subSize = (vh * 0.021).clamp(15.0, 20.0);
    final ctaHeight = (vh * 0.052).clamp(44.0, 48.0);
    const ctaHPad = 24.0;
    const ctaFontSize = 15.0;
    final alignment =
        isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center;
    final textAlign = isDesktop ? TextAlign.left : TextAlign.center;

    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Borderless status indicator with single surgical teal dot
        const BlurFade(
          triggerOnVisible: false,
          delay: Duration.zero,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 8,
                height: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: SariwaColors.brandPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Available on Android & Web',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _inkMuted,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Headline (H1) — dvh-scaled
        Semantics(
          header: true,
          child: BlurFade(
            triggerOnVisible: false,
            delay: const Duration(milliseconds: 60),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isDesktop ? 560 : 500),
              child: Text(
                'A clearer perspective on fish freshness.',
                textAlign: textAlign,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: h1Size,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.5,
                  height: 1.05,
                  color: _inkPrimary,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Subheadline — dvh-scaled
        BlurFade(
          triggerOnVisible: false,
          delay: const Duration(milliseconds: 120),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Text(
              'Check Tilapia freshness in seconds from a close-up eye or gill photo—right from your phone or browser.',
              textAlign: textAlign,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: subSize,
                fontWeight: FontWeight.w400,
                height: 1.55,
                color: _inkMuted,
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Primary (Near-Black Tactile) + Secondary (Crisp White) CTAs — dvh-scaled
        BlurFade(
          triggerOnVisible: false,
          delay: const Duration(milliseconds: 180),
          child: Wrap(
            alignment: isDesktop ? WrapAlignment.start : WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              _TactilePrimaryPill(
                label: 'Download App',
                height: ctaHeight,
                horizontalPadding: ctaHPad,
                fontSize: ctaFontSize,
                onPressed: onDownloads,
              ),
              _TactileSecondaryPill(
                label: 'Open Web Scanner',
                height: ctaHeight,
                horizontalPadding: ctaHPad,
                fontSize: ctaFontSize,
                trailing: const Icon(
                  CupertinoIcons.arrow_right,
                  size: 15,
                  color: _inkPrimary,
                ),
                onPressed: onDashboard ?? onLogIn,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGuestBanner() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1152.0),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _hairline),
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
                            color: _inkPrimary,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Guest Evaluation Mode',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _inkPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Scan history is temporary. Connect with Google to archive seafood quality audits.',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13,
                          height: 1.5,
                          color: _inkMuted,
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
                            foregroundColor: _inkPrimary,
                            side: const BorderSide(color: Color(0x1A171717)),
                            minimumSize: const Size(double.infinity, 44),
                            shape: const StadiumBorder(),
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
                        borderRadius: 999,
                        onPressed: onConnectGoogle,
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    const Icon(
                      CupertinoIcons.info_circle,
                      color: _inkPrimary,
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
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _inkPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Scan history is temporary. Connect with Google to archive seafood quality audits.',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 13,
                              color: _inkMuted,
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
                          foregroundColor: _inkPrimary,
                          side: const BorderSide(color: Color(0x1A171717)),
                          minimumSize: const Size(160, 40),
                          shape: const StadiumBorder(),
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
                      borderRadius: 999,
                      onPressed: onConnectGoogle,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TactilePrimaryPill extends StatefulWidget {
  final String label;
  final double height;
  final double horizontalPadding;
  final double fontSize;
  final VoidCallback onPressed;

  const _TactilePrimaryPill({
    required this.label,
    this.height = 50,
    this.horizontalPadding = 24,
    this.fontSize = 15,
    required this.onPressed,
  });

  @override
  State<_TactilePrimaryPill> createState() => _TactilePrimaryPillState();
}

class _TactilePrimaryPillState extends State<_TactilePrimaryPill> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          height: widget.height,
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFF262626) : const Color(0xFF111111),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.16),
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x24000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              customBorder: const StadiumBorder(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.horizontalPadding,
                ),
                child: Center(
                  widthFactor: 1.0,
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.1,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TactileSecondaryPill extends StatefulWidget {
  final String label;
  final double height;
  final double horizontalPadding;
  final double fontSize;
  final Widget? trailing;
  final VoidCallback onPressed;

  const _TactileSecondaryPill({
    required this.label,
    this.height = 50,
    this.horizontalPadding = 24,
    this.fontSize = 15,
    this.trailing,
    required this.onPressed,
  });

  @override
  State<_TactileSecondaryPill> createState() => _TactileSecondaryPillState();
}

class _TactileSecondaryPillState extends State<_TactileSecondaryPill> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          height: widget.height,
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFFFAFAFA) : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0x1A171717)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              customBorder: const StadiumBorder(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.horizontalPadding,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: widget.fontSize,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.1,
                        color: const Color(0xFF111111),
                      ),
                    ),
                    if (widget.trailing != null) ...[
                      const SizedBox(width: 8),
                      widget.trailing!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
