import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../../constants/theme/app_colors.dart';
import '../../../constants/theme/app_typography.dart';
import '../../../controllers/classification/classification_controller.dart';
import '../../../models/auth/user_model.dart';
import '../../../models/classification/classification_result.dart';
import '../../../widgets/common/staggered_reveal.dart';
import '../../../widgets/common/user_avatar.dart';
import '../../../widgets/dashboard/current_scan_panel.dart';
import '../../../widgets/dashboard/frosted_glass_card.dart';
import '../../../widgets/dashboard/inspection_details_modal.dart';
import '../../../widgets/dashboard/scan_thumbnail.dart';
import '../../../widgets/dashboard/scanner_workstation_card.dart';

/// Main Inspection Workstation section (Option A: Split Workbench + Recent Activity):
/// - Desktop (`>= 900px`): 12-column split (7 cols Scanner | 5 cols Current Scan + Recent Scans)
/// - Mobile (`< 900px`): Scanner -> Result (if photo selected) or Recent Scans (when empty), `pb-28` clearance
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
  final VoidCallback? onOpenSettings;
  final VoidCallback? onOpenGuide;
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
    this.onOpenSettings,
    this.onOpenGuide,
    this.scrollController,
    this.onRequestPermission,
  });

  static const Color _inkPrimary = Color(0xFF111111);
  static const Color _inkMuted = Color(0xFF737373);
  static const Color _divider = Color(0x12171717);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: !isDesktop,
      bottom: false,
      child: RefreshIndicator.adaptive(
        color: _inkPrimary,
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
            isDesktop ? 36 : 0,
            isDesktop ? 24 : 0,
            isDesktop ? 36 : 0,
            isDesktop ? 32 : 112, // pb-28 mobile clearance for floating bottom nav
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
                      child: _buildDesktopHeader(context),
                    ),
                    const SizedBox(height: 20),
                  ] else
                    StaggeredReveal(
                      staggerIndex: 0,
                      child: _buildMobileHeader(),
                    ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 0 : 16,
                    ),
                    child: LayoutBuilder(
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
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    StaggeredReveal(
                                      staggerIndex: 2,
                                      child: CurrentScanPanel(
                                        state: classState,
                                        controller: classController,
                                        isWide: true,
                                        onAdjustCrop: onOpenCropModal,
                                        onViewHistory: onViewMore,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    StaggeredReveal(
                                      staggerIndex: 3,
                                      child: _buildRecentScansCard(
                                        context,
                                        maxItems: 3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }

                        // Mobile / Narrow workspace:
                        // Hide empty CurrentScanPanel when no photo is selected and show Recent Scans instead.
                        final hasActiveScan = classState.hasSelectedImage ||
                            classState.batchScans.isNotEmpty;

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
                            if (hasActiveScan)
                              StaggeredReveal(
                                staggerIndex: 1,
                                child: CurrentScanPanel(
                                  state: classState,
                                  controller: classController,
                                  isWide: false,
                                  onAdjustCrop: onOpenCropModal,
                                  onViewHistory: onViewMore,
                                ),
                              )
                            else
                              StaggeredReveal(
                                staggerIndex: 1,
                                child: _buildRecentScansCard(
                                  context,
                                  maxItems: 3,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSimpleFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Unified iOS Large Title + Utility Row header for Mobile Inspect
  Widget _buildMobileHeader() {
    final typedUser = user is UserModel ? user as UserModel : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 36,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left: borderless status indicator
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isGuestUser
                            ? _inkMuted
                            : SariwaColors.brandPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isGuestUser ? 'Guest Mode' : 'Synced',
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _inkMuted,
                      ),
                    ),
                  ],
                ),
                // Right: Help/Guide (?) + Account Avatar (36x36 white circles, 8px gap)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onOpenGuide != null) ...[
                      Semantics(
                        button: true,
                        label: 'Freshness Guide',
                        child: Tooltip(
                          message: 'Freshness Guide',
                          child: Material(
                            color: Colors.white,
                            shape: CircleBorder(
                              side: BorderSide(
                                color: Colors.black.withValues(alpha: 0.08),
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                onOpenGuide!();
                              },
                              customBorder: const CircleBorder(),
                              child: const SizedBox(
                                width: 36,
                                height: 36,
                                child: Icon(
                                  CupertinoIcons.question,
                                  size: 16,
                                  color: _inkPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Semantics(
                      button: true,
                      label: 'Account settings',
                      child: Material(
                        color: Colors.white,
                        shape: CircleBorder(
                          side: BorderSide(
                            color: Colors.black.withValues(alpha: 0.08),
                          ),
                        ),
                        child: InkWell(
                          onTap: onOpenSettings,
                          customBorder: const CircleBorder(),
                          child: SizedBox(
                            width: 36,
                            height: 36,
                            child: ClipOval(
                              child: UserAvatar(user: typedUser, radius: 18),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Inspect',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              height: 1.15,
              color: _inkPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Desktop header: `Freshness Inspection` + borderless status dot + crisp white CTA
  Widget _buildDesktopHeader(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 640;

        final headerInfo = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Borderless status indicator (dot + muted label)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isGuestUser
                        ? _inkMuted
                        : SariwaColors.brandPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isGuestUser ? 'Guest Mode' : 'Synced',
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _inkMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Freshness Inspection',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                color: _inkPrimary,
                fontSize: isCompact ? 22 : 28,
                fontWeight: FontWeight.w700,
                letterSpacing: isCompact ? -0.55 : -0.7,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Snap or upload an eye, gill, or whole fish photo.',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                color: _inkMuted,
                fontSize: 14,
                fontWeight: FontWeight.w400,
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
                  color: _inkPrimary,
                ),
                label: const Text('Sign In'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _inkPrimary,
                  side: const BorderSide(color: Color(0x1A171717), width: 1.0),
                  backgroundColor: Colors.white,
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
                  color: _inkPrimary,
                ),
                label: const Text('Refresh'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _inkPrimary,
                  side: const BorderSide(color: Color(0x1A171717), width: 1.0),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: const StadiumBorder(),
                ),
              );

        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headerInfo,
                    const SizedBox(height: 12),
                    actionButton,
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: headerInfo),
                    const SizedBox(width: 16),
                    actionButton,
                  ],
                ),
        );
      },
    );
  }

  /// Compact white Recent Scans card (last 3 scans + `View all →` link to History)
  Widget _buildRecentScansCard(BuildContext context, {required int maxItems}) {
    final recent = classState.history.take(maxItems).toList();

    return FrostedGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Scans',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.15,
                  color: _inkPrimary,
                ),
              ),
              if (onViewMore != null)
                TextButton(
                  onPressed: onViewMore,
                  style: TextButton.styleFrom(
                    foregroundColor: _inkPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: const Text('View all →'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (recent.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No scans yet. Upload a photo or try a sample to see your latest readings here.',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13,
                  height: 1.5,
                  color: _inkMuted,
                ),
              ),
            )
          else
            for (var i = 0; i < recent.length; i++) ...[
              _buildRecentScanRow(context, recent[i]),
              if (i < recent.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1, color: _divider),
                ),
            ],
        ],
      ),
    );
  }

  Widget _buildRecentScanRow(BuildContext context, ClassificationResult scan) {
    final region = (scan.regionType ?? 'Eye').toLowerCase() == 'gill'
        ? 'Gill Scan'
        : 'Eye Scan';
    final isFresh = scan.isFresh;
    final statusColor =
        isFresh ? SariwaColors.brandPrimary : SariwaColors.statusSpoiled;

    return InkWell(
      onTap: () => InspectionDetailsModal.show(context, scan),
      borderRadius: BorderRadius.circular(10),
      child: Row(
        children: [
          ScanThumbnail(scan: scan, size: 40, borderRadius: 8, iconSize: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      region,
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _inkPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '· ${scan.label}',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  InspectionDetailsModal.formatDateTime(scan.createdAt),
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    color: _inkMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            scan.formattedConfidence,
            style: const TextStyle(
              fontFamily: 'Geist Mono',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _inkPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleFooter() {
    return Center(
      child: Text(
        '© ${DateTime.now().year} SariwaBa',
        style: const TextStyle(
          fontSize: 12,
          letterSpacing: AppTypography.defaultLetterSpacing,
          color: _inkMuted,
        ),
      ),
    );
  }
}
