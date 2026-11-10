import 'package:flutter/material.dart';
import '../../../constants/theme/app_colors.dart';
import '../../../constants/theme/app_typography.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/staggered_reveal.dart';

/// How It Works & Understanding Results Section
/// Presents the 4-step workflow, transparency around classification labels,
/// model confidence interpretation, and the final call-to-action.
class HowItWorksSection extends StatelessWidget {
  final VoidCallback onDownload;
  final VoidCallback? onTryInspection;

  const HowItWorksSection({
    super.key,
    required this.onDownload,
    this.onTryInspection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF0F7F6), // Consistent off-white leaning primary teal
      padding: const EdgeInsets.symmetric(vertical: 84.0, horizontal: 24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Eyebrow Badge
              StaggeredReveal(
                revealOnScroll: true,
                staggerIndex: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2F3F0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFBBE5DF),
                      width: 1.0,
                    ),
                  ),
                  child: const Text(
                    'INSPECTION WORKFLOW',
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

              // Title (Deep Ocean Slate #0A2229)
              StaggeredReveal(
                revealOnScroll: true,
                staggerIndex: 1,
                child: const Text(
                  'Four Steps to Quality Assurance',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.25,
                    color: Color(0xFF0A2229),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Subtitle
              StaggeredReveal(
                revealOnScroll: true,
                staggerIndex: 2,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Text(
                    'From specimen capture to verified inference, inspect Tilapia freshness in seconds through intelligent computer vision.',
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

              const SizedBox(height: 48),

              // 4 Classification Workflow Step Cards
              StaggeredReveal(
                revealOnScroll: true,
                staggerIndex: 1,
                child: _buildStepCard(
                  stepNumber: '01',
                  title: 'Capture or Upload Specimen',
                  description:
                      'Take a focused photograph of your Tilapia under natural, even illumination, or select an existing high-resolution image up to 5 MB.',
                  icon: Icons.camera_alt_outlined,
                ),
              ),

              const SizedBox(height: 16),

              StaggeredReveal(
                revealOnScroll: true,
                staggerIndex: 2,
                child: _buildStepCard(
                  stepNumber: '02',
                  title: 'Select Inspection Region',
                  description:
                      'Designate whether the model should analyze the ocular cornea (Eye) or exposed gill arch (Hasang) for targeted inference.',
                  icon: Icons.crop_free_rounded,
                ),
              ),

              const SizedBox(height: 16),

              StaggeredReveal(
                revealOnScroll: true,
                staggerIndex: 3,
                child: _buildStepCard(
                  stepNumber: '03',
                  title: 'Validate & Run AI Inference',
                  description:
                      'Our computer vision model verifies anatomical alignment, assesses transparency and color indicators, and scores quality markers.',
                  icon: Icons.memory_outlined,
                ),
              ),

              const SizedBox(height: 16),

              StaggeredReveal(
                revealOnScroll: true,
                staggerIndex: 4,
                child: _buildStepCard(
                  stepNumber: '04',
                  title: 'Review Classification & Certainty',
                  description:
                      'View the Fresh or Not Fresh classification along with transparent model confidence. Authenticated accounts automatically archive audit history.',
                  icon: Icons.task_alt_outlined,
                ),
              ),

              const SizedBox(height: 72),

              // --- Section 4: Understanding the Results ---
              StaggeredReveal(
                revealOnScroll: true,
                staggerIndex: 1,
                child: _buildUnderstandingResultsCard(),
              ),

              const SizedBox(height: 72),

              // --- Section 5: Final Call-To-Action Banner ---
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
  }

  Widget _buildStepCard({
    required String stepNumber,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFDCEFEA),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0A2229),
            blurRadius: 18,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Number Pill (Primary Teal)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: SariwaColors.brandPrimary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              stepNumber,
              style: AppTypography.monoMetric.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
                letterSpacing: -0.25,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: SariwaColors.brandPrimary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          letterSpacing: -0.25,
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0A2229),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    letterSpacing: -0.25,
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 14,
                    height: 1.55,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Section 4: Understanding the Results & Scientific Disclaimer Card
  Widget _buildUnderstandingResultsCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFDCEFEA),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0E0A2229),
            blurRadius: 24,
            offset: Offset(0, 6),
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
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFBBF7D0),
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
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFECACA),
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
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
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
    );
  }

  /// Section 5: Atmospheric Underwater Call to Action Banner (Centered)
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
                            onPressed: onDownload,
                          ),
                          if (onTryInspection != null)
                            AppButton.secondary(
                              label: 'Try Inspection',
                              width: 170,
                              height: 48,
                              borderRadius: 24,
                              onPressed: onTryInspection,
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
