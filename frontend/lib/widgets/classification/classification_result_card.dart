import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';
import '../../models/classification/classification_result.dart';

/// Shared by live results and the explicitly labelled landing-page example.
class ClassificationResultCard extends StatelessWidget {
  final ClassificationResult result;
  const ClassificationResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isNotFresh = result.isNotFresh;
    final primaryColor =
        isNotFresh ? SariwaColors.notFreshPrimary : SariwaColors.brandPrimary;
    final textColor =
        isNotFresh ? SariwaColors.notFreshText : SariwaColors.freshText;
    final iconBgColor =
        isNotFresh ? SariwaColors.notFreshIconBg : SariwaColors.freshIconBg;
    final borderColor =
        isNotFresh ? SariwaColors.notFreshBorder : SariwaColors.freshBorder;
    final trackColor =
        isNotFresh ? SariwaColors.notFreshTrack : SariwaColors.freshTrack;
    final cardBgColor =
        isNotFresh ? SariwaColors.notFreshCardBg : SariwaColors.freshCardBg;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        border: Border.all(color: borderColor, width: 1.0),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconBgColor,
                ),
                child: Icon(
                  result.isFresh
                      ? CupertinoIcons.checkmark_alt
                      : CupertinoIcons.exclamationmark_triangle,
                  color: primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Predicted label',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: AppTypography.defaultLetterSpacing,
                        color: SariwaColors.textSecondaryDark,
                      ),
                    ),
                    Text(
                      result.label,
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: AppTypography.defaultLetterSpacing,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                result.isFresh
                    ? CupertinoIcons.checkmark_circle_fill
                    : CupertinoIcons.exclamationmark_circle_fill,
                color: primaryColor,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Single row confidence presentation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Model Confidence',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: AppTypography.defaultLetterSpacing,
                    color: SariwaColors.textPrimaryDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                result.formattedConfidence,
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: AppTypography.defaultLetterSpacing,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: result.confidence.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: trackColor,
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              semanticsLabel: 'Model confidence',
              semanticsValue: result.formattedConfidence,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            ClassificationResult.confidenceExplanation,
            style: TextStyle(
              fontSize: 11.5,
              letterSpacing: AppTypography.defaultLetterSpacing,
              color: SariwaColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            ClassificationResult.defaultDisclaimer,
            style: TextStyle(
              fontSize: 11.5,
              letterSpacing: AppTypography.defaultLetterSpacing,
              color: SariwaColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
