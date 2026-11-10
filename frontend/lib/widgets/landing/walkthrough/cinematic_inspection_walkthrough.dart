import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../constants/theme/app_colors.dart';
import '../../../constants/theme/app_typography.dart';
import 'scanning_reticle_painter.dart';
import 'simulated_cursor.dart';

/// Cinematic Inspection Walkthrough
/// A high-fidelity programmatic simulation reproducing the actual SariwaBa?
/// dashboard shell — including the persistent sidebar, top KPIs, live inspection workspace,
/// audit history, and analytics views — with an animated cursor navigating realistically.
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

  // Total timeline: 22.0 seconds
  // Phase 1 (0.00 - 0.50): Live Inspection & Dashboard Overview
  //   - 0.00 - 0.12: Dropzone & click "Choose Image"
  //   - 0.12 - 0.21: Modest preview loaded, click "Eye" region
  //   - 0.21 - 0.29: Click "Validate & Classify Freshness"
  //   - 0.29 - 0.38: Laser scan sweep across the modest preview
  //   - 0.38 - 0.50: Fresh 94.7% result card revealed & inspected
  // Phase 2 (0.50 - 0.72): Cursor clicks "History" in sidebar -> full Seafood Audit History view
  // Phase 3 (0.72 - 0.92): Cursor clicks "Analytics" in sidebar -> full Freshness Analytics view
  // Phase 4 (0.92 - 1.00): Cursor clicks "Inspection" in sidebar -> returns & loops

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
  // 0: Inspection / Dashboard, 1: History, 2: Analytics
  int _getActiveTab(double t) {
    if (t < 0.56) return 0; // Inspection Overview
    if (t < 0.76) return 1; // Audit History
    if (t < 0.96) return 2; // Freshness Analytics
    return 0; // Return to Inspection
  }

  // --- Normalized Cursor Coordinates ---
  // Normalized (0.0 to 1.0) relative to the demonstration body
  Offset _getCursorPosition(double t, bool isMobile) {
    if (isMobile) {
      return _getMobileCursorPosition(t);
    }
    return _getDesktopCursorPosition(t);
  }

  Offset _getDesktopCursorPosition(double t) {
    // Desktop layout:
    // Sidebar on left (x: 0.0 to 0.19, y: 0.0 to 1.0)
    // Sidebar items: Inspection (0.09, 0.14), History (0.09, 0.20), Analytics (0.09, 0.26)
    // Workspace on right (x: 0.19 to 1.0):
    // Left inspection card: (x: ~0.20 to ~0.66)
    //   Choose Image button: (0.38, 0.62)
    //   Region Eye pill: (0.28, 0.43)
    //   Validate button: (0.38, 0.82)
    //   Result hover: (0.42, 0.78)
    // History table:
    //   Top row: (0.55, 0.42)
    // Analytics view:
    //   Distribution ratio bar: (0.55, 0.52)

    if (t < 0.09) {
      // Entry -> Choose Image button
      final subT = Curves.easeInOutCubic.transform((t / 0.09).clamp(0.0, 1.0));
      return Offset.lerp(const Offset(0.75, 0.25), const Offset(0.38, 0.62), subT)!;
    } else if (t < 0.12) {
      // Pauses on Choose Image button
      return const Offset(0.38, 0.62);
    } else if (t < 0.18) {
      // Glides to Region Eye pill
      final subT = Curves.easeInOutCubic.transform(((t - 0.12) / 0.06).clamp(0.0, 1.0));
      return Offset.lerp(const Offset(0.38, 0.62), const Offset(0.28, 0.43), subT)!;
    } else if (t < 0.21) {
      // Pauses on Eye pill
      return const Offset(0.28, 0.43);
    } else if (t < 0.26) {
      // Glides to Validate button
      final subT = Curves.easeInOutCubic.transform(((t - 0.21) / 0.05).clamp(0.0, 1.0));
      return Offset.lerp(const Offset(0.28, 0.43), const Offset(0.38, 0.82), subT)!;
    } else if (t < 0.29) {
      // Pauses on Validate button
      return const Offset(0.38, 0.82);
    } else if (t < 0.38) {
      // Drifts aside during laser scan sweep
      final subT = Curves.easeOutCubic.transform(((t - 0.29) / 0.09).clamp(0.0, 1.0));
      return Offset.lerp(const Offset(0.38, 0.82), const Offset(0.58, 0.65), subT)!;
    } else if (t < 0.50) {
      // Hovers on Fresh Result Card
      final subT = Curves.easeInOutCubic.transform(((t - 0.38) / 0.12).clamp(0.0, 1.0));
      return Offset.lerp(const Offset(0.58, 0.65), const Offset(0.42, 0.78), subT)!;
    } else if (t < 0.56) {
      // Glides to Sidebar -> History nav button
      final subT = Curves.easeInOutCubic.transform(((t - 0.50) / 0.06).clamp(0.0, 1.0));
      return Offset.lerp(const Offset(0.42, 0.78), const Offset(0.09, 0.20), subT)!;
    } else if (t < 0.59) {
      // Pauses on History nav button
      return const Offset(0.09, 0.20);
    } else if (t < 0.70) {
      // Glides into History table to inspect top record
      final subT = Curves.easeInOutCubic.transform(((t - 0.59) / 0.11).clamp(0.0, 1.0));
      return Offset.lerp(const Offset(0.09, 0.20), const Offset(0.55, 0.42), subT)!;
    } else if (t < 0.76) {
      // Glides to Sidebar -> Analytics nav button
      final subT = Curves.easeInOutCubic.transform(((t - 0.70) / 0.06).clamp(0.0, 1.0));
      return Offset.lerp(const Offset(0.55, 0.42), const Offset(0.09, 0.26), subT)!;
    } else if (t < 0.79) {
      // Pauses on Analytics nav button
      return const Offset(0.09, 0.26);
    } else if (t < 0.90) {
      // Glides into Analytics distribution bar
      final subT = Curves.easeInOutCubic.transform(((t - 0.79) / 0.11).clamp(0.0, 1.0));
      return Offset.lerp(const Offset(0.09, 0.26), const Offset(0.55, 0.52), subT)!;
    } else if (t < 0.96) {
      // Glides back to Sidebar -> Inspection button
      final subT = Curves.easeInOutCubic.transform(((t - 0.90) / 0.06).clamp(0.0, 1.0));
      return Offset.lerp(const Offset(0.55, 0.52), const Offset(0.09, 0.14), subT)!;
    } else if (t < 0.99) {
      // Pauses on Inspection button
      return const Offset(0.09, 0.14);
    } else {
      return const Offset(0.09, 0.14);
    }
  }

  Offset _getMobileCursorPosition(double t) {
    if (t < 0.12) {
      return const Offset(0.50, 0.62);
    } else if (t < 0.29) {
      return const Offset(0.50, 0.82);
    } else if (t < 0.50) {
      return const Offset(0.50, 0.78);
    } else if (t < 0.56) {
      return const Offset(0.50, 0.08); // History tab
    } else if (t < 0.72) {
      return const Offset(0.50, 0.48); // History list
    } else if (t < 0.78) {
      return const Offset(0.82, 0.08); // Analytics tab
    } else if (t < 0.92) {
      return const Offset(0.50, 0.52); // Analytics ratio
    } else {
      return const Offset(0.18, 0.08); // Inspection tab
    }
  }

  // --- Click Progress ---
  double _getClickProgress(double t) {
    // Click 1: Choose Image at t = 0.10
    if (t >= 0.09 && t < 0.12) return ((t - 0.09) / 0.03).clamp(0.0, 1.0);
    // Click 2: Region Eye at t = 0.19
    if (t >= 0.18 && t < 0.21) return ((t - 0.18) / 0.03).clamp(0.0, 1.0);
    // Click 3: Validate at t = 0.26
    if (t >= 0.25 && t < 0.28) return ((t - 0.25) / 0.03).clamp(0.0, 1.0);
    // Click 4: History Sidebar at t = 0.56
    if (t >= 0.55 && t < 0.58) return ((t - 0.55) / 0.03).clamp(0.0, 1.0);
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 760;
    final targetWidth = widget.width ?? (isMobile ? screenWidth - 32 : 1040.0);
    final targetHeight = widget.height ?? (isMobile ? 440.0 : 540.0);

    return Center(
      child: Container(
          width: targetWidth,
          constraints: const BoxConstraints(maxWidth: 1060),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F0A2229),
                blurRadius: 28,
                offset: Offset(0, 14),
                spreadRadius: -4,
              ),
              BoxShadow(
                color: Color(0x0A14B8A6),
                blurRadius: 44,
                offset: Offset(0, 22),
                spreadRadius: -6,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final t = _controller.value;
                final activeTab = _getActiveTab(t);
                final cursorNormalized = _getCursorPosition(t, isMobile);
                final clickProgress = _getClickProgress(t);
                final isClicking = _isClicking(t);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Clean macOS Window Header Chrome
                    _buildWindowHeader(isMobile, activeTab),

                    // Full Application Shell (Sidebar + Balanced Dashboard Workspace + Cursor)
                    _buildShellContainer(
                      context,
                      t,
                      activeTab,
                      isMobile,
                      cursorNormalized,
                      clickProgress,
                      isClicking,
                      targetHeight - 40.0,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
  }

  /// Window Chrome Header with traffic dots, title, simulation badge, and subtle play/pause
  Widget _buildWindowHeader(bool isMobile, int activeTab) {
    final tabTitles = [
      'Live Inspection & Overview',
      'Seafood Audit History',
      'Freshness Analytics & Trends'
    ];

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

          const SizedBox(width: 14),

          // Window Title / Workspace Label
          Expanded(
            child: Center(
              child: Text(
                'SariwaBa? Dashboard • ${tabTitles[activeTab]}',
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.25,
                  color: Color(0xFF475569),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Interactive Play/Pause & Live Badge
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4EA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCEEAD6), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 5.5, height: 5.5, decoration: const BoxDecoration(color: Color(0xFF1E8E3E), shape: BoxShape.circle)),
                    const SizedBox(width: 4.5),
                    const Text(
                      'Live Demo',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.25,
                        color: Color(0xFF137333),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                iconSize: 16,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                tooltip: _isPlaying ? 'Pause' : 'Play',
                onPressed: _togglePlayPause,
                icon: Icon(
                  _isPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline,
                  color: const Color(0xFF64748B),
                ),
              ),
              IconButton(
                iconSize: 15,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                tooltip: 'Replay',
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

  /// Application Shell (Sidebar + Workspace + Cursor)
  Widget _buildShellContainer(
    BuildContext context,
    double t,
    int activeTab,
    bool isMobile,
    Offset cursorNormalized,
    double clickProgress,
    bool isClicking,
    double bodyHeight,
  ) {
    return SizedBox(
      height: bodyHeight,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final shellWidth = constraints.maxWidth;
          final cursorX = cursorNormalized.dx * shellWidth;
          final cursorY = cursorNormalized.dy * bodyHeight;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Shell Interior
              Positioned.fill(
                child: Container(
                  color: const Color(0xFFF8FAFC), // Authentic dashboard soft slate background
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

  /// Desktop Shell: Left Sidebar (195px) + Right Main Workspace
  Widget _buildDesktopShell(double t, int activeTab) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Sidebar reproducing dashboard sidebar faithfully (~195px)
        SizedBox(
          width: 195,
          child: _buildFaithfulSidebar(t, activeTab),
        ),

        // Right Workspace (KPIs + Two Column or Tab Views)
        Expanded(
          child: _buildWorkspaceTabContent(t, activeTab, isMobile: false),
        ),
      ],
    );
  }

  /// Mobile Shell: Compact Top Tab Bar + Mobile Workspace
  Widget _buildMobileShell(double t, int activeTab) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            children: [
              Image.asset('assets/images/SariwaBa logo.png', width: 20, height: 20),
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
            fontSize: 10.5,
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
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Name
          Row(
            children: [
              Image.asset(
                'assets/images/SariwaBa logo.png',
                width: 26,
                height: 26,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'SariwaBa',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.25,
                    color: SariwaColors.textPrimaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Text(
              'WORKSPACE',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Sidebar Navigation Items
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
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: SariwaColors.brandPrimary.withValues(alpha: 0.15),
                  child: const Text(
                    'M',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: SariwaColors.brandPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Marc (Lead)',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.25,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Verified Evaluator',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 9,
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6.5),
      decoration: BoxDecoration(
        color: isActive
            ? SariwaColors.brandPrimary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 15,
            color: isActive ? SariwaColors.brandPrimary : const Color(0xFF64748B),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11.5,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: -0.25,
                color: isActive ? SariwaColors.brandPrimary : const Color(0xFF334155),
              ),
            ),
          ),
          if (badgeCount != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isActive ? SariwaColors.brandPrimary : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$badgeCount',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Dynamic Workspace Content according to active tab
  Widget _buildWorkspaceTabContent(double t, int activeTab, {required bool isMobile}) {
    if (activeTab == 1) {
      return _buildHistoryView(isMobile);
    }
    if (activeTab == 2) {
      return _buildAnalyticsView(isMobile);
    }
    return _buildInspectionOverviewView(t, isMobile);
  }

  // ===========================================================================
  // TAB 0: BALANCED DASHBOARD OVERVIEW & INSPECTION WORKSPACE
  // ===========================================================================
  Widget _buildInspectionOverviewView(double t, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 10 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Context / Greeting Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back, Evaluator',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.25,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    const Text(
                      'Real-time AI fish freshness monitoring and quality audits',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 10,
                        letterSpacing: -0.25,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.calendar, size: 10, color: Color(0xFF64748B)),
                    SizedBox(width: 4),
                    Text(
                      'Daily • Today',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.25,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 2. Row of 4 KPI Metric Cards across the top
          Row(
            children: [
              _buildTopKpiCard('TOTAL SCANS', '12', '+4 today', const Color(0xFF0F172A)),
              const SizedBox(width: 8),
              _buildTopKpiCard('FRESHNESS RATE', '91.7%', '11 fresh', const Color(0xFF15803D)),
              const SizedBox(width: 8),
              _buildTopKpiCard('NOT FRESH ALERTS', '1', 'Requires action', const Color(0xFFDC2626)),
              const SizedBox(width: 8),
              _buildTopKpiCard('AVG CONFIDENCE', '94.2%', 'High precision', SariwaColors.brandPrimary),
            ],
          ),

          const SizedBox(height: 10),

          // 3. Two-Column Core Layout: Live Inspection (flex 6) & Recent Audits (flex 5)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Column: Live Freshness Inspection with Modest Preview
                Expanded(
                  flex: 6,
                  child: _buildInspectionWorkstationCard(t, isMobile),
                ),

                if (!isMobile) ...[
                  const SizedBox(width: 10),
                  // Right Column: Recent Audits Snippet
                  Expanded(
                    flex: 5,
                    child: _buildRecentAuditsCard(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopKpiCard(String label, String value, String sub, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: Color(0xFF94A3B8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.25,
                color: valueColor,
              ),
            ),
            Text(
              sub,
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 8.5,
                letterSpacing: -0.25,
                color: Color(0xFF64748B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Left Card: Live Freshness Inspection with MODEST (~140px) fish preview
  Widget _buildInspectionWorkstationCard(double t, bool isMobile) {
    final isEyeSelected = t >= 0.18;
    final isScanning = t >= 0.29 && t < 0.38;
    final isValidatePressed = t >= 0.25 && t < 0.28;
    final isResultRevealed = t >= 0.38;

    double scanProgress = 0.0;
    if (isScanning) {
      final scanT = (t - 0.29) / 0.09;
      scanProgress = (math.sin(scanT * math.pi * 3 - math.pi / 2) + 1.0) / 2.0;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              const Icon(CupertinoIcons.viewfinder, size: 14, color: SariwaColors.brandPrimary),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Live Freshness Inspection',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.25,
                    color: Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Tilapia',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.25,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Region Selector (Eye vs Gill)
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isEyeSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: isEyeSelected
                          ? const [BoxShadow(color: Color(0x0F000000), blurRadius: 4, offset: Offset(0, 1))]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.visibility_outlined,
                          size: 11,
                          color: isEyeSelected ? SariwaColors.brandPrimary : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Eye (Mata)',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 10,
                            fontWeight: isEyeSelected ? FontWeight.w700 : FontWeight.w500,
                            letterSpacing: -0.25,
                            color: isEyeSelected ? SariwaColors.brandPrimary : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.grain, size: 11, color: Color(0xFF94A3B8)),
                        SizedBox(width: 4),
                        Text(
                          'Gill (Hasang)',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.25,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Center Work Area: Dropzone OR Modest Fish Preview (~135px height)
          Expanded(
            child: t < 0.12
                ? _buildEmptyDropzone(t)
                : _buildModestFishPreview(scanProgress, isScanning),
          ),

          const SizedBox(height: 8),

          // Bottom Area: Validate Button OR Classification Result Card
          if (!isResultRevealed)
            SizedBox(
              width: double.infinity,
              height: 34,
              child: Transform.scale(
                scale: isValidatePressed ? 0.96 : 1.0,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: isScanning
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.8,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Icon(Icons.auto_awesome, size: 13, color: Colors.white),
                  label: Text(
                    isScanning ? 'Analyzing Corneal Clarity...' : 'Validate & Classify Freshness',
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.25,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isScanning ? const Color(0xFF0F766E) : SariwaColors.brandPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
            )
          else
            _buildFreshnessResultCard(),
        ],
      ),
    );
  }

  /// Dropzone state when no image has been loaded yet
  Widget _buildEmptyDropzone(double t) {
    final isHovered = t >= 0.07 && t < 0.12;
    final isPressed = t >= 0.09 && t < 0.12;

    return Container(
      decoration: BoxDecoration(
        color: isHovered ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isHovered ? SariwaColors.brandPrimary : const Color(0xFFE2E8F0),
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 24,
              color: isHovered ? SariwaColors.brandPrimaryDark : const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 6),
            const Text(
              'Drop Tilapia specimen photo here',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.25,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            Transform.scale(
              scale: isPressed ? 0.94 : 1.0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: isHovered ? SariwaColors.brandPrimaryDark : SariwaColors.brandPrimary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.photo_library_outlined, size: 11, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Choose Image',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 10.5,
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
    );
  }

  /// Modest (~140px max) fish image preview container with reticle & scanning laser
  Widget _buildModestFishPreview(double scanProgress, bool isScanning) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Specimen image
          Image.asset(
            'assets/images/sample_tilapia.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.centerLeft,
          ),

          // Vignette
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.25, -0.1),
                radius: 0.85,
                colors: [
                  Colors.black.withValues(alpha: 0.10),
                  Colors.black.withValues(alpha: 0.60),
                ],
              ),
            ),
          ),

          // Reticle over Eye ROI
          Positioned(
            left: 28,
            top: 14,
            width: 100,
            height: 100,
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
                  top: 4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14B8A6).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Text(
                      'ROI: OCULAR EYE',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 7.5,
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

          // Specimen Verified Tag
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 10, color: Color(0xFF34D399)),
                  SizedBox(width: 3),
                  Text(
                    'Specimen: Tilapia',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w500,
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
    );
  }

  /// Compact Classification Result Card
  Widget _buildFreshnessResultCard() {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFBBF7D0), width: 1.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF168077), size: 14),
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Fresh ',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.25,
                          color: Color(0xFF15803D),
                        ),
                      ),
                      TextSpan(
                        text: '•  Tilapia Eye',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 10,
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
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: const Text(
                  '94.7%',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.25,
                    color: Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: const LinearProgressIndicator(
              value: 0.947,
              minHeight: 4,
              backgroundColor: Color(0xFFDCFCE7),
              valueColor: AlwaysStoppedAnimation(Color(0xFF168077)),
            ),
          ),
          const SizedBox(height: 4),
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 9, color: Color(0xFF64748B)),
              SizedBox(width: 3),
              Expanded(
                child: Text(
                  'Visual AI assessment only. Not a food safety guarantee.',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 8,
                    letterSpacing: -0.25,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Right Column: Recent Audits Snippet Card
  Widget _buildRecentAuditsCard() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          const Row(
            children: [
              Icon(CupertinoIcons.clock, size: 14, color: Color(0xFF64748B)),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Recent Audits',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.25,
                    color: Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'View all (12)',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.25,
                  color: SariwaColors.brandPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Audit Records List
          Expanded(
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildAuditMiniRow('#SB-2026-1108', 'Tilapia Eye', '94.7%', true, '2m ago', isLatest: true),
                _buildAuditMiniRow('#SB-2026-1107', 'Tilapia Gill', '91.2%', false, '14m ago'),
                _buildAuditMiniRow('#SB-2026-1106', 'Tilapia Eye', '96.0%', true, '1h ago'),
                _buildAuditMiniRow('#SB-2026-1105', 'Tilapia Eye', '93.5%', true, '3h ago'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditMiniRow(String id, String region, String conf, bool isFresh, String time, {bool isLatest = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isLatest ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isLatest ? const Color(0xFFBBF7D0) : const Color(0xFFF1F5F9),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  id,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 10.5,
                    fontWeight: isLatest ? FontWeight.w700 : FontWeight.w600,
                    letterSpacing: -0.25,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  '$region • $time',
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 8.5,
                    letterSpacing: -0.25,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Text(
            conf,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.25,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            decoration: BoxDecoration(
              color: isFresh ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isFresh ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA),
                width: 0.8,
              ),
            ),
            child: Text(
              isFresh ? 'Fresh' : 'Not Fresh',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.25,
                color: isFresh ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 1: SEAFOOD AUDIT HISTORY VIEW
  // ===========================================================================
  Widget _buildHistoryView(bool isMobile) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(isMobile ? 10 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWorkspaceHeader('Seafood Audit History', 'Traceability Log & Verification Records', isMobile: isMobile),
          const SizedBox(height: 10),

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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.search, size: 11, color: Color(0xFF64748B)),
                    SizedBox(width: 4),
                    Text(
                      'Search records...',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 10,
                        letterSpacing: -0.25,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('SPECIMEN ID', style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8), letterSpacing: 0.4))),
                Expanded(flex: 2, child: Text('REGION', style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8), letterSpacing: 0.4))),
                Expanded(flex: 2, child: Text('CONFIDENCE', style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8), letterSpacing: 0.4))),
                Expanded(flex: 2, child: Text('RESULT', style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8), letterSpacing: 0.4))),
              ],
            ),
          ),

          const SizedBox(height: 5),

          // Audit Rows
          Expanded(
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildHistoryRow('#SB-2026-1108', 'Tilapia Eye', '94.7%', true, isHighlighted: true),
                _buildHistoryRow('#SB-2026-1107', 'Tilapia Gill', '91.2%', false),
                _buildHistoryRow('#SB-2026-1106', 'Tilapia Eye', '96.0%', true),
                _buildHistoryRow('#SB-2026-1105', 'Tilapia Eye', '93.5%', true),
                _buildHistoryRow('#SB-2026-1104', 'Tilapia Eye', '95.2%', true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBadge(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? SariwaColors.brandPrimary.withValues(alpha: 0.12) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? SariwaColors.brandPrimary.withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 10,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: -0.25,
          color: isActive ? SariwaColors.brandPrimary : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildHistoryRow(String scanId, String region, String conf, bool isFresh, {bool isHighlighted = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(7),
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
                fontSize: 10.5,
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
                fontSize: 10.5,
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
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.25,
                color: Color(0xFF334155),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: isFresh ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isFresh ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA),
                  width: 0.8,
                ),
              ),
              child: Text(
                isFresh ? 'Fresh' : 'Not Fresh',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 9.5,
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

  // ===========================================================================
  // TAB 2: FRESHNESS ANALYTICS & QUALITY DISTRIBUTION VIEW
  // ===========================================================================
  Widget _buildAnalyticsView(bool isMobile) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(isMobile ? 10 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWorkspaceHeader('Freshness Analytics & Trends', 'Quality Aggregation & Model Performance', isMobile: isMobile),
          const SizedBox(height: 10),

          // 3 KPI Metric Cards
          Row(
            children: [
              _buildTopKpiCard('TOTAL AUDITS', '12', '+4 this week', const Color(0xFF0F172A)),
              const SizedBox(width: 8),
              _buildTopKpiCard('FRESH RATE', '91.7%', '11 verified', const Color(0xFF15803D)),
              const SizedBox(width: 8),
              _buildTopKpiCard('AVG CONF', '94.2%', 'High precision', SariwaColors.brandPrimary),
            ],
          ),

          const SizedBox(height: 12),

          // Quality Distribution Ratio Bar
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
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
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.25,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '11 Fresh  •  1 Not Fresh',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 9.5,
                        letterSpacing: -0.25,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
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
                const SizedBox(height: 7),
                Row(
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF168077), shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    const Text('Fresh (91.7%)', style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 9.5, letterSpacing: -0.25, color: Color(0xFF475569))),
                    const SizedBox(width: 12),
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFDC2626), shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    const Text('Not Fresh (8.3%)', style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 9.5, letterSpacing: -0.25, color: Color(0xFF475569))),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Regional Breakdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(CupertinoIcons.viewfinder, size: 12, color: SariwaColors.brandPrimary),
                    SizedBox(width: 5),
                    Text('Cornea (Eye): 9 scans • 94.2% avg', style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 10, letterSpacing: -0.25, color: Color(0xFF334155))),
                  ],
                ),
                Row(
                  children: [
                    Icon(CupertinoIcons.circle_grid_hex, size: 12, color: Color(0xFF0284C7)),
                    SizedBox(width: 5),
                    Text('Gill Arch: 3 scans • 91.0% avg', style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 10, letterSpacing: -0.25, color: Color(0xFF334155))),
                  ],
                ),
              ],
            ),
          ),
        ],
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
                  fontSize: 13.5,
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
                  fontSize: 10,
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
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Tilapia • Model A',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.25,
                color: Color(0xFF475569),
              ),
            ),
          ),
      ],
    );
  }
}
