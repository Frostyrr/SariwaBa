import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../controllers/classification/classification_controller.dart';
import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';
import 'frosted_glass_card.dart';

/// Notification banner displaying errors, rejections, or success messages with recovery actions.
class DashboardNotificationBanner extends StatelessWidget {
  final String message;
  final bool isError;
  final ClassificationState state;
  final ClassificationController controller;
  final VoidCallback onOpenCropModal;

  const DashboardNotificationBanner({
    super.key,
    required this.message,
    required this.isError,
    required this.state,
    required this.controller,
    required this.onOpenCropModal,
  });

  @override
  Widget build(BuildContext context) {
    final color = isError
        ? (state.isInputRejection
            ? SariwaColors.statusModerate
            : SariwaColors.statusSpoiled)
        : SariwaColors.statusFresh;

    final showRecoveryActions =
        isError && state.hasSelectedImage && !state.isClassifying;

    return FrostedGlassCard(
      key: Key(
        isError ? 'error_notification_banner' : 'success_notification_banner',
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      borderRadius: 18,
      borderColor: color.withValues(alpha: 0.35),
      blurSigma: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isError
                    ? (state.isInputRejection
                        ? CupertinoIcons.exclamationmark_circle_fill
                        : CupertinoIcons.xmark_octagon_fill)
                    : CupertinoIcons.checkmark_circle_fill,
                color: color,
                size: 19,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isError && state.errorCode != null) ...[
                      Text(
                        state.isInputRejection
                            ? 'Input Rejected (${state.errorCode})'
                            : 'Request Error (${state.errorCode})',
                        style: TextStyle(
                          color: color,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                          letterSpacing: AppTypography.defaultLetterSpacing,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      message,
                      style: const TextStyle(
                        color: SariwaColors.textPrimaryDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        letterSpacing: AppTypography.defaultLetterSpacing,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showRecoveryActions) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (state.isCropConfirmed)
                  OutlinedButton.icon(
                    key: const Key('banner_edit_crop_button'),
                    onPressed: () {
                      controller.editCrop();
                      onOpenCropModal();
                    },
                    icon: const Icon(CupertinoIcons.crop, size: 14),
                    label: const Text('Edit Crop'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SariwaColors.brandPrimary,
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      backgroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                OutlinedButton.icon(
                  key: const Key('banner_replace_image_button'),
                  onPressed: () => controller.clearSelection(),
                  icon: const Icon(CupertinoIcons.arrow_2_squarepath, size: 14),
                  label: const Text('Replace Image'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SariwaColors.statusSpoiled,
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    backgroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                if (state.isReadyToClassify)
                  ElevatedButton.icon(
                    key: const Key('banner_retry_button'),
                    onPressed: () => controller.classify(),
                    icon: const Icon(CupertinoIcons.refresh, size: 14),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SariwaColors.brandPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
