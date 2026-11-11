import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../constants/content/workflow_steps_data.dart';
import '../../../constants/theme/app_colors.dart';
import '../../../constants/theme/app_typography.dart';
import '../../../widgets/dashboard/frosted_glass_card.dart';

/// Dedicated dashboard instructional page explaining the end-to-end
/// fish freshness evaluation workflow, deriving from shared WorkflowStepsData.
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
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 24,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Section Header
                _buildSectionHeader(),

                const SizedBox(height: 20),

                // Critical Food Safety & AI Disclaimer
                _buildDisclaimerBanner(),

                const SizedBox(height: 24),

                // 5 Detailed Step Cards
                for (final step in WorkflowStepsData.steps) ...[
                  _buildStepCard(step),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 12),

                // Practical Capture Best Practices Card
                _buildCaptureTipsCard(),

                const SizedBox(height: 32),

                // CTA to Start Inspection
                if (onStartInspection != null)
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: onStartInspection,
                      icon: const Icon(CupertinoIcons.camera, size: 16),
                      label: const Text(
                        'Start New Inspection',
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontWeight: FontWeight.w500,
                          letterSpacing: AppTypography.defaultLetterSpacing,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: SariwaColors.brandPrimary,
                        side: const BorderSide(color: SariwaColors.brandPrimary),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: SariwaColors.brandPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: SariwaColors.brandPrimary.withValues(alpha: 0.2),
                ),
              ),
              child: const Text(
                'GUIDE & PROTOCOL',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: SariwaColors.brandPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'How SariwaBa? Works',
          style: TextStyle(
            fontFamily: 'Geist',
            fontSize: 26,
            fontWeight: FontWeight.w600,
            letterSpacing: AppTypography.defaultLetterSpacing,
            color: SariwaColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'A task-oriented breakdown of image capture, region selection, MobileNetV3 inference, and organoleptic validation.',
          style: TextStyle(
            fontFamily: 'Geist',
            fontSize: 14,
            fontWeight: FontWeight.w300,
            letterSpacing: AppTypography.defaultLetterSpacing,
            color: SariwaColors.textSecondaryDark,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimerBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB), // amber 50
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFDE68A), // amber 200
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_shield,
            color: Color(0xFFD97706),
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Food Safety & Preliminary Assessment Notice',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  WorkflowStepsData.preliminaryDisclaimer,
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFB45309),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(WorkflowStepModel step) {
    return FrostedGlassCard(
      padding: const EdgeInsets.all(22),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Tag & Meta Record
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: SariwaColors.brandPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  step.icon,
                  size: 18,
                  color: SariwaColors.brandPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.stepTag,
                      style: const TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.7,
                        color: SariwaColors.brandPrimary,
                      ),
                    ),
                    Text(
                      step.title,
                      style: const TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 16.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: AppTypography.defaultLetterSpacing,
                        color: SariwaColors.textPrimaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  step.metaRecord,
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Detailed Instruction
          Text(
            step.detailedInstruction,
            style: const TextStyle(
              fontFamily: 'Geist',
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
              letterSpacing: AppTypography.defaultLetterSpacing,
              color: SariwaColors.textSecondaryDark,
              height: 1.5,
            ),
          ),

          if (step.practicalTips.isNotEmpty) ...[
            const SizedBox(height: 14),
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
                  const Text(
                    'PRACTICAL RECOMMENDATIONS',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final tip in step.practicalTips) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            CupertinoIcons.checkmark_alt,
                            size: 14,
                            color: Color(0xFF10B981),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tip,
                              style: const TextStyle(
                                fontFamily: 'Geist',
                                fontSize: 12.5,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF334155),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCaptureTipsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                CupertinoIcons.sparkles,
                size: 18,
                color: SariwaColors.brandPrimary,
              ),
              SizedBox(width: 10),
              Text(
                'Golden Rules for Accurate Freshness Evaluation',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: SariwaColors.textPrimaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _TipItem(
                  title: 'Diffused Lighting',
                  description:
                      'Use bright, natural daylight or clean white market stalls. Avoid direct camera flash, which bleaches eye corneas.',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _TipItem(
                  title: 'Tight Framing',
                  description:
                      'Center the eye or lifted gill cover in the camera viewfinder. The feature should occupy at least 40% of the frame.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _TipItem(
                  title: 'Perpendicular Angle',
                  description:
                      'Hold your phone at a 90° angle to the fish head to prevent optical distortion and perspective tilt.',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _TipItem(
                  title: 'Sharp Focus',
                  description:
                      'Tap your screen on the fish eye or gill filament before capturing to ensure pin-sharp micro-contrast.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final String title;
  final String description;

  const _TipItem({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Geist',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(
            fontFamily: 'Geist',
            fontSize: 12,
            fontWeight: FontWeight.w300,
            color: Color(0xFF64748B),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
