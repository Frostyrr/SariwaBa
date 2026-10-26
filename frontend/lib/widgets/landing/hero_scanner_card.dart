import 'package:flutter/material.dart';

import '../../models/classification/classification_result.dart';
import '../classification/classification_result_card.dart';

class HeroScannerCard extends StatelessWidget {
  const HeroScannerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Example result',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Illustrative values only. Upload an image in the scanner for a real prediction.',
            ),
            const SizedBox(height: 16),
            const ClassificationResultCard(
              result: ClassificationResult(label: 'Fresh', confidence: 0.92),
            ),
            const SizedBox(height: 16),
            const Text(
              'Possible labels: Fresh or Not Fresh. Sign in before scanning to save results to your account.',
            ),
          ],
        ),
      ),
    );
  }
}
