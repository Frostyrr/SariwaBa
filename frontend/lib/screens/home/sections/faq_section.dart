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

/// Editorial FAQ & Reading Results Section
/// - Hairline-divided Fresh vs. Not Fresh quick guide on pure #FFFFFF (zero nested boxes)
/// - Crisp hairline-separated FAQ rows (eliminating card-stacking fatigue)
/// - Final atmospheric CTA banner
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
            horizontal: isMobile ? 20.0 : 24.0,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: const Text(
                          'How to read freshness results, photo guidelines, and how your scans are stored.',
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
                  ),
                  SizedBox(height: isMobile ? 32 : 48),

                  // Flat Hairline-Divided "How to Read the Results" Comparison
                  StaggeredReveal(
                    revealOnScroll: true,
                    staggerIndex: 1,
                    child: _buildResultsGuide(isMobile: isMobile),
                  ),

                  SizedBox(height: isMobile ? 36 : 48),

                  // Crisp Hairline-Separated FAQ Rows (no card-stacking)
                  const Divider(height: 1, color: SariwaColors.colorLine),
                  for (var index = 0; index < _faqList.length; index++) ...[
                    _buildAccordionRow(
                      index: index,
                      item: _faqList[index],
                      isExpanded: _expandedIndices.contains(index),
                    ),
                    const Divider(height: 1, color: SariwaColors.colorLine),
                  ],

                  SizedBox(height: isMobile ? 48 : 64),

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

  /// Flat hairline-separated visual reading guide (zero outer shadow / nested cards)
  Widget _buildResultsGuide({required bool isMobile}) {
    const freshCol = _GuideColumn(
      title: 'Fresh (Sariwa)',
      dotColor: SariwaColors.statusFresh,
      titleColor: SariwaColors.freshText,
      cues: [
        (label: 'Eyes', detail: 'Clear, rounded cornea with dark pupils.'),
        (label: 'Gills', detail: 'Bright red to crimson with clear mucus.'),
      ],
    );

    const notFreshCol = _GuideColumn(
      title: 'Not Fresh (Hindi Sariwa)',
      dotColor: SariwaColors.statusSpoiled,
      titleColor: SariwaColors.notFreshText,
      cues: [
        (label: 'Eyes', detail: 'Cloudy, milky, or sunken pupils.'),
        (label: 'Gills', detail: 'Pale, grey, or brown with sticky slime.'),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: SariwaColors.colorWorkspace,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SariwaColors.colorLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 20 : 28,
              20,
              isMobile ? 20 : 28,
              16,
            ),
            child: const Text(
              'How to Read the Results',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.2,
                color: SariwaColors.textPrimaryDark,
              ),
            ),
          ),
          const Divider(height: 1, color: SariwaColors.colorLine),
          if (!isMobile)
            const IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: freshCol,
                    ),
                  ),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: SariwaColors.colorLine,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: notFreshCol,
                    ),
                  ),
                ],
              ),
            )
          else
            const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(padding: EdgeInsets.all(20), child: freshCol),
                Divider(height: 1, color: SariwaColors.colorLine),
                Padding(padding: EdgeInsets.all(20), child: notFreshCol),
              ],
            ),
          const Divider(height: 1, color: SariwaColors.colorLine),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 28,
              vertical: 12,
            ),
            child: const Text(
              'Visual estimate only — always pair with smell and texture checks.',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: SariwaColors.inkSlateMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccordionRow({
    required int index,
    required FaqItem item,
    required bool isExpanded,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          toggled: isExpanded,
          label: item.question,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _toggleIndex(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
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
                      child: Icon(
                        CupertinoIcons.chevron_down,
                        size: 16,
                        color: isExpanded
                            ? SariwaColors.brandPrimary
                            : SariwaColors.inkSlateMuted,
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
          secondChild: Padding(
            padding: const EdgeInsets.only(bottom: 20, right: 32),
            child: Text(
              item.answer,
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w300,
                height: 1.55,
                letterSpacing: -0.1,
                color: SariwaColors.inkSlateSecondary,
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
                fontWeight: FontWeight.w500,
                color: titleColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < cues.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 44,
                child: Text(
                  cues[i].label,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: SariwaColors.textPrimaryDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  cues[i].detail,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    height: 1.45,
                    color: SariwaColors.inkSlateSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (i < cues.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}
