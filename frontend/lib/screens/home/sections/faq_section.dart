import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import '../../../constants/content/faq_data.dart';
import '../../../constants/theme/app_colors.dart';
import '../../../constants/theme/app_typography.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/staggered_reveal.dart';

class FaqItem {
  final String question;
  final String answer;

  const FaqItem({
    required this.question,
    required this.answer,
  });
}

/// Frequently Asked Questions Section
/// Clean bordered accordions with accessible focus/tap feedback and atmospheric CTA.
class FaqSection extends StatefulWidget {
  final VoidCallback onDownload;
  final VoidCallback? onTryInspection;

  const FaqSection({
    super.key,
    required this.onDownload,
    this.onTryInspection,
  });

  @override
  State<FaqSection> createState() => _FaqSectionState();
}

class _FaqSectionState extends State<FaqSection> {
  final Set<int> _expandedIndices = {};

  static final List<FaqItem> _faqList = FaqData.homepageFaqs
      .map((item) => FaqItem(question: item.question, answer: item.answer))
      .toList();

  void _toggleIndex(int index) {
    setState(() {
      if (_expandedIndices.contains(index)) {
        _expandedIndices.remove(index);
      } else {
        _expandedIndices.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: SariwaColors.cardSurfaceLight,
            border: Border(
              top: BorderSide(color: SariwaColors.colorLineSubtle),
            ),
          ),
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 64.0 : 80.0,
            horizontal: isMobile ? 16.0 : 24.0,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Semantics(
                    header: true,
                    child: StaggeredReveal(
                      revealOnScroll: true,
                      staggerIndex: 0,
                      child: Text(
                        'Common Questions',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: isMobile ? 28.0 : 36.0,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.7,
                          height: 1.15,
                          color: SariwaColors.textPrimaryDark,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  StaggeredReveal(
                    revealOnScroll: true,
                    staggerIndex: 1,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: const Text(
                        'Clear answers about capture guidelines, confidence scores, and how your inspection records are stored.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          letterSpacing: -0.15,
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          height: 1.5,
                          color: SariwaColors.inkSlateSecondary,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: isMobile ? 28 : 36),

                  ...List.generate(_faqList.length, (index) {
                    final item = _faqList[index];
                    final isExpanded = _expandedIndices.contains(index);

                    return StaggeredReveal(
                      revealOnScroll: true,
                      staggerIndex: index,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildAccordionCard(
                          isMobile: isMobile,
                          index: index,
                          item: item,
                          isExpanded: isExpanded,
                        ),
                      ),
                    );
                  }),

                  SizedBox(height: isMobile ? 40 : 52),

                  StaggeredReveal(
                    revealOnScroll: true,
                    staggerIndex: 1,
                    child: _buildFinalCtaBanner(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccordionCard({
    required bool isMobile,
    required int index,
    required FaqItem item,
    required bool isExpanded,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: SariwaColors.cardSurfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded
              ? SariwaColors.brandPrimary.withValues(alpha: 0.45)
              : SariwaColors.colorLine,
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          Semantics(
            button: true,
            toggled: isExpanded,
            label: item.question,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _toggleIndex(index),
                borderRadius: BorderRadius.circular(12),
                splashColor: SariwaColors.brandPrimary.withValues(alpha: 0.06),
                highlightColor: SariwaColors.brandPrimary.withValues(
                  alpha: 0.03,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16.0 : 20.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.question,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.2,
                            color: isExpanded
                                ? SariwaColors.brandPrimary
                                : SariwaColors.textPrimaryDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: isExpanded
                                ? SariwaColors.colorPale
                                : SariwaColors.colorSurface,
                            border: Border.all(color: SariwaColors.colorLine),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            CupertinoIcons.chevron_down,
                            size: 14,
                            color: isExpanded
                                ? SariwaColors.brandPrimary
                                : SariwaColors.inkSlateMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16.0 : 20.0,
                  ),
                  height: 1,
                  color: SariwaColors.colorLineSubtle,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isMobile ? 16.0 : 20.0,
                    12.0,
                    isMobile ? 16.0 : 20.0,
                    16.0,
                  ),
                  child: Text(
                    item.answer,
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      height: 1.5,
                      letterSpacing: -0.1,
                      color: SariwaColors.inkSlateSecondary,
                    ),
                  ),
                ),
              ],
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
            sizeCurve: Curves.easeOutCubic,
          ),
        ],
      ),
    );
  }

  Widget _buildFinalCtaBanner(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 768;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgroundBlurred.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: SariwaColors.bgAbyssDark.withValues(alpha: 0.90),
                border: Border.all(
                  color: SariwaColors.borderGlass,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: isMobile ? 40 : 48,
              horizontal: isMobile ? 24 : 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ready to inspect fish freshness with confidence?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.5,
                    height: 1.2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: const Text(
                    'Evaluate Tilapia freshness directly in your browser or install the mobile app for field inspections.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      height: 1.5,
                      color: SariwaColors.textSecondaryLight,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    AppButton.primary(
                      label: 'Download App',
                      icon: const Icon(
                        CupertinoIcons.arrow_down_to_line,
                        color: Colors.white,
                        size: 16,
                      ),
                      width: 176,
                      height: 48,
                      borderRadius: 999,
                      onPressed: widget.onDownload,
                    ),
                    if (widget.onTryInspection != null)
                      AppButton.outline(
                        label: 'Open Web Scanner',
                        width: 184,
                        height: 48,
                        borderRadius: 999,
                        onPressed: widget.onTryInspection,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
