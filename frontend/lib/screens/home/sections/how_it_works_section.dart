import 'dart:ui' as ui;
import 'package:flutter/material.dart';
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
///
/// Features a vertical step-by-step alternating timeline connected by a continuous
/// line from start to finish. Typography strictly adheres to Timber UI:
/// lighter restrained weights (400/500, no heavy bold), optical tracking,
/// tabular numbers, and high-contrast WCAG AAA inks.
class HowItWorksSection extends StatelessWidget {
  final VoidCallback? onDownload;
  final VoidCallback? onTryInspection;

  const HowItWorksSection({
    super.key,
    this.onDownload,
    this.onTryInspection,
  });

  static const List<_WorkflowStepData> _steps = [
    _WorkflowStepData(
      stepNumber: '01',
      stepTag: 'STEP 01 — TAKE A PHOTO',
      title: 'Take or Upload a Fish Photo',
      description:
          'Take a clear, focused photo of your Tilapia in good lighting, or choose an existing photo (up to 5 MB) from your device.',
      metaRecord: 'CLEAR PHOTO • UP TO 5 MB',
      icon: Icons.camera_alt_outlined,
    ),
    _WorkflowStepData(
      stepNumber: '02',
      stepTag: 'STEP 02 — CHOOSE PART',
      title: 'Select Eye or Gills',
      description:
          'Choose whether you want to inspect the fish eye (Mata) or the gills (Hasang). Focusing on one specific part gives you the most reliable check.',
      metaRecord: 'EYE (MATA) • GILLS (HASANG)',
      icon: Icons.crop_free_rounded,
    ),
    _WorkflowStepData(
      stepNumber: '03',
      stepTag: 'STEP 03 — SMART SCAN',
      title: 'Scan Freshness with AI',
      description:
          'Our smart AI examines key freshness signs in seconds—checking color vibrancy, clarity, and texture to see if the fish is fresh.',
      metaRecord: 'INSTANT SCAN • COLOR & CLARITY',
      icon: Icons.auto_awesome_outlined,
    ),
    _WorkflowStepData(
      stepNumber: '04',
      stepTag: 'STEP 04 — RESULTS',
      title: 'See Results & Helpful Tips',
      description:
          'Get a clear Fresh or Not Fresh verdict along with a confidence rating and practical advice on what to look for when buying.',
      metaRecord: 'CONFIDENCE SCORE • BUYER TIPS',
      icon: Icons.task_alt_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        return Container(
          width: double.infinity,
          color: const Color(0xFFF0F7F6), // Consistent off-white leaning primary teal
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 56.0 : 84.0,
            horizontal: isMobile ? 18.0 : 24.0,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Eyebrow Badge (Centered Frosted Pill, Timber Typography: w500, +0.08em tracking)
                  StaggeredReveal(
                    revealOnScroll: true,
                    staggerIndex: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2F3F0),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFBBE5DF),
                          width: 1.0,
                        ),
                      ),
                      child: const Text(
                        'HOW IT WORKS',
                        style: TextStyle(
                          fontFamily: TimberTypography.primarySansFamily,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500, // Medium
                          letterSpacing: 0.8, // +0.08em tracking
                          color: Color(0xFF0F766E),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Section Title (Timber Typography: w500, tight -0.03em tracking, Timber Ink #18221D)
                  StaggeredReveal(
                    revealOnScroll: true,
                    staggerIndex: 1,
                    child: Text(
                      'Four Simple Steps to Check Freshness',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: TimberTypography.primarySansFamily,
                        fontSize: isMobile ? 26.0 : 34.0,
                        fontWeight: FontWeight.w500, // Medium for headers/titles
                        letterSpacing: -0.84, // -0.03em tracking
                        height: 1.2,
                        color: const Color(0xFF18221D),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Section Subtitle (Timber Typography: w400, Timber Secondary Ink #66736B)
                  StaggeredReveal(
                    revealOnScroll: true,
                    staggerIndex: 2,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: const Text(
                        'From snapping a photo to getting instant results, check Tilapia freshness in seconds with clear, smart AI.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: TimberTypography.primarySansFamily,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w300, // Lighter for body copy
                          height: 1.48,
                          letterSpacing: -0.13,
                          color: Color(0xFF66736B),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: isMobile ? 36 : 48),

                  // Continuous Vertical Timeline (Alternating on Desktop, Left-Spine on Mobile)
                  _buildTimelineWorkflow(isMobile),

                  SizedBox(height: isMobile ? 40 : 54),

                  // --- Section: Understanding the Results (Atmospheric Aquatic CTA Styling) ---
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

  /// Builds the vertical timeline workflow.
  /// On Desktop: cards alternate Left and Right with a continuous central vertical line.
  /// On Mobile: cards are arranged along a left vertical spine line.
  Widget _buildTimelineWorkflow(bool isMobile) {
    return Column(
      children: List.generate(_steps.length, (index) {
        final step = _steps[index];
        final isFirst = index == 0;
        final isLast = index == _steps.length - 1;
        final isLeftCard = index.isEven; // 0, 2 are Left; 1, 3 are Right

        if (isMobile) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left spine with continuous line and node
                _TimelineSpineNode(
                  isFirst: isFirst,
                  isLast: isLast,
                  isLeftCard: false,
                  isMobile: true,
                  stepNumber: step.stepNumber,
                ),

                const SizedBox(width: 12),

                // Card on the right
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

        // Desktop: Alternating Left / Right
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Column (Card if even, empty spacer if odd)
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

              // Center Spine with node and continuous line
              _TimelineSpineNode(
                isFirst: isFirst,
                isLast: isLast,
                isLeftCard: isLeftCard,
                isMobile: false,
                stepNumber: step.stepNumber,
              ),

              // Right Column (Empty spacer if even, Card if odd)
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

  /// Individual Step Card following Timber UI Typography
  Widget _buildEditorialStepCard({
    required bool isMobile,
    required _WorkflowStepData step,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A), // 4% contact shadow
            blurRadius: 18,
            offset: Offset(0, 4),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Color(0x060F172A), // 2.5% ambient elevation
            blurRadius: 32,
            offset: Offset(0, 10),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Color(0x0814B8A6), // 3% subtle teal sheen
            blurRadius: 24,
            offset: Offset(0, 6),
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 22,
              vertical: isMobile ? 16 : 20,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.90),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFDDE3DE), // Timber clean border
                width: 1.0,
              ),
            ),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Row: Tag + Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F6F4),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFFBBE5DF),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      step.stepTag,
                      style: const TextStyle(
                        fontFamily: TimberTypography.primarySansFamily,
                        fontSize: 10.0,
                        fontWeight: FontWeight.w500, // Medium
                        letterSpacing: 0.8, // +0.08em tracking
                        color: Color(0xFF0F766E),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F6F4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFBBE5DF),
                        width: 0.8,
                      ),
                    ),
                    child: Icon(
                      step.icon,
                      size: 15,
                      color: const Color(0xFF0F766E),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Title: Lighter font (w500), -0.02em tracking, Timber Ink
              Text(
                step.title,
                style: TextStyle(
                  fontFamily: TimberTypography.primarySansFamily,
                  fontSize: isMobile ? 15.5 : 17.0,
                  fontWeight: FontWeight.w500, // Medium for titles
                  letterSpacing: -0.34, // -0.02em tracking
                  height: 1.25,
                  color: const Color(0xFF18221D), // Timber Primary Ink
                ),
              ),

              const SizedBox(height: 6),

              // Description: w400, comfortable leading, Timber secondary ink
              Text(
                step.description,
                style: TextStyle(
                  fontFamily: TimberTypography.primarySansFamily,
                  fontSize: isMobile ? 12.5 : 13.5,
                  fontWeight: FontWeight.w300, // Lighter for body text
                  height: 1.48,
                  letterSpacing: -0.1,
                  color: const Color(0xFF66736B), // Timber Secondary Ink
                ),
              ),

              const SizedBox(height: 14),

              // Meta Record at Bottom: Monospace tabular numbers, w500, Timber tertiary ink
              Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF14B8A6),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      step.metaRecord,
                      style: const TextStyle(
                        fontFamily: TimberTypography.monospaceFamily,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500, // Medium
                        letterSpacing: 0.4,
                        fontFeatures: [ui.FontFeature.tabularFigures()],
                        color: Color(0xFF88968D), // Timber Tertiary Ink
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  /// Section: Understanding the Results & Scientific Disclaimer Card
  /// Layered with assets/images/backgroundBlurred.jpg and deep abyss gradient overlay (same as CTA)
  Widget _buildUnderstandingResultsCard(bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x280A2229),
            blurRadius: 36,
            offset: Offset(0, 16),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Color(0x1814B8A6),
            blurRadius: 44,
            offset: Offset(0, 20),
            spreadRadius: -6,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Layer 1: Blurred Underwater Aquatic Backdrop (same as CTA)
            Positioned.fill(
              child: Image.asset(
                'assets/images/backgroundBlurred.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),

            // Layer 2: Deep Abyss Gradient Overlay (ensures high contrast & legibility)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      SariwaColors.bgAbyssDark.withValues(alpha: 0.88),
                      const Color(0xFF0D2F38).withValues(alpha: 0.82),
                      SariwaColors.bgAbyssDark.withValues(alpha: 0.92),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0x28CCEAE6),
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),

            // Layer 3: Ambient Radial Glow Flare in top-right corner
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 240,
                height: 240,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0x3514B8A6),
                      Color(0x0E2DD4BF),
                      Color(0x002DD4BF),
                    ],
                    stops: [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),

            // Layer 4: Foreground Content with Timber typography
            Padding(
              padding: EdgeInsets.all(isMobile ? 18 : 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0x2414B8A6),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0x402DD4BF),
                            width: 1.0,
                          ),
                        ),
                        child: const Icon(
                          Icons.psychology_outlined,
                          color: Color(0xFF5EEAD4),
                          size: 19,
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
                                fontSize: 18,
                                fontWeight: FontWeight.w500, // Medium for titles
                                letterSpacing: -0.3,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'What fresh eyes and gills look like in Tilapia',
                              style: TextStyle(
                                fontFamily: TimberTypography.primarySansFamily,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w300, // Lighter for body
                                letterSpacing: -0.1,
                                color: Color(0xFFD1FAF4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Two-column explanation: Fresh vs Not Fresh
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 600;

                      final freshCard = Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0x1810B981),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0x3334D399),
                            width: 1.0,
                          ),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF34D399),
                                  size: 16,
                                ),
                                SizedBox(width: 7),
                                Text(
                                  'Fresh Signs (Sariwa)',
                                  style: TextStyle(
                                    fontFamily: TimberTypography.primarySansFamily,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500, // Medium for titles
                                    letterSpacing: -0.2,
                                    color: Color(0xFF6EE7B7),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Clear, rounded eyes with dark pupils, and bright red or pink gills with no dull slime or bad odor.',
                              style: TextStyle(
                                fontFamily: TimberTypography.primarySansFamily,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w300, // Lighter for body
                                height: 1.45,
                                letterSpacing: -0.1,
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                          ],
                        ),
                      );

                      final notFreshCard = Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0x18EF4444),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0x33F87171),
                            width: 1.0,
                          ),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Color(0xFFFB7185),
                                  size: 16,
                                ),
                                SizedBox(width: 7),
                                Text(
                                  'Not Fresh Signs (Hindi Sariwa)',
                                  style: TextStyle(
                                    fontFamily: TimberTypography.primarySansFamily,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500, // Medium for titles
                                    letterSpacing: -0.2,
                                    color: Color(0xFFFCA5A5),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Cloudy, milky, or sunken eyes, along with pale, gray, or brownish gills that may have a sour smell.',
                              style: TextStyle(
                                fontFamily: TimberTypography.primarySansFamily,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w300, // Lighter for body
                                height: 1.45,
                                letterSpacing: -0.1,
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: freshCard),
                            const SizedBox(width: 14),
                            Expanded(child: notFreshCard),
                          ],
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

                  // Clarification on Model Confidence vs Food Safety
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x14FFFFFF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0x22FFFFFF),
                        width: 1.0,
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFF5EEAD4),
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'A Note on Confidence Scores: The confidence score shows how clearly the AI recognizes visual freshness signs from your photo. It serves as a helpful visual guide for buyers and sellers, not a laboratory test. It cannot detect invisible bacteria, chemical residues, or past improper storage temperatures.',
                            style: TextStyle(
                              fontFamily: TimberTypography.primarySansFamily,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w300, // Lighter for body
                              height: 1.45,
                              letterSpacing: -0.1,
                              color: Color(0xFFCBD5E1),
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
      ),
    );
  }
}

/// Spine node widget that houses the continuous vertical timeline line,
/// the horizontal card connector line, and the central tabular step number node.
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
    final spineWidth = isMobile ? 38.0 : 64.0;
    final nodeSize = isMobile ? 32.0 : 38.0;

    return SizedBox(
      width: spineWidth,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Continuous vertical line and horizontal connector line painter
          Positioned.fill(
            child: CustomPaint(
              painter: _TimelineSpinePainter(
                isFirst: isFirst,
                isLast: isLast,
                isLeftCard: isLeftCard,
                isMobile: isMobile,
                nodeSize: nodeSize,
                lineColor: const Color(0xFF14B8A6).withValues(alpha: 0.38),
                accentColor: SariwaColors.brandPrimary,
              ),
            ),
          ),

          // Central circular Node Badge with Tabular Step Number (Timber typography: w500, tabular-nums)
          Container(
            width: nodeSize,
            height: nodeSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFF14B8A6),
                width: 1.6,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1814B8A6),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
                BoxShadow(
                  color: Color(0x0A0F172A),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              stepNumber,
              style: TextStyle(
                fontFamily: TimberTypography.primarySansFamily,
                fontSize: isMobile ? 11.0 : 12.5,
                fontWeight: FontWeight.w500, // Medium
                letterSpacing: 0.0,
                fontFeatures: const [ui.FontFeature.tabularFigures()],
                color: const Color(0xFF0F766E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter that draws the continuous vertical timeline line and the horizontal connector line.
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
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // 1. Draw Vertical Spine Line
    final startY = isFirst ? centerY : 0.0;
    final endY = isLast ? centerY : size.height;
    canvas.drawLine(
      Offset(centerX, startY),
      Offset(centerX, endY),
      spinePaint,
    );

    // 2. Draw Horizontal Connector Line to Card
    final connectorPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (isMobile) {
      canvas.drawLine(
        Offset(centerX + nodeSize / 2, centerY),
        Offset(size.width, centerY),
        connectorPaint,
      );
    } else {
      if (isLeftCard) {
        canvas.drawLine(
          Offset(0.0, centerY),
          Offset(centerX - nodeSize / 2, centerY),
          connectorPaint,
        );
      } else {
        canvas.drawLine(
          Offset(centerX + nodeSize / 2, centerY),
          Offset(size.width, centerY),
          connectorPaint,
        );
      }
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
