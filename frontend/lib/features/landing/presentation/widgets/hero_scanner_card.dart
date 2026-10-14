import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';

/// Seafood Freshness Telemetry Showcase Card
/// Redesigned using SariwaGlassCard, clinical telemetry metrics, and brand aquatic styling.
class HeroScannerCard extends StatelessWidget {
  const HeroScannerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SariwaGlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header: Status Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: SariwaColors.statusFresh,
                        boxShadow: [
                          BoxShadow(
                            color: SariwaColors.statusFresh.withValues(alpha: 0.6),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Sariwa (Fresh Catch)',
                        style: AppTypography.caption.copyWith(
                          color: SariwaColors.textPrimaryLight,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: SariwaColors.bgLagoonMid,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: SariwaColors.borderGlass,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  'MobileNetV3',
                  style: AppTypography.monoMetric.copyWith(
                    fontSize: 11,
                    color: SariwaColors.brandLight,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Middle: Fish Telemetry & Confidence Gauge
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SariwaColors.bgAbyssDark.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: SariwaColors.borderGlass,
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                // Mascot Thumbnail / Scan Target
                Container(
                  width: 64,
                  height: 64,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: SariwaColors.bgLagoonMid,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: SariwaColors.brandLight.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Image.asset(
                    'assets/images/SariwaBa logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tilapia (Oreochromis niloticus)',
                        style: AppTypography.titleMedium.copyWith(
                          fontSize: 14,
                          color: SariwaColors.textPrimaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'AI Confidence: ',
                            style: AppTypography.caption,
                          ),
                          Text(
                            '98.4%',
                            style: AppTypography.monoMetric.copyWith(
                              fontSize: 13,
                              color: SariwaColors.statusFresh,
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

          const SizedBox(height: 20),

          // Feature Breakdown Indicators (Eyes, Gills, Skin)
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'Mata (Eyes)',
                  value: 'Clear',
                  color: SariwaColors.statusFresh,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  label: 'Hasang (Gills)',
                  value: 'Bright Red',
                  color: SariwaColors.statusFresh,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  label: 'Kaliskis (Skin)',
                  value: 'Firm',
                  color: SariwaColors.statusFresh,
                ),
              ),
            ],
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
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: SariwaColors.bgLagoonMid.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
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
              fontSize: 10.5,
              color: SariwaColors.textMutedLight,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  value,
                  style: AppTypography.labelMedium.copyWith(
                    fontSize: 12,
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
