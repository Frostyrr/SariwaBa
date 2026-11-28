import 'package:material_ui/material_ui.dart';
import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';

/// Web Footer Widget
class WebFooter extends StatelessWidget {
  final VoidCallback onHome;
  final VoidCallback onFeatures;
  final VoidCallback onHowItWorks;
  final VoidCallback onDownloads;
  final VoidCallback? onFaq;

  const WebFooter({
    super.key,
    required this.onHome,
    required this.onFeatures,
    required this.onHowItWorks,
    required this.onDownloads,
    this.onFaq,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 768;

        return Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/backgroundBlurred.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: SariwaColors.bgAbyssDark.withValues(alpha: 0.94),
                  border: const Border(
                    top: BorderSide(
                      color: SariwaColors.borderGlass,
                      width: 1.0,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 24 : 16,
                vertical: isDesktop ? 40 : 32,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1140.0),
                  child: Column(
                    children: [
                      if (isDesktop)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/SariwaBa logo.png',
                                  height: 32,
                                  semanticLabel: 'SariwaBa logo',
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'SariwaBa',
                                  style: AppTypography.brandLogo.copyWith(
                                    fontSize: 20,
                                    letterSpacing: -0.25,
                                  ),
                                ),
                              ],
                            ),
                            Wrap(
                              spacing: 16,
                              children: [
                                _FooterLinkItem(label: 'Home', onTap: onHome),
                                _FooterLinkItem(
                                  label: 'Features',
                                  onTap: onFeatures,
                                ),
                                _FooterLinkItem(
                                  label: 'How it Works',
                                  onTap: onHowItWorks,
                                ),
                                if (onFaq != null)
                                  _FooterLinkItem(label: 'FAQ', onTap: onFaq!),
                                _FooterLinkItem(
                                  label: 'Downloads',
                                  onTap: onDownloads,
                                ),
                              ],
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/SariwaBa logo.png',
                                  height: 32,
                                  semanticLabel: 'SariwaBa logo',
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'SariwaBa',
                                  style: AppTypography.brandLogo.copyWith(
                                    fontSize: 20,
                                    letterSpacing: -0.25,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                _FooterLinkItem(label: 'Home', onTap: onHome),
                                _FooterLinkItem(
                                  label: 'Features',
                                  onTap: onFeatures,
                                ),
                                _FooterLinkItem(
                                  label: 'How it Works',
                                  onTap: onHowItWorks,
                                ),
                                if (onFaq != null)
                                  _FooterLinkItem(label: 'FAQ', onTap: onFaq!),
                                _FooterLinkItem(
                                  label: 'Downloads',
                                  onTap: onDownloads,
                                ),
                              ],
                            ),
                          ],
                        ),
                      const SizedBox(height: 24),
                      const Divider(color: SariwaColors.borderGlass, height: 1),
                      const SizedBox(height: 24),
                      if (isDesktop)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Copyright 2026 SariwaBa. All rights reserved.',
                              style: AppTypography.caption.copyWith(
                                color: SariwaColors.textMutedLight,
                              ),
                            ),
                            Text(
                              'Standardized AI Fish Freshness Grading',
                              style: AppTypography.caption.copyWith(
                                color: SariwaColors.brandLight,
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            Text(
                              'Standardized AI Fish Freshness Grading',
                              style: AppTypography.caption.copyWith(
                                color: SariwaColors.brandLight,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Copyright 2026 SariwaBa. All rights reserved.',
                              style: AppTypography.caption.copyWith(
                                color: SariwaColors.textMutedLight,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FooterLinkItem extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterLinkItem({
    required this.label,
    required this.onTap,
  });

  @override
  State<_FooterLinkItem> createState() => _FooterLinkItemState();
}

class _FooterLinkItemState extends State<_FooterLinkItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return SelectionContainer.disabled(
      child: Semantics(
        button: true,
        label: widget.label,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Text(
                  widget.label,
                  style: AppTypography.navLink.copyWith(
                    fontSize: 14,
                    color: _isHovered
                        ? SariwaColors.brandLight
                        : SariwaColors.textSecondaryLight,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
