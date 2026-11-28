import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../../../constants/theme/app_colors.dart';
import '../../../constants/theme/app_typography.dart';
import '../../../models/auth/user_model.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/blur_fade.dart';

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
    final isLargeDesktop = size.width >= 1024;
    final isTablet = size.width >= 640 && size.width < 1024;
    final minHeroHeight = isLargeDesktop
        ? (size.height - 88).clamp(580.0, 820.0)
        : 0.0;

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
                  vertical: isLargeDesktop ? 64.0 : 44.0,
                ),
                child: isLargeDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 6,
                            child: _buildLeftEditorialColumn(
                              isDesktop: true,
                              isTablet: false,
                            ),
                          ),
                          const SizedBox(width: 32),
                          const Expanded(
                            flex: 6,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: BlurFade(
                                triggerOnVisible: false,
                                delay: Duration(milliseconds: 220),
                                yOffset: 14,
                                blurSigma: 8,
                                child: _PhoneMockup3D(isAngled: true),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildLeftEditorialColumn(
                            isDesktop: false,
                            isTablet: isTablet,
                          ),
                          const SizedBox(height: 48),
                          const BlurFade(
                            triggerOnVisible: false,
                            delay: Duration(milliseconds: 220),
                            yOffset: 14,
                            blurSigma: 8,
                            child: _PhoneMockup3D(isAngled: false),
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
    required bool isDesktop,
    required bool isTablet,
  }) {
    final h1Size = isDesktop ? 56.0 : (isTablet ? 46.0 : 36.0);
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

        // Headline (H1)
        Semantics(
          header: true,
          child: BlurFade(
            triggerOnVisible: false,
            delay: const Duration(milliseconds: 60),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isDesktop ? 540 : 480),
              child: Text(
                'A clearer perspective on fish freshness.',
                textAlign: textAlign,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: h1Size,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.03 * h1Size,
                  height: 1.06,
                  color: _inkPrimary,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Subheadline
        BlurFade(
          triggerOnVisible: false,
          delay: const Duration(milliseconds: 120),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Text(
              'Check Tilapia freshness in seconds from a close-up eye or gill photo—right from your phone or browser.',
              textAlign: textAlign,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: isDesktop ? 17 : 15,
                fontWeight: FontWeight.w400,
                height: 1.6,
                color: _inkMuted,
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Primary (Near-Black Tactile) + Secondary (Crisp White) CTAs
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
                onPressed: onDownloads,
              ),
              _TactileSecondaryPill(
                label: 'Open Web Scanner',
                trailing: const Icon(
                  CupertinoIcons.arrow_right,
                  size: 14,
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

/// Sleek 3D Angled Smartphone Mockup displaying the SariwaBa Mobile Inspection UI.
/// Uses subtle 3D perspective tilt on desktop (`rotateY(-12deg) rotateX(5deg) rotateZ(2deg)`)
/// and sits straight on mobile for crisp legibility.
class _PhoneMockup3D extends StatelessWidget {
  final bool isAngled;

  const _PhoneMockup3D({required this.isAngled});

  static const Color _canvas = Color(0xFFF5F5F7);
  static const Color _inkPrimary = Color(0xFF111111);
  static const Color _inkMuted = Color(0xFF737373);
  static const Color _border = Color(0x14171717);

  @override
  Widget build(BuildContext context) {
    final phoneWidth = isAngled ? 310.0 : 292.0;

    final Matrix4 transform = Matrix4.identity();
    if (isAngled) {
      transform
        ..setEntry(3, 2, 0.00072) // ~1400px perspective
        ..rotateY(-0.209) // -12 deg
        ..rotateX(0.087) // +5 deg
        ..rotateZ(0.035); // +2 deg
    }

    return Padding(
      padding: EdgeInsets.only(right: isAngled ? 16 : 0, bottom: 16),
      child: Transform(
        alignment: Alignment.center,
        transform: transform,
        child: SizedBox(
          width: phoneWidth + 6,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Left side hardware volume buttons
              Positioned(
                left: 0,
                top: 112,
                child: Container(
                  width: 3,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B2B2E),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 160,
                child: Container(
                  width: 3,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B2B2E),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Right side power button
              Positioned(
                right: 0,
                top: 136,
                child: Container(
                  width: 3,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B2B2E),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Main Smartphone Chassis
              Container(
                width: phoneWidth,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(46),
                  border: Border.all(
                    color: const Color(0xFF2E2E32),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x38000000),
                      blurRadius: 60,
                      offset: Offset(20, 32),
                      spreadRadius: -15,
                    ),
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                      spreadRadius: -8,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(36),
                  child: Container(
                    color: _canvas,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Status bar + Dynamic Island
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 18, 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '9:41',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _inkPrimary,
                                ),
                              ),
                              Container(
                                width: 82,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0A0A0A),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.wifi,
                                    size: 11,
                                    color: _inkPrimary,
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    CupertinoIcons.battery_full,
                                    size: 13,
                                    color: _inkPrimary,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Compact Native Mobile Header
                        const Padding(
                          padding: EdgeInsets.fromLTRB(14, 6, 14, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Freshness Inspection',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.35,
                                  color: _inkPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '10 scans · 100% fresh',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: _inkMuted,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Clean White Scanner Card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Tilapia Photo + Sharp Surgical Teal Eye Reticle (#1)
                                SizedBox(
                                  height: 132,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.asset(
                                          'assets/images/sample_tilapia2.jpg',
                                          fit: BoxFit.cover,
                                          alignment: const Alignment(0.0, 0.1),
                                          errorBuilder: (_, _, _) =>
                                              const ColoredBox(
                                            color: Color(0xFF171717),
                                          ),
                                        ),
                                        Positioned(
                                          left: 44,
                                          top: 26,
                                          width: 56,
                                          height: 56,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color:
                                                    SariwaColors.brandPrimary,
                                                width: 2.2,
                                              ),
                                              color: SariwaColors.brandPrimary
                                                  .withValues(alpha: 0.14),
                                            ),
                                            child: Align(
                                              alignment: Alignment.topLeft,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 5,
                                                  vertical: 1,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color:
                                                      SariwaColors.brandPrimary,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft: Radius.circular(5),
                                                    bottomRight:
                                                        Radius.circular(6),
                                                  ),
                                                ),
                                                child: const Text(
                                                  '#1',
                                                  style: TextStyle(
                                                    fontFamily: 'Geist Mono',
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Mini Eye-Crop Thumbnails
                                Row(
                                  children: [
                                    _miniEyeThumb('#1', isSelected: true),
                                    const SizedBox(width: 6),
                                    _miniEyeThumb('#2', isSelected: false),
                                    const SizedBox(width: 6),
                                    _miniEyeThumb('#3', isSelected: false),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Clean White Result Card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          CupertinoIcons.checkmark_seal_fill,
                                          size: 14,
                                          color: SariwaColors.brandPrimary,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          'Fresh',
                                          style: TextStyle(
                                            fontFamily:
                                                AppTypography.fontFamily,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: SariwaColors.brandPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Confidence · 95.1%',
                                      style: TextStyle(
                                        fontFamily: 'Geist Mono',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: _inkPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: const LinearProgressIndicator(
                                    value: 0.951,
                                    minHeight: 6,
                                    backgroundColor: Color(0xFFE5E5E7),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      SariwaColors.brandPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Subtle Floating Mobile Bottom Nav Bar + Near-Black Camera FAB
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: _border),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF5F5F5),
                                            borderRadius:
                                                BorderRadius.circular(999),
                                          ),
                                          child: const Icon(
                                            CupertinoIcons
                                                .viewfinder_circle_fill,
                                            size: 14,
                                            color: _inkPrimary,
                                          ),
                                        ),
                                      ),
                                      const Expanded(
                                        child: Icon(
                                          CupertinoIcons.clock,
                                          size: 14,
                                          color: _inkMuted,
                                        ),
                                      ),
                                      const Expanded(
                                        child: Icon(
                                          CupertinoIcons.settings,
                                          size: 14,
                                          color: _inkMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 34,
                                height: 34,
                                decoration: const BoxDecoration(
                                  color: _inkPrimary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  CupertinoIcons.camera_fill,
                                  size: 14,
                                  color: Colors.white,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniEyeThumb(String label, {required bool isSelected}) {
    return Container(
      width: 40,
      height: 30,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: isSelected
              ? SariwaColors.brandPrimary
              : const Color(0x14171717),
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.asset(
              'assets/images/sample_tilapia2.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const ColoredBox(
                color: Color(0xFFE5E5E7),
              ),
            ),
          ),
          Positioned(
            left: 2,
            top: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0.5),
              decoration: BoxDecoration(
                color: isSelected
                    ? SariwaColors.brandPrimary
                    : const Color(0xCC111111),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Geist Mono',
                  fontSize: 7,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TactilePrimaryPill extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _TactilePrimaryPill({
    required this.label,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 14,
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
    );
  }
}

class _TactileSecondaryPill extends StatefulWidget {
  final String label;
  final Widget? trailing;
  final VoidCallback onPressed;

  const _TactileSecondaryPill({
    required this.label,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.1,
                        color: Color(0xFF111111),
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
