import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import '../../../controllers/classification/classification_controller.dart';
import '../../../models/classification/classification_result.dart';
import '../../../constants/theme/app_colors.dart';
import '../../../constants/theme/app_typography.dart';
import '../../../utils/csv_export.dart';
import '../../../widgets/dashboard/frosted_glass_card.dart';
import '../../../widgets/dashboard/history_delete_dialog.dart';
import '../../../widgets/dashboard/inspection_details_modal.dart';
import '../../../widgets/dashboard/kpi_metrics_row.dart';
import '../../../widgets/dashboard/scan_thumbnail.dart';

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
  static bool _cachedShowKpis = true;

  final TextEditingController _searchController = TextEditingController();
  String _historyFilter = 'All'; // 'All', 'Fresh', 'Not Fresh'
  String _regionFilter = 'All'; // 'All', 'Eye', 'Gill'
  String _sortOrder = 'Newest'; // 'Newest', 'Oldest', 'Highest', 'Lowest'
  String _searchQuery = '';
  final Set<int> _selectedHistoryScanIds = <int>{};

  // Gmail-style pagination state
  int _currentPage = 1;
  int _pageSize = 10;
  bool _showMobileFilters = false;
  bool _showKpiSummary = _cachedShowKpis;
  bool _isMobileSelectionMode = false;

  void _toggleKpiSummary() {
    HapticFeedback.selectionClick();
    setState(() {
      _showKpiSummary = !_showKpiSummary;
      _cachedShowKpis = _showKpiSummary;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime? dt) =>
      InspectionDetailsModal.formatDateTime(dt);

  String _formatDesktopScanTitle(int? scanId) {
    if (scanId != null && scanId > 0) {
      return '#$scanId';
    }
    return 'Local scan';
  }

  String _formatMobileScanTitle(ClassificationResult scan) {
    final region = (scan.regionType ?? 'Eye').toLowerCase() == 'gill'
        ? 'Gill'
        : 'Eye';
    final scanId = scan.scanId;
    if (scanId != null && scanId > 0) {
      return '$region · #$scanId';
    }
    return '$region Scan';
  }

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

    return SafeArea(
      top: !widget.isDesktop,
      bottom: false,
      child: RefreshIndicator.adaptive(
        color: const Color(0xFF111111),
        onRefresh: () async {
          HapticFeedback.lightImpact();
          await widget.controller.loadHistory();
        },
        child: SingleChildScrollView(
          controller: widget.scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(
            widget.isDesktop ? 36 : 0,
            widget.isDesktop ? 28 : 0,
            widget.isDesktop ? 36 : 0,
            widget.isDesktop ? 28 : 128,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1320),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isDesktop)
                    // Desktop monochrome header with Hide/Show Stats pill
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'History & Insights',
                                style: TextStyle(
                                  fontFamily: 'Geist',
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.7,
                                  color: Color(0xFF111111),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Past scans, trends, and CSV export.',
                                style: TextStyle(
                                  fontFamily: 'Geist',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  height: 1.4,
                                  color: Color(0xFF737373),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Semantics(
                          button: true,
                          toggled: _showKpiSummary,
                          label: _showKpiSummary ? 'Hide stats' : 'Show stats',
                          child: OutlinedButton.icon(
                            key: const Key('toggle_history_kpis_button'),
                            onPressed: _toggleKpiSummary,
                            icon: Icon(
                              _showKpiSummary
                                  ? CupertinoIcons.eye_slash
                                  : CupertinoIcons.chart_bar,
                              size: 14,
                              color: const Color(0xFF111111),
                            ),
                            label: Text(
                              _showKpiSummary ? 'Hide Stats' : 'Show Stats',
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF111111),
                              side: const BorderSide(color: Color(0x1A171717)),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              shape: const StadiumBorder(),
                              textStyle: const TextStyle(
                                fontFamily: 'Geist',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    _buildMobileHistoryHeader(filtered),

                  // Desktop: collapsible KPI grid | Mobile: padded content with search + compact summary strip + list
                  if (widget.isDesktop) ...[
                    AnimatedCrossFade(
                      firstChild: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: KpiMetricsRow(history: filtered),
                      ),
                      secondChild: const SizedBox(width: double.infinity),
                      crossFadeState: _showKpiSummary
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: const Duration(milliseconds: 220),
                      sizeCurve: Curves.easeOutCubic,
                    ),
                    const SizedBox(height: 16),
                    FrostedGlassCard(
                      padding: const EdgeInsets.all(24),
                      borderRadius: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHistoryFilterBar(true, filtered),
                          const SizedBox(height: 16),
                          _buildGmailToolbar(
                            totalItems: totalItems,
                            startIndex: startIndex,
                            endIndex: endIndex,
                            totalPages: totalPages,
                            allOnPageSelected: allOnPageSelected,
                            someOnPageSelected: someOnPageSelected,
                            pageIds: pageIds,
                            filtered: filtered,
                            isDesktop: true,
                          ),
                          const SizedBox(height: 16),
                          if (filtered.isEmpty)
                            _buildEmptyHistoryState(
                              activeFilter: _historyFilter,
                              hasAnyHistory: widget.history.isNotEmpty,
                            )
                          else ...[
                            _buildDesktopDataTable(
                              pageScans: pageScans,
                              allOnPageSelected: allOnPageSelected,
                              someOnPageSelected: someOnPageSelected,
                              pageIds: pageIds,
                            ),
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
                  ] else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Full-width Search scans... directly below History title
                          _buildHistoryFilterBar(false, filtered),
                          const SizedBox(height: 12),
                          _buildMobileSummaryStrip(filtered),
                          const SizedBox(height: 12),
                          if (filtered.isEmpty)
                            _buildEmptyHistoryState(
                              activeFilter: _historyFilter,
                              hasAnyHistory: widget.history.isNotEmpty,
                            )
                          else
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.black.withValues(alpha: 0.06),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (_isMobileSelectionMode) ...[
                                      _buildMobileListHeader(filtered),
                                      const Divider(
                                        height: 1,
                                        color: Color(0xFFF0F0F2),
                                      ),
                                    ],
                                    _buildMobileHistoryList(filtered),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 36),
                  _buildSimpleFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryFilterBar(
    bool isDesktop,
    List<ClassificationResult> filtered,
  ) {
    final searchPill = Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDesktop ? SariwaColors.colorSurface : Colors.white,
        borderRadius: BorderRadius.circular(isDesktop ? 999 : 16),
        border: Border.all(
          color: isDesktop
              ? SariwaColors.colorLine
              : Colors.black.withValues(alpha: 0.08),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.search,
            size: 16,
            color: SariwaColors.inkSlateMuted,
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
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.2,
                color: SariwaColors.inkSlate,
              ),
              decoration: const InputDecoration(
                hintText: 'Search scans...',
                hintStyle: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -0.2,
                  color: SariwaColors.inkSlateSubtle,
                ),
                filled: false,
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _currentPage = 1;
                });
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              tooltip: 'Clear search',
              icon: const Icon(
                CupertinoIcons.xmark_circle_fill,
                size: 16,
                color: SariwaColors.inkSlateSubtle,
              ),
            ),
        ],
      ),
    );

    final searchInput = isDesktop
        ? _buildLabeledFilterControl(
            label: 'Search inspections',
            child: searchPill,
          )
        : searchPill;

    final regionDropdown = _buildLabeledFilterControl(
      label: 'Inspection region',
      child: _buildMenuAnchorFilter(
        value: _regionFilter,
        options: const [
          ('All', 'All regions'),
          ('Eye', 'Eye (Mata)'),
          ('Gill', 'Gill (Hasang)'),
        ],
        onSelected: (val) => setState(() {
          _regionFilter = val;
          _currentPage = 1;
        }),
      ),
    );

    final statusDropdown = _buildLabeledFilterControl(
      label: 'Freshness status',
      child: _buildMenuAnchorFilter(
        value: _historyFilter,
        options: const [
          ('All', 'All statuses'),
          ('Fresh', 'Fresh only'),
          ('Not Fresh', 'Not Fresh only'),
        ],
        onSelected: (val) => setState(() {
          _historyFilter = val;
          _currentPage = 1;
        }),
      ),
    );

    final sortDropdown = _buildLabeledFilterControl(
      label: 'Sort by',
      child: _buildMenuAnchorFilter(
        value: _sortOrder,
        options: const [
          ('Newest', 'Newest first'),
          ('Oldest', 'Oldest first'),
          ('Highest', 'Highest confidence'),
          ('Lowest', 'Lowest confidence'),
        ],
        onSelected: (val) => setState(() {
          _sortOrder = val;
          _currentPage = 1;
        }),
      ),
    );

    final exportButton = OutlinedButton.icon(
      key: const Key('export_history_csv_button'),
      onPressed: filtered.isEmpty
          ? null
          : () async {
              final downloaded = await exportAnalyticsCsv(filtered);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      downloaded
                          ? 'Exported ${filtered.length} history records to CSV.'
                          : 'Could not export CSV.',
                    ),
                  ),
                );
              }
            },
      icon: const Icon(CupertinoIcons.arrow_down_doc, size: 16),
      label: const Text('Export CSV'),
      style: OutlinedButton.styleFrom(
        foregroundColor: SariwaColors.brandPrimary,
        backgroundColor: SariwaColors.colorPale.withValues(alpha: 0.45),
        side: BorderSide(
          color: SariwaColors.brandPrimary.withValues(alpha: 0.25),
        ),
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
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
          const SizedBox(width: 12),
          exportButton,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        searchInput,
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: regionDropdown),
                    const SizedBox(width: 12),
                    Expanded(child: statusDropdown),
                  ],
                ),
                const SizedBox(height: 12),
                sortDropdown,
              ],
            ),
          ),
          crossFadeState: _showMobileFilters
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
          sizeCurve: Curves.easeOutCubic,
        ),
      ],
    );
  }

  /// Unified iOS Large Title + Utility Row header for Mobile History
  Widget _buildMobileHistoryHeader(List<ClassificationResult> filtered) {
    final total = filtered.length;
    final activeFilterCount = (_regionFilter != 'All' ? 1 : 0) +
        (_historyFilter != 'All' ? 1 : 0) +
        (_sortOrder != 'Newest' ? 1 : 0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 36,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '$total ${total == 1 ? 'scan' : 'scans'}',
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF737373),
                  ),
                ),
                MenuAnchor(
                  alignmentOffset: const Offset(-140, 6),
                  style: MenuStyle(
                    backgroundColor: const WidgetStatePropertyAll(Colors.white),
                    surfaceTintColor:
                        const WidgetStatePropertyAll(Colors.transparent),
                    elevation: const WidgetStatePropertyAll(6),
                    shadowColor: WidgetStatePropertyAll(
                      Colors.black.withValues(alpha: 0.12),
                    ),
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Colors.black.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                  ),
                  menuChildren: [
                    _buildOverflowMenuItem(
                      icon: CupertinoIcons.checkmark_circle,
                      label: _isMobileSelectionMode
                          ? 'Done Selecting'
                          : 'Select',
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _isMobileSelectionMode = !_isMobileSelectionMode;
                          if (!_isMobileSelectionMode) {
                            _selectedHistoryScanIds.clear();
                          }
                        });
                      },
                    ),
                    _buildOverflowMenuItem(
                      icon: CupertinoIcons.slider_horizontal_3,
                      label: _showMobileFilters
                          ? 'Hide Filters'
                          : (activeFilterCount > 0
                              ? 'Filter ($activeFilterCount)'
                              : 'Filter'),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        setState(
                          () => _showMobileFilters = !_showMobileFilters,
                        );
                      },
                    ),
                    _buildOverflowMenuItem(
                      icon: CupertinoIcons.arrow_up_arrow_down,
                      label: 'Sort by',
                      onPressed: () => _showMobileSortSheet(),
                    ),
                    _buildOverflowMenuItem(
                      key: const Key('export_history_csv_button'),
                      icon: CupertinoIcons.arrow_down_doc,
                      label: 'Export CSV',
                      enabled: filtered.isNotEmpty,
                      onPressed: filtered.isEmpty
                          ? null
                          : () async {
                              final downloaded =
                                  await exportAnalyticsCsv(filtered);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      downloaded
                                          ? 'Exported ${filtered.length} history records to CSV.'
                                          : 'Could not export CSV.',
                                    ),
                                  ),
                                );
                              }
                            },
                    ),
                  ],
                  builder: (context, controller, _) {
                    return Semantics(
                      button: true,
                      label: 'More history actions',
                      child: Tooltip(
                        message: 'More actions',
                        child: Material(
                          color: Colors.white,
                          shape: CircleBorder(
                            side: BorderSide(
                              color: Colors.black.withValues(alpha: 0.08),
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              if (controller.isOpen) {
                                controller.close();
                              } else {
                                controller.open();
                              }
                            },
                            customBorder: const CircleBorder(),
                            child: const SizedBox(
                              width: 36,
                              height: 36,
                              child: Icon(
                                Icons.more_horiz,
                                size: 18,
                                color: Color(0xFF111111),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'History',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              height: 1.15,
              color: Color(0xFF111111),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverflowMenuItem({
    Key? key,
    required IconData icon,
    required String label,
    bool enabled = true,
    VoidCallback? onPressed,
  }) {
    return MenuItemButton(
      key: key,
      onPressed: enabled ? onPressed : null,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return const Color(0xFFF5F5F7);
          }
          return Colors.transparent;
        }),
        foregroundColor: WidgetStatePropertyAll(
          enabled ? const Color(0xFF111111) : const Color(0xFFA3A3A3),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        minimumSize: const WidgetStatePropertyAll(Size(176, 40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: enabled ? const Color(0xFF111111) : const Color(0xFFA3A3A3),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color:
                  enabled ? const Color(0xFF111111) : const Color(0xFFA3A3A3),
            ),
          ),
        ],
      ),
    );
  }

  void _showMobileSortSheet() {
    const options = [
      ('Newest', 'Newest first'),
      ('Oldest', 'Oldest first'),
      ('Highest', 'Highest confidence'),
      ('Lowest', 'Lowest confidence'),
    ];
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: false,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4D4D8),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sort by',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 10),
              for (final opt in options)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: _sortOrder == opt.$1
                      ? const Color(0xFFF5F5F7)
                      : Colors.transparent,
                  title: Text(
                    opt.$2,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14,
                      fontWeight: _sortOrder == opt.$1
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: const Color(0xFF111111),
                    ),
                  ),
                  trailing: _sortOrder == opt.$1
                      ? const Icon(
                          CupertinoIcons.checkmark,
                          size: 16,
                          color: Color(0xFF111111),
                        )
                      : null,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _sortOrder = opt.$1;
                      _currentPage = 1;
                    });
                    Navigator.of(sheetCtx).pop();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuAnchorFilter({
    required String value,
    required List<(String, String)> options,
    required ValueChanged<String> onSelected,
  }) {
    final currentLabel = options
        .firstWhere((o) => o.$1 == value, orElse: () => options.first)
        .$2;

    return MenuAnchor(
      alignmentOffset: const Offset(0, 6),
      style: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll(Colors.white),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(6),
        shadowColor: WidgetStatePropertyAll(
          Colors.black.withValues(alpha: 0.10),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
          ),
        ),
      ),
      menuChildren: options.map((opt) {
        final isSelected = opt.$1 == value;
        return MenuItemButton(
          onPressed: () => onSelected(opt.$1),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (isSelected) return const Color(0xFFF5F5F7);
              if (states.contains(WidgetState.hovered)) {
                return Colors.black.withValues(alpha: 0.03);
              }
              return Colors.transparent;
            }),
            foregroundColor: const WidgetStatePropertyAll(Color(0xFF111111)),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            minimumSize: const WidgetStatePropertyAll(Size(168, 38)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(
                  opt.$2,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: const Color(0xFF111111),
                  ),
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 10),
                const Icon(
                  CupertinoIcons.checkmark,
                  size: 14,
                  color: Color(0xFF111111),
                ),
              ],
            ],
          ),
        );
      }).toList(),
      builder: (context, controller, _) {
        return InkWell(
          onTap: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: controller.isOpen
                    ? Colors.black.withValues(alpha: 0.22)
                    : Colors.black.withValues(alpha: 0.09),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    currentLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.2,
                      color: Color(0xFF111111),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  controller.isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: const Color(0xFF737373),
                ),
              ],
            ),
          ),
        );
      },
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
            color: SariwaColors.inkSlateSecondary,
          ),
        ),
        const SizedBox(height: 8),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                side: WidgetStateBorderSide.resolveWith((states) => BorderSide(
                  color: states.contains(WidgetState.selected)
                      ? SariwaColors.brandPrimary
                      : const Color(0xFF8FA6BF),
                  width: 1.2,
                )),
                fillColor: WidgetStateProperty.resolveWith((states) =>
                    states.contains(WidgetState.selected)
                        ? SariwaColors.brandPrimary
                        : SariwaColors.surfaceSlateTint),
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
              '${_selectedHistoryScanIds.length} selected',
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: SariwaColors.inkSlateSecondary,
              ),
            ),
            SizedBox(width: isDesktop ? 16 : 8),
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
                    ? 'Clear'
                    : 'All',
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: SariwaColors.brandPrimary,
                ),
              ),
            ),
            SizedBox(width: isDesktop ? 8 : 4),
            ElevatedButton.icon(
              key: const Key('history_bulk_delete_button'),
              onPressed: () =>
                  _confirmBulkDelete(_selectedHistoryScanIds.toList()),
              style: ElevatedButton.styleFrom(
                backgroundColor: SariwaColors.statusSpoiled,
                foregroundColor: SariwaColors.cardSurfaceLight,
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 16 : 12,
                  vertical: 8,
                ),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.padded,
                elevation: 0,
                shape: const StadiumBorder(),
              ),
              icon: const Icon(CupertinoIcons.trash, size: 14),
              label: Text(
                isDesktop
                    ? 'Delete (${_selectedHistoryScanIds.length})'
                    : 'Delete',
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ] else ...[
            Text(
              '$totalItems ${totalItems == 1 ? 'scan' : 'scans'}',
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: SariwaColors.inkSlateMuted,
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
    final textColor = isDarkTheme ? SariwaColors.textSecondaryLight : SariwaColors.inkSlateMuted;
    final iconColor = isDarkTheme ? Colors.white : SariwaColors.inkSlateSecondary;
    final disabledColor = isDarkTheme ? Colors.white24 : SariwaColors.lineSlate;

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
        const SizedBox(width: 8),
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
        color: SariwaColors.cardSurfaceLight.withValues(alpha: 0.50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: SariwaColors.cardSurfaceLight.withValues(alpha: 0.80),
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
                  color: SariwaColors.inkSlateMuted,
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
                    color: SariwaColors.inkSlate,
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
        color: SariwaColors.cardSurfaceLight.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: SariwaColors.cardSurfaceLight.withValues(alpha: 0.85),
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Table Header matching reference enterprise UI with Checkbox column
            Container(
              color: SariwaColors.cardSurfaceLight.withValues(alpha: 0.45),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        side: WidgetStateBorderSide.resolveWith((states) => BorderSide(
                          color: states.contains(WidgetState.selected)
                              ? SariwaColors.brandPrimary
                              : const Color(0xFF8FA6BF),
                          width: 1.2,
                        )),
                        fillColor: WidgetStateProperty.resolveWith((states) =>
                            states.contains(WidgetState.selected)
                                ? SariwaColors.brandPrimary
                                : SariwaColors.surfaceSlateTint),
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
                      'SCAN',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.6,
                        color: SariwaColors.inkSlateMuted,
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'REGION',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.6,
                        color: SariwaColors.inkSlateMuted,
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'DATE',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.6,
                        color: SariwaColors.inkSlateMuted,
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Tooltip(
                      message: 'Classifier confidence score.',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'SCORE',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.6,
                              color: SariwaColors.inkSlateMuted,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            CupertinoIcons.info_circle,
                            size: 13,
                            color: SariwaColors.inkSlateSubtle,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'STATUS',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.6,
                        color: SariwaColors.inkSlateMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 72),
                ],
              ),
            ),
            const Divider(height: 1, color: SariwaColors.surfaceSlateSubtle),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pageScans.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: SariwaColors.surfaceSlateWash),
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            side: WidgetStateBorderSide.resolveWith((states) => BorderSide(
                              color: states.contains(WidgetState.selected)
                                  ? SariwaColors.brandPrimary
                                  : const Color(0xFF8FA6BF),
                              width: 1.2,
                            )),
                            fillColor: WidgetStateProperty.resolveWith((states) =>
                                states.contains(WidgetState.selected)
                                    ? SariwaColors.brandPrimary
                                    : SariwaColors.surfaceSlateTint),
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
                      const SizedBox(width: 8),
                      _buildScanCropThumbnail(scan),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: Text(
                          _formatDesktopScanTitle(scanId),
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.2,
                            color: isSelected
                                ? SariwaColors.brandPrimary
                                : SariwaColors.inkSlate,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            (scan.regionType ?? 'Eye').toLowerCase() == 'gill'
                                ? 'Gill'
                                : 'Eye',
                            style: const TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.2,
                              color: SariwaColors.inkSlateSecondary,
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
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            letterSpacing: -0.2,
                            color: SariwaColors.inkSlateMuted,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 56,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: scan.confidence,
                                  backgroundColor:
                                      SariwaColors.surfaceSlateSubtle,
                                  valueColor: AlwaysStoppedAnimation(
                                    scan.isFresh
                                        ? SariwaColors.statusFresh
                                        : SariwaColors.statusSpoiled,
                                  ),
                                  minHeight: 5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(scan.confidence * 100).round()}%',
                              style: const TextStyle(
                                fontFamily: 'Geist Mono',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: SariwaColors.inkSlateSecondary,
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
                        width: 72,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(CupertinoIcons.eye, size: 15),
                              tooltip: 'View details',
                              color: SariwaColors.brandPrimary,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              onPressed: () =>
                                  InspectionDetailsModal.show(context, scan),
                            ),
                            _buildRowActionMenu(
                              scan,
                              scanId,
                              widget.controller,
                            ),
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

  /// Compact 4-metric white summary strip for mobile (`< md`)
  Widget _buildMobileSummaryStrip(List<ClassificationResult> scans) {
    final total = scans.length;
    final fresh = scans.where((s) => s.isFresh).length;
    final notFresh = scans.where((s) => s.isNotFresh).length;
    final avgConf = total == 0
        ? 0
        : ((scans.fold<double>(0.0, (sum, s) => sum + s.confidence) / total) *
                100)
            .round();

    Widget metricCell({
      required String label,
      required String value,
      Color valueColor = const Color(0xFF111111),
    }) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Geist Mono',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: valueColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF737373),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            metricCell(label: 'Total', value: '$total'),
            const VerticalDivider(
              width: 1,
              thickness: 1,
              indent: 10,
              endIndent: 10,
              color: Color(0xFFE5E5E7),
            ),
            metricCell(
              label: 'Fresh',
              value: '$fresh',
              valueColor: SariwaColors.brandPrimary,
            ),
            const VerticalDivider(
              width: 1,
              thickness: 1,
              indent: 10,
              endIndent: 10,
              color: Color(0xFFE5E5E7),
            ),
            metricCell(
              label: 'Not Fresh',
              value: '$notFresh',
              valueColor: notFresh > 0
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF111111),
            ),
            const VerticalDivider(
              width: 1,
              thickness: 1,
              indent: 10,
              endIndent: 10,
              color: Color(0xFFE5E5E7),
            ),
            metricCell(label: 'Avg. Conf', value: '$avgConf%'),
          ],
        ),
      ),
    );
  }

  /// Minimal header bar above the mobile history list; checkboxes remain hidden until Select or long-press
  Widget _buildMobileListHeader(List<ClassificationResult> filtered) {
    final total = filtered.length;
    final allIds = filtered.map((s) => s.scanId).whereType<int>().toSet();
    final hasSelection = _selectedHistoryScanIds.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          if (_isMobileSelectionMode && hasSelection) ...[
            Text(
              '${_selectedHistoryScanIds.length} selected',
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(width: 10),
            TextButton(
              key: const Key('history_select_all_button'),
              onPressed: () {
                setState(() {
                  if (_selectedHistoryScanIds.containsAll(allIds)) {
                    _selectedHistoryScanIds.clear();
                  } else {
                    _selectedHistoryScanIds.addAll(allIds);
                  }
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF111111),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                _selectedHistoryScanIds.containsAll(allIds) ? 'Clear' : 'All',
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 6),
            ElevatedButton.icon(
              key: const Key('history_bulk_delete_button'),
              onPressed: () =>
                  _confirmBulkDelete(_selectedHistoryScanIds.toList()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: const Size(0, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: const StadiumBorder(),
              ),
              icon: const Icon(CupertinoIcons.trash, size: 13),
              label: const Text(
                'Delete',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ] else
            Text(
              '$total ${total == 1 ? 'scan' : 'scans'}',
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF737373),
              ),
            ),
          const Spacer(),
          TextButton(
            key: const Key('history_toggle_selection_mode_button'),
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() {
                _isMobileSelectionMode = !_isMobileSelectionMode;
                if (!_isMobileSelectionMode) {
                  _selectedHistoryScanIds.clear();
                }
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF111111),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              _isMobileSelectionMode ? 'Done' : 'Select',
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHistoryList(List<ClassificationResult> scans) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: scans.length,
      separatorBuilder: (_, _) => const Divider(
        height: 1,
        indent: 64,
        color: Color(0xFFF0F0F2),
      ),
      itemBuilder: (context, index) {
        final scan = scans[index];
        final scanId = scan.scanId;
        final isSelected =
            scanId != null && _selectedHistoryScanIds.contains(scanId);
        final pct = '${(scan.confidence * 100).round()}%';
        final statusColor =
            scan.isFresh ? SariwaColors.brandPrimary : const Color(0xFFDC2626);

        void toggleSelection() {
          if (scanId == null) return;
          HapticFeedback.selectionClick();
          setState(() {
            if (_selectedHistoryScanIds.contains(scanId)) {
              _selectedHistoryScanIds.remove(scanId);
            } else {
              _selectedHistoryScanIds.add(scanId);
            }
          });
        }

        final row = Material(
          color: isSelected ? const Color(0xFFF5F5F7) : Colors.transparent,
          child: InkWell(
            hoverColor: const Color(0xFFF5F5F7),
            splashColor: Colors.black.withValues(alpha: 0.04),
            highlightColor: const Color(0xFFF5F5F7),
            onTap: () {
              if (_isMobileSelectionMode) {
                toggleSelection();
                return;
              }
              InspectionDetailsModal.show(
                context,
                scan,
                onDelete: scanId != null
                    ? () => _confirmDelete(scanId, scan: scan)
                    : null,
              );
            },
            onLongPress: scanId == null
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      _isMobileSelectionMode = true;
                      _selectedHistoryScanIds.add(scanId);
                    });
                  },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  if (_isMobileSelectionMode) ...[
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: Transform.scale(
                        scale: 0.88,
                        child: Checkbox(
                          key: scanId != null
                              ? Key('history_item_checkbox_$scanId')
                              : null,
                          value: isSelected,
                          activeColor: const Color(0xFF111111),
                          checkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          side: WidgetStateBorderSide.resolveWith(
                            (states) => BorderSide(
                              color: states.contains(WidgetState.selected)
                                  ? const Color(0xFF111111)
                                  : Colors.black.withValues(alpha: 0.22),
                              width: 1.2,
                            ),
                          ),
                          fillColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.selected)
                                ? const Color(0xFF111111)
                                : Colors.white,
                          ),
                          onChanged: (_) => toggleSelection(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  // Column 1: Thumbnail
                  ScanThumbnail(
                    scan: scan,
                    size: 40,
                    borderRadius: 8,
                    iconSize: 16,
                  ),
                  const SizedBox(width: 12),
                  // Column 2: Title + Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatMobileScanTitle(scan),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            color: Color(0xFF111111),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _formatDateTime(scan.createdAt),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF737373),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Column 3: Borderless "• Fresh" + Score %
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            scan.isFresh ? 'Fresh' : 'Not Fresh',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        pct,
                        style: const TextStyle(
                          fontFamily: 'Geist Mono',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF737373),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );

        if (scanId == null || _isMobileSelectionMode) return row;

        return Dismissible(
          key: ValueKey('mobile_history_dismiss_$scanId'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: const Color(0xFFDC2626),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.trash,
                  color: Colors.white,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Delete',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          confirmDismiss: (_) async {
            HapticFeedback.mediumImpact();
            _confirmDelete(scanId, scan: scan);
            return false;
          },
          child: row,
        );
      },
    );
  }

  Widget _buildScanCropThumbnail(ClassificationResult scan) {
    return ScanThumbnail(
      scan: scan,
      size: 36,
      borderRadius: 8,
      iconSize: 15,
    );
  }

  Widget _buildReferenceStatusPill(bool isFresh) {
    final dotColor = isFresh ? SariwaColors.statusFresh : SariwaColors.statusSpoiled;
    final bgColor = isFresh ? SariwaColors.freshTrack : SariwaColors.notFreshTrack;
    final textColor = isFresh ? SariwaColors.freshText : SariwaColors.notFreshText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
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
          const SizedBox(width: 8),
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
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      icon: const Icon(
        Icons.more_vert,
        size: 18,
        color: SariwaColors.inkSlateMuted,
      ),
      tooltip: 'Actions',
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFDCE8E5)),
      ),
      onSelected: (action) {
        if (action == 'view') {
          InspectionDetailsModal.show(context, scan);
        } else if (action == 'delete' && scanId != null) {
          _confirmDelete(scanId, scan: scan);
        }
      },
      itemBuilder: (ctx) => [
        const PopupMenuItem<String>(
          value: 'view',
          child: Row(
            children: [
              Icon(CupertinoIcons.eye, size: 16, color: SariwaColors.inkSlateSecondary),
              SizedBox(width: 12),
              Text('View details'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(CupertinoIcons.trash, size: 16, color: SariwaColors.notFreshPrimary),
              SizedBox(width: 12),
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
      emptyTitle = 'No scans yet';
      emptySubtitle = 'Snap or upload a photo to start your scan log.';
    } else if (activeFilter == 'Fresh') {
      emptyTitle = 'No Fresh scans';
      emptySubtitle = 'No Fresh scans match the current filter.';
    } else if (activeFilter == 'Not Fresh') {
      emptyTitle = 'No Not Fresh scans';
      emptySubtitle = 'No Not Fresh scans match the current filter.';
    } else {
      emptyTitle = 'No matches';
      emptySubtitle = 'Try clearing your search or filter.';
    }

    return Container(
      key: const Key('empty_history_state'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: SariwaColors.surfaceSlateTint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SariwaColors.surfaceSlateSubtle, width: 0.8),
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
          const SizedBox(height: 16),
          Text(
            emptyTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              letterSpacing: AppTypography.defaultLetterSpacing,
              color: SariwaColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 8),
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

  void _confirmDelete(int scanId, {ClassificationResult? scan}) async {
    final confirmed = await HistoryDeleteDialog.showSingle(
      context: context,
      scanId: scanId,
      scan: scan,
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
        '© ${DateTime.now().year} SariwaBa',
        style: const TextStyle(
          fontSize: 12,
          letterSpacing: AppTypography.defaultLetterSpacing,
          color: SariwaColors.textMutedDark,
        ),
      ),
    );
  }
}
