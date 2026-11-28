import 'dart:ui' as ui;
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import '../../constants/config/app_breakpoints.dart';
import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';
import '../common/sariwa_scrollbar.dart';

/// Concise, plain-English Freshness Guide sheet/dialog without regulatory jargon.
class OrganolepticGuidelinesDialog extends StatelessWidget {
  final bool asBottomSheet;

  const OrganolepticGuidelinesDialog({
    super.key,
    this.asBottomSheet = false,
  });

  static Future<void> show(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(MediaQuery.of(context).size.width);
    if (isMobile) {
      return showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        backgroundColor: SariwaColors.cardSurfaceLight,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => const OrganolepticGuidelinesDialog(
          asBottomSheet: true,
        ),
      );
    }
    return showDialog<void>(
      context: context,
      barrierColor: SariwaColors.bgAbyssDark.withValues(alpha: 0.45),
      builder: (context) => const OrganolepticGuidelinesDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = ClipRRect(
      borderRadius: asBottomSheet
          ? const BorderRadius.vertical(top: Radius.circular(20))
          : BorderRadius.circular(20),
      child: ColoredBox(
        color: SariwaColors.cardSurfaceLight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(
                20,
                asBottomSheet ? 4 : 20,
                16,
                16,
              ),
              decoration: const BoxDecoration(
                color: SariwaColors.cardSurfaceLight,
                border: Border(
                  bottom: BorderSide(color: SariwaColors.colorLine, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      CupertinoIcons.checkmark_shield,
                      color: Color(0xFF111111),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Freshness Guide',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.4,
                            color: SariwaColors.textPrimaryDark,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'What to check in person alongside your scan.',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            color: SariwaColors.colorMutedInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    icon: const Icon(
                      CupertinoIcons.xmark,
                      color: SariwaColors.inkSlateSecondary,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ColoredBox(
                color: SariwaColors.colorSurface,
                child: SariwaScrollbar(
                  builder: (context, controller) => SingleChildScrollView(
                    controller: controller,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildGuidelineCard(
                          title: 'Eyes',
                          freshDesc: 'Clear, bright, and slightly rounded.',
                          spoiledDesc: 'Cloudy, sunken, or dull grey.',
                          icon: CupertinoIcons.eye,
                        ),
                        const SizedBox(height: 12),
                        _buildGuidelineCard(
                          title: 'Gills',
                          freshDesc: 'Bright red and clean.',
                          spoiledDesc: 'Faded brown or grey with thick slime.',
                          icon: CupertinoIcons.drop,
                        ),
                        const SizedBox(height: 12),
                        _buildGuidelineCard(
                          title: 'Skin & Scales',
                          freshDesc: 'Shiny scales that stay firm.',
                          spoiledDesc: 'Dull skin with loose scales.',
                          icon: CupertinoIcons.sparkles,
                        ),
                        const SizedBox(height: 12),
                        _buildGuidelineCard(
                          title: 'Firmness & Smell',
                          freshDesc:
                              'Springs back when pressed; clean, mild smell.',
                          spoiledDesc: 'Finger dents stay; sour or sharp odor.',
                          icon: CupertinoIcons.hand_draw,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: SariwaColors.cardSurfaceLight,
                border: Border(
                  top: BorderSide(color: SariwaColors.colorLine, width: 1),
                ),
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF111111),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (asBottomSheet) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: content,
      );
    }

    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Container(
            decoration: BoxDecoration(
              color: SariwaColors.cardSurfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: SariwaColors.colorLine, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: SariwaColors.shadowSubtle,
                  blurRadius: 24,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: content,
          ),
        ),
      ),
    );
  }

  Widget _buildGuidelineCard({
    required String title,
    required String freshDesc,
    required String spoiledDesc,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 15, color: const Color(0xFF111111)),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  color: Color(0xFF111111),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isSideBySide = constraints.maxWidth >= 440;
              final freshBox = _buildComparisonColumn(
                label: 'Fresh',
                description: freshDesc,
                dotColor: SariwaColors.brandPrimary,
              );
              final spoiledBox = _buildComparisonColumn(
                label: 'Not Fresh',
                description: spoiledDesc,
                dotColor: const Color(0xFFDC2626),
              );

              if (isSideBySide) {
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: freshBox),
                      const VerticalDivider(
                        width: 24,
                        thickness: 1,
                        color: Color(0xFFE5E5E7),
                      ),
                      Expanded(child: spoiledBox),
                    ],
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  freshBox,
                  const Divider(height: 20, color: Color(0xFFE5E5E7)),
                  spoiledBox,
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonColumn({
    required String label,
    required String description,
    required Color dotColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111111),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 1.45,
            color: Color(0xFF525252),
          ),
        ),
      ],
    );
  }
}
