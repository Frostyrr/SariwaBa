import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/classification_result.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Modal dialog presenting detailed specimen metadata and organoleptic notes for an inspection scan.
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
    showDialog<void>(
      context: context,
      barrierColor: const Color(0x330A1926),
      builder: (ctx) {
        return BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.95),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                          spreadRadius: -2,
                        ),
                        BoxShadow(
                          color: const Color(0xFF14B8A6).withValues(alpha: 0.06),
                          blurRadius: 36,
                          offset: const Offset(0, 12),
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Inspection #${scan.scanId ?? ''}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: AppTypography.defaultLetterSpacing,
                                color: SariwaColors.textPrimaryDark,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(CupertinoIcons.xmark, size: 18),
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(14),
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
                                  ),
                                  Text(
                                    'Model Confidence: ${(scan.confidence * 100).toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing:
                                          AppTypography.defaultLetterSpacing,
                                      color: SariwaColors.textSecondaryDark,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildModalDetailRow(
                          'Region Examined',
                          scan.regionType ?? 'Eye',
                        ),
                        _buildModalDetailRow(
                          'Species Scope',
                          'Oreochromis niloticus (Tilapia)',
                        ),
                        _buildModalDetailRow(
                          'Timestamp',
                          formatDateTime(scan.createdAt),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'PNS Sensory Note: Fresh Tilapia eyes are clear, bright, and slightly convex. Exposed gills must exhibit bright red coloration and fresh neutral marine aroma.',
                            style: TextStyle(
                              fontSize: 11.5,
                              height: 1.4,
                              letterSpacing: AppTypography.defaultLetterSpacing,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Close'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              letterSpacing: AppTypography.defaultLetterSpacing,
              color: Color(0xFF64748B),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              letterSpacing: AppTypography.defaultLetterSpacing,
              color: SariwaColors.textPrimaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
