import 'package:flutter/material.dart';

import '../../models/classification/classification_result.dart';

/// Shared by live results and the explicitly labelled landing-page example.
class ClassificationResultCard extends StatelessWidget {
  final ClassificationResult result;
  const ClassificationResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: result.statusColor.withValues(alpha: 0.08),
        border: Border.all(color: result.statusColor.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Predicted label'),
          const SizedBox(height: 6),
          Text(result.label, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Text(
            'Model confidence: ${result.formattedConfidence}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: result.confidence.clamp(0.0, 1.0),
            semanticsLabel: 'Model confidence',
            semanticsValue: result.formattedConfidence,
          ),
          const SizedBox(height: 12),
          const Text(
            'Confidence is the model score for this prediction, not a freshness percentage or a measure of overall accuracy.',
          ),
          const SizedBox(height: 12),
          const Text(
            'This image prediction does not establish food safety. The model does not return separate eye, gill, or scale assessments.',
          ),
        ],
      ),
    );
  }
}
