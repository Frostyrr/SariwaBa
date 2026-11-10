import 'dart:ui';
import 'package:flutter/material.dart';
import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';
import '../../models/classification/classification_result.dart';
import 'organoleptic_guidelines_dialog.dart';

/// Solid Brand Hero Banner with 5 Embedded Frosted Glass KPI Cards
/// per Timber Dashboard Design System Specification (v2.0.0).
class HeroBanner extends StatelessWidget {
  final List<ClassificationResult> history;
  final VoidCallback onSync;
  final VoidCallback onNewScan;
  final bool isSyncing;

  const HeroBanner({
    super.key,
    required this.history,
    required this.onSync,
    required this.onNewScan,
    this.isSyncing = false,
  });

  @override
  Widget build(BuildContext context) {
    final total = history.length;
    final freshCount = history.where((s) => s.isFresh).length;
    final spoiledCount = history
        .where((s) => !s.isFresh && s.grade.contains('Grade C'))
        .length;
    final cautionCount = total - freshCount - spoiledCount;
    final avgConfidence = total > 0
        ? (history.fold(0.0, (acc, s) => acc + s.confidence) / total) * 100
        : 95.8;

    return Container(
      decoration: BoxDecoration(
        color: SariwaColors.colorPrimary,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.20),
          width: 1.2,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SariwaColors.colorPrimary,
            Color.lerp(SariwaColors.colorPrimary, const Color(0xFF0A2229), 0.25)!,
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x330A2229),
            blurRadius: 36,
            offset: Offset(0, 16),
          ),
          BoxShadow(
            color: Color(0x1A0A2229),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Title, Eyebrow & Action Pills
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 720;

              final infoColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Text(
                      'WORKSPACE CONTEXT • SEAFOOD QUALITY OPERATIONS',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.9,
                        color: Colors.white.withValues(alpha: 0.90),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Dashboard Overview',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 580),
                    child: Text(
                      'Real-time multi-cue classification of cornea, gills, and dermal sheen across audit records.',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.white.withValues(alpha: 0.78),
                      ),
                    ),
                  ),
                ],
              );

              final actionRow = Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  // Sync Button (Frosted Glass)
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: onSync,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(9999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            isSyncing
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.sync_rounded,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                            const SizedBox(width: 7),
                            const Text(
                              'Sync status',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // PNS Standards Modal Button
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => OrganolepticGuidelinesDialog.show(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(9999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_outlined,
                              size: 15,
                              color: Colors.white,
                            ),
                            SizedBox(width: 7),
                            Text(
                              'PNS 67 Guide',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // New Scan Button (Solid White)
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: onNewScan,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(9999),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1F0A2229),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              size: 15,
                              color: SariwaColors.colorPrimary,
                            ),
                            SizedBox(width: 7),
                            Text(
                              'Inspect catch',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: SariwaColors.colorPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    infoColumn,
                    const SizedBox(height: 16),
                    actionRow,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: infoColumn),
                  const SizedBox(width: 16),
                  actionRow,
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Embedded Frosted Glass KPI Grid (5 Cards)
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              final kpiCards = [
                _buildKpiCard(
                  title: 'Total audited',
                  value: total.toString(),
                  subtitle: 'PostgreSQL records',
                  icon: Icons.inventory_2_outlined,
                  accentColor: Colors.white,
                ),
                _buildKpiCard(
                  title: 'Sariwa (Fresh)',
                  value: freshCount.toString(),
                  subtitle: total > 0
                      ? '${((freshCount / total) * 100).toStringAsFixed(0)}% Grade A'
                      : 'Grade A benchmark',
                  icon: Icons.check_circle_outline_rounded,
                  accentColor: SariwaColors.brandLight,
                ),
                _buildKpiCard(
                  title: 'Katamtaman',
                  value: cautionCount.toString(),
                  subtitle: 'Grade B moderate',
                  icon: Icons.warning_amber_rounded,
                  accentColor: const Color(0xFFFCD34D),
                ),
                _buildKpiCard(
                  title: 'Needs review',
                  value: spoiledCount.toString(),
                  subtitle: 'Critical alerts',
                  icon: Icons.gpp_bad_outlined,
                  accentColor: const Color(0xFFFCA5A5),
                ),
                _buildKpiCard(
                  title: 'AI Precision',
                  value: '${avgConfidence.toStringAsFixed(1)}%',
                  subtitle: 'MobileNetV3 score',
                  icon: Icons.auto_awesome_outlined,
                  accentColor: SariwaColors.brandGlow,
                ),
              ];

              if (width >= 980) {
                // 5 columns on desktop
                return Row(
                  children: List.generate(
                    kpiCards.length,
                    (i) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: i == kpiCards.length - 1 ? 0 : 10,
                        ),
                        child: kpiCards[i],
                      ),
                    ),
                  ),
                );
              } else if (width >= 600) {
                // 3 + 2 layout on tablet
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(
                    kpiCards.length,
                    (i) => SizedBox(
                      width: (width - 20) / (i < 3 ? 3 : 2),
                      child: kpiCards[i],
                    ),
                  ),
                );
              } else {
                // 2 columns on mobile
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(
                    kpiCards.length,
                    (i) => SizedBox(
                      width: i == 4 ? width : (width - 10) / 2,
                      child: kpiCards[i],
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.20),
                      ),
                    ),
                    child: Center(
                      child: Icon(icon, size: 15, color: accentColor),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_outward_rounded,
                    size: 13,
                    color: Colors.white54,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.88),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 10.5,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
