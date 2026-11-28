import 'dart:ui' as ui;
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import '../../constants/config/app_breakpoints.dart';
import '../../models/classification/classification_result.dart';
import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';

/// Clean, compact scan details modal/sheet without scientific Latin or standards jargon.
class InspectionDetailsModal {
  static String formatDateTime(DateTime? dt) {
    if (dt == null) return 'Recent scan';
    const monthNames = [
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
    final m = monthNames[dt.month - 1];
    final d = dt.day;
    final y = dt.year;
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '$m $d, $y · $hour:$min $ampm';
  }

  static void show(BuildContext context, ClassificationResult scan) {
    final isMobile = AppBreakpoints.isMobile(MediaQuery.of(context).size.width);
    final scanId = scan.scanId;
    final headerTitle =
        (scanId != null && scanId > 0) ? 'Scan #$scanId' : 'Scan Details';
    final regionLabel =
        (scan.regionType ?? 'Eye').toLowerCase() == 'gill' ? 'Gill' : 'Eye';

    Widget buildBody(BuildContext ctx) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                headerTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: AppTypography.defaultLetterSpacing,
                  color: SariwaColors.textPrimaryDark,
                ),
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.xmark, size: 16),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
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
                      ? SariwaColors.statusFresh
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
                        fontWeight: FontWeight.w500,
                        letterSpacing: AppTypography.defaultLetterSpacing,
                        color: scan.isFresh
                            ? SariwaColors.freshText
                            : SariwaColors.notFreshText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Confidence · ${(scan.confidence * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        letterSpacing: AppTypography.defaultLetterSpacing,
                        color: SariwaColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildModalDetailRow('Region', regionLabel),
          const Divider(height: 16, color: SariwaColors.colorLineSubtle),
          _buildModalDetailRow('Date', formatDateTime(scan.createdAt)),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: OutlinedButton.styleFrom(
                shape: const StadiumBorder(),
                side: const BorderSide(color: SariwaColors.colorLine),
                foregroundColor: SariwaColors.textPrimaryDark,
              ),
              child: const Text('Done'),
            ),
          ),
        ],
      );
    }

    if (isMobile) {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        backgroundColor: SariwaColors.cardSurfaceLight,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: SingleChildScrollView(child: buildBody(ctx)),
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierColor: SariwaColors.liquidGlassShadow,
      builder: (ctx) {
        return BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: SariwaColors.cardSurfaceLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: SariwaColors.colorLine),
                  boxShadow: const [
                    BoxShadow(
                      color: SariwaColors.shadowSubtle,
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: buildBody(ctx),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildModalDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: AppTypography.defaultLetterSpacing,
              color: SariwaColors.inkSlateMuted,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: AppTypography.defaultLetterSpacing,
              color: SariwaColors.textPrimaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
