import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';

/// Monochrome-first Open-Bottom Dashboard Showcase Widget
/// Mirrors the refactored `/dashboard` workspace (`#F5F5F7` canvas, crisp white
/// sidebar & cards, minimalist header, tactile `#111111` buttons, surgical teal
/// strictly on synced dot, eye reticle, and Fresh progress bar) inside an
/// open-bottom frame that dissolves seamlessly into `#F5F5F7`.
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

  static const Color _canvas = Color(0xFFF5F5F7);
  static const Color _inkPrimary = Color(0xFF111111);
  static const Color _inkMuted = Color(0xFF737373);
  static const Color _border = Color(0x14171717);
  static const Color _neutralPill = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final targetWidth = width ?? 1060.0;
    final targetHeight = height ?? 520.0;

    return Center(
      child: Container(
        width: targetWidth.clamp(0.0, screenWidth - 48),
        constraints: const BoxConstraints(maxWidth: 1080),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          border: Border(
            top: BorderSide(color: _border, width: 1.0),
            left: BorderSide(color: _border, width: 1.0),
            right: BorderSide(color: _border, width: 1.0),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: SizedBox(
            height: targetHeight,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: (screenshotAsset != null && screenshotAsset!.isNotEmpty)
                      ? Image.asset(
                          screenshotAsset!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _buildMonochromeDashboard(),
                        )
                      : _buildMonochromeDashboard(),
                ),
                // Seamless bottom fade-out into #F5F5F7 canvas (h-40 = 160px)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 160,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          stops: const [0.0, 0.45, 1.0],
                          colors: [
                            _canvas,
                            _canvas.withValues(alpha: 0.85),
                            Colors.transparent,
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
      ),
    );
  }

  Widget _buildMonochromeDashboard() {
    return Container(
      color: _canvas,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: 204, child: _buildSidebar()),
          Expanded(child: _buildMainWorkspace()),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: _border, width: 1.0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/SariwaBa logo.png',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  CupertinoIcons.sparkles,
                  size: 18,
                  color: SariwaColors.brandPrimary,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'SariwaBa',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: _inkPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'WORKSPACE',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.8,
                color: _inkMuted,
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
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'GENERAL',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.8,
                color: _inkMuted,
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
          const Divider(height: 1, color: _border),
          const SizedBox(height: 10),
          Row(
            children: [
              const CircleAvatar(
                radius: 13,
                backgroundColor: _inkPrimary,
                child: Text(
                  'I',
                  style: TextStyle(
                    color: Colors.white,
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
                        color: _inkPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Synced account',
                      style: TextStyle(fontSize: 11, color: _inkMuted),
                    ),
                  ],
                ),
              ),
            ],
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
        color: isActive ? _neutralPill : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: isActive ? _inkPrimary : _inkMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                color: isActive ? _inkPrimary : const Color(0xFF525252),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5E5),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF404040),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainWorkspace() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Minimalist Monochrome Header (matches refactored InspectionWorkspaceSection)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Borderless status indicator
                    const Row(
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
                            color: _inkMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Freshness Inspection',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: _inkPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Snap or upload an eye, gill, or whole fish photo.',
                      style: TextStyle(fontSize: 12, color: _inkMuted),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0x1A171717)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.refresh, size: 12, color: _inkPrimary),
                    SizedBox(width: 6),
                    Text(
                      'Refresh',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _inkPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Two-Column Monochrome Workspace (7:5 ratio)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 7, child: _buildScannerCard()),
                const SizedBox(width: 16),
                Expanded(flex: 5, child: _buildResultCard()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _neutralPill,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  CupertinoIcons.viewfinder,
                  size: 14,
                  color: _inkPrimary,
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
                        fontWeight: FontWeight.w600,
                        color: _inkPrimary,
                      ),
                    ),
                    Text(
                      'Eye, gill, or whole fish photo.',
                      style: TextStyle(fontSize: 11, color: _inkMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: _border),
                ),
                child: const Text(
                  'Crop',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: _inkPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/sample_tilapia2.jpg',
                    fit: BoxFit.cover,
                    alignment: const Alignment(0.0, 0.1),
                    errorBuilder: (_, _, _) => const ColoredBox(
                      color: Color(0xFF171717),
                    ),
                  ),
                  // Surgical Teal Eye Bounding Reticle #1
                  Positioned(
                    left: 56,
                    top: 32,
                    width: 56,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: SariwaColors.brandPrimary,
                          width: 2.2,
                        ),
                        color: SariwaColors.brandPrimary.withValues(alpha: 0.14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: _neutralPill,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _miniRegionPill('Auto', isActive: true),
                    _miniRegionPill('Eye', isActive: false),
                    _miniRegionPill('Gill', isActive: false),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: _inkPrimary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Center(
                    child: Text(
                      'Check freshness',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniRegionPill(String label, {required bool isActive}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          color: isActive ? _inkPrimary : _inkMuted,
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
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
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 44,
                    height: 44,
                    color: _neutralPill,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.checkmark_seal_fill,
                          size: 15,
                          color: SariwaColors.brandPrimary,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Fresh',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: _inkPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Confidence · 94.7%',
                      style: TextStyle(
                        fontFamily: 'Geist Mono',
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
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const LinearProgressIndicator(
              value: 0.947,
              minHeight: 6,
              backgroundColor: Color(0xFFE5E5E7),
              valueColor: AlwaysStoppedAnimation<Color>(
                SariwaColors.brandPrimary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Visual freshness estimate — not a food-safety guarantee.',
            style: TextStyle(fontSize: 11, height: 1.4, color: _inkMuted),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: _inkPrimary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Center(
                    child: Text(
                      'Scan Another',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: _border),
                ),
                child: const Center(
                  child: Text(
                    'Adjust crop',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _inkPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'View scan history →',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _inkPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
