import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controllers/classification/classification_controller.dart';
import '../../../constants/theme/app_colors.dart';
import '../../../constants/theme/app_typography.dart';
import '../../../widgets/common/staggered_reveal.dart';
import '../../../widgets/dashboard/current_scan_panel.dart';
import '../../../widgets/dashboard/dashboard_atmospheric_banner.dart';
import '../../../widgets/dashboard/scanner_workstation_card.dart';

/// Main Inspection Workstation section:
/// - Wide: Left column (Scanner), Right column (Current-Scan Panel: Detected Eyes + Result)
/// - Narrow: Scanner -> Current-Scan Panel
class InspectionWorkspaceSection extends StatelessWidget {
  final dynamic user;
  final bool isGuestUser;
  final bool isDesktop;
  final bool isModalEffectivelyOpen;
  final ClassificationState classState;
  final ClassificationController classController;
  final VoidCallback onConnectGoogle;
  final VoidCallback onBackHome;
  final VoidCallback onOpenCropModal;
  final VoidCallback? onViewMore;
  final VoidCallback? onViewAnalytics;
  final ScrollController? scrollController;
  final Future<bool> Function(ImageSource source)? onRequestPermission;

  const InspectionWorkspaceSection({
    super.key,
    required this.user,
    required this.isGuestUser,
    required this.isDesktop,
    required this.isModalEffectivelyOpen,
    required this.classState,
    required this.classController,
    required this.onConnectGoogle,
    required this.onBackHome,
    required this.onOpenCropModal,
    this.onViewMore,
    this.onViewAnalytics,
    this.scrollController,
    this.onRequestPermission,
  });

  @override
  Widget build(BuildContext context) {
    final totalScans = classState.history.length;
    final freshScans = classState.history.where((s) => s.isFresh).length;

    return RefreshIndicator.adaptive(
      color: SariwaColors.brandPrimary,
      onRefresh: () async {
        HapticFeedback.lightImpact();
        await classController.loadHistory();
      },
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          isDesktop ? 36 : 16,
          isDesktop ? 24 : 12,
          isDesktop ? 36 : 16,
          isDesktop ? 24 : 104,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1320),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isDesktop) ...[
                  StaggeredReveal(
                    staggerIndex: 0,
                    child: _buildDashboardHeader(context),
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  StaggeredReveal(
                    staggerIndex: 0,
                    child: _buildCompactAtmosphericHeader(
                      totalScans: totalScans,
                      freshScans: freshScans,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 900;

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 7,
                            child: StaggeredReveal(
                              staggerIndex: 1,
                              child: ScannerWorkstationCard(
                                state: classState,
                                controller: classController,
                                isCropModalOpen: isModalEffectivelyOpen,
                                onOpenCropModal: onOpenCropModal,
                                onRequestPermission: onRequestPermission,
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 5,
                            child: StaggeredReveal(
                              staggerIndex: 2,
                              child: CurrentScanPanel(
                                state: classState,
                                controller: classController,
                                isWide: true,
                                onAdjustCrop: onOpenCropModal,
                                onViewHistory: onViewMore,
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    // Narrow workspace: Scanner -> Current-Scan Panel
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        StaggeredReveal(
                          staggerIndex: 0,
                          child: ScannerWorkstationCard(
                            state: classState,
                            controller: classController,
                            isCropModalOpen: isModalEffectivelyOpen,
                            onOpenCropModal: onOpenCropModal,
                            onRequestPermission: onRequestPermission,
                          ),
                        ),
                        const SizedBox(height: 16),
                        StaggeredReveal(
                          staggerIndex: 1,
                          child: CurrentScanPanel(
                            state: classState,
                            controller: classController,
                            isWide: false,
                            onAdjustCrop: onOpenCropModal,
                            onViewHistory: onViewMore,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
                _buildSimpleFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactAtmosphericHeader({
    required int totalScans,
    required int freshScans,
  }) {
    final freshPct =
        totalScans > 0 ? ((freshScans / totalScans) * 100).round() : 0;
    final historyTap = onViewMore ?? onViewAnalytics;

    return DashboardAtmosphericBanner(
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Freshness Inspection',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.3,
                    color: SariwaColors.cardSurfaceLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  totalScans > 0
                      ? '$totalScans ${totalScans == 1 ? 'scan' : 'scans'} · $freshPct% fresh'
                      : 'Snap or upload an eye or gill photo.',
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    height: 1.35,
                    color: SariwaColors.colorPale,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (historyTap != null) ...[
            const SizedBox(width: 12),
            Semantics(
              button: true,
              label: 'View History and Insights',
              child: Material(
                color: SariwaColors.cardSurfaceLight.withValues(alpha: 0.14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                  side: BorderSide(
                    color:
                        SariwaColors.cardSurfaceLight.withValues(alpha: 0.25),
                  ),
                ),
                child: InkWell(
                  onTap: historyTap,
                  borderRadius: BorderRadius.circular(999),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'History',
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          CupertinoIcons.chevron_right,
                          size: 12,
                          color: SariwaColors.brandLight,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDashboardHeader(BuildContext context) {
    final name = (user != null &&
            user.displayName != null &&
            user.displayName.toString().isNotEmpty)
        ? user.displayName.toString().split(' ').first
        : (isGuestUser ? 'Guest' : 'Inspector');

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 640;

        final headerInfo = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: SariwaColors.colorPale,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: SariwaColors.brandLight,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: SariwaColors.brandPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isGuestUser ? 'Guest Mode' : 'Synced',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: AppTypography.defaultLetterSpacing,
                          color: SariwaColors.brandPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Welcome, $name',
              style: AppTypography.displayLarge.copyWith(
                color: SariwaColors.cardSurfaceLight,
                fontSize: isCompact ? 20 : 28,
                fontWeight: FontWeight.w500,
                letterSpacing: AppTypography.defaultLetterSpacing,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Snap or upload an eye, gill, or whole fish photo.',
              style: AppTypography.bodyMedium.copyWith(
                color: SariwaColors.brandLight,
                fontSize: 14,
                fontWeight: FontWeight.w300,
                letterSpacing: AppTypography.defaultLetterSpacing,
              ),
            ),
          ],
        );

        final actionButton = isGuestUser
            ? OutlinedButton.icon(
                onPressed: onConnectGoogle,
                icon: const Icon(
                  CupertinoIcons.person_badge_plus,
                  size: 15,
                  color: SariwaColors.brandPrimary,
                ),
                label: const Text('Sign In'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: SariwaColors.brandPrimary,
                  side: const BorderSide(
                    color: SariwaColors.brandLight,
                    width: 1.0,
                  ),
                  backgroundColor: SariwaColors.colorPale,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: const StadiumBorder(),
                ),
              )
            : OutlinedButton.icon(
                onPressed: () => classController.loadHistory(),
                icon: const Icon(
                  CupertinoIcons.refresh,
                  size: 14,
                  color: SariwaColors.brandPrimary,
                ),
                label: const Text('Refresh'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: SariwaColors.brandPrimary,
                  side: const BorderSide(
                    color: SariwaColors.brandLight,
                    width: 1.0,
                  ),
                  backgroundColor: SariwaColors.colorPale,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: const StadiumBorder(),
                ),
              );

        final Widget innerContent;
        if (isCompact) {
          innerContent = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [headerInfo, const SizedBox(height: 12), actionButton],
          );
        } else {
          innerContent = Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: headerInfo),
              const SizedBox(width: 16),
              actionButton,
            ],
          );
        }

        return DashboardAtmosphericBanner(
          content: innerContent,
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 20 : 28,
            vertical: isCompact ? 20 : 24,
          ),
        );
      },
    );
  }

  Widget _buildSimpleFooter() {
    return Center(
      child: Text(
        '© ${DateTime.now().year} SariwaBa',
        style: const TextStyle(
          fontSize: 12,
          letterSpacing: AppTypography.defaultLetterSpacing,
          color: SariwaColors.textMutedDark,
        ),
      ),
    );
  }
}
