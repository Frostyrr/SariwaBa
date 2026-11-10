import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../constants/theme/app_colors.dart';
import '../../../constants/theme/app_typography.dart';
import '../../../widgets/common/staggered_reveal.dart';

/// How It Works & Understanding Results Section
/// Presents the 4-step workflow, transparency around classification labels,
/// model confidence interpretation, and the final call-to-action.
class HowItWorksSection extends StatelessWidget {
  final VoidCallback? onDownload;
  final VoidCallback? onTryInspection;

  const HowItWorksSection({
    super.key,
    this.onDownload,
    this.onTryInspection,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final headlineFontSize = isMobile ? 32.0 : 46.0;

        return Container(
          width: double.infinity,
          color: const Color(0xFFFAF9F6), // Warm ivory / coastal clean canvas
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 64.0 : 96.0,
            horizontal: isMobile ? 20.0 : 36.0,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Eyebrow Tag: DISCIPLINE (Editorial Accent)
                  StaggeredReveal(
                    revealOnScroll: true,
                    staggerIndex: 0,
                    child: const Text(
                      'DISCIPLINE',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.4,
                        color: Color(0xFF0D9488),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Headline: Serious About Freshness, No Guesswork.
                  StaggeredReveal(
                    revealOnScroll: true,
                    staggerIndex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Serious About Freshness,',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: headlineFontSize,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.0,
                            height: 1.15,
                            color: const Color(0xFF0A2229),
                          ),
                        ),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'No ',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: headlineFontSize,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.0,
                                height: 1.15,
                                color: const Color(0xFF0A2229),
                              ),
                            ),
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Color(0xFF0D9488), // Coastal teal
                                  Color(0xFF0284C7), // Vibrant marine cyan
                                ],
                              ).createShader(bounds),
                              child: Text(
                                'Guesswork.',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: headlineFontSize,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1.0,
                                  height: 1.15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isMobile ? 40 : 64),

                  // 4 Discipline Practice Step Cards
                  StaggeredReveal(
                    revealOnScroll: true,
                    staggerIndex: 1,
                    child: _buildEditorialStep(
                      isMobile: isMobile,
                      stepNumber: '01',
                      stepTag: 'PRACTICE 01 — CAPTURE',
                      title: 'Begin With the Specimen',
                      description:
                          'Capture a sharp, well-lit photograph under natural or balanced illumination, or upload an uncompressed image up to 5 MB. Optical fidelity ensures our convolutional layers receive true chromatic and structural data.',
                      metaRecord: 'ANATOMICAL_SPECIMEN • RAW_INGESTION',
                    ),
                  ),

                  SizedBox(height: isMobile ? 24 : 36),

                  StaggeredReveal(
                    revealOnScroll: true,
                    staggerIndex: 2,
                    child: _buildEditorialStep(
                      isMobile: isMobile,
                      stepNumber: '02',
                      stepTag: 'PRACTICE 02 — ISOLATE',
                      title: 'Isolate Key Biomarkers',
                      description:
                          'Focus directly on physiological decay indicators: ocular corneal clarity (Eye) or exposed gill arch vascularization (Hasang). Isolating the region of interest eliminates background noise and grounds predictions in anatomy.',
                      metaRecord: 'REGION_OF_INTEREST • ANATOMICAL_MASK',
                    ),
                  ),

                  SizedBox(height: isMobile ? 24 : 36),

                  StaggeredReveal(
                    revealOnScroll: true,
                    staggerIndex: 3,
                    child: _buildEditorialStep(
                      isMobile: isMobile,
                      stepNumber: '03',
                      stepTag: 'PRACTICE 03 — INFER',
                      title: 'Hold Objective Standards',
                      description:
                          'Our dual-model pipeline evaluates corneal opacity, pupil definition, and gill filament discoloration. Every feature map is verified against strict confidence thresholds before an assessment is computed.',
                      metaRecord: 'DEEP_CONVNET • MULTI_FEATURE_EXTRACTION',
                    ),
                  ),

                  SizedBox(height: isMobile ? 24 : 36),

                  StaggeredReveal(
                    revealOnScroll: true,
                    staggerIndex: 4,
                    child: _buildEditorialStep(
                      isMobile: isMobile,
                      stepNumber: '04',
                      stepTag: 'PRACTICE 04 — AUDIT',
                      title: 'Deliver Honest Certainty',
                      description:
                          'Receive an unambiguous Fresh or Not Fresh classification paired with transparent model confidence metrics. Authenticated scans are preserved in an audit history log for full traceability.',
                      metaRecord: 'QUALITY_ASSURANCE • AUDIT_CHAIN',
                    ),
                  ),

                  const SizedBox(height: 72),

                  // --- Section 4: Understanding the Results ---
                  StaggeredReveal(
                    revealOnScroll: true,
                    staggerIndex: 1,
                    child: _buildUnderstandingResultsCard(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNumberCircle(String stepNumber, {double size = 44}) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.78),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.90),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: const Color(0xFF0D9488).withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            stepNumber,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: size == 44 ? 14 : 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0D9488),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditorialStep({
    required bool isMobile,
    required String stepNumber,
    required String stepTag,
    required String title,
    required String description,
    required String metaRecord,
  }) {
    final cardContent = ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 22 : 36,
            vertical: isMobile ? 24 : 32,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.90),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 6),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: const Color(0xFF14B8A6).withValues(alpha: 0.05),
                blurRadius: 28,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Header Tag + Horizontal Hairline Divider
          Row(
            children: [
              Text(
                stepTag,
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                  color: Color(0xFF0D9488),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 1,
                  color: const Color(0xFFF1F5F9),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Card Title
          Text(
            title,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: isMobile ? 20 : 25,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: const Color(0xFF0A2229),
            ),
          ),

          const SizedBox(height: 12),

          // Card Description
          Text(
            description,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: isMobile ? 14 : 15,
              height: 1.6,
              letterSpacing: -0.2,
              color: const Color(0xFF475569),
            ),
          ),

          const SizedBox(height: 26),

          // Industrial Meta Record at Bottom Left
          Row(
            children: [
              Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFCBD5E1),
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  metaRecord,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: Color(0xFF94A3B8),
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
);

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNumberCircle(stepNumber, size: 36),
          const SizedBox(height: 10),
          cardContent,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNumberCircle(stepNumber, size: 44),
        const SizedBox(width: 32),
        Expanded(child: cardContent),
      ],
    );
  }

  /// Section 4: Understanding the Results & Scientific Disclaimer Card
  Widget _buildUnderstandingResultsCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.90),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: const Color(0xFF14B8A6).withValues(alpha: 0.06),
                blurRadius: 32,
                offset: const Offset(0, 10),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F6F4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.psychology_outlined,
                  color: SariwaColors.brandPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Understanding Classification Outputs',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.25,
                      color: Color(0xFF0A2229),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'How SariwaBa? interprets ocular clarity and gill coloration',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13,
                      letterSpacing: -0.25,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Two-column explanation: Fresh vs Not Fresh
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 640;

              final freshCard = Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.90),
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
                          color: Color(0xFF168077),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Fresh Assessment',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.25,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Indicates clear, transparent cornea, intact circular pupil lens, and bright, uniform reddish pigmentation on exposed gill arches.',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13,
                        height: 1.5,
                        letterSpacing: -0.25,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              );

              final notFreshCard = Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.90),
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
                          color: Color(0xFFDC2626),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Not Fresh Assessment',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.25,
                            color: Color(0xFFB91C1C),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Indicates corneal opacity, cloudy milky discoloration, sunken orbital tissue, or faded brownish coloration across gill filaments.',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13,
                        height: 1.5,
                        letterSpacing: -0.25,
                        color: Color(0xFF334155),
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
                    const SizedBox(width: 16),
                    Expanded(child: notFreshCard),
                  ],
                );
              }

              return Column(
                children: [
                  freshCard,
                  const SizedBox(height: 14),
                  notFreshCard,
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          // Clarification on Model Confidence vs Food Safety
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.90),
                width: 1.0,
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF64748B),
                  size: 18,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Model Confidence represents the algorithmic certainty of the neural network based on image features. It is not a food safety guarantee or risk index. External inspection does not detect internal chemical contaminants, biological toxins, or improper thermal handling.',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12.5,
                      height: 1.5,
                      letterSpacing: -0.25,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);
  }
}
