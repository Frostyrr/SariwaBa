import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../controllers/classification/classification_controller.dart';
import '../../models/classification/classification_result.dart';
import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';
import 'frosted_glass_card.dart';
import 'history_delete_dialog.dart';

/// Embedded Audit History card for the workstation tab with selection mode, filtering, and deletion.
class AuditHistoryCard extends StatefulWidget {
  final ClassificationState state;
  final ClassificationController controller;
  final VoidCallback? onViewMore;
  final int maxDisplayItems;

  const AuditHistoryCard({
    super.key,
    required this.state,
    required this.controller,
    this.onViewMore,
    this.maxDisplayItems = 5,
  });

  @override
  State<AuditHistoryCard> createState() => _AuditHistoryCardState();
}

class _AuditHistoryCardState extends State<AuditHistoryCard> {
  String _historyFilter = 'All'; // 'All', 'Fresh', 'Not Fresh'
  bool _isSelectionMode = false;
  final Set<int> _selectedScanIds = <int>{};

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final controller = widget.controller;

    // Keep selection synchronized with current history
    final existingIds = state.history
        .map((s) => s.scanId)
        .whereType<int>()
        .toSet();
    _selectedScanIds.removeWhere((id) => !existingIds.contains(id));

    var filtered = state.history;
    if (_historyFilter == 'Fresh') {
      filtered = filtered.where((s) => s.isFresh).toList();
    } else if (_historyFilter == 'Not Fresh') {
      filtered = filtered.where((s) => !s.isFresh).toList();
    }

    return FrostedGlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      blurSigma: 6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: SariwaColors.brandPrimary.withValues(
                          alpha: 0.10,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        CupertinoIcons.clock,
                        size: 20,
                        color: SariwaColors.brandPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Audit History',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500, // Medium
                              letterSpacing: AppTypography.defaultLetterSpacing,
                              color: SariwaColors.textPrimaryDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            state.history.length == 1
                                ? '1 saved scan'
                                : '${state.history.length} saved scans',
                            style: const TextStyle(
                              fontSize: 12,
                              letterSpacing: AppTypography.defaultLetterSpacing,
                              color: SariwaColors.textSecondaryDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state.history.isNotEmpty) ...[
                    TextButton.icon(
                      key: const Key('history_toggle_selection_mode_button'),
                      onPressed: () {
                        setState(() {
                          _isSelectionMode = !_isSelectionMode;
                          if (!_isSelectionMode) {
                            _selectedScanIds.clear();
                          }
                        });
                      },
                      icon: Icon(
                        _isSelectionMode
                            ? CupertinoIcons.xmark_circle
                            : CupertinoIcons.checkmark_circle,
                        size: 15,
                      ),
                      label: Text(_isSelectionMode ? 'Done' : 'Select'),
                      style: TextButton.styleFrom(
                        foregroundColor: SariwaColors.brandPrimary,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'Geist',
                          fontWeight: FontWeight.w400,
                          letterSpacing: AppTypography.defaultLetterSpacing,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  IconButton(
                    onPressed: () => controller.loadHistory(),
                    icon: const Icon(CupertinoIcons.refresh, size: 18),
                    tooltip: 'Refresh history from server',
                    color: SariwaColors.brandPrimary,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.50),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.75),
                width: 1.0,
              ),
            ),
            child: Row(
              children: ['All', 'Fresh', 'Not Fresh'].map((filter) {
                final isSelected = _historyFilter == filter;
                return Expanded(
                  child: GestureDetector(
                    key: Key(
                      'history_filter_${filter.toLowerCase().replaceAll(' ', '_')}',
                    ),
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() => _historyFilter = filter);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white.withValues(alpha: 0.90) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            letterSpacing: AppTypography.defaultLetterSpacing,
                            color: isSelected
                                ? SariwaColors.textPrimaryDark
                                : const Color(0xFF6B7280),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (_isSelectionMode && filtered.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              key: const Key('history_bulk_action_bar'),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: SariwaColors.brandPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: SariwaColors.brandPrimary.withValues(alpha: 0.22),
                  width: 1,
                ),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '${_selectedScanIds.length} of ${filtered.length} selected',
                    style: const TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: SariwaColors.textPrimaryDark,
                      letterSpacing: AppTypography.defaultLetterSpacing,
                    ),
                  ),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      TextButton(
                        key: const Key('history_select_all_button'),
                        onPressed: () {
                          setState(() {
                            final validIds = filtered
                                .map((s) => s.scanId)
                                .whereType<int>()
                                .toSet();
                            if (_selectedScanIds.containsAll(validIds)) {
                              _selectedScanIds.removeAll(validIds);
                            } else {
                              _selectedScanIds.addAll(validIds);
                            }
                          });
                        },
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          foregroundColor: SariwaColors.brandPrimary,
                        ),
                        child: Text(
                          filtered.isNotEmpty &&
                                  _selectedScanIds.containsAll(
                                    filtered
                                        .map((s) => s.scanId)
                                        .whereType<int>()
                                        .toSet(),
                                  )
                              ? 'Deselect All'
                              : 'Select All',
                          style: const TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            letterSpacing: AppTypography.defaultLetterSpacing,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        key: const Key('history_bulk_delete_button'),
                        onPressed: _selectedScanIds.isEmpty
                            ? null
                            : () => _confirmBulkDelete(
                                  context,
                                  _selectedScanIds.toList(),
                                  controller,
                                ),
                        icon: const Icon(CupertinoIcons.trash, size: 13),
                        label: Text(
                          'Delete (${_selectedScanIds.length})',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SariwaColors.statusSpoiled,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: SariwaColors.statusSpoiled
                              .withValues(alpha: 0.35),
                          disabledForegroundColor: Colors.white70,
                          elevation: 0,
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(99),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                            letterSpacing: AppTypography.defaultLetterSpacing,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (state.isLoadingHistory && state.history.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CupertinoActivityIndicator(radius: 14),
              ),
            )
          else if (filtered.isEmpty)
            _buildEmptyHistoryState(
              activeFilter: _historyFilter,
              hasAnyHistory: state.history.isNotEmpty,
            )
          else ...[
            Builder(
              builder: (context) {
                final displayList = filtered.take(widget.maxDisplayItems).toList();
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayList.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final scan = displayList[index];
                        return _buildHistoryItemRow(scan, controller, state);
                      },
                    ),
                    if (filtered.length > widget.maxDisplayItems || widget.onViewMore != null) ...[
                      const SizedBox(height: 14),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          key: const Key('audit_history_view_more_button'),
                          onTap: widget.onViewMore,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 11,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: SariwaColors.brandPrimary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: SariwaColors.brandPrimary.withValues(alpha: 0.20),
                                width: 1.0,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'View more',
                                  style: TextStyle(
                                    fontFamily: 'Geist',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: AppTypography.defaultLetterSpacing,
                                    color: SariwaColors.brandPrimary,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(
                                  CupertinoIcons.arrow_right,
                                  size: 14,
                                  color: SariwaColors.brandPrimary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyHistoryState({
    required String activeFilter,
    required bool hasAnyHistory,
  }) {
    String emptyTitle;
    String emptySubtitle;

    if (!hasAnyHistory) {
      emptyTitle = 'No classification history';
      emptySubtitle =
          'Upload a Tilapia photo to start building your permanent quality log.';
    } else if (activeFilter == 'Fresh') {
      emptyTitle = 'No Fresh results';
      emptySubtitle =
          'No scans classified as Fresh were found in your audit history.';
    } else if (activeFilter == 'Not Fresh') {
      emptyTitle = 'No Not Fresh results';
      emptySubtitle =
          'No scans classified as Not Fresh were found in your audit history.';
    } else {
      emptyTitle = 'No matching records';
      emptySubtitle = 'Adjust your selected filter to view recorded scans.';
    }

    return Container(
      key: const Key('empty_history_state'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 38, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/images/SariwaBa logo.png',
            height: 56,
            errorBuilder: (_, _, _) => const Icon(
              CupertinoIcons.tray,
              size: 42,
              color: SariwaColors.textMutedDark,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            emptyTitle,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              letterSpacing: AppTypography.defaultLetterSpacing,
              color: SariwaColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            emptySubtitle,
            style: const TextStyle(
              fontSize: 12,
              letterSpacing: AppTypography.defaultLetterSpacing,
              color: SariwaColors.textSecondaryDark,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItemRow(
    ClassificationResult scan,
    ClassificationController controller,
    ClassificationState state,
  ) {
    final isDeleting = state.deletingScanId == scan.scanId;
    final isSelected =
        scan.scanId != null && _selectedScanIds.contains(scan.scanId);

    return GestureDetector(
      key: Key('history_item_${scan.scanId}'),
      onTap: _isSelectionMode && scan.scanId != null
          ? () {
              setState(() {
                if (isSelected) {
                  _selectedScanIds.remove(scan.scanId);
                } else {
                  _selectedScanIds.add(scan.scanId!);
                }
              });
            }
          : null,
      onLongPress: !_isSelectionMode && scan.scanId != null
          ? () {
              setState(() {
                _isSelectionMode = true;
                _selectedScanIds.add(scan.scanId!);
              });
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? SariwaColors.brandPrimary.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.70),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? SariwaColors.brandPrimary
                : Colors.white.withValues(alpha: 0.85),
            width: isSelected ? 1.6 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_isSelectionMode) ...[
              GestureDetector(
                key: Key('history_item_checkbox_${scan.scanId}'),
                onTap: () {
                  if (scan.scanId != null) {
                    setState(() {
                      if (isSelected) {
                        _selectedScanIds.remove(scan.scanId);
                      } else {
                        _selectedScanIds.add(scan.scanId!);
                      }
                    });
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? SariwaColors.brandPrimary
                        : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? SariwaColors.brandPrimary
                          : const Color(0xFFCBD5E1),
                      width: 1.8,
                    ),
                  ),
                  child: isSelected
                      ? const Center(
                          child: Icon(
                            CupertinoIcons.checkmark,
                            size: 13,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
            ],
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 44,
                height: 44,
                color: scan.statusColor.withValues(alpha: 0.12),
                child: scan.imageUrl != null && scan.imageUrl!.isNotEmpty
                    ? Image.network(
                        scan.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                          scan.isFresh
                              ? CupertinoIcons.checkmark_alt
                              : CupertinoIcons.exclamationmark_triangle,
                          color: scan.statusColor,
                          size: 20,
                        ),
                      )
                    : Icon(
                        scan.isFresh
                            ? CupertinoIcons.checkmark_alt
                            : CupertinoIcons.exclamationmark_triangle,
                        color: scan.statusColor,
                        size: 20,
                      ),
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
                              scan.label,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                letterSpacing:
                                    AppTypography.defaultLetterSpacing,
                                color: scan.statusColor,
                              ),
                            ),
                            if (scan.regionDisplayName != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Text(
                                  'Selected region: ${scan.regionDisplayName!}',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing:
                                        AppTypography.defaultLetterSpacing,
                                    color: SariwaColors.brandPrimary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (scan.scanId != null && !_isSelectionMode)
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          icon: isDeleting
                              ? const CupertinoActivityIndicator(radius: 8)
                              : const Icon(CupertinoIcons.trash, size: 16),
                          color: const Color(0xFF94A3B8),
                          tooltip: 'Delete scan',
                          onPressed: isDeleting
                              ? null
                              : () => _confirmDelete(
                                    context,
                                    scan.scanId!,
                                    controller,
                                  ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: scan.confidence.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        scan.statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          scan.createdAt != null
                              ? '${scan.createdAt!.month}/${scan.createdAt!.day}/${scan.createdAt!.year} at ${scan.createdAt!.hour}:${scan.createdAt!.minute.toString().padLeft(2, '0')}'
                              : 'Audit Scan #${scan.scanId ?? ''}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            letterSpacing: AppTypography.defaultLetterSpacing,
                            color: SariwaColors.textSecondaryDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        scan.formattedConfidence,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          letterSpacing: AppTypography.defaultLetterSpacing,
                          color: scan.statusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    int scanId,
    ClassificationController controller,
  ) async {
    final confirmed = await HistoryDeleteDialog.showSingle(
      context: context,
      scanId: scanId,
    );
    if (confirmed == true) {
      setState(() {
        _selectedScanIds.remove(scanId);
      });
      controller.deleteScan(scanId);
    }
  }

  void _confirmBulkDelete(
    BuildContext context,
    List<int> scanIds,
    ClassificationController controller,
  ) async {
    final confirmed = await HistoryDeleteDialog.showBulk(
      context: context,
      scanIds: scanIds,
    );
    if (confirmed == true) {
      setState(() {
        _selectedScanIds.clear();
        _isSelectionMode = false;
      });
      await controller.deleteMultipleScans(scanIds);
    }
  }
}
