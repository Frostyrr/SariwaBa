import os

# ==========================================
# 1. Update classification_result.dart
# ==========================================
with open('frontend/lib/models/classification/classification_result.dart', 'r', encoding='utf-8') as f:
    c = f.read()

target = """  Color get statusColor {
    if (isFresh) return SariwaColors.statusFresh;
    return SariwaColors.statusSpoiled;
  }

  String get formattedConfidence => '${(confidence * 100).toStringAsFixed(1)}%';
}"""

replacement = """  Color get statusColor {
    if (isFresh) return SariwaColors.statusFresh;
    return SariwaColors.notFreshPrimary;
  }

  Color get textColor {
    if (isFresh) return SariwaColors.freshText;
    return SariwaColors.notFreshText;
  }

  Color get iconBgColor {
    if (isFresh) return SariwaColors.freshIconBg;
    return SariwaColors.notFreshIconBg;
  }

  Color get borderColor {
    if (isFresh) return SariwaColors.freshBorder;
    return SariwaColors.notFreshBorder;
  }

  Color get trackColor {
    if (isFresh) return SariwaColors.freshTrack;
    return SariwaColors.notFreshTrack;
  }

  Color get cardBgColor {
    if (isFresh) return SariwaColors.freshCardBg;
    return SariwaColors.notFreshCardBg;
  }

  String get formattedConfidence => '${(confidence * 100).toStringAsFixed(1)}%';
}"""

c = c.replace('\r\n', '\n')
target = target.replace('\r\n', '\n')
replacement = replacement.replace('\r\n', '\n')
assert target in c, "target not found in classification_result.dart"
c = c.replace(target, replacement, 1)

with open('frontend/lib/models/classification/classification_result.dart', 'w', encoding='utf-8') as f:
    f.write(c)
print("1. classification_result.dart updated!")


# ==========================================
# 2. Update classification_result_card.dart
# ==========================================
card_code = """import 'package:flutter/cupertino.dart';
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
      padding: const EdgeInsets.all(20),
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
              const Text(
                'Model Confidence',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: AppTypography.defaultLetterSpacing,
                  color: SariwaColors.textPrimaryDark,
                ),
              ),
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
"""

with open('frontend/lib/widgets/classification/classification_result_card.dart', 'w', encoding='utf-8') as f:
    f.write(card_code)
print("2. classification_result_card.dart updated!")


# ==========================================
# 3. Update roi_cropper_widget.dart
# ==========================================
with open('frontend/lib/widgets/classification/roi_cropper_widget.dart', 'r', encoding='utf-8') as f:
    cropper = f.read()

old_modal_result = """  /// Freshness Result View displayed directly inside the iOS ROI Modal
  Widget _buildModalResultView(
    ClassificationResult result,
    ClassificationState state,
    ClassificationController controller,
  ) {
    final isFresh = result.isFresh;
    final statusColor = result.statusColor;

    return Container(
      key: const Key('modal_classification_result_view'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Confirmed / Framed Image Thumbnail
          if (state.confirmedImageBytes != null ||
              state.selectedImageBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: _buildSafeMemoryImage(
                  state.confirmedImageBytes ?? state.selectedImageBytes!,
                  state.selectedImageName,
                ),
              ),
            ),
          const SizedBox(height: 16),

          // 2. SlothUI-style Result Breakdown Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.30),
                width: 1.0,
              ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusColor.withValues(alpha: 0.12),
                      ),
                      child: Icon(
                        isFresh
                            ? CupertinoIcons.checkmark_alt
                            : CupertinoIcons.exclamationmark_triangle,
                        color: statusColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      result.label,
                                      style: TextStyle(
                                        fontFamily: 'Geist',
                                        fontSize: 19,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing:
                                            AppTypography.defaultLetterSpacing,
                                        color: statusColor,
                                      ),
                                    ),
                                    if (result.selectedRegionLabel != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius:
                                              BorderRadius.circular(99),
                                        ),
                                        child: Text(
                                          result.selectedRegionLabel!,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: AppTypography.defaultLetterSpacing,
                                            color: SariwaColors.brandPrimary,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Icon(
                                isFresh
                                    ? CupertinoIcons.checkmark_circle_fill
                                    : CupertinoIcons.exclamationmark_circle_fill,
                                color: statusColor,
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: result.confidence.clamp(0.0, 1.0),
                              minHeight: 7,
                              backgroundColor: const Color(0xFFF1F5F9),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                statusColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'Model Confidence: ${result.formattedConfidence}',
                                  style: const TextStyle(
                                    fontFamily: 'Geist',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing:
                                        AppTypography.defaultLetterSpacing,
                                    color: SariwaColors.textPrimaryDark,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                result.formattedConfidence,
                                style: TextStyle(
                                  fontFamily: 'Geist',
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing:
                                      AppTypography.defaultLetterSpacing,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                          if (result.modelVersion != null) ...[
                            const SizedBox(height: 3),
                            Text(
                              'Model: ${result.modelVersion}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                letterSpacing:
                                    AppTypography.defaultLetterSpacing,
                                color: SariwaColors.textSecondaryDark,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),"""

new_modal_result = """  /// Freshness Result View displayed directly inside the iOS ROI Modal
  Widget _buildModalResultView(
    ClassificationResult result,
    ClassificationState state,
    ClassificationController controller,
  ) {
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
      key: const Key('modal_classification_result_view'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Confirmed / Framed Image Thumbnail
          if (state.confirmedImageBytes != null ||
              state.selectedImageBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: borderColor,
                    width: 1.5,
                  ),
                ),
                child: _buildSafeMemoryImage(
                  state.confirmedImageBytes ?? state.selectedImageBytes!,
                  state.selectedImageName,
                ),
              ),
            ),
          const SizedBox(height: 16),

          // 2. Refined Result Breakdown Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: borderColor,
                width: 1.0,
              ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      result.label,
                                      style: TextStyle(
                                        fontFamily: 'Geist',
                                        fontSize: 19,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing:
                                            AppTypography.defaultLetterSpacing,
                                        color: textColor,
                                      ),
                                    ),
                                    if (result.selectedRegionLabel != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius:
                                              BorderRadius.circular(99),
                                        ),
                                        child: Text(
                                          result.selectedRegionLabel!,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: AppTypography.defaultLetterSpacing,
                                            color: SariwaColors.brandPrimary,
                                          ),
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
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Single row confidence presentation
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Model Confidence',
                                style: TextStyle(
                                  fontFamily: 'Geist',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing:
                                      AppTypography.defaultLetterSpacing,
                                  color: SariwaColors.textPrimaryDark,
                                ),
                              ),
                              Text(
                                result.formattedConfidence,
                                style: TextStyle(
                                  fontFamily: 'Geist',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing:
                                      AppTypography.defaultLetterSpacing,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Dynamic confidence progress bar directly below
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: result.confidence.clamp(0.0, 1.0),
                              minHeight: 7,
                              backgroundColor: trackColor,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                primaryColor,
                              ),
                            ),
                          ),
                          if (result.modelVersion != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Model: ${result.modelVersion}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                letterSpacing:
                                    AppTypography.defaultLetterSpacing,
                                color: SariwaColors.textSecondaryDark,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),"""

cropper = cropper.replace('\r\n', '\n')
old_modal_result = old_modal_result.replace('\r\n', '\n')
new_modal_result = new_modal_result.replace('\r\n', '\n')
assert old_modal_result in cropper, "old_modal_result not found in roi_cropper_widget.dart"
cropper = cropper.replace(old_modal_result, new_modal_result, 1)

with open('frontend/lib/widgets/classification/roi_cropper_widget.dart', 'w', encoding='utf-8') as f:
    f.write(cropper)
print("3. roi_cropper_widget.dart updated!")


# ==========================================
# 4. Update dashboard_page.dart
# ==========================================
with open('frontend/lib/pages/dashboard/dashboard_page.dart', 'r', encoding='utf-8') as f:
    dash = f.read()

# Update _buildInspectionResultView
old_result_view = """  Widget _buildInspectionResultView(ClassificationResult result) {
    final selectedRegionText = result.selectedRegionLabel;
    final timestampText = result.formattedTimestamp;

    return Container(
      key: const Key('classification_result_view'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: result.statusColor.withValues(alpha: 0.30),
                width: 1.0,
              ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: result.statusColor.withValues(alpha: 0.12),
                      ),
                      child: Icon(
                        result.isFresh
                            ? CupertinoIcons.checkmark_alt
                            : CupertinoIcons.exclamationmark_triangle,
                        color: result.statusColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      result.label,
                                      style: TextStyle(
                                        fontFamily: 'Geist',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing:
                                            AppTypography.defaultLetterSpacing,
                                        color: result.statusColor,
                                      ),
                                    ),
                                    if (selectedRegionText != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius:
                                              BorderRadius.circular(99),
                                        ),
                                        child: Text(
                                          selectedRegionText,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: AppTypography.defaultLetterSpacing,
                                            color: SariwaColors.brandPrimary,
                                          ),
                                        ),
                                      ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(99),
                                      ),
                                      child: Text(
                                        result.assessmentScopeLabel,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: AppTypography.defaultLetterSpacing,
                                          color:
                                              SariwaColors.textSecondaryDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                result.isFresh
                                    ? CupertinoIcons.checkmark_circle_fill
                                    : CupertinoIcons.exclamationmark_circle_fill,
                                color: result.statusColor,
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: result.confidence.clamp(0.0, 1.0),
                              minHeight: 7,
                              backgroundColor: const Color(0xFFF1F5F9),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                result.statusColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'Model Confidence: ${result.formattedConfidence}',
                                  style: const TextStyle(
                                    fontFamily: 'Geist',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing:
                                        AppTypography.defaultLetterSpacing,
                                    color: SariwaColors.textPrimaryDark,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                result.formattedConfidence,
                                style: TextStyle(
                                  fontFamily: 'Geist',
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing:
                                      AppTypography.defaultLetterSpacing,
                                  color: result.statusColor,
                                ),
                              ),
                            ],
                          ),
                          if (timestampText != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Classified at: $timestampText',
                              style: const TextStyle(
                                fontSize: 11.5,
                                letterSpacing:
                                    AppTypography.defaultLetterSpacing,
                                color: SariwaColors.textSecondaryDark,
                              ),
                            ),
                          ],
                          if (result.modelVersion != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Model: ${result.modelVersion}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                letterSpacing:
                                    AppTypography.defaultLetterSpacing,
                                color: SariwaColors.textSecondaryDark,
                              ),
                            ),
                          ],
                          const SizedBox(height: 3),
                          const Text(
                            ClassificationResult.confidenceExplanation,
                            style: TextStyle(
                              fontSize: 11.5,
                              letterSpacing:
                                  AppTypography.defaultLetterSpacing,
                              color: SariwaColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),"""

new_result_view = """  Widget _buildInspectionResultView(ClassificationResult result) {
    final selectedRegionText = result.selectedRegionLabel;
    final timestampText = result.formattedTimestamp;

    final isNotFresh = result.isNotFresh;
    final primaryColor =
        isNotFresh ? SariwaColors.notFreshPrimary : SariwaColors.brandPrimary;
    final textColor =
        isNotFresh ? SariwaColors.notFreshText : SariwaColors.freshText;
    final iconBgColor =
        isNotFresh ? SariwaColors.notFreshIconBg : SariwaColors.freshIconBg;
    final cardBorderColor =
        isNotFresh ? SariwaColors.notFreshBorder : SariwaColors.freshBorder;
    final trackColor =
        isNotFresh ? SariwaColors.notFreshTrack : SariwaColors.freshTrack;
    final cardBgColor =
        isNotFresh ? SariwaColors.notFreshCardBg : SariwaColors.freshCardBg;

    return Container(
      key: const Key('classification_result_view'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: cardBorderColor,
                width: 1.0,
              ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      result.label,
                                      style: TextStyle(
                                        fontFamily: 'Geist',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing:
                                            AppTypography.defaultLetterSpacing,
                                        color: textColor,
                                      ),
                                    ),
                                    if (selectedRegionText != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius:
                                              BorderRadius.circular(99),
                                        ),
                                        child: Text(
                                          selectedRegionText,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: AppTypography.defaultLetterSpacing,
                                            color: SariwaColors.brandPrimary,
                                          ),
                                        ),
                                      ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(99),
                                      ),
                                      child: Text(
                                        result.assessmentScopeLabel,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: AppTypography.defaultLetterSpacing,
                                          color:
                                              SariwaColors.textSecondaryDark,
                                        ),
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
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Single row confidence presentation
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Model Confidence',
                                style: TextStyle(
                                  fontFamily: 'Geist',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing:
                                      AppTypography.defaultLetterSpacing,
                                  color: SariwaColors.textPrimaryDark,
                                ),
                              ),
                              Text(
                                result.formattedConfidence,
                                style: TextStyle(
                                  fontFamily: 'Geist',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing:
                                      AppTypography.defaultLetterSpacing,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Dynamic confidence progress bar directly below
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: result.confidence.clamp(0.0, 1.0),
                              minHeight: 7,
                              backgroundColor: trackColor,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                primaryColor,
                              ),
                            ),
                          ),
                          if (timestampText != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Classified at: $timestampText',
                              style: const TextStyle(
                                fontSize: 11.5,
                                letterSpacing:
                                    AppTypography.defaultLetterSpacing,
                                color: SariwaColors.textSecondaryDark,
                              ),
                            ),
                          ],
                          if (result.modelVersion != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Model: ${result.modelVersion}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                letterSpacing:
                                    AppTypography.defaultLetterSpacing,
                                color: SariwaColors.textSecondaryDark,
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          const Text(
                            ClassificationResult.confidenceExplanation,
                            style: TextStyle(
                              fontSize: 11.5,
                              letterSpacing:
                                  AppTypography.defaultLetterSpacing,
                              color: SariwaColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),"""

dash = dash.replace('\r\n', '\n')
old_result_view = old_result_view.replace('\r\n', '\n')
new_result_view = new_result_view.replace('\r\n', '\n')
assert old_result_view in dash, "old_result_view not found in dashboard_page.dart"
dash = dash.replace(old_result_view, new_result_view, 1)

# Update KPI metrics 'Not Fresh Alerts' card colors
dash = dash.replace(
    """          _buildMetricBox(
            title: 'Not Fresh Alerts',
            value: cautionCount.toString(),
            subtitle: 'Needs attention',
            icon: CupertinoIcons.exclamationmark_triangle,
            iconColor: SariwaColors.statusModerate,
            iconBg: SariwaColors.statusModerate.withValues(alpha: 0.10),
          ),""",
    """          _buildMetricBox(
            title: 'Not Fresh Alerts',
            value: cautionCount.toString(),
            subtitle: 'Needs attention',
            icon: CupertinoIcons.exclamationmark_triangle,
            iconColor: SariwaColors.notFreshPrimary,
            iconBg: SariwaColors.notFreshIconBg,
          ),"""
)

# Update _showInspectionDetailsModal
old_modal_detail = """                      decoration: BoxDecoration(
                        color: scan.isFresh
                            ? const Color(0xFFF0FDF4)
                            : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: scan.isFresh
                              ? const Color(0xFFBBF7D0)
                              : const Color(0xFFFECACA),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            scan.isFresh
                                ? CupertinoIcons.checkmark_seal_fill
                                : CupertinoIcons.exclamationmark_triangle_fill,
                            color: scan.isFresh
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFEF4444),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                scan.label,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing:
                                      AppTypography.defaultLetterSpacing,
                                  color: scan.isFresh
                                      ? const Color(0xFF15803D)
                                      : const Color(0xFFB91C1C),
                                ),
                              ),"""

new_modal_detail = """                      decoration: BoxDecoration(
                        color: scan.isFresh
                            ? SariwaColors.freshIconBg
                            : SariwaColors.notFreshIconBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: scan.isFresh
                              ? SariwaColors.freshBorder
                              : SariwaColors.notFreshBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            scan.isFresh
                                ? CupertinoIcons.checkmark_seal_fill
                                : CupertinoIcons.exclamationmark_triangle_fill,
                            color: scan.isFresh
                                ? const Color(0xFF16A34A)
                                : SariwaColors.notFreshPrimary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                scan.label,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing:
                                      AppTypography.defaultLetterSpacing,
                                  color: scan.isFresh
                                      ? SariwaColors.freshText
                                      : SariwaColors.notFreshText,
                                ),
                              ),"""

old_modal_detail = old_modal_detail.replace('\r\n', '\n')
new_modal_detail = new_modal_detail.replace('\r\n', '\n')
if old_modal_detail in dash:
    dash = dash.replace(old_modal_detail, new_modal_detail, 1)

# Update DataTable status badge and progress indicator in _buildDesktopDataTable
dash = dash.replace(
    """                          child: _buildDetailBadge(
                            label: scan.label,
                            bg: scan.isFresh
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEE2E2),
                            text: scan.isFresh
                                ? const Color(0xFF15803D)
                                : const Color(0xFFB91C1C),
                          ),""",
    """                          child: _buildDetailBadge(
                            label: scan.label,
                            bg: scan.isFresh
                                ? SariwaColors.freshTrack
                                : SariwaColors.notFreshTrack,
                            text: scan.isFresh
                                ? SariwaColors.freshText
                                : SariwaColors.notFreshText,
                          ),"""
)

dash = dash.replace(
    """                                  backgroundColor: const Color(0xFFE2E8F0),
                                  valueColor: AlwaysStoppedAnimation(
                                    scan.isFresh
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFEF4444),
                                  ),""",
    """                                  backgroundColor: scan.isFresh
                                      ? const Color(0xFFE2E8F0)
                                      : SariwaColors.notFreshTrack,
                                  valueColor: AlwaysStoppedAnimation(
                                    scan.isFresh
                                        ? const Color(0xFF16A34A)
                                        : SariwaColors.notFreshPrimary,
                                  ),"""
)

dash = dash.replace(
    """                          decoration: BoxDecoration(
                            color: scan.isFresh
                                ? const Color(0xFFF0FDF4)
                                : const Color(0xFFFEF2F2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            scan.isFresh
                                ? CupertinoIcons.checkmark_seal_fill
                                : CupertinoIcons.exclamationmark_triangle_fill,
                            size: 15,
                            color: scan.isFresh
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFEF4444),
                          ),""",
    """                          decoration: BoxDecoration(
                            color: scan.isFresh
                                ? SariwaColors.freshIconBg
                                : SariwaColors.notFreshIconBg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            scan.isFresh
                                ? CupertinoIcons.checkmark_seal_fill
                                : CupertinoIcons.exclamationmark_triangle_fill,
                            size: 15,
                            color: scan.isFresh
                                ? const Color(0xFF16A34A)
                                : SariwaColors.notFreshPrimary,
                          ),"""
)

# Update Mobile list status badge in _buildMobileHistoryList
dash = dash.replace(
    """                  _buildDetailBadge(
                    label: scan.label,
                    bg: scan.isFresh
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFFEE2E2),
                    text: scan.isFresh
                        ? const Color(0xFF15803D)
                        : const Color(0xFFB91C1C),
                  ),""",
    """                  _buildDetailBadge(
                    label: scan.label,
                    bg: scan.isFresh
                        ? SariwaColors.freshTrack
                        : SariwaColors.notFreshTrack,
                    text: scan.isFresh
                        ? SariwaColors.freshText
                        : SariwaColors.notFreshText,
                  ),"""
)

# Update Analytics ratio bar Not Fresh color
dash = dash.replace(
    """                                  if (notFreshCount > 0)
                                    Expanded(
                                      flex: notFreshCount,
                                      child: Container(
                                        color: const Color(0xFFEF4444),
                                      ),
                                    ),""",
    """                                  if (notFreshCount > 0)
                                    Expanded(
                                      flex: notFreshCount,
                                      child: Container(
                                        color: SariwaColors.notFreshPrimary,
                                      ),
                                    ),"""
)

dash = dash.replace(
    """                        _buildDistributionLegend(
                          label: 'Not Fresh: $notFreshPct%',
                          color: const Color(0xFFEF4444),
                        ),""",
    """                        _buildDistributionLegend(
                          label: 'Not Fresh: $notFreshPct%',
                          color: SariwaColors.notFreshPrimary,
                        ),"""
)

with open('frontend/lib/pages/dashboard/dashboard_page.dart', 'w', encoding='utf-8') as f:
    f.write(dash)
print("4. dashboard_page.dart updated!")


# ==========================================
# 5. Update widget_test.dart
# ==========================================
with open('frontend/test/widget_test.dart', 'r', encoding='utf-8') as f:
    wt = f.read()

wt = wt.replace(
    "expect(find.text('Model Confidence: 94.2%'), findsOneWidget);",
    "expect(find.text('Model Confidence'), findsOneWidget);\n    expect(find.text('94.2%'), findsWidgets);"
)

with open('frontend/test/widget_test.dart', 'w', encoding='utf-8') as f:
    f.write(wt)
print("5. widget_test.dart updated!")
