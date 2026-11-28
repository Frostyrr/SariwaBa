import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../../constants/content/faq_data.dart';
import '../../../constants/theme/app_colors.dart';
import '../../../constants/theme/app_typography.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/blur_fade.dart';
import '../../../widgets/common/staggered_reveal.dart';

class FaqItem {
  final String question;
  final String answer;
  final bool isResultsGuide;

  const FaqItem({
    required this.question,
    required this.answer,
    this.isResultsGuide = false,
  });
}

/// Monochrome-first FAQ Section
/// - Single unified FAQ Accordion (`max-w-3xl mx-auto`) in a pure white rounded-3xl card,
///   including "How do I read the freshness results?" with the 2-column Fresh vs. Not Fresh comparison
/// - Existing Final CTA Banner below (untouched)
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

  static const Color _canvasColor = Color(0xFFF5F5F7);
  static const Color _inkPrimary = Color(0xFF111111);
  static const Color _inkMuted = Color(0xFF737373);
  static const Color _hairline = Color(0x0D171717);
  static const Color _dividerColor = Color(0x12171717);
  static const Color _pillBg = Color(0xFFF5F5F5);
  static const Color _pillText = Color(0xFF404040);

  static final List<FaqItem> _faqList = [
    const FaqItem(
      question: 'How do I read the freshness results?',
      answer: '',
      isResultsGuide: true,
    ),
    ...FaqData.homepageFaqs
        .map((item) => FaqItem(question: item.question, answer: item.answer)),
  ];

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
          color: _canvasColor,
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 56.0 : 80.0,
            horizontal: 24.0,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BlurFade(
                    triggerOnVisible: true,
                    delay: Duration.zero,
                    child: Column(
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            'Common Questions',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: isMobile ? 28.0 : 36.0,
                              fontWeight: FontWeight.w700,
                              letterSpacing: isMobile ? -0.7 : -0.9,
                              height: 1.15,
                              color: _inkPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: const Text(
                              'Answers about photo guidelines, confidence scores, and how your scans are stored.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 1.6,
                                color: _inkMuted,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isMobile ? 32 : 44),

                  // 1. Unified FAQ Accordion (max-w-3xl = 768px centered)
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 768.0),
                      child: BlurFade(
                        triggerOnVisible: true,
                        delay: const Duration(milliseconds: 80),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: _hairline),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              for (var index = 0;
                                  index < _faqList.length;
                                  index++) ...[
                                _buildAccordionRow(
                                  index: index,
                                  item: _faqList[index],
                                  isExpanded: _expandedIndices.contains(index),
                                  isMobile: isMobile,
                                ),
                                if (index < _faqList.length - 1)
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 12 : 20,
                                    ),
                                    child: const Divider(
                                      height: 1,
                                      color: _dividerColor,
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: isMobile ? 48 : 64),

                  // 2. Existing Final CTA Banner (UNTOUCHED)
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

  /// 2-column Fresh vs. Not Fresh comparison rendered inside the expanded FAQ row
  Widget _buildResultsComparisonBody({required bool isMobile}) {
    const freshCol = _GuideColumn(
      title: 'Fresh (Sariwa)',
      dotColor: SariwaColors.brandPrimary,
      titleColor: _inkPrimary,
      cues: [
        (label: 'Eyes', detail: 'Clear, rounded cornea with dark pupils.'),
        (label: 'Gills', detail: 'Bright red to crimson with clear mucus.'),
      ],
    );

    const notFreshCol = _GuideColumn(
      title: 'Not Fresh (Hindi Sariwa)',
      dotColor: SariwaColors.statusSpoiled,
      titleColor: _inkPrimary,
      cues: [
        (label: 'Eyes', detail: 'Cloudy, milky, or sunken pupils.'),
        (label: 'Gills', detail: 'Pale, grey, or brown with sticky slime.'),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _hairline),
          ),
          child: !isMobile
              ? const IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(18),
                          child: freshCol,
                        ),
                      ),
                      VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: _dividerColor,
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(18),
                          child: notFreshCol,
                        ),
                      ),
                    ],
                  ),
                )
              : const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(padding: EdgeInsets.all(16), child: freshCol),
                    Divider(height: 1, color: _dividerColor),
                    Padding(padding: EdgeInsets.all(16), child: notFreshCol),
                  ],
                ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Visual estimate only — always pair with smell and texture checks.',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: _inkMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildAccordionRow({
    required int index,
    required FaqItem item,
    required bool isExpanded,
    required bool isMobile,
  }) {
    final rowHorizontalPadding = isMobile ? 12.0 : 20.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          toggled: isExpanded,
          label: item.question,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _toggleIndex(index),
                borderRadius: BorderRadius.circular(12),
                hoverColor: Colors.black.withValues(alpha: 0.025),
                highlightColor: Colors.black.withValues(alpha: 0.04),
                splashColor: Colors.black.withValues(alpha: 0.04),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: rowHorizontalPadding,
                    vertical: 18,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.question,
                          style: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.15,
                            color: _inkPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        child: Icon(
                          CupertinoIcons.chevron_down,
                          size: 16,
                          color: isExpanded ? _inkPrimary : _inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity, height: 0),
          secondChild: Padding(
            padding: EdgeInsets.fromLTRB(
              rowHorizontalPadding,
              0,
              rowHorizontalPadding,
              18,
            ),
            child: item.isResultsGuide
                ? _buildResultsComparisonBody(isMobile: isMobile)
                : Text(
                    item.answer,
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                      color: _inkMuted,
                    ),
                  ),
          ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
          sizeCurve: Curves.easeOutCubic,
        ),
      ],
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

class _GuideColumn extends StatelessWidget {
  final String title;
  final Color dotColor;
  final Color titleColor;
  final List<({String label, String detail})> cues;

  const _GuideColumn({
    required this.title,
    required this.dotColor,
    required this.titleColor,
    required this.cues,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < cues.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _FaqSectionState._pillBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  cues[i].label,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _FaqSectionState._pillText,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  cues[i].detail,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: _FaqSectionState._inkMuted,
                  ),
                ),
              ),
            ],
          ),
          if (i < cues.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}
