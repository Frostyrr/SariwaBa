import 'package:material_ui/material_ui.dart';

import '../../constants/theme/app_typography.dart';

/// Monochrome Light Web Footer separated by a crisp 1px top hairline divider.
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

  static const Color _bgColor = Color(0xFFF5F5F7);
  static const Color _inkPrimary = Color(0xFF111111);
  static const Color _inkMuted = Color(0xFF71717A);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 768;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _bgColor,
            border: Border(
              top: BorderSide(
                color: Colors.black.withValues(alpha: 0.06),
                width: 1.0,
              ),
            ),
          ),
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
                              height: 30,
                              semanticLabel: 'SariwaBa logo',
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'SariwaBa',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                                color: _inkPrimary,
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
                              height: 28,
                              semanticLabel: 'SariwaBa logo',
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'SariwaBa',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                                color: _inkPrimary,
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
                  Divider(
                    color: Colors.black.withValues(alpha: 0.06),
                    height: 1,
                  ),
                  const SizedBox(height: 20),
                  if (isDesktop)
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '© 2026 SariwaBa',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            color: _inkMuted,
                          ),
                        ),
                        Text(
                          'Tilapia freshness checks for web and mobile',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            color: _inkMuted,
                          ),
                        ),
                      ],
                    )
                  else
                    const Column(
                      children: [
                        Text(
                          'Tilapia freshness checks for web and mobile',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            color: _inkMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          '© 2026 SariwaBa',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            color: _inkMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
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
              hoverColor: Colors.black.withValues(alpha: 0.04),
              splashColor: Colors.black.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: _isHovered
                        ? const Color(0xFF111111)
                        : const Color(0xFF525252),
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
