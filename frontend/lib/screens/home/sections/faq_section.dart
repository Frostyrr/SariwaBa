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
      question: 'Which fish species does SariwaBa? support?',
      answer:
          'SariwaBa? is specifically trained for Nile Tilapia. By focusing on Tilapia, our system can accurately read the natural signs of freshness in its eyes and gills without getting confused by differences in other fish species.',
    ),
    FaqItem(
      question: 'What kind of photo gives the best results?',
      answer:
          'Take a clear, steady photo in bright, even lighting (like daylight or a well-lit stall). Avoid strong flash glare, heavy shadows, or blurry shots. Make sure the eye or open gills fill most of the frame for the most accurate check.',
    ),
    FaqItem(
      question: 'What does the Confidence score mean?',
      answer:
          'The confidence score shows how certain the AI is based on what it sees in the photo—such as eye clarity and gill color. It is a quick visual guide to help you choose fresh fish, but it is not a laboratory test or health guarantee.',
    ),
    FaqItem(
      question: 'Can I check fish without creating an account?',
      answer:
          'Yes! You can try the freshness checker right away in Guest mode without signing up. If you create a free account, you can also save your scan history, view past checks anytime, and access them across all your devices.',
    ),
    FaqItem(
      question: 'How does SariwaBa? protect my photos and privacy?',
      answer:
          'Your photos are uploaded securely through encrypted connections and are only used to check freshness and maintain your scan history. We never sell or share your photos, and photos uploaded in Guest mode are not saved on our servers.',
    ),
    FaqItem(
      question: 'Do I need an internet connection to use the app?',
      answer:
          'You can take photos and browse your saved history offline. However, you need an active internet connection (Wi-Fi or mobile data) to run a new freshness check with our AI.',
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
            horizontal: isMobile ? 20.0 : 24.0,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1140.0),
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
                          fontWeight: FontWeight.w500,
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
                        fontWeight: FontWeight.w500, // Medium
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
                        'Clear answers about how SariwaBa? works, how to take good photos, what your scores mean, and how your privacy is protected.',
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

                  SizedBox(height: isMobile ? 28 : 36),

                  // Accordion List
                  ...List.generate(_faqList.length, (index) {
                    final item = _faqList[index];
                    final isExpanded = _expandedIndices.contains(index);

                    return StaggeredReveal(
                      revealOnScroll: true,
                      staggerIndex: index,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: _buildAccordionCard(
                          isMobile: isMobile,
                          index: index,
                          item: item,
                          isExpanded: isExpanded,
                        ),
                      ),
                    );
                  }),

                  SizedBox(height: isMobile ? 40 : 52),

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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: isExpanded ? 0.05 : 0.03),
            blurRadius: isExpanded ? 22 : 16,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: isExpanded ? 0.035 : 0.02),
            blurRadius: isExpanded ? 34 : 26,
            offset: const Offset(0, 10),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: const Color(0xFF14B8A6).withValues(alpha: isExpanded ? 0.05 : 0.025),
            blurRadius: isExpanded ? 26 : 20,
            offset: const Offset(0, 6),
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isExpanded ? 0.86 : 0.76),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isExpanded
                    ? const Color(0xFF0D9488).withValues(alpha: 0.45)
                    : Colors.white.withValues(alpha: 0.88),
                width: 1.2,
              ),
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
                      horizontal: isMobile ? 18.0 : 22.0,
                      vertical: isMobile ? 14.0 : 16.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.question,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: isMobile ? 15.0 : 16.0,
                              fontWeight: FontWeight.w500, // Medium
                              letterSpacing: -0.2,
                              color: isExpanded
                                  ? const Color(0xFF0D9488)
                                  : const Color(0xFF0A2229),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOutCubic,
                          child: Container(
                            width: 28,
                            height: 28,
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
                              size: 18,
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
                        horizontal: isMobile ? 18.0 : 22.0,
                      ),
                      height: 1,
                      color: const Color(0xFFF1F5F9).withValues(alpha: 0.70),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        isMobile ? 18.0 : 22.0,
                        10.0,
                        isMobile ? 18.0 : 22.0,
                        16.0,
                      ),
                      child: Text(
                        item.answer,
                        style: const TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13.5,
                          height: 1.5,
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
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.width < 768 ? 44 : 48,
                horizontal: MediaQuery.of(context).size.width < 768 ? 24 : 32,
              ),
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
                      'START CHECKING TODAY',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        color: Color(0xFF5EEAD4),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Ready to check fish freshness with confidence?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 30,
                      fontWeight: FontWeight.w500, // Medium
                      letterSpacing: -0.25,
                      height: 1.2,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 14),

                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 580),
                    child: const Text(
                      'Check Tilapia freshness in your browser right now or download the mobile app to scan on the go at the market.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w300,
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
