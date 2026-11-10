import 'package:flutter/material.dart';

import '../../../models/classification/classification_result.dart';

class FreshnessTrendsSection extends StatelessWidget {
  final List<ClassificationResult> history;
  const FreshnessTrendsSection({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<ClassificationResult>>{};
    for (final scan in history) {
      final date = scan.createdAt?.toLocal();
      if (date == null) continue;
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      groups.putIfAbsent(key, () => []).add(scan);
    }
    final months = groups.keys.toList()..sort((a, b) => b.compareTo(a));
    final undated = history.where((s) => s.createdAt == null).length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Predictions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Counts from available dated scans, grouped by local calendar month.',
            ),
            const SizedBox(height: 16),
            if (months.isEmpty) const Text('No dated scans available yet.'),
            for (final month in months)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  '$month: ${groups[month]!.length} scans · '
                  '${groups[month]!.where((s) => s.isFresh).length} Fresh · '
                  '${groups[month]!.where((s) => s.isNotFresh).length} Not Fresh',
                ),
              ),
            if (undated > 0)
              Text('$undated scans without a timestamp are excluded.'),
          ],
        ),
      ),
    );
  }
}
