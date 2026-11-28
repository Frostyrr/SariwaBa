import 'dart:ui' as ui;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../../constants/content/workflow_steps_data.dart';
import '../../../constants/theme/app_colors.dart';
import '../../../constants/theme/app_typography.dart';
import '../../../widgets/common/staggered_reveal.dart';

class _WorkflowStepData {
  final String stepNumber;
  final String stepTag;
  final String title;
  final String description;
  final String metaRecord;
  final IconData icon;

  const _WorkflowStepData({
    required this.stepNumber,
    required this.stepTag,
    required this.title,
    required this.description,
    required this.metaRecord,
    required this.icon,
  });
}

/// Vertical Left-Rail "How It Works" Section (Bantai-inspired, lean copy)
/// Continuous left-rail step spine (`01`–`04`) paired with full-width daylight cards.
class HowItWorksSection extends StatelessWidget {
  final VoidCallback? onDownload;
  final VoidCallback? onTryInspection;

  const HowItWorksSection({
    super.key,
    this.onDownload,
    this.onTryInspection,
  });

  static final List<_WorkflowStepData> _steps = WorkflowStepsData.steps
      .take(4)
      .map(
        (s) => _WorkflowStepData(
          stepNumber: s.stepNumber,
          stepTag: s.stepTag,
          title: s.title,
          description: s.summary,
          metaRecord: s.metaRecord,
          icon: s.icon,
        ),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        return Container(
          width: double.infinity,
          color: SariwaColors.colorWorkspace,
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 56.0 : 80.0,
            horizontal: isMobile ? 20.0 : 24.0,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 880.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Semantics(
                    header: true,
                    child: StaggeredReveal(
                      revealOnScroll: true,
                      staggerIndex: 0,
                      child: Text(
                        'Four Simple Steps to Check Freshness',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: isMobile ? 28.0 : 36.0,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.7,
                          height: 1.15,
                          color: SariwaColors.textPrimaryDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  StaggeredReveal(
                    revealOnScroll: true,
                    staggerIndex: 1,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: const Text(
                        'Snap a close-up eye or gill photo and get an instant freshness reading.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          height: 1.5,
                          letterSpacing: -0.15,
                          color: SariwaColors.inkSlateSecondary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 32 : 48),

                  // Vertical Left-Rail Stepper (`01`..`04`)
                  Column(
                    children: List.generate(_steps.length, (index) {
                      final step = _steps[index];
                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _LeftRailNode(
                              stepNumber: step.stepNumber,
                              isFirst: index == 0,
                              isLast: index == _steps.length - 1,
                              isMobile: isMobile,
                            ),
                            SizedBox(width: isMobile ? 16 : 24),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  bottom: index == _steps.length - 1 ? 0 : 20,
                                ),
                                child: StaggeredReveal(
                                  revealOnScroll: true,
                                  staggerIndex: index,
                                  child: _VerticalStepCard(
                                    step: step,
                                    isMobile: isMobile,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LeftRailNode extends StatelessWidget {
  final String stepNumber;
  final bool isFirst;
  final bool isLast;
  final bool isMobile;

  const _LeftRailNode({
    required this.stepNumber,
    required this.isFirst,
    required this.isLast,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final badgeSize = isMobile ? 40.0 : 48.0;

    return SizedBox(
      width: badgeSize,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _RailLinePainter(
                isFirst: isFirst,
                isLast: isLast,
                badgeCenterY: badgeSize / 2,
                color: SariwaColors.colorLine,
              ),
            ),
          ),
          Container(
            width: badgeSize,
            height: badgeSize,
            decoration: BoxDecoration(
              color: SariwaColors.cardSurfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SariwaColors.colorLine),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  stepNumber,
                  style: const TextStyle(
                    fontFamily: 'Geist Mono',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFeatures: [ui.FontFeature.tabularFigures()],
                    color: SariwaColors.brandPrimary,
                  ),
                ),
                if (!isMobile)
                  const Text(
                    'STEP',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.0,
                      color: SariwaColors.inkSlateMuted,
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

class _RailLinePainter extends CustomPainter {
  final bool isFirst;
  final bool isLast;
  final double badgeCenterY;
  final Color color;

  const _RailLinePainter({
    required this.isFirst,
    required this.isLast,
    required this.badgeCenterY,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final startY = isFirst ? badgeCenterY : 0.0;
    final endY = isLast ? badgeCenterY : size.height;

    if (endY > startY) {
      canvas.drawLine(Offset(cx, startY), Offset(cx, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RailLinePainter oldDelegate) {
    return oldDelegate.isFirst != isFirst ||
        oldDelegate.isLast != isLast ||
        oldDelegate.badgeCenterY != badgeCenterY ||
        oldDelegate.color != color;
  }
}

class _VerticalStepCard extends StatelessWidget {
  final _WorkflowStepData step;
  final bool isMobile;

  const _VerticalStepCard({
    required this.step,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: SariwaColors.cardSurfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SariwaColors.colorLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                step.stepTag,
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: SariwaColors.brandPrimary,
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: SariwaColors.colorPale,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  step.icon,
                  size: 16,
                  color: SariwaColors.brandPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            step.title,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.3,
              height: 1.25,
              color: SariwaColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            step.description,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w300,
              height: 1.5,
              color: SariwaColors.inkSlateSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            step.metaRecord,
            style: const TextStyle(
              fontFamily: 'Geist Mono',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: SariwaColors.inkSlateMuted,
            ),
          ),
        ],
      ),
    );
  }
}
