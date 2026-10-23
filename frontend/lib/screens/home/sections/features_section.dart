import 'package:flutter/material.dart';
import '../../../constants/theme/app_colors.dart';
import '../../../constants/theme/app_typography.dart';
import '../../../widgets/common/staggered_reveal.dart';

/// Features Section Widget
/// Styled with an off-white background leaning toward our primary teal palette (0xFFF0F7F6),
/// high-contrast slate typography, and elevated white cards.
class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF0F7F6), // Off-white leaning primary teal
      padding: const EdgeInsets.symmetric(vertical: 84.0, horizontal: 24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140.0),
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
                  child: Text(
                    'PRECISION GRADING',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: SariwaColors.brandPrimaryDark,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Section Heading (Deep Ocean Slate #0A2229)
              StaggeredReveal(
                revealOnScroll: true,
                staggerIndex: 1,
                child: Text(
                  'Engineered for Precision Grading',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 38,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -1.0,
                    color: const Color(0xFF0A2229),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Subtitle
              StaggeredReveal(
                revealOnScroll: true,
                staggerIndex: 2,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Text(
                    'Standardize seafood inspection across markets, harbors, and cold storage with clinical computer vision.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 16,
                      height: 1.5,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // 4 Feature Cards Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 768;

                  return Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: [
                      SizedBox(
                        width: isDesktop ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                        child: StaggeredReveal(
                          revealOnScroll: true,
                          staggerIndex: 1,
                          child: _buildFeatureCard(
                            icon: Icons.remove_red_eye_outlined,
                            title: 'Cornea Optical Clarity',
                            desc: 'Analyzes pupil transparency and lens convexity to detect post-mortem cloudiness within milliseconds.',
                          ),
                        ),
                      ),
                      SizedBox(
                        width: isDesktop ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                        child: StaggeredReveal(
                          revealOnScroll: true,
                          staggerIndex: 2,
                          child: _buildFeatureCard(
                            icon: Icons.bloodtype_outlined,
                            title: 'Branchial Gill Pigmentation',
                            desc: 'Measures RGB redness variance and discoloration across gill arches to separate fresh catch from oxidized fish.',
                          ),
                        ),
                      ),
                      SizedBox(
                        width: isDesktop ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                        child: StaggeredReveal(
                          revealOnScroll: true,
                          staggerIndex: 3,
                          child: _buildFeatureCard(
                            icon: Icons.offline_bolt_outlined,
                            title: 'Offline Smart Scanning',
                            desc: 'Assess fish freshness anytime on your mobile device, even in markets or ports without an internet connection.',
                          ),
                        ),
                      ),
                      SizedBox(
                        width: isDesktop ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth,
                        child: StaggeredReveal(
                          revealOnScroll: true,
                          staggerIndex: 4,
                          child: _buildFeatureCard(
                            icon: Icons.history_edu_outlined,
                            title: 'Saved Inspection History',
                            desc: 'Automatically backs up your fish freshness scan results when you sign in with your Google account.',
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(28),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F6F4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFCCEAE6),
                width: 1.0,
              ),
            ),
            child: Icon(
              icon,
              color: SariwaColors.brandPrimary,
              size: 24,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 18.5,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
              color: const Color(0xFF0A2229),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14,
              height: 1.55,
              color: const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}
