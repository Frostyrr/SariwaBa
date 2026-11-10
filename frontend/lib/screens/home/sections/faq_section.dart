import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../constants/theme/app_colors.dart';
import '../../../constants/theme/app_typography.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/staggered_reveal.dart';

/// Item data model for FAQ entries
class FaqItem {
  final String question;
  final String answer;

  const FaqItem({
    required this.question,
    required this.answer,
  });
}

/// Frequently Asked Questions Section
/// Features an interactive accordion with smooth animations, authentic SariwaBa? branding,
/// and the atmospheric Call-To-Action banner transitioning cleanly into the footer.
class FaqSection extends StatefulWidget {
  final VoidCallback onDownload;
  final VoidCallback? onTryInspection;

  const FaqSection({
    super.key,
    required this.onDownload,
    this.onTryInspection,
  });

  @override
  State<FaqSection> createState() => _FaqSectionState();
}

class _FaqSectionState extends State<FaqSection> {
  // First item open by default for immediate discoverability
  final Set<int> _expandedIndices = {0};

  static const List<FaqItem> _faqList = [
    FaqItem(
      question: 'Which fish species does SariwaBa? currently support?',
      answer:
          'SariwaBa? is currently trained and calibrated exclusively for Nile Tilapia (Oreochromis niloticus). By focusing strictly on this commercial species, our neural network models detect subtle physiological indicators in ocular corneal clarity and branchial arch coloration without cross-species morphological variance.',
    ),
    FaqItem(
      question: 'What image quality is required for accurate classification?',
      answer:
          'For optimal assessment accuracy, capture a sharp, well-focused photograph under natural or balanced white lighting. Avoid heavy shadows, direct flash reflections, or optical blur. The fish eye or exposed gill arch should fill a substantial portion of the reticle frame with clean edge definition.',
    ),
    FaqItem(
      question: 'What does the "Model Confidence" score represent?',
      answer:
          'Model Confidence reflects the algorithmic certainty of the convolutional network based on learned visual features—such as pupil transparency, corneal cloudiness, or gill pigment degradation. It is an objective visual assessment tool designed to assist inspectors, not an absolute biochemical safety guarantee or toxicity test.',
    ),
    FaqItem(
      question: 'Can I test fish specimens without creating an account?',
      answer:
          'Yes. Anyone can access our interactive inspection tool immediately in Guest mode without creating an account. Registering a free authenticated account unlocks persistent cloud audit logging, multi-scan export, and history synchronization across all your devices.',
    ),
    FaqItem(
      question: 'How does SariwaBa? protect uploaded specimen images?',
      answer:
          'Specimen images uploaded for classification are transmitted over encrypted TLS connections and evaluated strictly for feature inference and audit logging. We do not sell or distribute your imagery to third parties, and guest scans are never persisted on our server infrastructure.',
    ),
    FaqItem(
      question: 'Is an active internet connection required for the mobile app?',
      answer:
          'The mobile application allows you to capture images, align the camera reticle, and review cached history offline. However, running active deep learning inference requires an internet or cellular connection to communicate with our verification service.',
    ),
  ];

  void _toggleIndex(int index) {
    setState(() {
      if (_expandedIndices.contains(index)) {
        _expandedIndices.remove(index);
      } else {
        _expandedIndices.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        return Container(
          width: double.infinity,
          color: const Color(0xFFF0F7F6), // Consistent off-white leaning primary teal
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 64.0 : 88.0,
            horizontal: isMobile ? 20.0 : 36.0,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Eyebrow Badge (Centered Frosted Pill)
                  StaggeredReveal(
                    revealOnScroll: true,
                    staggerIndex: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
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
                        'FREQUENTLY ASKED QUESTIONS',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.25,
                          color: SariwaColors.brandPrimaryDark,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Section Title (Deep Ocean Slate #0A2229)
                  StaggeredReveal(
                    revealOnScroll: true,
                    staggerIndex: 1,
                    child: Text(
                      'Got Questions? We Have Answers.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: isMobile ? 32.0 : 38.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.25,
                        color: const Color(0xFF0A2229),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Section Subtitle
                  StaggeredReveal(
                    revealOnScroll: true,
                    staggerIndex: 2,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: const Text(
                        'Clear answers regarding our machine learning pipeline, supported anatomy, confidence scoring, and data security.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          letterSpacing: -0.25,
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 16,
                          height: 1.5,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: isMobile ? 36 : 48),

                  // Accordion List
                  ...List.generate(_faqList.length, (index) {
                    final item = _faqList[index];
                    final isExpanded = _expandedIndices.contains(index);

                    return StaggeredReveal(
                      revealOnScroll: true,
                      staggerIndex: index,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 14.0),
                        child: _buildAccordionCard(
                          isMobile: isMobile,
                          index: index,
                          item: item,
                          isExpanded: isExpanded,
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 64),

                  // Final Call-To-Action Banner
                  StaggeredReveal(
                    revealOnScroll: true,
                    staggerIndex: 1,
                    child: _buildFinalCtaBanner(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccordionCard({
    required bool isMobile,
    required int index,
    required FaqItem item,
    required bool isExpanded,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isExpanded ? 0.85 : 0.75),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isExpanded
                  ? const Color(0xFF0D9488).withValues(alpha: 0.45)
                  : Colors.white.withValues(alpha: 0.88),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: isExpanded ? 0.05 : 0.03),
                blurRadius: isExpanded ? 24 : 16,
                offset: const Offset(0, 6),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: const Color(0xFF14B8A6).withValues(alpha: isExpanded ? 0.07 : 0.03),
                blurRadius: 30,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            children: [
              // Clickable Question Header
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _toggleIndex(index),
                  borderRadius: BorderRadius.circular(18),
                  splashColor: const Color(0x100D9488),
                  highlightColor: const Color(0x080D9488),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 20.0 : 26.0,
                      vertical: isMobile ? 18.0 : 22.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.question,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: isMobile ? 16.0 : 17.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                              color: isExpanded
                                  ? const Color(0xFF0D9488)
                                  : const Color(0xFF0A2229),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOutCubic,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isExpanded
                                  ? const Color(0xFFE6F6F4).withValues(alpha: 0.90)
                                  : const Color(0xFFF1F5F9).withValues(alpha: 0.85),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.80),
                                width: 1.0,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 20,
                              color: isExpanded
                                  ? const Color(0xFF0D9488)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Animated Expandable Answer Body
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity, height: 0),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: isMobile ? 20.0 : 26.0,
                      ),
                      height: 1,
                      color: const Color(0xFFF1F5F9).withValues(alpha: 0.70),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        isMobile ? 20.0 : 26.0,
                        14.0,
                        isMobile ? 20.0 : 26.0,
                        22.0,
                      ),
                      child: Text(
                        item.answer,
                        style: const TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14.5,
                          height: 1.6,
                          letterSpacing: -0.2,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
                sizeCurve: Curves.easeInOutCubic,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Atmospheric Underwater Call to Action Banner (Centered)
  Widget _buildFinalCtaBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x240A2229),
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
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Layer 1: Blurred Underwater Aquatic Backdrop
            Positioned.fill(
              child: Image.asset(
                'assets/images/backgroundBlurred.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),

            // Layer 2: Deep Abyss Gradient Overlay (ensures high contrast & text legibility)
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
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),

            // Layer 3: Ambient Radial Glow Flare in top-right corner
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 320,
                height: 320,
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

            // Layer 4: Foreground Content (Centered across full width)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Subtle Pill Eyebrow
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x2414B8A6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0x402DD4BF),
                        width: 1.0,
                      ),
                    ),
                    child: const Text(
                      'START AUDITING TODAY',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: Color(0xFF5EEAD4),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Ready to experience intelligent fish inspection?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.25,
                      height: 1.2,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 14),

                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 580),
                    child: const Text(
                      'Inspect Tilapia freshness in your browser right now or download the mobile application for field audits.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 15.5,
                        height: 1.55,
                        letterSpacing: -0.25,
                        color: Color(0xFFD1FAF4),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Symmetrically Centered Action Buttons
                  SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 16,
                        runSpacing: 12,
                        children: [
                          AppButton.primary(
                            label: 'Download App',
                            icon: const Icon(
                              Icons.download_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            width: 180,
                            height: 48,
                            borderRadius: 24,
                            onPressed: widget.onDownload,
                          ),
                          if (widget.onTryInspection != null)
                            AppButton.secondary(
                              label: 'Try Inspection',
                              width: 170,
                              height: 48,
                              borderRadius: 24,
                              onPressed: widget.onTryInspection,
                            ),
                        ],
                      ),
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
