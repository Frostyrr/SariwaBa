import 'dart:ui';
import 'package:flutter/material.dart';
import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';

/// Modal dialog providing the official Philippine National Standard
/// (PNS/BAFPS 67:2008) Organoleptic Sensory Inspection Protocol.
class OrganolepticGuidelinesDialog extends StatelessWidget {
  const OrganolepticGuidelinesDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: const Color(0x660A2229),
      builder: (context) => const OrganolepticGuidelinesDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.9),
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x180A2229),
                  blurRadius: 36,
                  offset: Offset(0, 16),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dialog Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: SariwaColors.colorPrimary,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Icon(
                            Icons.verified_user_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ORGANOLEPTIC INSPECTION PROTOCOL',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'PNS/BAFPS 67:2008 & BFAR Standards',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content Body
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Organoleptic sensory validation serves as the ground-truth benchmark for SariwaBa AI MobileNetV3 model evaluations. Inspect each anatomical biomarker using the criteria below:',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 13,
                              height: 1.45,
                              color: SariwaColors.colorMutedInk,
                            ),
                          ),
                          const SizedBox(height: 18),

                          _buildGuidelineCard(
                            badge: 'CRITERION 1',
                            title: 'Cornea & Ocular Structure (Mata)',
                            freshDesc:
                                'Clear, convex and transparent cornea. Pupils are shiny black with metallic reflections.',
                            cautionDesc:
                                'Slightly sunken cornea with cloudy or milky lens. Pupil loses brightness.',
                            spoiledDesc:
                                'Sunken, opaque, grey cornea. Pupil is washed out, collapsed or bloodshot.',
                            icon: Icons.remove_red_eye_outlined,
                          ),
                          const SizedBox(height: 12),

                          _buildGuidelineCard(
                            badge: 'CRITERION 2',
                            title: 'Branchial Gills (Hasang)',
                            freshDesc:
                                'Bright crimson to blood red color. Mucus is clear and transparent with sea-fresh aroma.',
                            cautionDesc:
                                'Pale pink or brownish red. Mucus is slightly viscous or opaque.',
                            spoiledDesc:
                                'Brown, yellowish, or bleach-gray discoloration. Sticky, sour or ammoniacal stench.',
                            icon: Icons.water_drop_outlined,
                          ),
                          const SizedBox(height: 12),

                          _buildGuidelineCard(
                            badge: 'CRITERION 3',
                            title: 'Dermal Scales & Sheen (Kaliskis)',
                            freshDesc:
                                'Firmly attached scales with iridescent pearlescent sheen. Skin is taut and elastic.',
                            cautionDesc:
                                'Scales loosen slightly with light mechanical friction. Slight dulling of natural pigment.',
                            spoiledDesc:
                                'Scales easily peel off in patches. Skin covered in cloudy, sticky bacterial slime.',
                            icon: Icons.blur_linear_outlined,
                          ),
                          const SizedBox(height: 12),

                          _buildGuidelineCard(
                            badge: 'CRITERION 4',
                            title: 'Muscular Elasticity & Odor (Laman at Amoy)',
                            freshDesc:
                                'Firm muscle tissue; finger impression recovers instantly. Mild clean ocean scent.',
                            cautionDesc:
                                'Softened resilience; impression lingers momentarily. Slight fishy/stale smell.',
                            spoiledDesc:
                                'Soft, flabby, disintegrating tissue. Distinct putrid, ammonia, or rotten odor.',
                            icon: Icons.touch_app_outlined,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Dialog Footer
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 14,
                    ),
                    decoration: const BoxDecoration(
                      color: SariwaColors.colorSurface,
                      border: Border(
                        top: BorderSide(
                          color: SariwaColors.colorLine,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'BFAR PNS 67:2008 Compliance',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: SariwaColors.colorMutedInk,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SariwaColors.colorPrimary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Understood'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuidelineCard({
    required String badge,
    required String title,
    required String freshDesc,
    required String cautionDesc,
    required String spoiledDesc,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SariwaColors.colorWorkspace,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SariwaColors.colorLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: SariwaColors.colorPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: SariwaColors.colorPrimary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: SariwaColors.colorInk,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: SariwaColors.colorLine),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: SariwaColors.colorPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildTierRow('Grade A (Sariwa):', freshDesc, SariwaColors.statusFresh),
          const SizedBox(height: 4),
          _buildTierRow('Grade B (Caution):', cautionDesc, SariwaColors.statusModerate),
          const SizedBox(height: 4),
          _buildTierRow('Grade C (Spoiled):', spoiledDesc, SariwaColors.statusSpoiled),
        ],
      ),
    );
  }

  Widget _buildTierRow(String grade, String description, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 5, right: 8),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(
          width: 110,
          child: Text(
            grade,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        Expanded(
          child: Text(
            description,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 11.5,
              height: 1.35,
              color: SariwaColors.colorInk,
            ),
          ),
        ),
      ],
    );
  }
}
