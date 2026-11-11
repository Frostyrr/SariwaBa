import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';

/// High-contrast delete confirmation dialogs with frosted blur background.
class HistoryDeleteDialog {
  static Future<bool?> showSingle({
    required BuildContext context,
    required int scanId,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogCtx) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
        child: AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SariwaColors.statusSpoiled.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  CupertinoIcons.trash,
                  color: SariwaColors.statusSpoiled,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Delete Scan Record?',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: SariwaColors.textPrimaryDark,
                    letterSpacing: AppTypography.defaultLetterSpacing,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to permanently delete Scan #$scanId from your history?',
            style: const TextStyle(
              fontFamily: 'Geist',
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: SariwaColors.textSecondaryDark,
              letterSpacing: AppTypography.defaultLetterSpacing,
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              style: TextButton.styleFrom(
                foregroundColor: SariwaColors.textSecondaryDark,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontWeight: FontWeight.w600,
                  color: SariwaColors.textSecondaryDark,
                  letterSpacing: AppTypography.defaultLetterSpacing,
                ),
              ),
            ),
            ElevatedButton(
              key: const Key('confirm_delete_button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SariwaColors.statusSpoiled,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              onPressed: () => Navigator.pop(dialogCtx, true),
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontWeight: FontWeight.w700,
                  letterSpacing: AppTypography.defaultLetterSpacing,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<bool?> showBulk({
    required BuildContext context,
    required List<int> scanIds,
  }) {
    if (scanIds.isEmpty) return Future.value(false);
    final count = scanIds.length;
    return showDialog<bool>(
      context: context,
      builder: (dialogCtx) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
        child: AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SariwaColors.statusSpoiled.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  CupertinoIcons.trash,
                  color: SariwaColors.statusSpoiled,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  count == 1
                      ? 'Delete Scan Record?'
                      : 'Delete $count Scan Records?',
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: SariwaColors.textPrimaryDark,
                    letterSpacing: AppTypography.defaultLetterSpacing,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            count == 1
                ? 'Are you sure you want to permanently delete Scan #${scanIds.first} from your history?'
                : 'Are you sure you want to permanently delete $count selected scans from your history?',
            style: const TextStyle(
              fontFamily: 'Geist',
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: SariwaColors.textSecondaryDark,
              letterSpacing: AppTypography.defaultLetterSpacing,
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              style: TextButton.styleFrom(
                foregroundColor: SariwaColors.textSecondaryDark,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontWeight: FontWeight.w600,
                  color: SariwaColors.textSecondaryDark,
                  letterSpacing: AppTypography.defaultLetterSpacing,
                ),
              ),
            ),
            ElevatedButton(
              key: const Key('confirm_bulk_delete_button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SariwaColors.statusSpoiled,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              onPressed: () => Navigator.pop(dialogCtx, true),
              child: Text(
                count == 1 ? 'Delete' : 'Delete ($count)',
                style: const TextStyle(
                  fontFamily: 'Geist',
                  fontWeight: FontWeight.w700,
                  letterSpacing: AppTypography.defaultLetterSpacing,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
