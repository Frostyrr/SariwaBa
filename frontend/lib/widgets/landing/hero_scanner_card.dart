import 'package:flutter/material.dart';
import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_theme.dart';
import '../../constants/theme/app_typography.dart';

class _ClassificationSample {
  final String species;
  final String scientificName;
  final String status;
  final String grade;
  final Color statusColor;
  final double confidence;
  final String eyes;
  final String gills;
  final String scales;
  final String recommendation;

  const _ClassificationSample({
    required this.species,
    required this.scientificName,
    required this.status,
    required this.grade,
    required this.statusColor,
    required this.confidence,
    required this.eyes,
    required this.gills,
    required this.scales,
    required this.recommendation,
  });
}

const _kSamples = [
  _ClassificationSample(
    species: 'Bangus',
    scientificName: 'Chanos chanos',
    status: 'Sariwa (Fresh)',
    grade: 'Grade A',
    statusColor: SariwaColors.statusFresh,
    confidence: 0.991,
    eyes: 'Clear',
    gills: 'Ruby Red',
    scales: 'Intact',
    recommendation:
        'Clinical Grade A: Fresh catch ready for retail distribution.',
  ),
  _ClassificationSample(
    species: 'Tilapia',
    scientificName: 'Oreochromis niloticus',
    status: 'Katamtaman',
    grade: 'Grade B',
    statusColor: SariwaColors.statusModerate,
    confidence: 0.847,
    eyes: 'Cloudy',
    gills: 'Pinkish',
    scales: 'Faded',
    recommendation: 'Grade B: Cook immediately. Do not store long-term.',
  ),
  _ClassificationSample(
    species: 'Galunggong',
    scientificName: 'Decapterus macarellus',
    status: 'Hindi Sariwa',
    grade: 'Grade C',
    statusColor: SariwaColors.statusSpoiled,
    confidence: 0.948,
    eyes: 'Sunken',
    gills: 'Gray',
    scales: 'Slimy',
    recommendation: 'Grade C: Sensory decomposition detected. Reject catch.',
  ),
];

/// Interactive Seafood Freshness Classification Placeholder Card
/// Serves as the interactive AI classification preview on the landing page hero.
class HeroScannerCard extends StatefulWidget {
  const HeroScannerCard({super.key});

  @override
  State<HeroScannerCard> createState() => _HeroScannerCardState();
}

class _HeroScannerCardState extends State<HeroScannerCard> {
  int _selectedSampleIndex = 0;

  @override
  Widget build(BuildContext context) {
    final sample = _kSamples[_selectedSampleIndex];

    return SariwaGlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Classification Placeholder Title & Live Status Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: sample.statusColor,
                        boxShadow: [
                          BoxShadow(
                            color: sample.statusColor.withValues(alpha: 0.7),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Classification Model',
                        style: AppTypography.titleMedium.copyWith(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: SariwaColors.textPrimaryLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: SariwaColors.bgLagoonMid,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: SariwaColors.borderGlass,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  'Edge INT8 · ~32ms',
                  style: AppTypography.monoMetric.copyWith(
                    fontSize: 10.5,
                    color: SariwaColors.brandLight,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Sample Selector Pills: Interactive Preview of Classification
          Row(
            children: List.generate(_kSamples.length, (index) {
              final isSelected = _selectedSampleIndex == index;
              final s = _kSamples[index];

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : 3.0,
                    right: index == _kSamples.length - 1 ? 0 : 3.0,
                  ),
                  child: InkWell(
                    onTap: () => setState(() => _selectedSampleIndex = index),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? SariwaColors.brandPrimary.withValues(alpha: 0.45)
                            : SariwaColors.bgAbyssDark.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? SariwaColors.brandLight
                              : SariwaColors.borderGlass,
                          width: isSelected ? 1.2 : 0.8,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          s.species,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? SariwaColors.brandLight
                                : SariwaColors.textSecondaryLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 12),

          // Central Inspection Target & Species Identification
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SariwaColors.bgAbyssDark.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: SariwaColors.borderGlass,
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                // Mascot Scan Avatar
                Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: SariwaColors.bgLagoonMid,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: sample.statusColor.withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                  ),
                  child: Image.asset(
                    'assets/images/SariwaBa logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              sample.species,
                              style: AppTypography.titleMedium.copyWith(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: SariwaColors.textPrimaryLight,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: sample.statusColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color:
                                    sample.statusColor.withValues(alpha: 0.5),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              sample.grade,
                              style: AppTypography.caption.copyWith(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: sample.statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sample.scientificName,
                        style: AppTypography.caption.copyWith(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: SariwaColors.textMutedLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: sample.confidence,
                          minHeight: 4.5,
                          backgroundColor: SariwaColors.bgLagoonMid,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(sample.statusColor),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              sample.status,
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: sample.statusColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(sample.confidence * 100).toStringAsFixed(1)}%',
                            style: AppTypography.monoMetric.copyWith(
                              fontSize: 10.5,
                              color: SariwaColors.brandLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Feature Breakdown Indicators (Eyes, Gills, Skin)
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'Mata (Eyes)',
                  value: sample.eyes,
                  color: sample.statusColor,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildMetricTile(
                  label: 'Hasang (Gills)',
                  value: sample.gills,
                  color: sample.statusColor,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildMetricTile(
                  label: 'Kaliskis (Skin)',
                  value: sample.scales,
                  color: sample.statusColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Sensory Evaluation Summary Note
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: SariwaColors.bgAbyssDark.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: SariwaColors.borderGlass.withValues(alpha: 0.5),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified_outlined,
                  size: 14,
                  color: sample.statusColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    sample.recommendation,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 10.5,
                      color: SariwaColors.brandLight.withValues(alpha: 0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
      decoration: BoxDecoration(
        color: SariwaColors.bgLagoonMid.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: SariwaColors.borderGlass,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              fontSize: 9.5,
              color: SariwaColors.textMutedLight,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  value,
                  style: AppTypography.labelMedium.copyWith(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: SariwaColors.textPrimaryLight,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
