import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../constants/content/faq_data.dart';
import '../../../constants/theme/app_colors.dart';
import '../../../constants/theme/app_typography.dart';

/// Dedicated Help & FAQs dashboard section with live search query filtering,
/// category chips, and accessible accordions, derived from shared FaqData.
class HelpFaqDashboardSection extends StatefulWidget {
  final bool isDesktop;
  final ScrollController? scrollController;

  const HelpFaqDashboardSection({
    super.key,
    required this.isDesktop,
    this.scrollController,
  });

  @override
  State<HelpFaqDashboardSection> createState() => _HelpFaqDashboardSectionState();
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
      final qMatch = item.question.toLowerCase().contains(query);
      final aMatch = item.answer.toLowerCase().contains(query);
      return qMatch || aMatch;
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
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 24,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                _buildHeader(),

                const SizedBox(height: 20),

                // Search Bar
                _buildSearchBar(),

                const SizedBox(height: 16),

                // Category Chips
                _buildCategoryChips(),

                const SizedBox(height: 24),

                // FAQ Accordions or Empty State
                if (faqs.isEmpty)
                  _buildEmptyState()
                else
                  for (final item in faqs) ...[
                    _buildAccordionItem(item),
                    const SizedBox(height: 10),
                  ],

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: SariwaColors.brandPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: SariwaColors.brandPrimary.withValues(alpha: 0.2),
                ),
              ),
              child: const Text(
                'KNOWLEDGE BASE & SUPPORT',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: SariwaColors.brandPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Help & Frequently Asked Questions',
          style: TextStyle(
            fontFamily: 'Geist',
            fontSize: 26,
            fontWeight: FontWeight.w600,
            letterSpacing: AppTypography.defaultLetterSpacing,
            color: SariwaColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Find answers regarding image requirements, AI classification metrics, account data retention, and troubleshooting.',
          style: TextStyle(
            fontFamily: 'Geist',
            fontSize: 14,
            fontWeight: FontWeight.w300,
            letterSpacing: AppTypography.defaultLetterSpacing,
            color: SariwaColors.textSecondaryDark,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.search,
            size: 18,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(
                fontFamily: 'Geist',
                fontSize: 13.5,
                color: Color(0xFF0F172A),
              ),
              decoration: const InputDecoration(
                hintText: 'Search questions, keywords, or topics...',
                hintStyle: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF94A3B8),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(CupertinoIcons.clear_circled_solid, size: 16),
              color: const Color(0xFF94A3B8),
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final cat in FaqData.categories) ...[
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
                      ? Colors.white
                      : const Color(0xFF475569),
                ),
                selectedColor: SariwaColors.brandPrimary,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                  side: BorderSide(
                    color: _selectedCategory == cat
                        ? SariwaColors.brandPrimary
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAccordionItem(FaqItemModel item) {
    final isExpanded = _expandedItemIds.contains(item.id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isExpanded
              ? SariwaColors.brandPrimary.withValues(alpha: 0.35)
              : const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            InkWell(
              onTap: () => _toggleExpanded(item.id),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.category.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
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
                    const SizedBox(width: 8),
                    Icon(
                      isExpanded
                          ? CupertinoIcons.chevron_up
                          : CupertinoIcons.chevron_down,
                      size: 16,
                      color: const Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
              Container(
                width: double.infinity,
                color: const Color(0xFFF8FAFC),
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                child: Text(
                  item.answer,
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    letterSpacing: AppTypography.defaultLetterSpacing,
                    color: Color(0xFF334155),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(
            CupertinoIcons.search,
            size: 36,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 12),
          Text(
            'No FAQs matching "$_searchQuery"',
            style: const TextStyle(
              fontFamily: 'Geist',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: SariwaColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try different search terms or select another category filter.',
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 13,
              fontWeight: FontWeight.w300,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _selectedCategory = 'All';
              });
            },
            child: const Text('Reset filters'),
          ),
        ],
      ),
    );
  }
}
