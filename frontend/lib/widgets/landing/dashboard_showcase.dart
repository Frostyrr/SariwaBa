import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';
import '../dashboard/dashboard_atmospheric_banner.dart';

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
          color: SariwaColors.cardSurfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: SariwaColors.colorLine,
            width: 1.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: SariwaColors.shadowSubtle,
              blurRadius: 24,
              offset: Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
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
    );
  }

  /// Clean macOS / Browser Top Chrome Header
  Widget _buildBrowserHeader(bool isMobile) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: SariwaColors.surfaceSlateTint.withValues(alpha: 0.70),
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
              const SizedBox(width: 8),
              Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFBD2E),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
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

          const SizedBox(width: 16),

          // Browser URL Pill
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: SariwaColors.cardSurfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: SariwaColors.surfaceSlateSubtle,
                    width: 0.8,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 11,
                      color: SariwaColors.inkSlateMuted,
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'sariwaba.com/dashboard',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: SariwaColors.inkSlateSecondary,
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

          const SizedBox(width: 60),
        ],
      ),
    );
  }

  /// Static, pixel-faithful rendering of our actual existing SariwaBa dashboard
  Widget _buildStaticDashboard(bool isMobile) {
    if (isMobile) {
      return _buildMobileDashboard();
    }

    return Container(
      color: SariwaColors.surfaceSlateTint,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar (196px)
          SizedBox(
            width: 196,
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
        color: SariwaColors.cardSurfaceLight,
        border: Border(
          right: BorderSide(color: SariwaColors.surfaceSlateSubtle, width: 1.0),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Lockup
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/images/SariwaBa logo.png',
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: SariwaColors.brandPrimary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.waves,
                      color: SariwaColors.cardSurfaceLight,
                      size: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'SariwaBa',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.3,
                    color: SariwaColors.textPrimaryDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'WORKSPACE',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 10,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.8,
                color: SariwaColors.inkSlateSubtle,
              ),
            ),
          ),

          const SizedBox(height: 6),

          _buildNavItem(
            icon: CupertinoIcons.viewfinder,
            label: 'Inspection',
            isActive: true,
          ),
          const SizedBox(height: 4),
          _buildNavItem(
            icon: CupertinoIcons.clock,
            label: 'History & Insights',
            isActive: false,
            badge: '12',
          ),

          const SizedBox(height: 16),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'GENERAL',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 10,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.8,
                color: SariwaColors.inkSlateSubtle,
              ),
            ),
          ),

          const SizedBox(height: 6),

          _buildNavItem(
            icon: CupertinoIcons.question_circle,
            label: 'Help & Guide',
            isActive: false,
          ),
          const SizedBox(height: 4),
          _buildNavItem(
            icon: CupertinoIcons.device_phone_portrait,
            label: 'Get Mobile App',
            isActive: false,
          ),

          const Spacer(),
          const Divider(height: 1, color: SariwaColors.surfaceSlateSubtle),
          const SizedBox(height: 10),

          // User Profile Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: SariwaColors.surfaceSlateWash,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 13,
                  backgroundColor: SariwaColors.brandPrimary,
                  child: Text(
                    'I',
                    style: TextStyle(
                      color: SariwaColors.cardSurfaceLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
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
                        'Inspector',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: SariwaColors.inkSlate,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Synced account',
                        style: TextStyle(
                          fontSize: 11,
                          color: SariwaColors.inkSlateMuted,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE6F5F2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 15,
            color: isActive ? SariwaColors.brandPrimary : SariwaColors.inkSlateMuted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? SariwaColors.brandPrimary : SariwaColors.inkSlateSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isActive ? SariwaColors.brandPrimary : SariwaColors.surfaceSlateSubtle,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isActive ? SariwaColors.cardSurfaceLight : SariwaColors.inkSlateSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Main Dashboard Workspace matching InspectionWorkspaceSection
  Widget _buildMainWorkspace() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Atmospheric Banner matching real DashboardAtmosphericBanner (backgroundBlurred.jpg)
          DashboardAtmosphericBanner(
            borderRadius: 16,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
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
                            SizedBox(width: 6),
                            Text(
                              'Synced',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: SariwaColors.brandPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Welcome back',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.3,
                          color: SariwaColors.cardSurfaceLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Snap or upload an eye, gill, or whole fish photo.',
                        style: TextStyle(
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
                    vertical: 7,
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
                        CupertinoIcons.refresh,
                        size: 12,
                        color: SariwaColors.brandPrimary,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Refresh',
                        style: TextStyle(
                          fontSize: 11,
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

          // Two-Column Studio (7:5 ratio matching InspectionWorkspaceSection)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 7,
                  child: _buildModernScannerCard(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 5,
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SariwaColors.cardSurfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SariwaColors.borderLightTeal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header matching ScannerWorkstationCard (no "Tilapia only" pill)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: SariwaColors.brandPrimary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  CupertinoIcons.viewfinder,
                  size: 14,
                  color: SariwaColors.brandPrimary,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Freshness Scanner',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: SariwaColors.textPrimaryDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Eye, gill, or whole fish photo.',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w300,
                        color: SariwaColors.textSecondaryDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Slim action header row ABOVE image canvas (matches real ScannerWorkstationCard)
          Row(
            children: [
              const Icon(
                CupertinoIcons.photo,
                size: 12,
                color: SariwaColors.textSecondaryDark,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'tilapia_sample.jpg',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: SariwaColors.textSecondaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: SariwaColors.surfaceSlateWash,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: SariwaColors.lineSlate),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.crop,
                      size: 10,
                      color: SariwaColors.textPrimaryDark,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Crop',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: SariwaColors.textPrimaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: SariwaColors.surfaceSlateWash,
                  shape: BoxShape.circle,
                  border: Border.all(color: SariwaColors.lineSlate),
                ),
                child: const Icon(
                  CupertinoIcons.xmark,
                  size: 10,
                  color: SariwaColors.textSecondaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Dark image frame with numbered eye marker #1
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
                      top: 32,
                      width: 52,
                      height: 52,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: SariwaColors.brandGlow,
                            width: 2.0,
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
                                topLeft: Radius.circular(6),
                                bottomRight: Radius.circular(6),
                              ),
                            ),
                            child: const Text(
                              '1',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: SariwaColors.cardSurfaceLight,
                              ),
                            ),
                          ),
                        ),
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
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xCC0A1926),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: SariwaColors.cardSurfaceLight.withValues(alpha: 0.22),
                          ),
                        ),
                        child: const Text(
                          '1 / 3',
                          style: TextStyle(
                            fontSize: 10,
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
          ),

          const SizedBox(height: 8),

          // Eye Thumbnail Filmstrip (#1 selected + Fresh check, #2, #3)
          SizedBox(
            height: 36,
            child: Row(
              children: [
                _buildMiniEyeThumb('#1', isSelected: true, checkedFresh: true),
                const SizedBox(width: 8),
                _buildMiniEyeThumb('#2', isSelected: false),
                const SizedBox(width: 8),
                _buildMiniEyeThumb('#3', isSelected: false),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Region Switcher (Auto | Eye | Gill) + Pill Check freshness CTA
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: SariwaColors.surfaceSlateWash,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: SariwaColors.surfaceSlateSubtle),
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
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: SariwaColors.brandPrimary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.sparkles,
                        size: 12,
                        color: SariwaColors.cardSurfaceLight,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Check freshness',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: SariwaColors.cardSurfaceLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
        border: Border.all(color: SariwaColors.cardSurfaceLight.withValues(alpha: 0.25)),
      ),
      child: Icon(icon, size: 11, color: SariwaColors.cardSurfaceLight),
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
            : SariwaColors.cardSurfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? SariwaColors.brandPrimary
              : SariwaColors.lineSlate,
          width: isSelected ? 1.6 : 1.0,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/sample_tilapia2.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: SariwaColors.surfaceSlateSubtle,
              ),
            ),
          ),
          Positioned(
            left: 2,
            top: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? SariwaColors.brandPrimary
                    : const Color(0xCC0A1926),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: SariwaColors.cardSurfaceLight,
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
        color: isActive ? SariwaColors.cardSurfaceLight : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
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
            size: 10,
            color: isActive
                ? SariwaColors.brandPrimary
                : SariwaColors.inkSlateMuted,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isActive
                  ? SariwaColors.textPrimaryDark
                  : SariwaColors.inkSlateMuted,
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
        color: SariwaColors.cardSurfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SariwaColors.borderLightTeal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Freshness Result Card matching CurrentScanPanel._buildResultCard
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SariwaColors.freshIconBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SariwaColors.freshBorder, width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/sample_tilapia2.jpg',
                        width: 42,
                        height: 42,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 42,
                          height: 42,
                          color: SariwaColors.freshTrack,
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
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: SariwaColors.statusFresh,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Confidence · 94.7%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: SariwaColors.textPrimaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: const LinearProgressIndicator(
                    value: 0.947,
                    minHeight: 6,
                    backgroundColor: SariwaColors.cardSurfaceLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      SariwaColors.statusFresh,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Visual freshness estimate — not a food-safety guarantee.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w300,
                    height: 1.35,
                    color: SariwaColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                          color: SariwaColors.brandPrimary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.camera_viewfinder,
                              size: 12,
                              color: SariwaColors.cardSurfaceLight,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Scan Another',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: SariwaColors.cardSurfaceLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: SariwaColors.cardSurfaceLight,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: SariwaColors.lineSlate),
                      ),
                      child: const Center(
                        child: Text(
                          'Adjust crop',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: SariwaColors.textPrimaryDark,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.clock,
                        size: 12,
                        color: SariwaColors.brandPrimary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'View scan history →',
                        style: TextStyle(
                          fontSize: 11,
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
          const Spacer(),
          // Detected Eyes summary matching CurrentScanPanel
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: SariwaColors.surfaceSlateWash,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SariwaColors.surfaceSlateSubtle),
            ),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.eye_fill,
                  size: 13,
                  color: SariwaColors.brandPrimary,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Detected Eyes (3)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: SariwaColors.textPrimaryDark,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: SariwaColors.freshTrack,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Eye #1 selected',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: SariwaColors.freshText,
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

  /// Clean, tailored responsive mobile dashboard presentation matching our iOS-style mobile UI
  Widget _buildMobileDashboard() {
    return Container(
      color: SariwaColors.surfaceSlateTint,
      child: Column(
        children: [
          // Compact Mobile Top Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: SariwaColors.cardSurfaceLight,
              border: Border(
                bottom: BorderSide(color: SariwaColors.surfaceSlateSubtle),
              ),
            ),
            child: const Row(
              children: [
                Icon(CupertinoIcons.bars, size: 16, color: SariwaColors.textPrimaryDark),
                SizedBox(width: 8),
                Text(
                  'Inspect',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: SariwaColors.textPrimaryDark,
                  ),
                ),
                Spacer(),
                Icon(
                  CupertinoIcons.question_circle,
                  size: 16,
                  color: SariwaColors.inkSlateMuted,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _buildModernScannerCard(),
            ),
          ),
          // iOS-style Bottom Navbar with center '+' button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: SariwaColors.cardSurfaceLight,
              border: Border(top: BorderSide(color: SariwaColors.surfaceSlateSubtle)),
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
                  color: SariwaColors.inkSlateMuted,
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    CupertinoIcons.plus,
                    size: 16,
                    color: SariwaColors.cardSurfaceLight,
                  ),
                ),
                const Icon(
                  CupertinoIcons.chart_bar,
                  size: 18,
                  color: SariwaColors.inkSlateMuted,
                ),
                const Icon(
                  CupertinoIcons.gear,
                  size: 18,
                  color: SariwaColors.inkSlateMuted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
