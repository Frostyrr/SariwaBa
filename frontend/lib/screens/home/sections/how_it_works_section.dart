import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '../../../constants/content/workflow_steps_data.dart';
import '../../../constants/theme/app_typography.dart';
import '../../../widgets/common/blur_fade.dart';

class _WorkflowStepData {
  final String stepNumber;
  final String title;
  final String description;
  final IconData icon;

  const _WorkflowStepData({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.icon,
  });
}

/// Monochrome-first 4-Column "How It Works" Section
/// - Desktop (`>= 1024px`): 4-column horizontal grid (gap 20)
/// - Tablet (`>= 640px`): 2x2 grid
/// - Mobile (`< 640px`): clean vertical stack
/// Single clean step badge (`01`–`04`), icon, title, and concise description.
class HowItWorksSection extends StatelessWidget {
  final VoidCallback? onDownload;
  final VoidCallback? onTryInspection;

  const HowItWorksSection({
    super.key,
    this.onDownload,
    this.onTryInspection,
  });

  static const Color _canvasColor = Color(0xFFF5F5F7);
  static const Color _inkPrimary = Color(0xFF111111);
  static const Color _inkMuted = Color(0xFF737373);
  static const Color _hairline = Color(0x0D171717);
  static const Color _badgeBg = Color(0xFFF5F5F5);
  static const Color _badgeText = Color(0xFF404040);

  static final List<_WorkflowStepData> _steps = WorkflowStepsData.steps
      .take(4)
      .map(
        (s) => _WorkflowStepData(
          stepNumber: s.stepNumber,
          title: s.title,
          description: s.summary,
          icon: s.icon,
        ),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final isMobile = maxW < 640;
        final isDesktop = maxW >= 1024;

        return Container(
          width: double.infinity,
          color: _canvasColor,
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 56.0 : 80.0,
            horizontal: 24.0,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BlurFade(
                    triggerOnVisible: true,
                    delay: Duration.zero,
                    child: Column(
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            'Four Simple Steps to Check Freshness',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: isMobile ? 28.0 : 36.0,
                              fontWeight: FontWeight.w700,
                              letterSpacing: isMobile ? -0.7 : -0.9,
                              height: 1.15,
                              color: _inkPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: const Text(
                            'Snap a close-up eye or gill photo and get an instant freshness reading.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.6,
                              color: _inkMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isMobile ? 32 : 48),

                  _buildResponsiveGrid(
                    isDesktop: isDesktop,
                    isMobile: isMobile,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResponsiveGrid({
    required bool isDesktop,
    required bool isMobile,
  }) {
    const gap = 20.0;

    if (isDesktop) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < _steps.length; i++) ...[
              Expanded(
                child: BlurFade(
                  triggerOnVisible: true,
                  delay: Duration(milliseconds: 60 * i),
                  child: _StepGridCard(step: _steps[i]),
                ),
              ),
              if (i < _steps.length - 1) const SizedBox(width: gap),
            ],
          ],
        ),
      );
    }

    if (!isMobile) {
      return Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: BlurFade(
                    triggerOnVisible: true,
                    delay: Duration.zero,
                    child: _StepGridCard(step: _steps[0]),
                  ),
                ),
                const SizedBox(width: gap),
                Expanded(
                  child: BlurFade(
                    triggerOnVisible: true,
                    delay: const Duration(milliseconds: 60),
                    child: _StepGridCard(step: _steps[1]),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: gap),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: BlurFade(
                    triggerOnVisible: true,
                    delay: const Duration(milliseconds: 120),
                    child: _StepGridCard(step: _steps[2]),
                  ),
                ),
                const SizedBox(width: gap),
                Expanded(
                  child: BlurFade(
                    triggerOnVisible: true,
                    delay: const Duration(milliseconds: 180),
                    child: _StepGridCard(step: _steps[3]),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < _steps.length; i++) ...[
          BlurFade(
            triggerOnVisible: true,
            delay: Duration(milliseconds: 60 * i),
            child: _StepGridCard(step: _steps[i]),
          ),
          if (i < _steps.length - 1) const SizedBox(height: gap),
        ],
      ],
    );
  }
}

class _StepGridCard extends StatelessWidget {
  final _WorkflowStepData step;

  const _StepGridCard({required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: HowItWorksSection._hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: HowItWorksSection._badgeBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  step.stepNumber,
                  style: const TextStyle(
                    fontFamily: 'Geist Mono',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFeatures: [ui.FontFeature.tabularFigures()],
                    color: HowItWorksSection._badgeText,
                  ),
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: HowItWorksSection._badgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  step.icon,
                  size: 16,
                  color: HowItWorksSection._inkPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            step.title,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.16,
              height: 1.3,
              color: HowItWorksSection._inkPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            step.description,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.55,
              color: HowItWorksSection._inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}
