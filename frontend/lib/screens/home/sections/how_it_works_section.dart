import 'dart:ui' as ui;
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import '../../../constants/content/workflow_steps_data.dart';
import '../../../constants/theme/app_colors.dart';
import '../../../constants/theme/timber_typography.dart';
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

/// How It Works & Understanding Results Section
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
            horizontal: isMobile ? 16.0 : 24.0,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040.0),
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
                          fontFamily: TimberTypography.primarySansFamily,
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
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: const Text(
                        'From capturing a close-up to reviewing sensory guidance, verify Tilapia freshness in seconds.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: TimberTypography.primarySansFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          height: 1.5,
                          letterSpacing: -0.15,
                          color: SariwaColors.inkSlateSecondary,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: isMobile ? 36 : 48),

                  _buildTimelineWorkflow(isMobile),

                  SizedBox(height: isMobile ? 40 : 52),

                  StaggeredReveal(
                    revealOnScroll: true,
                    staggerIndex: 1,
                    child: _buildUnderstandingResultsCard(isMobile),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimelineWorkflow(bool isMobile) {
    return Column(
      children: List.generate(_steps.length, (index) {
        final step = _steps[index];
        final isFirst = index == 0;
        final isLast = index == _steps.length - 1;
        final isLeftCard = index.isEven;

        if (isMobile) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TimelineSpineNode(
                  isFirst: isFirst,
                  isLast: isLast,
                  isLeftCard: false,
                  isMobile: true,
                  stepNumber: step.stepNumber,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: StaggeredReveal(
                      revealOnScroll: true,
                      staggerIndex: index + 1,
                      child: _buildEditorialStepCard(
                        isMobile: true,
                        step: step,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: isLeftCard
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: StaggeredReveal(
                          revealOnScroll: true,
                          staggerIndex: index + 1,
                          child: _buildEditorialStepCard(
                            isMobile: false,
                            step: step,
                          ),
                        ),
                      )
                    : const SizedBox.expand(),
              ),
              _TimelineSpineNode(
                isFirst: isFirst,
                isLast: isLast,
                isLeftCard: isLeftCard,
                isMobile: false,
                stepNumber: step.stepNumber,
              ),
              Expanded(
                child: !isLeftCard
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: StaggeredReveal(
                          revealOnScroll: true,
                          staggerIndex: index + 1,
                          child: _buildEditorialStepCard(
                            isMobile: false,
                            step: step,
                          ),
                        ),
                      )
                    : const SizedBox.expand(),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEditorialStepCard({
    required bool isMobile,
    required _WorkflowStepData step,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: SariwaColors.cardSurfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SariwaColors.colorLine,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: SariwaColors.colorPale,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  step.stepTag,
                  style: const TextStyle(
                    fontFamily: TimberTypography.primarySansFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.6,
                    color: SariwaColors.brandPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SariwaColors.colorPale,
                  borderRadius: BorderRadius.circular(8),
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
              fontFamily: TimberTypography.primarySansFamily,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.25,
              height: 1.3,
              color: SariwaColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            step.description,
            style: const TextStyle(
              fontFamily: TimberTypography.primarySansFamily,
              fontSize: 14,
              fontWeight: FontWeight.w300,
              height: 1.48,
              letterSpacing: -0.1,
              color: SariwaColors.inkSlateSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: SariwaColors.brandGlow,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  step.metaRecord,
                  style: const TextStyle(
                    fontFamily: TimberTypography.monospaceFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.3,
                    fontFeatures: [ui.FontFeature.tabularFigures()],
                    color: SariwaColors.inkSlateMuted,
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

  Widget _buildUnderstandingResultsCard(bool isMobile) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgroundBlurred.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: SariwaColors.bgAbyssDark.withValues(alpha: 0.90),
                border: Border.all(
                  color: SariwaColors.borderGlass,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isMobile ? 20 : 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: SariwaColors.surfaceGlass,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: SariwaColors.borderGlass),
                      ),
                      child: const Icon(
                        CupertinoIcons.checkmark_shield,
                        color: SariwaColors.brandLight,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How to Read the Results',
                            style: TextStyle(
                              fontFamily: TimberTypography.primarySansFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.25,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Visual indicators for fresh vs. spoiled Tilapia eyes and gills',
                            style: TextStyle(
                              fontFamily: TimberTypography.primarySansFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              color: SariwaColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 600;

                    final freshCard = Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: SariwaColors.freshIconBgDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: SariwaColors.freshBorderDark),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.checkmark_circle_fill,
                                color: SariwaColors.statusFresh,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Fresh Signs (Sariwa)',
                                style: TextStyle(
                                  fontFamily:
                                      TimberTypography.primarySansFamily,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: SariwaColors.freshBorder,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Clear, rounded eyes with dark pupils, and bright red or crimson gills with clear mucus and no sour odor.',
                            style: TextStyle(
                              fontFamily: TimberTypography.primarySansFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              height: 1.45,
                              color: SariwaColors.colorPale,
                            ),
                          ),
                        ],
                      ),
                    );

                    final notFreshCard = Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: SariwaColors.notFreshIconBgDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: SariwaColors.notFreshBorderDark,
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.exclamationmark_triangle_fill,
                                color: SariwaColors.notFreshPrimaryDark,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Not Fresh Signs (Hindi Sariwa)',
                                style: TextStyle(
                                  fontFamily:
                                      TimberTypography.primarySansFamily,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: SariwaColors.notFreshTextDark,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Cloudy, milky, or sunken eyes, along with pale, grey, or brownish gills that may carry sticky slime or sour odor.',
                            style: TextStyle(
                              fontFamily: TimberTypography.primarySansFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              height: 1.45,
                              color: SariwaColors.colorPale,
                            ),
                          ),
                        ],
                      ),
                    );

                    if (isWide) {
                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: freshCard),
                            const SizedBox(width: 16),
                            Expanded(child: notFreshCard),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        freshCard,
                        const SizedBox(height: 12),
                        notFreshCard,
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: SariwaColors.bgLagoonMid.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SariwaColors.borderGlass),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        CupertinoIcons.info_circle,
                        color: SariwaColors.brandLight,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Confidence scores reflect how clearly the classifier recognizes visual freshness cues from your photo. Always pair visual readings with sensory smell and texture checks; image models cannot detect bacteria or storage history.',
                          style: TextStyle(
                            fontFamily: TimberTypography.primarySansFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            height: 1.45,
                            color: SariwaColors.textSecondaryLight,
                          ),
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
}

class _TimelineSpineNode extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final bool isLeftCard;
  final bool isMobile;
  final String stepNumber;

  const _TimelineSpineNode({
    required this.isFirst,
    required this.isLast,
    required this.isLeftCard,
    required this.isMobile,
    required this.stepNumber,
  });

  @override
  Widget build(BuildContext context) {
    final spineWidth = isMobile ? 40.0 : 64.0;
    final nodeSize = isMobile ? 32.0 : 36.0;

    return SizedBox(
      width: spineWidth,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _TimelineSpinePainter(
                isFirst: isFirst,
                isLast: isLast,
                isLeftCard: isLeftCard,
                isMobile: isMobile,
                nodeSize: nodeSize,
                lineColor: SariwaColors.brandGlow.withValues(alpha: 0.35),
                accentColor: SariwaColors.brandPrimary,
              ),
            ),
          ),
          Container(
            width: nodeSize,
            height: nodeSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SariwaColors.cardSurfaceLight,
              border: Border.all(
                color: SariwaColors.brandPrimary,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              stepNumber,
              style: const TextStyle(
                fontFamily: TimberTypography.primarySansFamily,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFeatures: [ui.FontFeature.tabularFigures()],
                color: SariwaColors.brandPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineSpinePainter extends CustomPainter {
  final bool isFirst;
  final bool isLast;
  final bool isLeftCard;
  final bool isMobile;
  final double nodeSize;
  final Color lineColor;
  final Color accentColor;

  _TimelineSpinePainter({
    required this.isFirst,
    required this.isLast,
    required this.isLeftCard,
    required this.isMobile,
    required this.nodeSize,
    required this.lineColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final spinePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final startY = isFirst ? centerY : 0.0;
    final endY = isLast ? centerY : size.height;
    canvas.drawLine(
      Offset(centerX, startY),
      Offset(centerX, endY),
      spinePaint,
    );

    if (isMobile) {
      canvas.drawLine(
        Offset(centerX + nodeSize / 2, centerY),
        Offset(size.width, centerY),
        spinePaint,
      );
    } else if (isLeftCard) {
      canvas.drawLine(
        Offset(0.0, centerY),
        Offset(centerX - nodeSize / 2, centerY),
        spinePaint,
      );
    } else {
      canvas.drawLine(
        Offset(centerX + nodeSize / 2, centerY),
        Offset(size.width, centerY),
        spinePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TimelineSpinePainter oldDelegate) {
    return oldDelegate.isFirst != isFirst ||
        oldDelegate.isLast != isLast ||
        oldDelegate.isLeftCard != isLeftCard ||
        oldDelegate.isMobile != isMobile ||
        oldDelegate.nodeSize != nodeSize ||
        oldDelegate.lineColor != lineColor;
  }
}
