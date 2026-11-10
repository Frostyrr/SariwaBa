import 'package:flutter/material.dart';

import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';

/// Static Dashboard Showcase Widget
/// Displays a high-fidelity static presentation of the actual existing SariwaBa? dashboard
/// inside an elegant, subtle browser / macOS window frame with realistic depth shadows.
///
/// Supports an optional static screenshot asset (`assets/images/dashboard_screenshot.png`),
/// with a pixel-faithful static presentation of the real SariwaBa? workstation as fallback.
class DashboardShowcase extends StatelessWidget {
  final double? width;
  final double? height;
  final String screenshotAsset;

  const DashboardShowcase({
    super.key,
    this.width,
    this.height,
    this.screenshotAsset = 'assets/images/dashboard_screenshot.png',
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.0,
          ),
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
          borderRadius: BorderRadius.circular(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Clean Browser / macOS Window Chrome Header
              _buildBrowserHeader(isMobile),

              // Dashboard Workspace Body (Height constrained)
              SizedBox(
                height: targetHeight - 40.0,
                width: double.infinity,
                child: Image.asset(
                  screenshotAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildStaticDashboard(isMobile);
                  },
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE2E8F0),
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
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
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

  /// Main Dashboard Workspace (KPIs + Split Workstation)
  Widget _buildMainWorkspace() {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 4 Top KPI Cards
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  title: 'Total Inspections',
                  value: '12',
                  trend: 'Available',
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildKpiCard(
                  title: 'Sariwa (Fresh)',
                  value: '11',
                  trend: '91.7%',
                  color: const Color(0xFF15803D),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildKpiCard(
                  title: 'Not Fresh',
                  value: '1',
                  trend: '8.3%',
                  color: const Color(0xFFB91C1C),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildKpiCard(
                  title: 'Avg. AI Confidence',
                  value: '94.7%',
                  trend: 'Score',
                  color: SariwaColors.brandPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Two-Column Workstation (Inspection Card + Audit Log Table)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Workstation: Live Specimen Inspection Card (54%)
                Expanded(
                  flex: 54,
                  child: _buildInspectionCard(),
                ),

                const SizedBox(width: 10),

                // Right Workstation: Audit History Log Table (46%)
                Expanded(
                  flex: 46,
                  child: _buildAuditLogCard(),
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

          // Modest Tilapia Image Preview
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/sample_tilapia.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (_, _, _) => Container(
                      color: const Color(0xFFE2E8F0),
                      child: const Center(
                        child: Icon(Icons.image_outlined, color: Color(0xFF94A3B8)),
                      ),
                    ),
                  ),
                  // Reticle overlay indicating Eye region
                  Positioned(
                    left: 18,
                    top: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF2DD4BF), width: 1.2),
                      ),
                      child: const Text(
                        'Target ROI: Eye',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                        ),
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

  /// Clean, tailored responsive mobile dashboard presentation
  Widget _buildMobileDashboard() {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          // 4 KPIs in 2x2 grid
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  title: 'Total Scans',
                  value: '12',
                  trend: 'Active',
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildKpiCard(
                  title: 'Sariwa',
                  value: '11',
                  trend: '91.7%',
                  color: const Color(0xFF15803D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  title: 'Not Fresh',
                  value: '1',
                  trend: '8.3%',
                  color: const Color(0xFFB91C1C),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildKpiCard(
                  title: 'Confidence',
                  value: '94.7%',
                  trend: 'Score',
                  color: SariwaColors.brandPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _buildInspectionCard(),
          ),
        ],
      ),
    );
  }
}
