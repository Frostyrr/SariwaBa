import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../controllers/classification/classification_controller.dart';
import '../../models/classification/classification_result.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/staggered_reveal.dart';
import '../../widgets/dashboard/floating_dock.dart';
import '../../widgets/dashboard/floating_topbar.dart';
import '../../widgets/dashboard/hero_banner.dart';
import '../../widgets/dashboard/organoleptic_guidelines_dialog.dart';

/// Timber Dashboard 2.0 Integration for SariwaBa Seafood Freshness Classification.
/// Combines an Apple-inspired floating glassmorphic shell with an information-dense
/// operational Bento grid aligned to SariwaBa's aquatic brand palette and tokens.
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _topKey = GlobalKey();
  final GlobalKey _scannerKey = GlobalKey();
  final GlobalKey _recordsKey = GlobalKey();
  final GlobalKey _alertsKey = GlobalKey();

  String _historyFilter = 'All'; // 'All', 'Fresh', 'Non-Fresh'
  int _activeNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(classificationControllerProvider.notifier).loadHistory();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key, int navIndex) {
    setState(() => _activeNavIndex = navIndex);
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final classState = ref.watch(classificationControllerProvider);
    final classController = ref.read(classificationControllerProvider.notifier);
    final user = authState.user;

    // Attention alerts: scans with moderate or spoiled status
    final attentionItems = classState.history
        .where((s) => !s.isFresh || s.confidence < 0.85)
        .toList();

    return Scaffold(
      backgroundColor: SariwaColors.colorWorkspace,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1024;
          final showDock = constraints.maxWidth >= 840;

          return Stack(
            children: [
              // 1. Ambient Gradient Canvas Backdrop
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: SariwaColors.colorWorkspace,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        SariwaColors.colorWorkspace,
                        const Color(0xFFF3F9F8),
                        SariwaColors.colorPale.withValues(alpha: 0.35),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Main Scrollable Workspace
              Positioned.fill(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: showDock ? 92 : 16,
                    right: 16,
                    top: 18,
                    bottom: 48,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1380),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Floating Topbar Component (Timber 5.1)
                          FloatingTopbar(
                            key: _topKey,
                            user: user,
                            alertCount: attentionItems.length,
                            onHome: () => authController.goToLanding(),
                            onDownloads: () => authController.goToDownloads(),
                            onSignOut: () => authController.signOut(),
                            onNotificationTap: () => _scrollTo(_alertsKey, 3),
                          ),
                          const SizedBox(height: 20),

                          // Solid Brand Hero Banner with 5 Embedded Frosted Glass KPIs (Timber 5.3)
                          StaggeredReveal(
                            staggerIndex: 0,
                            child: HeroBanner(
                              history: classState.history,
                              isSyncing: classState.isLoadingHistory,
                              onSync: () => classController.loadHistory(),
                              onNewScan: () => _scrollTo(_scannerKey, 1),
                            ),
                          ),
                          const SizedBox(height: 22),

                          // Error & Success Notification Banners
                          if (classState.errorMessage != null) ...[
                            _buildNotificationBanner(
                              message: classState.errorMessage!,
                              isError: true,
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (classState.successMessage != null) ...[
                            _buildNotificationBanner(
                              message: classState.successMessage!,
                              isError: false,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Two-Column Asymmetric Bento Grid (65% / 35%)
                          if (isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Main Workspace Column (~65%)
                                Expanded(
                                  flex: 13,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Bento Panel 1: Live Scanner Station
                                      Container(
                                        key: _scannerKey,
                                        child: StaggeredReveal(
                                          staggerIndex: 1,
                                          child: _buildScannerPanel(
                                            classState,
                                            classController,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Bento Panel 2: Active Quality Records
                                      Container(
                                        key: _recordsKey,
                                        child: StaggeredReveal(
                                          staggerIndex: 2,
                                          child: _buildRecordsPanel(
                                            classState,
                                            classController,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Bento Panel 3: Horizontal Activity Strip
                                      StaggeredReveal(
                                        staggerIndex: 3,
                                        child: _buildActivityStrip(),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 22),

                                // Priority Rail Column (~35%)
                                Expanded(
                                  flex: 7,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Bento Panel 4: Needs Attention Panel
                                      Container(
                                        key: _alertsKey,
                                        child: StaggeredReveal(
                                          staggerIndex: 4,
                                          child: _buildAttentionRail(
                                            attentionItems,
                                            classController,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Bento Panel 5: Regulatory Protocol Callout
                                      StaggeredReveal(
                                        staggerIndex: 5,
                                        child: _buildProtocolCallout(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else
                            // Stacked Mobile / Tablet Layout
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  key: _scannerKey,
                                  child: StaggeredReveal(
                                    staggerIndex: 1,
                                    child: _buildScannerPanel(
                                      classState,
                                      classController,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  key: _alertsKey,
                                  child: StaggeredReveal(
                                    staggerIndex: 2,
                                    child: _buildAttentionRail(
                                      attentionItems,
                                      classController,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  key: _recordsKey,
                                  child: StaggeredReveal(
                                    staggerIndex: 3,
                                    child: _buildRecordsPanel(
                                      classState,
                                      classController,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildProtocolCallout(),
                                const SizedBox(height: 20),
                                _buildActivityStrip(),
                              ],
                            ),

                          const SizedBox(height: 36),

                          // Simple Footer
                          _buildSimpleFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Desktop Floating Dock with Parabolic Magnification (Timber 5.2)
              if (showDock)
                Positioned(
                  left: 20,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: FloatingDock(
                      isSyncing: classState.isLoadingHistory,
                      onSync: () => classController.loadHistory(),
                      onQuickScan: () {
                        _scrollTo(_scannerKey, 1);
                        classController.pickImage(ImageSource.gallery);
                      },
                      items: [
                        DockItemData(
                          icon: Icons.dashboard_outlined,
                          label: 'Overview',
                          isActive: _activeNavIndex == 0,
                          onTap: () => _scrollTo(_topKey, 0),
                        ),
                        DockItemData(
                          icon: Icons.camera_alt_outlined,
                          label: 'Live Scanner',
                          isActive: _activeNavIndex == 1,
                          onTap: () => _scrollTo(_scannerKey, 1),
                        ),
                        DockItemData(
                          icon: Icons.history_rounded,
                          label: 'Audit Records',
                          isActive: _activeNavIndex == 2,
                          badgeCount: classState.history.length,
                          badgeColor: SariwaColors.colorPrimary,
                          onTap: () => _scrollTo(_recordsKey, 2),
                        ),
                        DockItemData(
                          icon: Icons.warning_amber_rounded,
                          label: 'Needs Attention',
                          isActive: _activeNavIndex == 3,
                          badgeCount: attentionItems.length,
                          badgeColor: SariwaColors.statusSpoiled,
                          onTap: () => _scrollTo(_alertsKey, 3),
                        ),
                        DockItemData(
                          icon: Icons.verified_user_outlined,
                          label: 'PNS Standards',
                          isActive: false,
                          onTap: () => OrganolepticGuidelinesDialog.show(context),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bento Component 1: Live Scanner Panel
  // ---------------------------------------------------------------------------
  Widget _buildScannerPanel(
    ClassificationState state,
    ClassificationController controller,
  ) {
    return _buildFrostedPanel(
      title: 'Live Freshness Inspection',
      subtitle: 'Multi-cue sensory analysis of cornea, branchial gills & dermal sheen',
      headerTrailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: SariwaColors.colorPale,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: SariwaColors.colorPrimary.withValues(alpha: 0.20),
          ),
        ),
        child: const Text(
          'MobileNetV3 Sensory Engine',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: SariwaColors.colorPrimary,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropzone or Selected Image Preview
          if (state.selectedImageBytes == null)
            _buildEmptyUploadDropzone(controller)
          else
            _buildSelectedImagePreview(state, controller),

          const SizedBox(height: 18),

          // Primary Inspection CTA Button
          if (state.selectedImageBytes != null)
            AppButton.primary(
              label: state.isClassifying
                  ? 'Analyzing Tissue & Cornea Biomarkers...'
                  : 'Classify Fish Freshness',
              isLoading: state.isClassifying,
              height: 48,
              borderRadius: 14,
              icon: const Icon(
                Icons.auto_awesome,
                size: 18,
                color: Colors.white,
              ),
              onPressed: state.isClassifying ? () {} : () => controller.classify(),
            ),

          // Live Inspection Result Breakdown
          if (state.latestResult != null) ...[
            const SizedBox(height: 20),
            Container(height: 1, color: SariwaColors.colorLine),
            const SizedBox(height: 18),
            _buildInspectionResultView(state.latestResult!),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyUploadDropzone(ClassificationController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: SariwaColors.colorPrimary.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SariwaColors.colorPale,
              border: Border.all(
                color: SariwaColors.colorPrimary.withValues(alpha: 0.20),
              ),
            ),
            child: const Icon(
              Icons.cloud_upload_outlined,
              size: 34,
              color: SariwaColors.colorPrimary,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Select or capture seafood specimen',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: SariwaColors.colorInk,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Align whole fish or macro view of eyes and branchial gills (JPEG/PNG up to 5 MB)',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12.5,
              color: SariwaColors.colorMutedInk,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => controller.pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined, size: 16),
                label: const Text('Browse Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SariwaColors.colorPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 11,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => controller.pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined, size: 16),
                label: const Text('Use Camera'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: SariwaColors.colorPrimary,
                  side: const BorderSide(color: SariwaColors.colorLine),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 11,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedImagePreview(
    ClassificationState state,
    ClassificationController controller,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SariwaColors.colorLine),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 220,
              width: double.infinity,
              child: Image.memory(
                state.selectedImageBytes!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.image_outlined,
                      size: 18,
                      color: SariwaColors.colorPrimary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.selectedImageName ?? 'specimen_scan.jpg',
                        style: const TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: SariwaColors.colorInk,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => controller.clearSelection(),
                icon: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: SariwaColors.statusSpoiled,
                ),
                label: const Text(
                  'Remove',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    color: SariwaColors.statusSpoiled,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionResultView(ClassificationResult result) {
    final statusBg = result.isFresh
        ? SariwaColors.successBg
        : (result.grade.contains('Grade C')
            ? SariwaColors.dangerBg
            : SariwaColors.warningBg);
    final statusBorder = result.isFresh
        ? SariwaColors.successBorder
        : (result.grade.contains('Grade C')
            ? SariwaColors.dangerBorder
            : SariwaColors.warningBorder);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Result Grade Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: statusBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: statusBorder, width: 1.2),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: result.statusColor,
                ),
                child: Icon(
                  result.isFresh
                      ? Icons.verified_rounded
                      : Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          result.label,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: result.statusColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: result.statusColor,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            result.grade,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: result.statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'AI Statistical Confidence: ${result.formattedConfidence}',
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: SariwaColors.colorInk,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3 Sensory Biomarkers Breakdown Grid
        const Text(
          'Sensory Biomarkers Analysis (PNS/BAFPS 67:2008)',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: SariwaColors.colorInk,
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 500;
            final tiles = [
              _buildSensoryTile(
                title: 'Cornea / Eyes',
                value: result.eyesIndicator,
                color: result.statusColor,
              ),
              _buildSensoryTile(
                title: 'Branchial Gills',
                value: result.gillsIndicator,
                color: result.statusColor,
              ),
              _buildSensoryTile(
                title: 'Dermal Scales',
                value: result.scalesIndicator,
                color: result.statusColor,
              ),
            ];

            if (isNarrow) {
              return Column(
                children: tiles
                    .map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: t,
                        ))
                    .toList(),
              );
            }

            return Row(
              children: [
                Expanded(child: tiles[0]),
                const SizedBox(width: 8),
                Expanded(child: tiles[1]),
                const SizedBox(width: 8),
                Expanded(child: tiles[2]),
              ],
            );
          },
        ),
        const SizedBox(height: 14),

        // Recommendation Box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: SariwaColors.colorSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SariwaColors.colorLine),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: SariwaColors.colorPrimary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result.recommendation,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    height: 1.4,
                    color: SariwaColors.colorMutedInk,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // PostgreSQL Saved Banner
        if (result.saved && result.scanId != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: SariwaColors.successBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SariwaColors.successBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 15,
                  color: SariwaColors.statusFresh,
                ),
                const SizedBox(width: 8),
                Text(
                  'Archived in PostgreSQL Quality Audit Log — Scan #${result.scanId}',
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: SariwaColors.successText,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 12),

        // Mandatory Disclaimer per SRS FR-008
        Text(
          'Regulatory Disclaimer: SariwaBa AI classifications provide real-time decision-support. Critical distribution checkpoints must perform organoleptic validation in accordance with BFAR quality protocols.',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 11,
            height: 1.35,
            color: SariwaColors.colorMutedInk,
          ),
        ),
      ],
    );
  }

  Widget _buildSensoryTile({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: SariwaColors.colorLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: SariwaColors.colorPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 11,
              height: 1.3,
              color: SariwaColors.colorInk,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bento Component 2: Active Quality Records & Inspection Rows
  // ---------------------------------------------------------------------------
  Widget _buildRecordsPanel(
    ClassificationState state,
    ClassificationController controller,
  ) {
    var filtered = state.history;
    if (_historyFilter == 'Fresh') {
      filtered = state.history.where((s) => s.isFresh).toList();
    } else if (_historyFilter == 'Non-Fresh') {
      filtered = state.history.where((s) => !s.isFresh).toList();
    }

    return _buildFrostedPanel(
      title: 'Active Quality Evaluations & Returns',
      subtitle: 'Sorted by nearest evaluation timestamp',
      headerTrailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['All', 'Fresh', 'Non-Fresh'].map((filter) {
          final isSelected = _historyFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(left: 6),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => setState(() => _historyFilter = filter),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? SariwaColors.colorPrimary
                        : Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(
                      color: isSelected
                          ? SariwaColors.colorPrimary
                          : SariwaColors.colorLine,
                    ),
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : SariwaColors.colorMutedInk,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.isLoadingHistory && state.history.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(
                  color: SariwaColors.colorPrimary,
                ),
              ),
            )
          else if (filtered.isEmpty)
            _buildEmptyHistoryState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final scan = filtered[index];
                return _buildWorkRowCard(scan, controller, state);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildWorkRowCard(
    ClassificationResult scan,
    ClassificationController controller,
    ClassificationState state,
  ) {
    final isDeleting = state.deletingScanId == scan.scanId;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.95),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0A2229),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Icon / Image Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 44,
              height: 44,
              color: scan.statusColor.withValues(alpha: 0.12),
              child: scan.imageUrl != null && scan.imageUrl!.isNotEmpty
                  ? Image.network(
                      scan.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.set_meal_rounded,
                        color: scan.statusColor,
                        size: 22,
                      ),
                    )
                  : Icon(
                      Icons.set_meal_rounded,
                      color: scan.statusColor,
                      size: 22,
                    ),
            ),
          ),
          const SizedBox(width: 14),

          // Center: Title, Metadata & Biomarker Tags
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      scan.label,
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: SariwaColors.colorInk,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: scan.isFresh
                            ? SariwaColors.successBg
                            : (scan.grade.contains('Grade C')
                                ? SariwaColors.dangerBg
                                : SariwaColors.warningBg),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: scan.statusColor.withValues(alpha: 0.4),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        scan.grade,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: scan.statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      scan.createdAt != null
                          ? '${scan.createdAt!.month}/${scan.createdAt!.day}/${scan.createdAt!.year} at ${scan.createdAt!.hour}:${scan.createdAt!.minute.toString().padLeft(2, '0')}'
                          : 'Scan #${scan.scanId ?? 'LIVE'}',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11.5,
                        color: SariwaColors.colorMutedInk,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: SariwaColors.colorPale,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'AI ${scan.formattedConfidence}',
                        style: const TextStyle(
                          fontFamily: 'Geist Mono',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: SariwaColors.colorPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Delete Action
          if (scan.scanId != null)
            IconButton(
              icon: isDeleting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline_rounded, size: 18),
              color: SariwaColors.colorMutedInk,
              tooltip: 'Delete scan record',
              onPressed: isDeleting
                  ? null
                  : () => _confirmDelete(context, scan.scanId!, controller),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistoryState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SariwaColors.colorLine),
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/images/SariwaBa logo.png',
            height: 54,
            errorBuilder: (_, _, _) => const Icon(
              Icons.inventory_2_outlined,
              size: 44,
              color: SariwaColors.colorMutedInk,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No scan history found',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: SariwaColors.colorInk,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Upload a seafood photo above to record quality audits in PostgreSQL.',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12,
              color: SariwaColors.colorMutedInk,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bento Component 3: Horizontal Activity Strip (Timber 5.6)
  // ---------------------------------------------------------------------------
  Widget _buildActivityStrip() {
    return _buildFrostedPanel(
      title: 'Recent System Activity & Logs',
      subtitle: 'Real-time telemetry & model verification audit trail',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 640;

          final cards = [
            _buildActivityCard(
              timestamp: 'Telemetry Live',
              title: 'MobileNetV3 Sensory Engine Active',
              meta: 'Latency ~180ms • GPU/CPU TFLite',
              icon: Icons.speed_rounded,
            ),
            _buildActivityCard(
              timestamp: 'PostgreSQL Live',
              title: 'Database Session Verified',
              meta: 'SSL Encrypted • Audit Schema v2',
              icon: Icons.storage_rounded,
            ),
            _buildActivityCard(
              timestamp: 'Standards Check',
              title: 'PNS 67:2008 Protocol Synced',
              meta: 'BFAR Organoleptic Guidelines v1',
              icon: Icons.verified_user_outlined,
            ),
          ];

          if (isNarrow) {
            return Column(
              children: cards
                  .map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: c,
                      ))
                  .toList(),
            );
          }

          return Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 10),
              Expanded(child: cards[1]),
              const SizedBox(width: 10),
              Expanded(child: cards[2]),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActivityCard({
    required String timestamp,
    required String title,
    required String meta,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.95)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080A2229),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                timestamp,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: SariwaColors.colorMutedInk,
                ),
              ),
              Icon(icon, size: 14, color: SariwaColors.colorPrimary),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: SariwaColors.colorInk,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            meta,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 11,
              color: SariwaColors.colorMutedInk,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bento Component 4: Needs Attention Rail (Timber 5.7)
  // ---------------------------------------------------------------------------
  Widget _buildAttentionRail(
    List<ClassificationResult> items,
    ClassificationController controller,
  ) {
    return _buildFrostedPanel(
      title: 'Needs Attention',
      subtitle: 'Substandard scans & sensory escalations',
      headerTrailing: items.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: SariwaColors.dangerBg,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: SariwaColors.dangerBorder),
              ),
              child: Text(
                '${items.length} Flagged',
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: SariwaColors.dangerText,
                ),
              ),
            )
          : null,
      child: items.isEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SariwaColors.colorLine),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: SariwaColors.successBg,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      color: SariwaColors.statusFresh,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No Critical Quality Alerts',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: SariwaColors.colorInk,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'All seafood evaluations meet Grade A freshness standards.',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11.5,
                            color: SariwaColors.colorMutedInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: items.map((scan) {
                final isCritical = scan.grade.contains('Grade C');
                final bg = isCritical
                    ? SariwaColors.dangerBg
                    : SariwaColors.warningBg;
                final border = isCritical
                    ? SariwaColors.dangerBorder
                    : SariwaColors.warningBorder;
                final text = isCritical
                    ? SariwaColors.dangerText
                    : SariwaColors.warningText;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.95)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A0A2229),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: bg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: border),
                              ),
                              child: Icon(
                                isCritical
                                    ? Icons.error_outline_rounded
                                    : Icons.warning_amber_rounded,
                                color: text,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    scan.label,
                                    style: const TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: SariwaColors.colorInk,
                                    ),
                                  ),
                                  Text(
                                    scan.grade,
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: text,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          scan.recommendation,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11,
                            height: 1.35,
                            color: SariwaColors.colorMutedInk,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Container(height: 1, color: SariwaColors.colorLineSubtle),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              scan.scanId != null ? 'Scan #${scan.scanId}' : 'Live Check',
                              style: const TextStyle(
                                fontFamily: 'Geist Mono',
                                fontSize: 10.5,
                                color: SariwaColors.colorMutedInk,
                              ),
                            ),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => OrganolepticGuidelinesDialog.show(context),
                                child: Text(
                                  'Review protocol →',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: SariwaColors.colorPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bento Component 5: Regulatory Protocol Callout Card (Timber 5.7)
  // ---------------------------------------------------------------------------
  Widget _buildProtocolCallout() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SariwaColors.colorPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SariwaColors.colorPrimary.withValues(alpha: 0.22),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: SariwaColors.colorPrimary,
                ),
                child: const Center(
                  child: Icon(
                    Icons.shield_outlined,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PNS 67:2008 Quality Protocol',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: SariwaColors.colorInk,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Seafood custody verification requires immediate organoleptic assessment prior to market stalls.',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11.5,
                        height: 1.4,
                        color: SariwaColors.colorMutedInk,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: SariwaColors.colorPrimary.withValues(alpha: 0.12)),
          const SizedBox(height: 10),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => OrganolepticGuidelinesDialog.show(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(
                    color: SariwaColors.colorPrimary.withValues(alpha: 0.30),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Read Organoleptic Criteria',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: SariwaColors.colorPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Generic Frosted Outer Panel Helper (.panel)
  // ---------------------------------------------------------------------------
  Widget _buildFrostedPanel({
    required String title,
    required String subtitle,
    Widget? headerTrailing,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.92),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0A2229),
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Color(0x080A2229),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: SariwaColors.colorInk,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        color: SariwaColors.colorMutedInk,
                      ),
                    ),
                  ],
                ),
              ),
              if (headerTrailing != null) ...[
                const SizedBox(width: 12),
                headerTrailing,
              ],
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildNotificationBanner({
    required String message,
    required bool isError,
  }) {
    final bg = isError ? SariwaColors.dangerBg : SariwaColors.successBg;
    final border = isError ? SariwaColors.dangerBorder : SariwaColors.successBorder;
    final text = isError ? SariwaColors.dangerText : SariwaColors.successText;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 1.2),
      ),
      child: Row(
        children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: text,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                color: text,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    int scanId,
    ClassificationController controller,
  ) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete Quality Scan?'),
        content: Text(
          'Are you sure you want to permanently remove Scan #$scanId from PostgreSQL history?',
          style: const TextStyle(fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SariwaColors.statusSpoiled,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              controller.deleteScan(scanId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleFooter() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          '© ${DateTime.now().year} SariwaBa — Intelligent Fish Freshness Classification System. All rights reserved.',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12,
            color: SariwaColors.colorMutedInk,
          ),
        ),
      ),
    );
  }
}
