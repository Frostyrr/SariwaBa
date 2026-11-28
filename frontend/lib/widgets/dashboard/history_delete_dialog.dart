import 'dart:ui' as ui;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../constants/theme/app_typography.dart';
import '../../models/classification/classification_result.dart';

/// Monochrome delete confirmation dialogs with human-readable copy and
/// constrained max-width (`400px`).
class HistoryDeleteDialog {
  static const Color _inkPrimary = Color(0xFF111111);
  static const Color _inkSecondary = Color(0xFF525252);
  static const Color _destructiveRed = Color(0xFFDC2626);

  static String _formatShortDateTime(DateTime? dt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final m = months[local.month - 1];
    final d = local.day;
    final hour = local.hour > 12
        ? local.hour - 12
        : (local.hour == 0 ? 12 : local.hour);
    final ampm = local.hour >= 12 ? 'PM' : 'AM';
    final min = local.minute.toString().padLeft(2, '0');
    return '$m $d, $hour:$min $ampm';
  }

  static String _singleDeleteCopy(int scanId, ClassificationResult? scan) {
    if (scan != null) {
      final region =
          (scan.regionType ?? 'Eye').toLowerCase() == 'gill' ? 'Gill' : 'Eye';
      final when = _formatShortDateTime(scan.createdAt);
      if (when.isNotEmpty) {
        return 'Are you sure you want to permanently delete this $region scan from $when?';
      }
      return 'Are you sure you want to permanently delete this $region scan from your history?';
    }
    if (scanId > 0) {
      return 'Are you sure you want to permanently delete Scan #$scanId from your history?';
    }
    return 'Are you sure you want to permanently delete this scan from your history?';
  }

  static Future<bool?> showSingle({
    required BuildContext context,
    required int scanId,
    ClassificationResult? scan,
  }) {
    return _showConstrainedDialog(
      context: context,
      title: 'Delete Scan Record?',
      body: _singleDeleteCopy(scanId, scan),
      confirmLabel: 'Delete',
      confirmButtonKey: const Key('confirm_delete_button'),
    );
  }

  static Future<bool?> showBulk({
    required BuildContext context,
    required List<int> scanIds,
  }) {
    if (scanIds.isEmpty) return Future.value(false);
    final count = scanIds.length;
    final singleId = scanIds.first;
    final body = count == 1
        ? _singleDeleteCopy(singleId, null)
        : 'Are you sure you want to permanently delete $count selected scans from your history?';

    return _showConstrainedDialog(
      context: context,
      title: count == 1 ? 'Delete Scan Record?' : 'Delete $count Scan Records?',
      body: body,
      confirmLabel: count == 1 ? 'Delete' : 'Delete ($count)',
      confirmButtonKey: const Key('confirm_bulk_delete_button'),
    );
  }

  static Future<bool?> _showConstrainedDialog({
    required BuildContext context,
    required String title,
    required String body,
    required String confirmLabel,
    required Key confirmButtonKey,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (dialogCtx) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _destructiveRed.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          CupertinoIcons.trash,
                          color: _destructiveRed,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _inkPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    body,
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: _inkSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(dialogCtx, false),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _inkPrimary,
                          side: BorderSide(
                            color: Colors.black.withValues(alpha: 0.12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 11,
                          ),
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        key: confirmButtonKey,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _destructiveRed,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 11,
                          ),
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onPressed: () => Navigator.pop(dialogCtx, true),
                        child: Text(confirmLabel),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
