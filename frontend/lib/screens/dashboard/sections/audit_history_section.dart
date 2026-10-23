import 'package:flutter/material.dart';
import '../../../constants/theme/app_colors.dart';
import '../../../controllers/classification/classification_controller.dart';
import '../../../models/classification/classification_result.dart';

class AuditHistorySection extends StatelessWidget {
  final ClassificationState state;
  final ClassificationController controller;
  final String historyFilter;
  final ValueChanged<String> onFilterChanged;
  final String searchQuery;
  final bool isGuest;
  final VoidCallback? onSignIn;

  const AuditHistorySection({
    super.key,
    required this.state,
    required this.controller,
    required this.historyFilter,
    required this.onFilterChanged,
    required this.searchQuery,
    this.isGuest = false,
    this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    var filtered = state.history;
    if (historyFilter == 'Fresh') {
      filtered = filtered.where((s) => s.isFresh).toList();
    } else if (historyFilter == 'Non-Fresh') {
      filtered = filtered.where((s) => !s.isFresh).toList();
    }

    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase();
      filtered = filtered.where((s) {
        return s.label.toLowerCase().contains(q) ||
            s.grade.toLowerCase().contains(q) ||
            (s.scanId?.toString().contains(q) ?? false);
      }).toList();
    }

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: SariwaColors.borderLightTeal, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060A2229),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: SariwaColors.brandPrimary.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.history_rounded,
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
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              color: SariwaColors.textPrimaryDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            isGuest
                                ? '${state.history.length} scan(s) in temporary local cache'
                                : '${state.history.length} scans saved in your history',
                            style: const TextStyle(
                              fontSize: 12,
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
              if (isGuest && state.history.isNotEmpty)
                IconButton(
                  onPressed: () => controller.clearGuestCache(),
                  icon: const Icon(Icons.delete_sweep_outlined, size: 20),
                  tooltip: 'Clear temporary guest cache',
                  color: SariwaColors.textMutedDark,
                ),
              IconButton(
                onPressed: () => controller.loadHistory(),
                icon: const Icon(Icons.refresh_rounded, size: 20),
                tooltip: 'Refresh history',
                color: SariwaColors.brandPrimary,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Filter Segment Tabs
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['All', 'Fresh', 'Non-Fresh'].map((filter) {
              final isSelected = historyFilter == filter;
              return FilterChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (_) => onFilterChanged(filter),
                selectedColor: SariwaColors.brandPrimary.withValues(
                  alpha: 0.15,
                ),
                backgroundColor: SariwaColors.bgDashboard,
                side: BorderSide(
                  color: isSelected
                      ? SariwaColors.brandPrimary
                      : SariwaColors.borderLightTeal,
                ),
                labelStyle: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? SariwaColors.brandPrimary
                      : SariwaColors.textSecondaryDark,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          if (state.isLoadingHistory && state.history.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(
                  color: SariwaColors.brandPrimary,
                ),
              ),
            )
          else if (filtered.isEmpty)
            _buildEmptyHistoryState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final scan = filtered[index];
                return _buildHistoryItemRow(context, scan);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistoryState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 20),
      decoration: BoxDecoration(
        color: SariwaColors.bgDashboard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SariwaColors.borderLightTeal),
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/images/SariwaBa logo.png',
            height: 56,
            errorBuilder: (_, _, _) => const Icon(
              Icons.inventory_2_outlined,
              size: 44,
              color: SariwaColors.textMutedDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isGuest ? 'No Cached Guest Scans Yet' : 'No scan history found',
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: SariwaColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isGuest
                ? 'Scans performed in Guest Mode are cached locally in this browser. Sign in with Google to back them up permanently.'
                : 'Upload a fish photo to start building your permanent quality log.',
            style: const TextStyle(
              fontSize: 12,
              color: SariwaColors.textSecondaryDark,
            ),
            textAlign: TextAlign.center,
          ),
          if (isGuest && onSignIn != null) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onSignIn,
              icon: const Icon(Icons.login_rounded, size: 16),
              label: const Text('Sign in to Save Permanently'),
              style: OutlinedButton.styleFrom(
                foregroundColor: SariwaColors.brandPrimary,
                side: const BorderSide(color: SariwaColors.brandPrimary),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryItemRow(BuildContext context, ClassificationResult scan) {
    final isDeleting = state.deletingScanId == scan.scanId;
    final isLocalCache = !scan.saved || (scan.scanId != null && scan.scanId! < 0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SariwaColors.bgDashboard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SariwaColors.borderLightTeal),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 48,
              height: 48,
              color: scan.statusColor.withValues(alpha: 0.15),
              child: scan.imageUrl != null && scan.imageUrl!.isNotEmpty
                  ? Image.network(
                      scan.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.set_meal_rounded,
                        color: scan.statusColor,
                        size: 24,
                      ),
                    )
                  : Icon(
                      Icons.set_meal_rounded,
                      color: scan.statusColor,
                      size: 24,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Text(
                      scan.label,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: scan.statusColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: scan.statusColor, width: 0.8),
                      ),
                      child: Text(
                        scan.formattedConfidence,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: scan.statusColor,
                        ),
                      ),
                    ),
                    if (isLocalCache)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: SariwaColors.statusModerate.withValues(
                            alpha: 0.14,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Local Cache',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: SariwaColors.statusModerate,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  scan.createdAt != null
                      ? '${scan.createdAt!.month}/${scan.createdAt!.day}/${scan.createdAt!.year} at ${scan.createdAt!.hour}:${scan.createdAt!.minute.toString().padLeft(2, '0')}'
                      : (isLocalCache
                          ? 'Temporary Guest Scan'
                          : 'Audit Scan #${scan.scanId ?? ''}'),
                  style: const TextStyle(
                    fontSize: 11,
                    color: SariwaColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
          if (scan.scanId != null)
            IconButton(
              icon: isDeleting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline_rounded, size: 18),
              color: SariwaColors.textMutedDark,
              tooltip: isLocalCache ? 'Remove from cache' : 'Delete scan',
              onPressed: isDeleting
                  ? null
                  : () => _confirmDelete(context, scan.scanId!, isLocalCache),
            ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, int scanId, bool isLocalCache) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          isLocalCache ? 'Remove Cached Scan?' : 'Delete Scan Record?',
        ),
        content: Text(
          isLocalCache
              ? 'Remove this scan from your temporary local browser cache?'
              : 'Are you sure you want to permanently remove Scan #$scanId from your classification history?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SariwaColors.statusSpoiled,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              controller.deleteScan(scanId);
            },
            child: Text(isLocalCache ? 'Remove' : 'Delete'),
          ),
        ],
      ),
    );
  }
}
