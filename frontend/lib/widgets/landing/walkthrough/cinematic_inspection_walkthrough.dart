import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../constants/theme/app_colors.dart';
import '../../../constants/theme/app_typography.dart';
import 'scanning_reticle_painter.dart';
import 'simulated_cursor.dart';

/// Cinematic Inspection Walkthrough
/// A high-fidelity programmatic simulation reproducing the actual SariwaBa?
/// dashboard shell — including the sidebar, live inspection workflow, audit history,
/// and analytics views — with an animated cursor navigating realistically.
class CinematicInspectionWalkthrough extends StatefulWidget {
  final double? width;
  final double? height;

  const CinematicInspectionWalkthrough({
    super.key,
    this.width,
    this.height,
  });

  @override
  State<CinematicInspectionWalkthrough> createState() =>
      _CinematicInspectionWalkthroughState();
}

class _CinematicInspectionWalkthroughState
    extends State<CinematicInspectionWalkthrough>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isPlaying = true;
  bool _isHoveringDemo = false;

  // Total timeline: 22.0 seconds
  // Phase 1 (0.00 - 0.44): Inspection Workflow (Upload -> Preview -> Region -> AI Scan -> Result)
  // Phase 2 (0.44 - 0.66): Click History -> Audit Log Table & Filters
  // Phase 3 (0.66 - 0.88): Click Analytics -> Freshness Insights & Quality Distribution
  // Phase 4 (0.88 - 1.00): Click Inspection -> Return & Loop

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 22000),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.repeat();
        }
      });

    // In widget tests, avoid infinite animation loop to allow pumpAndSettle
    final bindingName = WidgetsBinding.instance.runtimeType.toString();
    final isTest = bindingName.contains('Test');
    if (isTest) {
      _controller.value = 0.40; // Settle at inspection result for tests
      _isPlaying = false;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.stop();
        _isPlaying = false;
      } else {
        _controller.repeat();
        _isPlaying = true;
      }
    });
  }

  void _restart() {
    setState(() {
      _controller.reset();
      _controller.forward();
      _isPlaying = true;
    });
  }

  // --- Active Tab Calculation ---
  // 0: Inspection, 1: History, 2: Analytics
  int _getActiveTab(double t) {
    if (t < 0.54) return 0; // Inspection
    if (t < 0.76) return 1; // History
    if (t < 0.96) return 2; // Analytics
    return 0; // Return to Inspection
  }

  // --- Normalized Cursor Coordinates ---
  // Coordinates are normalized (0.0 to 1.0) relative to the demonstration body
  Offset _getCursorPosition(double t, bool isMobile) {
    if (isMobile) {
      return _getMobileCursorPosition(t);
    }
    return _getDesktopCursorPosition(t);
  }

  Offset _getDesktopCursorPosition(double t) {
    // Desktop layout: Sidebar on left (x: 0.0 to 0.24), Main workspace (x: 0.24 to 1.0)
    // Sidebar nav items:
    // Inspection: (0.11, 0.20)
    // History:    (0.11, 0.27)
    // Analytics:  (0.11, 0.34)

    if (t < 0.08) {
      // Entry -> Choose Image button
      final subT = Curves.easeInOutCubic.transform((t / 0.08).clamp(0.0, 1.0));
      return Offset.lerp(const Offset(0.85, 0.25), const Offset(0.60, 0.65), subT)!;
    } else if (t < 0.12) {
      // Pauses on Choose Image button
      return const Offset(0.60, 0.65);
    } else if (t < 0.18) {
      // Glides to Region Eye tab
      final subT = Curves.easeInOutCubic.transform(((t - 0.12) / 0.06).clamp(0.0, 1.0));
      return Offset.lerp(const Offset(0.60, 0.65), const Offset(0.42, 0.30), subT)!;
    } else if (t < 0.21) {
      // Pauses on Eye tab
      return const Offset(0.42, 0.30);
    } else if (t < 0.26) {
      // Glides to Validate & Classify button
      final subT = Curves.easeInOutCubic.transform(((t - 0.21) / 0.05).clamp(0.0, 1.0));
      return Offset.lerp(const Offset(0.42, 0.30), const Offset(0.60, 0.88), subT)!;
    } else if (t < 0.30) {
      // Pauses on Validate button
      return const Offset(0.60, 0.88);
    } else if (t < 0.44) {
      // Slides aside during AI scanning & result review
      final subT = Curves.easeOutCubic.transform(((t - 0.30) / 0.14).clamp(0.0, 1.0));
      return Offset.lerp(const Offset(0.60, 0.88), const Offset(0.86, 0.45), subT)!;
    } else if (t < 0.52) {
      // Glides to Sidebar -> History nav button
      final subT = Curves.easeInOutCubic.transform(((t - 0.44) / 0.08).clamp(0.0, 1.0));
      return Offset.lerp(const Offset(0.86, 0.45), const Offset(0.11, 0.27), subT)!;
    } else if (t < 0.56) {
      // Pauses on History nav button
      return const Offset(0.11, 0.27);
    } else if (t < 0.66) {
      // Glides into History table to inspect top record
      final subT = Curves.easeInOutCubic.transform(((t - 0.56) / 0.10).clamp(0.0, 1.0));
      return Offset.lerp(const Offset(0.11, 0.27), const Offset(0.58, 0.46), subT)!;
    } else if (t < 0.74) {
      // Glides to Sidebar -> Analytics nav button
      final subT = Curves.easeInOutCubic.transform(((t - 0.66) / 0.08).clamp(0.0, 1.0));
      return Offset.lerp(const Offset(0.58, 0.46), const Offset(0.11, 0.34), subT)!;
    } else if (t < 0.78) {
      // Pauses on Analytics nav button
      return const Offset(0.11, 0.34);
    } else if (t < 0.88) {
      // Glides into Analytics distribution bar
      final subT = Curves.easeInOutCubic.transform(((t - 0.78) / 0.10).clamp(0.0, 1.0));
      return Offset.lerp(const Offset(0.11, 0.34), const Offset(0.60, 0.62), subT)!;
    } else if (t < 0.94) {
      // Glides back to Sidebar -> Inspection button
      final subT = Curves.easeInOutCubic.transform(((t - 0.88) / 0.06).clamp(0.0, 1.0));
      return Offset.lerp(const Offset(0.60, 0.62), const Offset(0.11, 0.20), subT)!;
    } else if (t < 0.98) {
      // Pauses on Inspection button
      return const Offset(0.11, 0.20);
    } else {
      return const Offset(0.11, 0.20);
    }
  }

  Offset _getMobileCursorPosition(double t) {
    // Mobile layout: Tabs at top (y: ~0.10)
    // Inspection: (0.20, 0.10)
    // History:    (0.50, 0.10)
    // Analytics:  (0.80, 0.10)
    if (t < 0.12) {
      return const Offset(0.50, 0.65);
    } else if (t < 0.26) {
      return const Offset(0.50, 0.86);
    } else if (t < 0.44) {
      return const Offset(0.85, 0.40);
    } else if (t < 0.54) {
      return const Offset(0.50, 0.10); // History tab
    } else if (t < 0.66) {
      return const Offset(0.50, 0.50); // Inside history
    } else if (t < 0.76) {
      return const Offset(0.80, 0.10); // Analytics tab
    } else if (t < 0.88) {
      return const Offset(0.50, 0.60); // Inside analytics
    } else {
      return const Offset(0.20, 0.10); // Inspection tab
    }
  }

  // --- Click Calculations ---
  double _getClickProgress(double t) {
    // Click 1: Choose Image at t = 0.10
    if (t >= 0.09 && t < 0.12) return ((t - 0.09) / 0.03).clamp(0.0, 1.0);
    // Click 2: Region Eye at t = 0.19
    if (t >= 0.18 && t < 0.21) return ((t - 0.18) / 0.03).clamp(0.0, 1.0);
    // Click 3: Validate at t = 0.24
    if (t >= 0.23 && t < 0.26) return ((t - 0.23) / 0.03).clamp(0.0, 1.0);
    // Click 4: History Sidebar at t = 0.54
    if (t >= 0.53 && t < 0.56) return ((t - 0.53) / 0.03).clamp(0.0, 1.0);
    // Click 5: Analytics Sidebar at t = 0.76
    if (t >= 0.75 && t < 0.78) return ((t - 0.75) / 0.03).clamp(0.0, 1.0);
    // Click 6: Inspection Sidebar at t = 0.96
    if (t >= 0.95 && t < 0.98) return ((t - 0.95) / 0.03).clamp(0.0, 1.0);
    return 0.0;
  }

  bool _isClicking(double t) {
    final cp = _getClickProgress(t);
    return cp > 0.0 && cp < 0.75;
  }

  int _getActiveStepIndex(double t) {
    if (t < 0.36) return 0; // 1. Live Inspection
    if (t < 0.44) return 1; // 2. Freshness Result
    if (t < 0.66) return 2; // 3. Audit History
    return 3; // 4. Quality Analytics
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 720;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHoveringDemo = true),
      onExit: (_) => setState(() => _isHoveringDemo = false),
      child: Center(
        child: Container(
          width: widget.width ?? 860,
          constraints: const BoxConstraints(maxWidth: 860),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHoveringDemo
                  ? SariwaColors.brandPrimary.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.85),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x280A2229),
                blurRadius: 40,
                offset: Offset(0, 20),
                spreadRadius: -4,
              ),
              BoxShadow(
                color: Color(0x1F14B8A6),
                blurRadius: 60,
                offset: Offset(0, 30),
                spreadRadius: -8,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(19),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final t = _controller.value;
                final activeTab = _getActiveTab(t);
                final activeStep = _getActiveStepIndex(t);
                final cursorNormalized = _getCursorPosition(t, isMobile);
                final clickProgress = _getClickProgress(t);
                final isClicking = _isClicking(t);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // macOS Chrome Window Header
                    _buildWindowHeader(isMobile, activeTab),

                    // Complete SariwaBa Shell (Sidebar + Workspace + Cursor)
                    _buildShellContainer(
                      context,
                      t,
                      activeTab,
                      isMobile,
                      cursorNormalized,
                      clickProgress,
                      isClicking,
                    ),

                    // Demonstration Footer & Controls
                    _buildDemoFooter(activeStep),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// macOS Window Header with traffic lights & active tab title
  Widget _buildWindowHeader(bool isMobile, int activeTab) {
    final tabTitles = ['Live Inspection Workspace', 'Seafood Audit History', 'Freshness Analytics & Trends'];

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
          // macOS traffic dots
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 11, height: 11, decoration: const BoxDecoration(color: Color(0xFFFF5F56), shape: BoxShape.circle)),
              const SizedBox(width: 7),
              Container(width: 11, height: 11, decoration: const BoxDecoration(color: Color(0xFFFFBD2E), shape: BoxShape.circle)),
              const SizedBox(width: 7),
              Container(width: 11, height: 11, decoration: const BoxDecoration(color: Color(0xFF27C93F), shape: BoxShape.circle)),
            ],
          ),

          const SizedBox(width: 16),

          // Window Title / Workspace Label
          Expanded(
            child: Center(
              child: Text(
                'SariwaBa? Dashboard • ${tabTitles[activeTab]}',
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.25,
                  color: Color(0xFF475569),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Live Simulation Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F4EA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCEEAD6), width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF1E8E3E), shape: BoxShape.circle)),
                const SizedBox(width: 5),
                const Text(
                  'Simulation',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.25,
                    color: Color(0xFF137333),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Complete Dashboard Shell (Sidebar + Main Workspace + Cursor Layer)
  Widget _buildShellContainer(
    BuildContext context,
    double t,
    int activeTab,
    bool isMobile,
    Offset cursorNormalized,
    double clickProgress,
    bool isClicking,
  ) {
    final shellHeight = isMobile ? 390.0 : 460.0;

    return SizedBox(
      height: shellHeight,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final shellWidth = constraints.maxWidth;
          final cursorX = cursorNormalized.dx * shellWidth;
          final cursorY = cursorNormalized.dy * shellHeight;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Shell Interior
              Positioned.fill(
                child: Container(
                  color: const Color(0xFFF3F6F9), // Actual dashboard background
                  child: isMobile
                      ? _buildMobileShell(t, activeTab)
                      : _buildDesktopShell(t, activeTab),
                ),
              ),

              // Animated Simulated Cursor Layer
              Positioned(
                left: cursorX,
                top: cursorY,
                child: IgnorePointer(
                  child: SimulatedCursor(
                    isClicking: isClicking,
                    clickProgress: clickProgress,
                    isTouchMode: isMobile,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Desktop Shell: Left Sidebar (190px) + Right Workspace
  Widget _buildDesktopShell(double t, int activeTab) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Sidebar reproducing dashboard sidebar faithfully
        SizedBox(
          width: 190,
          child: _buildFaithfulSidebar(t, activeTab),
        ),

        // Right Workspace Tab Views
        Expanded(
          child: _buildWorkspaceTabContent(t, activeTab, isMobile: false),
        ),
      ],
    );
  }

  /// Mobile Shell: Compact Top Tab Bar + Workspace
  Widget _buildMobileShell(double t, int activeTab) {
    return Column(
      children: [
        // Mobile Tab Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            children: [
              Image.asset('assets/images/SariwaBa logo.png', width: 22, height: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      _buildMobilePill('Inspection', activeTab == 0),
                      _buildMobilePill('History', activeTab == 1),
                      _buildMobilePill('Analytics', activeTab == 2),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: _buildWorkspaceTabContent(t, activeTab, isMobile: true),
        ),
      ],
    );
  }

  Widget _buildMobilePill(String label, bool isActive) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isActive
              ? const [BoxShadow(color: Color(0x0F000000), blurRadius: 4, offset: Offset(0, 1))]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: -0.25,
            color: isActive ? SariwaColors.brandPrimary : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  /// Faithful Sidebar Component mirroring dashboard_page.dart
  Widget _buildFaithfulSidebar(double t, int activeTab) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xD9FFFFFF),
        border: Border(
          right: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Name
          Row(
            children: [
              Image.asset(
                'assets/images/SariwaBa logo.png',
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'SariwaBa',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.25,
                    color: SariwaColors.textPrimaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Text(
              'WORKSPACE',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Nav Items
          _buildSidebarNavItem(
            icon: CupertinoIcons.viewfinder,
            label: 'Inspection',
            isActive: activeTab == 0,
          ),
          const SizedBox(height: 3),
          _buildSidebarNavItem(
            icon: CupertinoIcons.clock,
            label: 'History',
            badgeCount: 12,
            isActive: activeTab == 1,
          ),
          const SizedBox(height: 3),
          _buildSidebarNavItem(
            icon: CupertinoIcons.chart_bar_square,
            label: 'Analytics',
            isActive: activeTab == 2,
          ),

          const Spacer(),

          // User Profile Card at bottom of sidebar
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: SariwaColors.brandPrimary.withValues(alpha: 0.15),
                  child: const Text(
                    'M',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: SariwaColors.brandPrimary,
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
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.25,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Verified Account',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 9.5,
                          letterSpacing: -0.25,
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w500,
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

  Widget _buildSidebarNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    int? badgeCount,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isActive
            ? SariwaColors.brandPrimary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
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
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: -0.25,
                color: isActive ? SariwaColors.brandPrimary : const Color(0xFF334155),
              ),
            ),
          ),
          if (badgeCount != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: isActive ? SariwaColors.brandPrimary : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$badgeCount',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
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

  /// Dynamic Workspace Tab Views
  Widget _buildWorkspaceTabContent(double t, int activeTab, {required bool isMobile}) {
    if (activeTab == 1) {
      return _buildHistoryView(isMobile);
    }
    if (activeTab == 2) {
      return _buildAnalyticsView(isMobile);
    }
    return _buildInspectionView(t, isMobile);
  }

  // ==========================================
  // TAB 1: INSPECTION VIEW
  // ==========================================
  Widget _buildInspectionView(double t, bool isMobile) {
    if (t < 0.12) {
      // Empty dropzone view
      final isHovered = t >= 0.07 && t < 0.12;
      final isPressed = t >= 0.09 && t < 0.12;

      return Container(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            _buildWorkspaceHeader('Quality Workstation', 'AI Ocular & Gill Freshness Grading', isMobile: isMobile),
            const SizedBox(height: 12),
            // Dropzone
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isHovered ? const Color(0xFFF0FDF4) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isHovered ? SariwaColors.brandPrimary : const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isHovered ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.cloud_upload_outlined,
                          size: 24,
                          color: isHovered ? SariwaColors.brandPrimaryDark : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Drop your Tilapia image here',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.25,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Supports JPEG & PNG • Max 5 MB',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          letterSpacing: -0.25,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Transform.scale(
                        scale: isPressed ? 0.94 : 1.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isHovered ? SariwaColors.brandPrimaryDark : SariwaColors.brandPrimary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.photo_library_outlined, size: 14, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                'Choose Image',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.25,
                                  color: Colors.white,
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
            ),
          ],
        ),
      );
    }

    // Specimen loaded view
    final isEyeSelected = t >= 0.18;
    final isScanning = t >= 0.24 && t < 0.36;
    final isValidatePressed = t >= 0.23 && t < 0.25;
    final isResultRevealed = t >= 0.36;

    double scanProgress = 0.0;
    if (isScanning) {
      final scanT = (t - 0.24) / 0.12;
      scanProgress = (math.sin(scanT * math.pi * 3 - math.pi / 2) + 1.0) / 2.0;
    }

    return Container(
      color: const Color(0xFF0F172A),
      child: Stack(
        children: [
          // Tilapia specimen image
          Positioned.fill(
            child: Image.asset(
              'assets/images/sample_tilapia.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.centerLeft,
            ),
          ),

          // Vignette
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.2, 0.0),
                  radius: 0.95,
                  colors: [Colors.black.withValues(alpha: 0.15), Colors.black.withValues(alpha: 0.65)],
                ),
              ),
            ),
          ),

          // Top Toolbar: Region Selector & Specimen Badge
          Positioned(
            top: 10,
            left: 12,
            right: 12,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isEyeSelected ? SariwaColors.brandPrimary : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.visibility_outlined, size: 12, color: isEyeSelected ? Colors.white : Colors.white70),
                            const SizedBox(width: 4),
                            Text(
                              isMobile ? 'Eye' : 'Eye (Mata)',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 11,
                                fontWeight: isEyeSelected ? FontWeight.w600 : FontWeight.w400,
                                letterSpacing: -0.25,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          isMobile ? 'Gill' : 'Gill (Hasang)',
                          style: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11,
                            letterSpacing: -0.25,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isMobile) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline, size: 12, color: Color(0xFF34D399)),
                        SizedBox(width: 4),
                        Text(
                          'Tilapia Specimen',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 10.5,
                            letterSpacing: -0.25,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Central ROI Framing Reticle & Laser Scanning Beam
          Positioned(
            left: isMobile ? 36 : 90,
            top: isMobile ? 48 : 64,
            width: isMobile ? 160 : 210,
            height: isMobile ? 160 : 190,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: ScanningReticlePainter(
                      scanProgress: scanProgress,
                      isScanning: isScanning,
                      primaryColor: const Color(0xFF14B8A6),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14B8A6).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'ROI: OCULAR CORNEA',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action Button
          if (!isResultRevealed)
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Center(
                child: Transform.scale(
                  scale: isValidatePressed ? 0.95 : 1.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isScanning ? const Color(0xFF0F766E) : SariwaColors.brandPrimary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF14B8A6).withValues(alpha: isScanning ? 0.4 : 0.25),
                          blurRadius: isScanning ? 16 : 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isScanning) ...[
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 1.8, valueColor: AlwaysStoppedAnimation(Colors.white)),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Analyzing Corneal Clarity...',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.25,
                              color: Colors.white,
                            ),
                          ),
                        ] else ...[
                          const Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                          const SizedBox(width: 6),
                          const Text(
                            'Validate & Classify Freshness',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.25,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Classification Result Card (Fresh)
          if (isResultRevealed)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFBBF7D0), width: 1.2),
                  boxShadow: const [
                    BoxShadow(color: Color(0x1F0A2229), blurRadius: 16, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(color: Color(0xFFF0FDF4), shape: BoxShape.circle),
                          child: const Icon(Icons.check_circle_rounded, color: Color(0xFF168077), size: 18),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Fresh ',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.25,
                                    color: Color(0xFF15803D),
                                  ),
                                ),
                                TextSpan(
                                  text: '•  Tilapia Eye',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -0.25,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                          ),
                          child: const Text(
                            'Demo',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.25,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Model Confidence',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.25,
                            color: Color(0xFF475569),
                          ),
                        ),
                        Text(
                          '94.7%',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.25,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: const LinearProgressIndicator(
                        value: 0.947,
                        minHeight: 5,
                        backgroundColor: Color(0xFFDCFCE7),
                        valueColor: AlwaysStoppedAnimation(Color(0xFF168077)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 11, color: Color(0xFF94A3B8)),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Visual AI assessment only. Not a food safety guarantee.',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 9.5,
                              letterSpacing: -0.25,
                              color: Color(0xFF94A3B8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: AUDIT HISTORY VIEW
  // ==========================================
  Widget _buildHistoryView(bool isMobile) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWorkspaceHeader('Seafood Audit History', 'Traceability Log & Verification Records', isMobile: isMobile),
          const SizedBox(height: 12),

          // Filters Row
          Row(
            children: [
              _buildFilterBadge('All (12)', true),
              const SizedBox(width: 6),
              _buildFilterBadge('Fresh (11)', false),
              const SizedBox(width: 6),
              _buildFilterBadge('Not Fresh (1)', false),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.search, size: 12, color: Color(0xFF64748B)),
                    SizedBox(width: 4),
                    Text(
                      'Filter...',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 10.5,
                        letterSpacing: -0.25,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('SPECIMEN ID', style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8), letterSpacing: 0.4))),
                Expanded(flex: 2, child: Text('REGION', style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8), letterSpacing: 0.4))),
                Expanded(flex: 2, child: Text('CONFIDENCE', style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8), letterSpacing: 0.4))),
                Expanded(flex: 2, child: Text('RESULT', style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8), letterSpacing: 0.4))),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Rows
          Expanded(
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildHistoryRow('#SB-2026-1108', 'Tilapia Eye', '94.7%', true, isHighlighted: true),
                _buildHistoryRow('#SB-2026-1107', 'Tilapia Gill', '91.2%', false),
                _buildHistoryRow('#SB-2026-1106', 'Tilapia Eye', '96.0%', true),
                _buildHistoryRow('#SB-2026-1105', 'Tilapia Eye', '93.5%', true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBadge(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? SariwaColors.brandPrimary.withValues(alpha: 0.12) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? SariwaColors.brandPrimary.withValues(alpha: 0.4) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 10.5,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: -0.25,
          color: isActive ? SariwaColors.brandPrimary : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildHistoryRow(String scanId, String region, String conf, bool isFresh, {bool isHighlighted = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isHighlighted ? const Color(0xFFBBF7D0) : const Color(0xFFF1F5F9),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              scanId,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11,
                fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: -0.25,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              region,
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11,
                letterSpacing: -0.25,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              conf,
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.25,
                color: Color(0xFF334155),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isFresh ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isFresh ? 'Fresh' : 'Not Fresh',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.25,
                  color: isFresh ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: ANALYTICS VIEW
  // ==========================================
  Widget _buildAnalyticsView(bool isMobile) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWorkspaceHeader('Freshness Insights', 'Quality Aggregation & Model Performance', isMobile: isMobile),
          const SizedBox(height: 12),

          // 3 KPI Cards
          Row(
            children: [
              _buildKpiCard('TOTAL SCANS', '12', '+4 this week', const Color(0xFF0F172A)),
              const SizedBox(width: 8),
              _buildKpiCard('FRESH RATE', '91.7%', '11 verified', const Color(0xFF15803D)),
              const SizedBox(width: 8),
              _buildKpiCard('AVG CONF', '94.2%', 'High precision', SariwaColors.brandPrimary),
            ],
          ),

          const SizedBox(height: 16),

          // Fresh vs Not Fresh Distribution Ratio Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quality Distribution Ratio',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.25,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '11 Fresh  •  1 Not Fresh',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 10.5,
                        letterSpacing: -0.25,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Split Ratio Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 92,
                        child: Container(height: 8, color: const Color(0xFF168077)),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        flex: 8,
                        child: Container(height: 8, color: const Color(0xFFDC2626)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF168077), shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    const Text('Fresh (91.7%)', style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 10, letterSpacing: -0.25, color: Color(0xFF475569))),
                    const SizedBox(width: 14),
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFDC2626), shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    const Text('Not Fresh (8.3%)', style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 10, letterSpacing: -0.25, color: Color(0xFF475569))),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Regional Breakdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(CupertinoIcons.viewfinder, size: 14, color: SariwaColors.brandPrimary),
                    SizedBox(width: 6),
                    Text('Cornea (Eye): 9 scans', style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 11, letterSpacing: -0.25, color: Color(0xFF334155))),
                  ],
                ),
                Row(
                  children: [
                    Icon(CupertinoIcons.circle_grid_hex, size: 14, color: Color(0xFF0284C7)),
                    SizedBox(width: 6),
                    Text('Gill Arch: 3 scans', style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 11, letterSpacing: -0.25, color: Color(0xFF334155))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, String sub, Color valColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 8.5, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: Color(0xFF94A3B8))),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.25, color: valColor)),
            const SizedBox(height: 2),
            Text(sub, style: const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 9.5, letterSpacing: -0.25, color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkspaceHeader(String title, String subtitle, {bool isMobile = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.25,
                  color: Color(0xFF0F172A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 10.5,
                  letterSpacing: -0.25,
                  color: Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (!isMobile)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Tilapia • Model A',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.25,
                color: Color(0xFF475569),
              ),
            ),
          ),
      ],
    );
  }

  /// Footer with Step Pills and Playback Controls
  Widget _buildDemoFooter(int activeStep) {
    const steps = [
      '1. Live Inspection',
      '2. Freshness Result',
      '3. Audit History',
      '4. Analytics & Trends',
    ];

    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(
          top: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          // Step Pills
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(steps.length, (index) {
                  final isActive = activeStep == index;
                  final isCompleted = activeStep > index;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFFDCFCE7)
                            : isCompleted
                                ? const Color(0xFFF1F5F9)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isActive ? const Color(0xFFBBF7D0) : Colors.transparent,
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        steps[index],
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 11,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          letterSpacing: -0.25,
                          color: isActive
                              ? const Color(0xFF15803D)
                              : isCompleted
                                  ? const Color(0xFF475569)
                                  : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Play/Pause & Replay Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                iconSize: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                tooltip: _isPlaying ? 'Pause Demo' : 'Play Demo',
                onPressed: _togglePlayPause,
                icon: Icon(
                  _isPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline,
                  color: const Color(0xFF64748B),
                ),
              ),
              IconButton(
                iconSize: 17,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                tooltip: 'Replay Demo',
                onPressed: _restart,
                icon: const Icon(
                  Icons.replay_rounded,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
