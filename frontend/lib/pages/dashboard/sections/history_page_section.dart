import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../controllers/classification/classification_controller.dart';
import '../../../models/classification/classification_result.dart';
import '../../../constants/theme/app_colors.dart';
import '../../../constants/theme/app_typography.dart';
import '../../../widgets/dashboard/frosted_glass_card.dart';
import '../../../widgets/dashboard/dashboard_atmospheric_banner.dart';
import '../../../widgets/dashboard/history_delete_dialog.dart';
import '../../../widgets/dashboard/inspection_details_modal.dart';

/// Dedicated Inspection History management view with Gmail-style instant checkmarks,
/// batch selection toolbar, and full pagination.
class HistoryPageSection extends StatefulWidget {
  final List<ClassificationResult> history;
  final ClassificationController controller;
  final bool isDesktop;
  final ScrollController? scrollController;

  const HistoryPageSection({
    super.key,
    required this.history,
    required this.controller,
    required this.isDesktop,
    this.scrollController,
  });

  @override
  State<HistoryPageSection> createState() => _HistoryPageSectionState();
}

class _HistoryPageSectionState extends State<HistoryPageSection> {
  final TextEditingController _searchController = TextEditingController();
  String _historyFilter = 'All'; // 'All', 'Fresh', 'Not Fresh'
  String _regionFilter = 'All'; // 'All', 'Eye', 'Gill'
  String _sortOrder = 'Newest'; // 'Newest', 'Oldest', 'Highest', 'Lowest'
  String _searchQuery = '';
  final Set<int> _selectedHistoryScanIds = <int>{};

  // Gmail-style pagination state
  int _currentPage = 1;
  int _pageSize = 10;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime? dt) =>
      InspectionDetailsModal.formatDateTime(dt);

  @override
  Widget build(BuildContext context) {
    var filtered = widget.history.where((scan) {
      if (_historyFilter == 'Fresh' && !scan.isFresh) return false;
      if (_historyFilter == 'Not Fresh' && !scan.isNotFresh) return false;
      if (_regionFilter == 'Eye' &&
          (scan.regionType ?? '').toLowerCase() != 'eye') {
        return false;
      }
      if (_regionFilter == 'Gill' &&
          (scan.regionType ?? '').toLowerCase() != 'gill') {
        return false;
      }
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final scanIdStr = scan.scanId?.toString() ?? '';
        final labelStr = scan.label.toLowerCase();
        final dateStr = scan.createdAt?.toString().toLowerCase() ?? '';
        final regionStr = (scan.regionType ?? '').toLowerCase();
        final matches = scanIdStr.contains(query) ||
            labelStr.contains(query) ||
            dateStr.contains(query) ||
            regionStr.contains(query);
        if (!matches) return false;
      }
      return true;
    }).toList();

    // Sorting
    if (_sortOrder == 'Newest') {
      filtered.sort((a, b) {
        final da = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final db = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return db.compareTo(da);
      });
    } else if (_sortOrder == 'Oldest') {
      filtered.sort((a, b) {
        final da = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final db = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return da.compareTo(db);
      });
    } else if (_sortOrder == 'Highest') {
      filtered.sort((a, b) => b.confidence.compareTo(a.confidence));
    } else if (_sortOrder == 'Lowest') {
      filtered.sort((a, b) => a.confidence.compareTo(b.confidence));
    }

    // Pagination calculations
    final totalItems = filtered.length;
    final totalPages = totalItems == 0 ? 1 : ((totalItems + _pageSize - 1) ~/ _pageSize);
    if (_currentPage > totalPages) {
      _currentPage = totalPages;
    }
    if (_currentPage < 1) {
      _currentPage = 1;
    }

    final startIndex = totalItems == 0 ? 0 : (_currentPage - 1) * _pageSize;
    final endIndex = (startIndex + _pageSize) > totalItems ? totalItems : (startIndex + _pageSize);
    final pageScans = totalItems == 0 ? <ClassificationResult>[] : filtered.sublist(startIndex, endIndex);

    final pageIds = pageScans.map((s) => s.scanId).whereType<int>().toSet();
    final selectedOnPage = pageIds.where(_selectedHistoryScanIds.contains).length;
    final allOnPageSelected = pageIds.isNotEmpty && selectedOnPage == pageIds.length;
    final someOnPageSelected = selectedOnPage > 0 && !allOnPageSelected;

    return SingleChildScrollView(
      controller: widget.scrollController,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: widget.isDesktop ? 36 : 18,
        vertical: widget.isDesktop ? 28 : 20,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image-backed section header
              const DashboardAtmosphericBanner(
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inspection History',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w500, // Medium for titles
                        letterSpacing: AppTypography.defaultLetterSpacing,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Review and manage your previous freshness assessments.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300, // Lighter for body
                        letterSpacing: AppTypography.defaultLetterSpacing,
                        color: Color(0xFFD1FAF4),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Unified History Management Card
              FrostedGlassCard(
                padding: EdgeInsets.all(widget.isDesktop ? 22 : 16),
                borderRadius: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Filter Controls Row (Search, Region, Status, Sort)
                    _buildHistoryFilterBar(widget.isDesktop),

                    const SizedBox(height: 18),

                    // Gmail-style Batch Actions & Pagination Toolbar
                    _buildGmailToolbar(
                      totalItems: totalItems,
                      startIndex: startIndex,
                      endIndex: endIndex,
                      totalPages: totalPages,
                      allOnPageSelected: allOnPageSelected,
                      someOnPageSelected: someOnPageSelected,
                      pageIds: pageIds,
                      filtered: filtered,
                      isDesktop: widget.isDesktop,
                    ),

                    const SizedBox(height: 16),

                    // Data Table or Empty State
                    if (filtered.isEmpty)
                      _buildEmptyHistoryState(
                        activeFilter: _historyFilter,
                        hasAnyHistory: widget.history.isNotEmpty,
                      )
                    else if (widget.isDesktop)
                      _buildDesktopDataTable(
                        pageScans: pageScans,
                        allOnPageSelected: allOnPageSelected,
                        someOnPageSelected: someOnPageSelected,
                        pageIds: pageIds,
                      )
                    else
                      _buildMobileHistoryList(pageScans),

                    // Bottom pagination when items exist
                    if (filtered.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildBottomPaginationBar(
                        totalItems: totalItems,
                        startIndex: startIndex,
                        endIndex: endIndex,
                        totalPages: totalPages,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 36),
              _buildSimpleFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryFilterBar(bool isDesktop) {
    final searchInput = _buildLabeledFilterControl(
      label: 'Search inspections',
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.90),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.search,
              size: 16,
              color: Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() {
                  _searchQuery = val;
                  _currentPage = 1;
                }),
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13,
                  letterSpacing: -0.2,
                  color: Color(0xFF0F172A),
                ),
                decoration: const InputDecoration(
                  hintText: 'Scan ID, date, or region...',
                  hintStyle: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13,
                    letterSpacing: -0.2,
                    color: Color(0xFF94A3B8),
                  ),
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _currentPage = 1;
                  });
                },
                child: const Icon(
                  CupertinoIcons.xmark_circle_fill,
                  size: 15,
                  color: Color(0xFF94A3B8),
                ),
              ),
          ],
        ),
      ),
    );

    final regionDropdown = _buildLabeledFilterControl(
      label: 'Inspection region',
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.90),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _regionFilter,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: Color(0xFF64748B),
            ),
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.2,
              color: Color(0xFF0F172A),
            ),
            borderRadius: BorderRadius.circular(12),
            dropdownColor: Colors.white,
            elevation: 3,
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All regions')),
              DropdownMenuItem(value: 'Eye', child: Text('Eye (Mata)')),
              DropdownMenuItem(value: 'Gill', child: Text('Gill (Hasang)')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _regionFilter = val;
                  _currentPage = 1;
                });
              }
            },
          ),
        ),
      ),
    );

    final statusDropdown = _buildLabeledFilterControl(
      label: 'Freshness status',
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.90),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _historyFilter,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: Color(0xFF64748B),
            ),
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.2,
              color: Color(0xFF0F172A),
            ),
            borderRadius: BorderRadius.circular(12),
            dropdownColor: Colors.white,
            elevation: 3,
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All statuses')),
              DropdownMenuItem(value: 'Fresh', child: Text('Fresh only')),
              DropdownMenuItem(value: 'Not Fresh', child: Text('Not Fresh only')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _historyFilter = val;
                  _currentPage = 1;
                });
              }
            },
          ),
        ),
      ),
    );

    final sortDropdown = _buildLabeledFilterControl(
      label: 'Sort by',
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.90),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _sortOrder,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: Color(0xFF64748B),
            ),
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.2,
              color: Color(0xFF0F172A),
            ),
            borderRadius: BorderRadius.circular(12),
            dropdownColor: Colors.white,
            elevation: 3,
            items: const [
              DropdownMenuItem(value: 'Newest', child: Text('Newest first')),
              DropdownMenuItem(value: 'Oldest', child: Text('Oldest first')),
              DropdownMenuItem(value: 'Highest', child: Text('Highest confidence')),
              DropdownMenuItem(value: 'Lowest', child: Text('Lowest confidence')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _sortOrder = val;
                  _currentPage = 1;
                });
              }
            },
          ),
        ),
      ),
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(flex: 3, child: searchInput),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: regionDropdown),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: statusDropdown),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: sortDropdown),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        searchInput,
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: regionDropdown),
            const SizedBox(width: 10),
            Expanded(child: statusDropdown),
          ],
        ),
        const SizedBox(height: 10),
        sortDropdown,
      ],
    );
  }

  Widget _buildLabeledFilterControl({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.2,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  /// Gmail-style Toolbar combining Master Checkbox, Batch Action buttons, and Pagination
  Widget _buildGmailToolbar({
    required int totalItems,
    required int startIndex,
    required int endIndex,
    required int totalPages,
    required bool allOnPageSelected,
    required bool someOnPageSelected,
    required Set<int> pageIds,
    required List<ClassificationResult> filtered,
    required bool isDesktop,
  }) {
    final hasSelection = _selectedHistoryScanIds.isNotEmpty;

    return Container(
      key: const Key('history_bulk_action_bar'),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 16 : 10,
        vertical: 8,
      ),
      child: Row(
        children: [
          // Master Checkbox button ready to be checked immediately
          SizedBox(
            width: 32,
            height: 32,
            child: Transform.scale(
              scale: 0.90,
              child: Checkbox(
                key: const Key('history_toggle_selection_mode_button'),
                tristate: true,
                value: allOnPageSelected ? true : (someOnPageSelected ? null : false),
                activeColor: SariwaColors.brandPrimary,
                checkColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                side: WidgetStateBorderSide.resolveWith((states) => BorderSide(
                  color: states.contains(WidgetState.selected)
                      ? SariwaColors.brandPrimary
                      : const Color(0xFF8FA6BF),
                  width: 1.2,
                )),
                fillColor: WidgetStateProperty.resolveWith((states) =>
                    states.contains(WidgetState.selected)
                        ? SariwaColors.brandPrimary
                        : const Color(0xFFF8FAFC)),
                onChanged: (val) {
                  setState(() {
                    if (allOnPageSelected) {
                      _selectedHistoryScanIds.removeAll(pageIds);
                    } else {
                      _selectedHistoryScanIds.addAll(pageIds);
                    }
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Selection State or Entry Counter
          if (hasSelection) ...[
            Text(
              '${_selectedHistoryScanIds.length} of $totalItems selected',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: isDesktop ? 13 : 11.5,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF334155),
              ),
            ),
            SizedBox(width: isDesktop ? 14 : 8),
            TextButton(
              key: const Key('history_select_all_button'),
              onPressed: () {
                setState(() {
                  final allFilteredIds = filtered
                      .map((s) => s.scanId)
                      .whereType<int>()
                      .toSet();
                  if (_selectedHistoryScanIds.containsAll(allFilteredIds)) {
                    _selectedHistoryScanIds.clear();
                  } else {
                    _selectedHistoryScanIds.addAll(allFilteredIds);
                  }
                });
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                _selectedHistoryScanIds.containsAll(
                  filtered.map((s) => s.scanId).whereType<int>().toSet(),
                )
                    ? 'Deselect All'
                    : 'Select All',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: isDesktop ? 12 : 11,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF0F766E),
                ),
              ),
            ),
            SizedBox(width: isDesktop ? 8 : 4),
            ElevatedButton.icon(
              key: const Key('history_bulk_delete_button'),
              onPressed: () => _confirmBulkDelete(_selectedHistoryScanIds.toList()),
              style: ElevatedButton.styleFrom(
                backgroundColor: SariwaColors.statusSpoiled,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 16 : 12,
                  vertical: 10,
                ),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.padded,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
              ),
              icon: const Icon(CupertinoIcons.trash, size: 14),
              label: Text(
                isDesktop ? 'Delete (${_selectedHistoryScanIds.length})' : 'Delete',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: isDesktop ? 12 : 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'Deselect all',
              onPressed: () => setState(() => _selectedHistoryScanIds.clear()),
              icon: const Icon(CupertinoIcons.clear, size: 13, color: Color(0xFF64748B)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
            ),
          ] else ...[
            Text(
              '$totalItems matching ${totalItems == 1 ? 'entry' : 'entries'}',
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B),
              ),
            ),
          ],

          const Spacer(),

          // Right: Gmail-style Pager Controls
          _buildPaginationControls(
            totalItems: totalItems,
            startIndex: startIndex,
            endIndex: endIndex,
            totalPages: totalPages,
            isDarkTheme: false,
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls({
    required int totalItems,
    required int startIndex,
    required int endIndex,
    required int totalPages,
    bool isDarkTheme = false,
  }) {
    final textColor = isDarkTheme ? Colors.white70 : const Color(0xFF64748B);
    final iconColor = isDarkTheme ? Colors.white : const Color(0xFF334155);
    final disabledColor = isDarkTheme ? Colors.white24 : const Color(0xFFCBD5E1);

    final rangeText = totalItems == 0
        ? '0 of 0'
        : '${startIndex + 1}–$endIndex of $totalItems';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          rangeText,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.2,
            color: textColor,
          ),
        ),
        const SizedBox(width: 6),
        IconButton(
          tooltip: 'Previous page',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          onPressed: _currentPage > 1
              ? () => setState(() => _currentPage--)
              : null,
          icon: Icon(
            Icons.chevron_left_rounded,
            size: 20,
            color: _currentPage > 1 ? iconColor : disabledColor,
          ),
        ),
        IconButton(
          tooltip: 'Next page',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          onPressed: _currentPage < totalPages
              ? () => setState(() => _currentPage++)
              : null,
          icon: Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: _currentPage < totalPages ? iconColor : disabledColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomPaginationBar({
    required int totalItems,
    required int startIndex,
    required int endIndex,
    required int totalPages,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.80),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                'Show ',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _pageSize,
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF0F172A),
                  ),
                  items: const [
                    DropdownMenuItem(value: 5, child: Text('5 per page')),
                    DropdownMenuItem(value: 10, child: Text('10 per page')),
                    DropdownMenuItem(value: 25, child: Text('25 per page')),
                    DropdownMenuItem(value: 50, child: Text('50 per page')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _pageSize = val;
                        _currentPage = 1;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          _buildPaginationControls(
            totalItems: totalItems,
            startIndex: startIndex,
            endIndex: endIndex,
            totalPages: totalPages,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopDataTable({
    required List<ClassificationResult> pageScans,
    required bool allOnPageSelected,
    required bool someOnPageSelected,
    required Set<int> pageIds,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.85),
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            // Table Header matching reference enterprise UI with Checkbox column
            Container(
              color: Colors.white.withValues(alpha: 0.45),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: Transform.scale(
                      scale: 0.90,
                      child: Checkbox(
                        tristate: true,
                        value: allOnPageSelected ? true : (someOnPageSelected ? null : false),
                        activeColor: SariwaColors.brandPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                        side: WidgetStateBorderSide.resolveWith((states) => BorderSide(
                          color: states.contains(WidgetState.selected)
                              ? SariwaColors.brandPrimary
                              : const Color(0xFF8FA6BF),
                          width: 1.2,
                        )),
                        fillColor: WidgetStateProperty.resolveWith((states) =>
                            states.contains(WidgetState.selected)
                                ? SariwaColors.brandPrimary
                                : const Color(0xFFF8FAFC)),
                        onChanged: (val) {
                          setState(() {
                            if (allOnPageSelected) {
                              _selectedHistoryScanIds.removeAll(pageIds);
                            } else {
                              _selectedHistoryScanIds.addAll(pageIds);
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 3,
                    child: Text(
                      'SPECIMEN / ID',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.8,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'REGION',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.8,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'INSPECTION DATE',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.8,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'CONFIDENCE',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.8,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'STATUS',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.8,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 90,
                    child: Text(
                      'ACTIONS',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.8,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pageScans.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) {
                final scan = pageScans[index];
                final scanId = scan.scanId;
                final isSelected =
                    scanId != null && _selectedHistoryScanIds.contains(scanId);

                return Container(
                  color: isSelected
                      ? SariwaColors.brandPrimary.withValues(alpha: 0.06)
                      : Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // Individual Checkbox ready to check immediately
                      SizedBox(
                        width: 36,
                        child: Transform.scale(
                          scale: 0.90,
                          child: Checkbox(
                            key: scanId != null
                                ? Key('history_item_checkbox_$scanId')
                                : null,
                            value: isSelected,
                            activeColor: SariwaColors.brandPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                            side: WidgetStateBorderSide.resolveWith((states) => BorderSide(
                              color: states.contains(WidgetState.selected)
                                  ? SariwaColors.brandPrimary
                                  : const Color(0xFF8FA6BF),
                              width: 1.2,
                            )),
                            fillColor: WidgetStateProperty.resolveWith((states) =>
                                states.contains(WidgetState.selected)
                                    ? SariwaColors.brandPrimary
                                    : const Color(0xFFF8FAFC)),
                            onChanged: (val) {
                              if (scanId == null) return;
                              setState(() {
                                if (val == true) {
                                  _selectedHistoryScanIds.add(scanId);
                                } else {
                                  _selectedHistoryScanIds.remove(scanId);
                                }
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              scanId != null ? 'Scan #$scanId' : 'Scan',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.2,
                                color: isSelected
                                    ? SariwaColors.brandPrimary
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                            const Text(
                              'Nile Tilapia',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 11,
                                letterSpacing: -0.2,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            (scan.regionType ?? 'Eye').toLowerCase() == 'gill'
                                ? 'Gill (Hasang)'
                                : 'Eye (Mata)',
                            style: const TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.2,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          _formatDateTime(scan.createdAt),
                          style: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12.5,
                            letterSpacing: -0.2,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 65,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(99),
                                child: LinearProgressIndicator(
                                  value: scan.confidence,
                                  backgroundColor: const Color(0xFFE2E8F0),
                                  valueColor: AlwaysStoppedAnimation(
                                    scan.isFresh
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFDC2626),
                                  ),
                                  minHeight: 5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(scan.confidence * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.2,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _buildReferenceStatusPill(scan.isFresh),
                        ),
                      ),
                      SizedBox(
                        width: 90,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(CupertinoIcons.eye, size: 15),
                              tooltip: 'View details',
                              color: SariwaColors.brandPrimary,
                              onPressed: () =>
                                  InspectionDetailsModal.show(context, scan),
                            ),
                            _buildRowActionMenu(scan, scanId, widget.controller),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileHistoryList(List<ClassificationResult> scans) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: scans.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final scan = scans[index];
        final scanId = scan.scanId;
        final isSelected =
            scanId != null && _selectedHistoryScanIds.contains(scanId);

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? SariwaColors.brandPrimary.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? SariwaColors.brandPrimary
                  : Colors.white.withValues(alpha: 0.85),
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Checkbox ready to check immediately
                      Transform.scale(
                        scale: 0.90,
                        child: Checkbox(
                          key: scanId != null
                              ? Key('history_item_checkbox_$scanId')
                              : null,
                          value: isSelected,
                          activeColor: SariwaColors.brandPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                          side: WidgetStateBorderSide.resolveWith((states) => BorderSide(
                            color: states.contains(WidgetState.selected)
                                ? SariwaColors.brandPrimary
                                : const Color(0xFF8FA6BF),
                            width: 1.2,
                          )),
                          fillColor: WidgetStateProperty.resolveWith((states) =>
                              states.contains(WidgetState.selected)
                                  ? SariwaColors.brandPrimary
                                  : const Color(0xFFF8FAFC)),
                          onChanged: (val) {
                            if (scanId == null) return;
                            setState(() {
                              if (val == true) {
                                _selectedHistoryScanIds.add(scanId);
                              } else {
                                _selectedHistoryScanIds.remove(scanId);
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 4),
                      _buildReferenceStatusPill(scan.isFresh),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(CupertinoIcons.eye, size: 16),
                        tooltip: 'View details',
                        color: SariwaColors.brandPrimary,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        onPressed: () =>
                            InspectionDetailsModal.show(context, scan),
                      ),
                      _buildRowActionMenu(scan, scanId, widget.controller),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                scanId != null ? 'Scan #$scanId' : 'Scan',
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(scan.regionType ?? 'Eye').toUpperCase()} • ${_formatDateTime(scan.createdAt)}',
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: scan.confidence,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation(
                          scan.isFresh
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFDC2626),
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${(scan.confidence * 100).toStringAsFixed(1)}% Certainty',
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReferenceStatusPill(bool isFresh) {
    final dotColor = isFresh ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final bgColor = isFresh ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2);
    final textColor = isFresh ? const Color(0xFF15803D) : const Color(0xFFB91C1C);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isFresh ? 'Fresh' : 'Not Fresh',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.2,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowActionMenu(
    ClassificationResult scan,
    int? scanId,
    ClassificationController controller,
  ) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_vert,
        size: 19,
        color: Color(0xFF64748B),
      ),
      tooltip: 'Actions',
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFDCE8E5)),
      ),
      onSelected: (action) {
        if (action == 'view') {
          InspectionDetailsModal.show(context, scan);
        } else if (action == 'delete' && scanId != null) {
          _confirmDelete(scanId);
        }
      },
      itemBuilder: (ctx) => [
        const PopupMenuItem<String>(
          value: 'view',
          child: Row(
            children: [
              Icon(CupertinoIcons.eye, size: 16, color: Color(0xFF475569)),
              SizedBox(width: 10),
              Text('View details'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(CupertinoIcons.trash, size: 16, color: SariwaColors.notFreshPrimary),
              SizedBox(width: 10),
              Text(
                'Delete scan',
                style: TextStyle(color: SariwaColors.notFreshPrimary),
              ),
            ],
          ),
        ),
      ],
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

  void _confirmDelete(int scanId) async {
    final confirmed = await HistoryDeleteDialog.showSingle(
      context: context,
      scanId: scanId,
    );
    if (confirmed == true) {
      setState(() {
        _selectedHistoryScanIds.remove(scanId);
      });
      widget.controller.deleteScan(scanId);
    }
  }

  void _confirmBulkDelete(List<int> scanIds) async {
    final confirmed = await HistoryDeleteDialog.showBulk(
      context: context,
      scanIds: scanIds,
    );
    if (confirmed == true) {
      setState(() {
        _selectedHistoryScanIds.clear();
      });
      await widget.controller.deleteMultipleScans(scanIds);
    }
  }

  Widget _buildSimpleFooter() {
    return Center(
      child: Text(
        '© ${DateTime.now().year} SariwaBa — Fish Freshness Classification. All rights reserved.',
        style: const TextStyle(
          fontSize: 12,
          letterSpacing: AppTypography.defaultLetterSpacing,
          color: SariwaColors.textMutedDark,
        ),
      ),
    );
  }
}
