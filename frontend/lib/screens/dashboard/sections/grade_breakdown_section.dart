import 'package:flutter/material.dart';

import '../../../models/classification/classification_result.dart';

class GradeBreakdownSection extends StatelessWidget {
  final List<ClassificationResult> history;
  const GradeBreakdownSection({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final fresh = history.where((s) => s.isFresh).length;
    final notFresh = history.where((s) => s.isNotFresh).length;
    final unknown = history.length - fresh - notFresh;
    final average = history.isEmpty
        ? null
        : history.fold(0.0, (sum, s) => sum + s.confidence) / history.length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Classification Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Based on available scan history. These are model predictions, not verified grades.',
            ),
            const SizedBox(height: 20),
            if (history.isEmpty)
              const Text('No scans yet. Classify an image to see your summary.')
            else ...[
              _count('Fresh', fresh),
              _count('Not Fresh', notFresh),
              if (unknown > 0) _count('Unknown label', unknown),
              const Divider(height: 32),
              Text(
                'Average model confidence: ${(average! * 100).toStringAsFixed(1)}%',
              ),
              const SizedBox(height: 8),
              const Text(
                'An average of prediction scores, not measured model accuracy.',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _count(String label, int count) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: $count of ${history.length} scans'),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: count / history.length,
          semanticsLabel: '$label scans',
        ),
      ],
    ),
  );
}
