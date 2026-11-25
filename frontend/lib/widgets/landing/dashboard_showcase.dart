import 'dart:ui';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';
import 'walkthrough/scanning_reticle_painter.dart';

/// Static Dashboard Showcase Widget
/// Displays a high-fidelity static presentation of the actual existing SariwaBa? dashboard
/// inside an elegant, subtle browser / macOS window frame with realistic depth shadows.
///
/// If an optional [screenshotAsset] path is provided, it attempts to load that image,
/// falling back to the built-in pixel-faithful static presentation of the SariwaBa? workstation.
/// By default, it directly renders the built-in workstation view without making unnecessary asset requests.
class DashboardShowcase extends StatelessWidget {
  final double? width;
  final double? height;
  final String? screenshotAsset;

  const DashboardShowcase({
    super.key,
    this.width,
    this.height,
    this.screenshotAsset,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;
    final targetWidth = width ?? (isMobile ? screenWidth - 32 : 1060.0);
    final targetHeight = height ?? (isMobile ? 480.0 : 540.0);

    return Center(
      child: Container(
        width: targetWidth,
        constraints: const BoxConstraints(maxWidth: 1080),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0E0A2229),
              blurRadius: 32,
              offset: Offset(0, 16),
              spreadRadius: -4,
            ),
            BoxShadow(
              color: Color(0x080D9488),
              blurRadius: 54,
              offset: Offset(0, 26),
              spreadRadius: -8,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.90),
                  width: 1.2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Clean Browser / macOS Window Chrome Header
                  _buildBrowserHeader(isMobile),

                  // Dashboard Workspace Body (Height constrained)
                  SizedBox(
                    height: targetHeight - 40.0,
                    width: double.infinity,
                    child: (screenshotAsset != null && screenshotAsset!.isNotEmpty)
                        ? Image.asset(
                            screenshotAsset!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildStaticDashboard(isMobile);
                            },
                          )
                        : _buildStaticDashboard(isMobile),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Clean macOS / Browser Top Chrome Header
  Widget _buildBrowserHeader(bool isMobile) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC).withValues(alpha: 0.70),
        border: const Border(
          bottom: BorderSide(
            color: Color(0x200D9488),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          // macOS window traffic dots
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF5F56),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFBD2E),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  color: Color(0xFF27C93F),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),

          const SizedBox(width: 14),

          // Browser URL / Console Title Pill
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 11,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        isMobile
                            ? 'sariwaba.com/dashboard'
                            : 'sariwaba.com/dashboard — Seafood Quality Audit Console',
                        style: const TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF475569),
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // System Status Pill
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              if (!isMobile) ...[
                const SizedBox(width: 6),
                const Text(
                  'Model A • Online',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0F766E),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Static, pixel-faithful rendering of our actual existing SariwaBa? dashboard
  Widget _buildStaticDashboard(bool isMobile) {
    if (isMobile) {
      return _buildMobileDashboard();
    }

    return Container(
      color: const Color(0xFFF8FAFC),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar (190px)
          SizedBox(
            width: 190,
            child: _buildSidebar(),
          ),

          // Main Workspace
          Expanded(
            child: _buildMainWorkspace(),
          ),
        ],
      ),
    );
  }

  /// Authentic Left Sidebar matching DashboardSidebar
  Widget _buildSidebar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Lockup
          Row(
            children: [
              Image.asset(
                'assets/images/SariwaBa logo.png',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: SariwaColors.brandPrimary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.waves, color: Colors.white, size: 14),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'SariwaBa',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: Color(0xFF0A2229),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          const Text(
            'WORKSPACE',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: Color(0xFF94A3B8),
            ),
          ),

          const SizedBox(height: 8),

          // Nav Items
          _buildNavItem(
            icon: CupertinoIcons.viewfinder,
            label: 'Inspection',
            isActive: true,
          ),
          const SizedBox(height: 4),
          _buildNavItem(
            icon: Icons.history_rounded,
            label: 'Audit History',
            isActive: false,
            badge: '12',
          ),
          const SizedBox(height: 4),
          _buildNavItem(
            icon: Icons.insights_rounded,
            label: 'Analytics',
            isActive: false,
          ),
          const SizedBox(height: 4),
          _buildNavItem(
            icon: Icons.fact_check_outlined,
            label: 'Grade Standards',
            isActive: false,
          ),

          const Spacer(),

          // Evaluator User Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: SariwaColors.brandPrimary,
                  child: const Text(
                    'M',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Marc (Lead)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Verified Evaluator',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    String? badge,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE6F5F2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isActive ? SariwaColors.brandPrimary : const Color(0xFF64748B),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12.5,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? SariwaColors.brandPrimary : const Color(0xFF334155),
              ),
            ),
          ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isActive ? SariwaColors.brandPrimary : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Main Dashboard Workspace (Atmospheric Banner + 2-Column Studio matching real UI)
  Widget _buildMainWorkspace() {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Atmospheric Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0A2229),
                  Color(0xFF0F4C4C),
                  Color(0xFF168077),
                ],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x180A2229),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
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
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 1),
                      Text(
                        'Inspect close-up eyes, exposed gills, or whole Tilapia photos.',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFFD1FAF4),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.28),
                    ),
                  ),
                  child: const Text(
                    'Example preview',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Two-Column Studio (Left: Freshness Scanner + Eye Filmstrip, Right: Current Scan Result)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 58,
                  child: _buildModernScannerCard(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 42,
                  child: _buildModernResultPanel(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernScannerCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SariwaColors.borderLightTeal),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: SariwaColors.brandPrimary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  CupertinoIcons.viewfinder,
                  size: 13,
                  color: SariwaColors.brandPrimary,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Freshness Scanner',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: SariwaColors.textPrimaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 5, color: SariwaColors.brandPrimary),
                    SizedBox(width: 4),
                    Text(
                      'Tilapia only',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Dark image frame with numbered eye marker, Crop + X, and < 1/3 > carousel
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: const Color(0xFF0A1926),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/sample_tilapia2.jpg',
                      fit: BoxFit.cover,
                      alignment: const Alignment(0.0, 0.1),
                      errorBuilder: (_, _, _) => Container(
                        color: const Color(0xFF0F2933),
                      ),
                    ),
                    // Numbered Eye Marker #1
                    Positioned(
                      left: 56,
                      top: 38,
                      width: 56,
                      height: 56,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: SariwaColors.brandGlow,
                            width: 2.2,
                          ),
                          color: SariwaColors.brandGlow.withValues(alpha: 0.16),
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: const BoxDecoration(
                              color: SariwaColors.brandPrimary,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(5),
                                bottomRight: Radius.circular(5),
                              ),
                            ),
                            child: const Text(
                              '1',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Top-right Crop + Close overlay
                    Positioned(
                      top: 7,
                      right: 7,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildMiniCircleOverlay(CupertinoIcons.crop),
                          const SizedBox(width: 5),
                          _buildMiniCircleOverlay(CupertinoIcons.xmark),
                        ],
                      ),
                    ),
                    // Carousel < > arrows
                    Positioned(
                      left: 7,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _buildMiniCircleOverlay(
                          CupertinoIcons.chevron_left,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 7,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _buildMiniCircleOverlay(
                          CupertinoIcons.chevron_right,
                        ),
                      ),
                    ),
                    // 1 / 3 counter pill
                    Positioned(
                      right: 7,
                      bottom: 7,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xCC0A1926),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22),
                          ),
                        ),
                        child: const Text(
                          '1 / 3',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Eye Thumbnail Filmstrip (#1 selected + Fresh check, #2, #3)
          SizedBox(
            height: 40,
            child: Row(
              children: [
                _buildMiniEyeThumb('#1', isSelected: true, checkedFresh: true),
                const SizedBox(width: 6),
                _buildMiniEyeThumb('#2', isSelected: false),
                const SizedBox(width: 6),
                _buildMiniEyeThumb('#3', isSelected: false),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Soft Pill Region Switcher (Auto | Eye | Gill) + Detect Eyes icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildMiniRegionPill(
                      'Auto',
                      CupertinoIcons.sparkles,
                      isActive: true,
                    ),
                    _buildMiniRegionPill(
                      'Eye',
                      CupertinoIcons.eye,
                      isActive: false,
                    ),
                    _buildMiniRegionPill(
                      'Gill',
                      CupertinoIcons.waveform_path,
                      isActive: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: const Icon(
                  Icons.center_focus_strong_rounded,
                  size: 13,
                  color: SariwaColors.brandPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Aquatic-Gradient Check Freshness Button
          Container(
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D5E57),
                  Color(0xFF168077),
                  Color(0xFF249E92),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D5E57).withValues(alpha: 0.22),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.sparkles, size: 12, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'Check freshness',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCircleOverlay(IconData icon) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: const Color(0xB80A1926),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Icon(icon, size: 11, color: Colors.white),
    );
  }

  Widget _buildMiniEyeThumb(
    String label, {
    required bool isSelected,
    bool? checkedFresh,
  }) {
    return Container(
      width: 50,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isSelected
            ? SariwaColors.brandPrimary.withValues(alpha: 0.12)
            : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? SariwaColors.brandPrimary
              : const Color(0xFFCBD5E1),
          width: isSelected ? 1.6 : 1.0,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              'assets/images/sample_tilapia2.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFFE2E8F0),
              ),
            ),
          ),
          Positioned(
            left: 2,
            top: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? SariwaColors.brandPrimary
                    : const Color(0xCC0A1926),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 7.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (checkedFresh != null)
            const Positioned(
              right: 2,
              bottom: 2,
              child: Icon(
                CupertinoIcons.checkmark_circle_fill,
                size: 10,
                color: SariwaColors.statusFresh,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMiniRegionPill(
    String label,
    IconData icon, {
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        boxShadow: isActive
            ? const [
                BoxShadow(
                  color: Color(0x120F172A),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10.5,
            color: isActive
                ? SariwaColors.brandPrimary
                : const Color(0xFF64748B),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive
                  ? SariwaColors.textPrimaryDark
                  : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernResultPanel() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SariwaColors.borderLightTeal),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Freshness Result Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SariwaColors.freshIconBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: SariwaColors.freshBorder, width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/sample_tilapia2.jpg',
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 40,
                          height: 40,
                          color: const Color(0xFFDCFCE7),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fresh',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: SariwaColors.statusFresh,
                            ),
                          ),
                          SizedBox(height: 1),
                          Text(
                            'Model confidence: 94.7%',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: SariwaColors.textPrimaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: const LinearProgressIndicator(
                    value: 0.947,
                    minHeight: 5.5,
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      SariwaColors.statusFresh,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Model confidence reflects the classifier prediction score, not a freshness percentage or food-safety guarantee.',
                  style: TextStyle(
                    fontSize: 9.5,
                    height: 1.35,
                    color: SariwaColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF0D5E57),
                              Color(0xFF168077),
                              Color(0xFF249E92),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Scan Another',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: const Center(
                        child: Text(
                          'Adjust crop',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: SariwaColors.textPrimaryDark,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'View scan history →',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: SariwaColors.brandPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Compact Batch Preview strip at bottom of right panel
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFA),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: SariwaColors.borderLightTeal),
            ),
            child: const Row(
              children: [
                Icon(
                  CupertinoIcons.checkmark_shield_fill,
                  size: 14,
                  color: SariwaColors.brandPrimary,
                ),
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Auto-detects eyes on whole Tilapia & crowded trays.',
                    style: TextStyle(
                      fontSize: 10,
                      color: SariwaColors.textSecondaryDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String trend,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Left Specimen Inspection Card with Tilapia specimen preview
  Widget _buildInspectionCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Specimen #SB-2026-1108',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Verified SARIWA',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Specimen Image Preview with authentic dashboard inspection overlay
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Layer 1: Actual specimen image
                  Image.asset(
                    'assets/images/sample_tilapia2.jpg',
                    fit: BoxFit.cover,
                    alignment: const Alignment(0.0, 0.15),
                    errorBuilder: (_, _, _) => Container(
                      color: const Color(0xFFE2E8F0),
                      child: const Center(
                        child: Icon(Icons.image_outlined, color: Color(0xFF94A3B8)),
                      ),
                    ),
                  ),

                  // Layer 2: Subtle radial vignette for optical inspection chamber depth
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(-0.15, -0.05),
                          radius: 0.90,
                          colors: [
                            Colors.black.withValues(alpha: 0.05),
                            Colors.black.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Layer 3: Scanning Reticle & Corner Brackets framing the target ROI
                  Positioned(
                    left: 24,
                    top: 14,
                    width: 104,
                    height: 104,
                    child: CustomPaint(
                      painter: ScanningReticlePainter(
                        scanProgress: 0.70,
                        isScanning: true,
                        primaryColor: const Color(0xFF2DD4BF),
                      ),
                    ),
                  ),

                  // Layer 4: Top Floating Frosted-Glass HUD Bar
                  Positioned(
                    top: 7,
                    left: 8,
                    right: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Filename pill
                        Flexible(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0x991C1C1E),
                                  borderRadius: BorderRadius.circular(99),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.20),
                                    width: 0.5,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.photo_outlined,
                                      size: 10.5,
                                      color: Colors.white70,
                                    ),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'sample_tilapia2.jpg',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          letterSpacing: -0.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Target ROI pill with glowing teal accent
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xD00D9488),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                              color: const Color(0xFF5EEAD4),
                              width: 0.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF14B8A6).withValues(alpha: 0.45),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.crop_free_rounded,
                                size: 10,
                                color: Colors.white,
                              ),
                              SizedBox(width: 3.5),
                              Text(
                                'Target ROI: Eye',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Layer 5: Bottom live confidence & calibrated inference badge
                  Positioned(
                    bottom: 7,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0x602DD4BF),
                          width: 0.8,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 10,
                            color: Color(0xFF34D399),
                          ),
                          SizedBox(width: 3.5),
                          Text(
                            'AI Conf: 94.7%',
                            style: TextStyle(
                              color: Color(0xFF5EEAD4),
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
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

          const SizedBox(height: 8),

          // Region Selector and Model Confidence Score
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F5F2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: SariwaColors.brandPrimary, width: 1.0),
                    ),
                    child: const Text(
                      'Eye (Selected)',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: SariwaColors.brandPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                    ),
                    child: const Text(
                      'Gills',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF15803D)),
                  SizedBox(width: 4),
                  Text(
                    '94.7% Confidence',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Right Audit Log Table matching AuditHistorySection
  Widget _buildAuditLogCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Recent Audits',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '12 Scans',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'SPECIMEN ID',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'REGION',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'SCORE',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'STATUS',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Audit Rows
          Expanded(
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildAuditRow('#SB-2026-1108', 'Tilapia Eye', '94.7%', isFresh: true),
                _buildAuditRow('#SB-2026-1107', 'Tilapia Gill', '91.2%', isFresh: false),
                _buildAuditRow('#SB-2026-1106', 'Tilapia Eye', '96.0%', isFresh: true),
                _buildAuditRow('#SB-2026-1105', 'Tilapia Eye', '93.5%', isFresh: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditRow(String id, String region, String score, {required bool isFresh}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF8FAFC))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              id,
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              region,
              style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              score,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF334155)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: isFresh ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isFresh ? 'Fresh' : 'Not Fresh',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: isFresh ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Clean, tailored responsive mobile dashboard presentation matching our iOS-style mobile UI
  Widget _buildMobileDashboard() {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          // Compact Mobile Top Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            child: const Row(
              children: [
                Icon(CupertinoIcons.bars, size: 16, color: Color(0xFF0A2229)),
                SizedBox(width: 8),
                Text(
                  'Inspect',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0A2229),
                  ),
                ),
                Spacer(),
                Icon(
                  CupertinoIcons.question_circle,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: _buildModernScannerCard(),
            ),
          ),
          // iOS-style Bottom Navbar with center '+' button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Icon(
                  CupertinoIcons.viewfinder,
                  size: 18,
                  color: SariwaColors.brandPrimary,
                ),
                const Icon(
                  CupertinoIcons.clock,
                  size: 18,
                  color: Color(0xFF64748B),
                ),
                Container(
                  width: 38,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        SariwaColors.brandGlow,
                        SariwaColors.brandPrimary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    CupertinoIcons.plus,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const Icon(
                  CupertinoIcons.chart_bar,
                  size: 18,
                  color: Color(0xFF64748B),
                ),
                const Icon(
                  CupertinoIcons.gear,
                  size: 18,
                  color: Color(0xFF64748B),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
