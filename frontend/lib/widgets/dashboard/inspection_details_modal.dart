import 'dart:ui' as ui;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../constants/config/app_breakpoints.dart';
import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';
import '../../models/classification/classification_result.dart';
import 'scan_thumbnail.dart';

/// Clean, compact scan details modal/sheet styled in the monochrome + surgical teal system.
class InspectionDetailsModal {
  static const Color _inkPrimary = Color(0xFF111111);
  static const Color _inkMuted = Color(0xFF737373);
  static const Color _divider = Color(0xFFE5E5E7);

  static String formatDateTime(DateTime? dt) {
    if (dt == null) return 'Recent scan';
    final local = dt.toLocal();
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
    final m = monthNames[local.month - 1];
    final d = local.day;
    final y = local.year;
    final hour = local.hour > 12
        ? local.hour - 12
        : (local.hour == 0 ? 12 : local.hour);
    final ampm = local.hour >= 12 ? 'PM' : 'AM';
    final min = local.minute.toString().padLeft(2, '0');
    return '$m $d, $y · $hour:$min $ampm';
  }

  static void show(
    BuildContext context,
    ClassificationResult scan, {
    VoidCallback? onDelete,
  }) {
    final isMobile = AppBreakpoints.isMobile(MediaQuery.of(context).size.width);
    final scanId = scan.scanId;
    final headerTitle =
        (scanId != null && scanId > 0) ? 'Scan #$scanId' : 'Scan Details';
    final regionLabel =
        (scan.regionType ?? 'Eye').toLowerCase() == 'gill' ? 'Gill' : 'Eye';
    final verdictColor =
        scan.isFresh ? SariwaColors.brandPrimary : const Color(0xFFDC2626);

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
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  color: _inkPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.xmark, size: 16),
                color: _inkMuted,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ScanThumbnail(
                scan: scan,
                size: 56,
                borderRadius: 10,
                iconSize: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          scan.isFresh
                              ? CupertinoIcons.checkmark_seal_fill
                              : CupertinoIcons.exclamationmark_triangle_fill,
                          color: verdictColor,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          scan.label,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            color: verdictColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Confidence · ${(scan.confidence * 100).round()}%',
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: _inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: _divider),
          const SizedBox(height: 12),
          _buildModalDetailRow('Region', regionLabel),
          const Divider(height: 16, color: _divider),
          _buildModalDetailRow('Date', formatDateTime(scan.createdAt)),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: onDelete != null
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.end,
            children: [
              if (onDelete != null)
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    onDelete();
                  },
                  icon: const Icon(
                    CupertinoIcons.trash,
                    size: 15,
                    color: Color(0xFFDC2626),
                  ),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              OutlinedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  side: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
                  foregroundColor: _inkPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  textStyle: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: const Text('Done'),
              ),
            ],
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
        barrierColor: Colors.black.withValues(alpha: 0.35),
        backgroundColor: Colors.white,
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
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) {
        return BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.08),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
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
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: _inkMuted,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _inkPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
