import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../controllers/classification/classification_controller.dart';
import '../../../constants/theme/app_colors.dart';
import '../../../constants/theme/app_typography.dart';
import '../../../widgets/common/staggered_reveal.dart';
import '../../../widgets/dashboard/audit_history_card.dart';
import '../../../widgets/dashboard/dashboard_atmospheric_banner.dart';
import '../../../widgets/dashboard/dashboard_notification_banner.dart';
import '../../../widgets/dashboard/kpi_metrics_row.dart';
import '../../../widgets/dashboard/scanner_workstation_card.dart';

/// Main Inspection Workstation section providing the KPI strip, live scanner card, and audit history.
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
  final ScrollController? scrollController;

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
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 36 : 18,
        vertical: isDesktop ? 28 : 20,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StaggeredReveal(
                staggerIndex: 0,
                child: _buildDashboardHeader(context),
              ),
              const SizedBox(height: 20),
              KpiMetricsRow(history: classState.history),
              const SizedBox(height: 22),
              if (classState.errorMessage != null && !isModalEffectivelyOpen)
                DashboardNotificationBanner(
                  message: classState.errorMessage!,
                  isError: true,
                  state: classState,
                  controller: classController,
                  onOpenCropModal: onOpenCropModal,
                ),
              if (classState.successMessage != null)
                DashboardNotificationBanner(
                  message: classState.successMessage!,
                  isError: false,
                  state: classState,
                  controller: classController,
                  onOpenCropModal: onOpenCropModal,
                ),
              if ((classState.errorMessage != null && !isModalEffectivelyOpen) ||
                  classState.successMessage != null)
                const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isTwoCol = constraints.maxWidth >= 820;

                  if (isTwoCol) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: StaggeredReveal(
                            staggerIndex: 5,
                            child: ScannerWorkstationCard(
                              state: classState,
                              controller: classController,
                              isCropModalOpen: isModalEffectivelyOpen,
                              onOpenCropModal: onOpenCropModal,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 5,
                          child: StaggeredReveal(
                            staggerIndex: 6,
                            child: AuditHistoryCard(
                              state: classState,
                              controller: classController,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      StaggeredReveal(
                        staggerIndex: 5,
                        child: ScannerWorkstationCard(
                          state: classState,
                          controller: classController,
                          isCropModalOpen: isModalEffectivelyOpen,
                          onOpenCropModal: onOpenCropModal,
                        ),
                      ),
                      const SizedBox(height: 24),
                      StaggeredReveal(
                        staggerIndex: 6,
                        child: AuditHistoryCard(
                          state: classState,
                          controller: classController,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 36),
              _buildSimpleFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardHeader(BuildContext context) {
    final name = (user?.displayName ?? 'Evaluator').toString().split(' ').first;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;

        final headerInfo = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: onBackHome,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.chevron_left,
                          size: 13,
                          color: Color(0xFF5EEAD4),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Back to Home',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: AppTypography.defaultLetterSpacing,
                            color: Color(0xFF5EEAD4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x2814B8A6),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: const Color(0x402DD4BF),
                      width: 0.8,
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
                          color: Color(0xFF2DD4BF),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isGuestUser
                            ? 'Guest Evaluation Mode'
                            : 'Account Synced',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: AppTypography.defaultLetterSpacing,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Welcome back, $name!',
              style: AppTypography.displayLarge.copyWith(
                color: Colors.white,
                fontSize: isCompact ? 23 : 28,
                fontWeight: FontWeight.w800,
                letterSpacing: AppTypography.defaultLetterSpacing,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Upload a Tilapia photo, frame the eye or exposed gill, and check its freshness in seconds.',
              style: AppTypography.bodyMedium.copyWith(
                color: const Color(0xFFD1FAF4),
                fontSize: 13.5,
                letterSpacing: AppTypography.defaultLetterSpacing,
              ),
            ),
          ],
        );

        final actionsRow = Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildCircularHeaderIconButton(
              icon: CupertinoIcons.question,
              tooltip:
                  'Eye is selected by default. Hover over an uploaded photo for framing guidance.',
              isDark: true,
              onTap: () {},
            ),
            if (isGuestUser)
              OutlinedButton.icon(
                onPressed: onConnectGoogle,
                icon: const Icon(
                  CupertinoIcons.person_badge_plus,
                  size: 15,
                  color: Color(0xFF5EEAD4),
                ),
                label: const Text('Connect with Google'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(
                    color: Color(0x402DD4BF),
                    width: 1.0,
                  ),
                  backgroundColor: const Color(0x2414B8A6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: () => classController.loadHistory(),
                icon: const Icon(
                  CupertinoIcons.refresh,
                  size: 14,
                  color: Color(0xFF5EEAD4),
                ),
                label: const Text('Sync History'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0x402DD4BF), width: 1.0),
                  backgroundColor: const Color(0x2414B8A6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
          ],
        );

        final Widget innerContent;
        if (isCompact) {
          innerContent = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [headerInfo, const SizedBox(height: 12), actionsRow],
          );
        } else {
          innerContent = Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: headerInfo),
              const SizedBox(width: 16),
              actionsRow,
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

  Widget _buildCircularHeaderIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool isDark = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: ClipOval(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Material(
            color: isDark ? const Color(0x24FFFFFF) : const Color(0xD9FFFFFF),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              splashColor: isDark ? const Color(0x2014B8A6) : null,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? const Color(0x33CCEAE6)
                        : const Color(0xFFE2E8F0),
                    width: 1.0,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: isDark ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleFooter() {
    return Center(
      child: Text(
        '© ${DateTime.now().year} SariwaBa — Fish Freshness Classification. All rights reserved.',
        style: const TextStyle(
          fontSize: 12,
          letterSpacing: AppTypography.defaultLetterSpacing,
          color: SariwaColors.textMutedDark,
        ),
      ),
    );
  }
}
