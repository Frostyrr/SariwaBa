import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';

/// How It Works Section Widget
/// Styled with an off-white background leaning toward our primary teal palette (0xFFF0F7F6),
/// numbered clinical inspection steps, and high-contrast elevated cards.
class HowItWorksSection extends StatelessWidget {
  final VoidCallback onDownload;

  const HowItWorksSection({
    super.key,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF0F7F6), // Off-white leaning primary teal
      padding: const EdgeInsets.symmetric(vertical: 84.0, horizontal: 24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Eyebrow Badge
              Container(
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
                  'SEAFOOD QUALITY WORKFLOW',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: SariwaColors.brandPrimaryDark,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Title (Deep Ocean Slate #0A2229)
              Text(
                'Three Steps to Quality Assurance',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.0,
                  color: const Color(0xFF0A2229),
                ),
              ),

              const SizedBox(height: 14),

              // Subtitle
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Text(
                  'Eliminate subjective guesswork with real-time sensory classification aligned with international seafood grading standards.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 16,
                    height: 1.5,
                    color: const Color(0xFF475569),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // 3 Clinical Workflow Step Cards
              _buildStepCard(
                stepNumber: '01',
                title: 'Capture Seafood Specimen',
                description:
                    'Position the fish eye cornea or gill arch directly in the camera viewfinder under natural lighting, or upload high-resolution images.',
                icon: Icons.camera_alt_outlined,
              ),

              const SizedBox(height: 20),

              _buildStepCard(
                stepNumber: '02',
                title: 'Multi-Spectral AI Analysis',
                description:
                    'Our edge MobileNetV3 neural model segments optical cornea cloudiness, measures RGB branchial redness, and evaluates tissue degradation.',
                icon: Icons.memory_outlined,
              ),

              const SizedBox(height: 20),

              _buildStepCard(
                stepNumber: '03',
                title: 'Standardized Grading & Telemetry Sync',
                description:
                    'Receive an immediate freshness confidence score (Grade A Sariwa, Grade B Katamtaman, Grade C Spoiled) and synchronize records with PostgreSQL.',
                icon: Icons.task_alt_outlined,
              ),

              const SizedBox(height: 52),

              // CTA Button: Primary Teal
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
      padding: const EdgeInsets.all(26),
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
                fontWeight: FontWeight.w700,
                fontSize: 15,
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
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 18.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0A2229),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 14,
                    height: 1.55,
                    color: const Color(0xFF475569),
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
