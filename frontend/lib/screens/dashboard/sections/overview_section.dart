import 'package:flutter/material.dart';

import '../../../constants/theme/app_colors.dart';
import '../../../controllers/classification/classification_controller.dart';
import '../../../widgets/common/staggered_reveal.dart';
import '../widgets/dashboard_charts.dart';
import 'audit_history_section.dart';
import 'freshness_trends_section.dart';
import 'grade_breakdown_section.dart';
import 'live_scanner_section.dart';

class OverviewSection extends StatelessWidget {
  final ClassificationState classState;
  final ClassificationController classController;
  final String historyFilter;
  final ValueChanged<String> onFilterChanged;
  final String searchQuery;
  final bool isGuest;
  final VoidCallback onSignIn;
  final ValueChanged<String> onNavigateSection;

  const OverviewSection({
    super.key,
    required this.classState,
    required this.classController,
    required this.historyFilter,
    required this.onFilterChanged,
    required this.searchQuery,
    required this.isGuest,
    required this.onSignIn,
    required this.onNavigateSection,
  });

  @override
  Widget build(BuildContext context) {
    final history = classState.history;
    final total = history.length;
    final freshCount = history.where((s) => s.isFresh).length;
    final cautionCount = history.where((s) => s.isNotFresh).length;
    final avgConfidence = total > 0
        ? (history.fold(0.0, (acc, s) => acc + s.confidence) / total) * 100
        : 0.0;
    final freshRate = total > 0 ? (freshCount / total) * 100 : 0.0;

    final cards = [
      NotchedKpiCard(
        title: 'Total Inspections',
        value: total.toString(),
        trendText: 'Available',
        comparisonText: 'scan history',
        waveColor: SariwaColors.textPrimaryDark,
        trendColor: SariwaColors.statusFresh,
        points: const [0.42, 0.25, 0.58, 0.64, 0.32, 0.18, 0.72],
        showSparkline: false,
        isCompact: false,
        onTap: () => onNavigateSection('Scan Logs'),
      ),
      NotchedKpiCard(
        title: 'Sariwa (Fresh)',
        value: freshCount.toString(),
        trendText: '${freshRate.toStringAsFixed(1)}%',
        comparisonText: 'of scans',
        waveColor: SariwaColors.statusFresh,
        trendColor: SariwaColors.statusFresh,
        points: const [0.22, 0.45, 0.30, 0.55, 0.38, 0.48, 0.85],
        showSparkline: false,
        isCompact: false,
        onTap: () {
          onFilterChanged('Fresh');
          onNavigateSection('Scan Logs');
        },
      ),
      NotchedKpiCard(
        title: 'Not Fresh',
        value: cautionCount.toString(),
        trendText: total > 0
            ? '${((cautionCount / total) * 100).toStringAsFixed(1)}%'
            : '0%',
        comparisonText: 'of scans',
        waveColor: SariwaColors.statusModerate,
        trendColor: SariwaColors.statusModerate,
        points: const [0.18, 0.48, 0.28, 0.32, 0.62, 0.44, 0.78],
        showSparkline: false,
        isCompact: false,
        onTap: () {
          onFilterChanged('Non-Fresh');
          onNavigateSection('Scan Logs');
        },
      ),
      NotchedKpiCard(
        title: 'Avg. AI Confidence',
        value: total == 0 ? '—' : '${avgConfidence.toStringAsFixed(1)}%',
        trendText: 'Model score',
        comparisonText: 'not accuracy',
        waveColor: SariwaColors.brandPrimary,
        trendColor: SariwaColors.statusFresh,
        points: const [0.25, 0.68, 0.74, 0.45, 0.20, 0.35, 0.82],
        showSparkline: false,
        isCompact: false,
        onTap: () => onNavigateSection('Freshness Trends'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: 4 Notched KPI Cards with Sparkline Waves
        Row(
          children: List.generate(
            cards.length,
            (i) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: i == 0 ? 0 : 7,
                  right: i == cards.length - 1 ? 0 : 7,
                ),
                child: StaggeredReveal(staggerIndex: i + 1, child: cards[i]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),

        // Row 2: Middle Split Row — Live Freshness Inspection (60% / flex: 6) & Audit History (40% / flex: 4)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: StaggeredReveal(
                staggerIndex: 5,
                child: LiveScannerSection(
                  state: classState,
                  controller: classController,
                  isMobile: false,
                  isGuest: isGuest,
                  onSignInToSave: onSignIn,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 4,
              child: StaggeredReveal(
                staggerIndex: 6,
                child: AuditHistorySection(
                  state: classState,
                  controller: classController,
                  historyFilter: historyFilter,
                  onFilterChanged: onFilterChanged,
                  searchQuery: searchQuery,
                  isGuest: isGuest,
                  onSignIn: onSignIn,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),

        // Row 3: Bottom Full-Width Freshness Inspection Overview Chart Card
        StaggeredReveal(
          revealOnScroll: true,
          staggerIndex: 1,
          child: FreshnessTrendsSection(history: history),
        ),
        const SizedBox(height: 22),

        // Row 4: Grade Breakdown & AI Confidence Summary
        StaggeredReveal(
          revealOnScroll: true,
          staggerIndex: 2,
          child: GradeBreakdownSection(history: history),
        ),
      ],
    );
  }
}
