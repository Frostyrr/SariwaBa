import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import '../../../constants/content/workflow_steps_data.dart';
import '../../../constants/theme/app_colors.dart';
import '../../../constants/theme/app_typography.dart';
import '../../../widgets/dashboard/organoleptic_guidelines_dialog.dart';

/// Concise iOS-style grouped How to Scan view without nested checklists or jargon.
class HowItWorksDashboardSection extends StatelessWidget {
  final bool isDesktop;
  final ScrollController? scrollController;
  final VoidCallback? onStartInspection;

  const HowItWorksDashboardSection({
    super.key,
    required this.isDesktop,
    this.scrollController,
    this.onStartInspection,
  });

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = isDesktop ? 32.0 : 16.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        controller: scrollController,
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          isDesktop ? 24 : 56,
          horizontalPadding,
          isDesktop ? 32 : 112,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'How to Scan',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: isDesktop ? 28 : 24,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.5,
                    color: SariwaColors.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Five quick steps for clear eye and gill readings.',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: SariwaColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: 16),

                // Single clean iOS inset-grouped list (zero nested cards)
                Container(
                  decoration: BoxDecoration(
                    color: SariwaColors.cardSurfaceLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: SariwaColors.colorLine),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0;
                          i < WorkflowStepsData.steps.length;
                          i++) ...[
                        _buildStepRow(i + 1, WorkflowStepsData.steps[i]),
                        if (i < WorkflowStepsData.steps.length - 1)
                          const Divider(
                            height: 1,
                            indent: 64,
                            color: SariwaColors.colorLineSubtle,
                          ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Concise 1-line safety note
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: SariwaColors.warningBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SariwaColors.warningBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.info_circle,
                        color: SariwaColors.warningText,
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          WorkflowStepsData.preliminaryDisclaimer,
                          style: const TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: SariwaColors.warningText,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    if (onStartInspection != null)
                      FilledButton.icon(
                        onPressed: onStartInspection,
                        icon: const Icon(CupertinoIcons.camera, size: 16),
                        label: const Text('Start New Inspection'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF111111),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: AppTypography.defaultLetterSpacing,
                          ),
                        ),
                      ),
                    OutlinedButton.icon(
                      onPressed: () =>
                          OrganolepticGuidelinesDialog.show(context),
                      icon: const Icon(
                        CupertinoIcons.checkmark_shield,
                        size: 16,
                      ),
                      label: const Text('Freshness Guide'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: SariwaColors.textPrimaryDark,
                        side: const BorderSide(color: SariwaColors.colorLine),
                        backgroundColor: SariwaColors.cardSurfaceLight,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          letterSpacing: AppTypography.defaultLetterSpacing,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow(int number, WorkflowStepModel step) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: const TextStyle(
                fontFamily: 'Geist Mono',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111111),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                    color: SariwaColors.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.detailedInstruction,
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: SariwaColors.textSecondaryDark,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
