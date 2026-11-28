import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import '../../../constants/content/faq_data.dart';
import '../../../constants/theme/app_colors.dart';
import '../../../constants/theme/app_typography.dart';
import '../../../widgets/common/sariwa_scrollbar.dart';

/// Clean, single-surface iOS-style FAQs view with zero category badge clutter.
class HelpFaqDashboardSection extends StatefulWidget {
  final bool isDesktop;
  final ScrollController? scrollController;

  const HelpFaqDashboardSection({
    super.key,
    required this.isDesktop,
    this.scrollController,
  });

  @override
  State<HelpFaqDashboardSection> createState() =>
      _HelpFaqDashboardSectionState();
}

class _HelpFaqDashboardSectionState extends State<HelpFaqDashboardSection> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final Set<String> _expandedItemIds = <String>{};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FaqItemModel> get _filteredFaqs {
    final query = _searchQuery.trim().toLowerCase();
    return FaqData.items.where((item) {
      final matchesCategory = _selectedCategory == 'All' ||
          item.category.toLowerCase() == _selectedCategory.toLowerCase();
      if (!matchesCategory) return false;

      if (query.isEmpty) return true;
      return item.question.toLowerCase().contains(query) ||
          item.answer.toLowerCase().contains(query);
    }).toList();
  }

  void _toggleExpanded(String id) {
    setState(() {
      if (_expandedItemIds.contains(id)) {
        _expandedItemIds.remove(id);
      } else {
        _expandedItemIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = widget.isDesktop ? 32.0 : 16.0;
    final faqs = _filteredFaqs;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        controller: widget.scrollController,
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          widget.isDesktop ? 24 : 56,
          horizontalPadding,
          widget.isDesktop ? 32 : 104,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Help & Frequently Asked Questions',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: widget.isDesktop ? 28 : 24,
                    fontWeight: FontWeight.w500,
                    letterSpacing: AppTypography.defaultLetterSpacing,
                    color: SariwaColors.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSearchBar(),
                const SizedBox(height: 12),
                _buildCategoryChips(),
                const SizedBox(height: 16),
                if (faqs.isEmpty)
                  _buildEmptyState()
                else
                  Container(
                    decoration: BoxDecoration(
                      color: SariwaColors.cardSurfaceLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: SariwaColors.colorLine),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        children: [
                          for (var i = 0; i < faqs.length; i++) ...[
                            _buildAccordionRow(faqs[i]),
                            if (i < faqs.length - 1)
                              const Divider(
                                height: 1,
                                indent: 16,
                                color: SariwaColors.colorLineSubtle,
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: SariwaColors.cardSurfaceLight,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: SariwaColors.colorLine),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.search,
            size: 16,
            color: SariwaColors.inkSlateSubtle,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(
                fontFamily: 'Geist',
                fontSize: 14,
                color: SariwaColors.inkSlate,
              ),
              decoration: const InputDecoration(
                hintText: 'Search FAQs...',
                hintStyle: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: SariwaColors.inkSlateSubtle,
                ),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(CupertinoIcons.clear_circled_solid, size: 16),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              color: SariwaColors.inkSlateSubtle,
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SariwaScrollbar(
      alwaysVisible: false,
      builder: (context, controller) => SingleChildScrollView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final cat in FaqData.categories)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: _selectedCategory == cat,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCategory = cat);
                    }
                  },
                  labelStyle: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 12,
                    fontWeight: _selectedCategory == cat
                        ? FontWeight.w500
                        : FontWeight.w400,
                    color: _selectedCategory == cat
                        ? SariwaColors.cardSurfaceLight
                        : SariwaColors.inkSlateSecondary,
                  ),
                  selectedColor: SariwaColors.brandPrimary,
                  backgroundColor: SariwaColors.cardSurfaceLight,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: _selectedCategory == cat
                          ? SariwaColors.brandPrimary
                          : SariwaColors.colorLine,
                    ),
                  ),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccordionRow(FaqItemModel item) {
    final isExpanded = _expandedItemIds.contains(item.id);

    return Column(
      children: [
        InkWell(
          onTap: () => _toggleExpanded(item.id),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.question,
                    style: const TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: AppTypography.defaultLetterSpacing,
                      color: SariwaColors.textPrimaryDark,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  isExpanded
                      ? CupertinoIcons.chevron_up
                      : CupertinoIcons.chevron_down,
                  size: 16,
                  color: SariwaColors.inkSlateSubtle,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Container(
            width: double.infinity,
            color: SariwaColors.colorSurface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Text(
              item.answer,
              style: const TextStyle(
                fontFamily: 'Geist',
                fontSize: 14,
                fontWeight: FontWeight.w300,
                letterSpacing: AppTypography.defaultLetterSpacing,
                color: SariwaColors.inkSlateSecondary,
                height: 1.45,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: SariwaColors.cardSurfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SariwaColors.colorLine),
      ),
      child: Column(
        children: [
          const Icon(
            CupertinoIcons.search,
            size: 32,
            color: SariwaColors.inkSlateSubtle,
          ),
          const SizedBox(height: 12),
          Text(
            'No matches for "$_searchQuery"',
            style: const TextStyle(
              fontFamily: 'Geist',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: SariwaColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _selectedCategory = 'All';
              });
            },
            child: const Text('Clear search'),
          ),
        ],
      ),
    );
  }
}
