import 'package:flutter/material.dart';
import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';

class WebFooter extends StatelessWidget {
  final VoidCallback onHome;
  final VoidCallback onFeatures;
  final VoidCallback onHowItWorks;
  final VoidCallback onDownloads;

  const WebFooter({
    super.key,
    required this.onHome,
    required this.onFeatures,
    required this.onHowItWorks,
    required this.onDownloads,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 768;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: SariwaColors.bgAbyssDark.withValues(alpha: 0.85),
            border: const Border(
              top: BorderSide(
                color: SariwaColors.borderGlass,
                width: 1.0,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 24 : 16,
            vertical: isDesktop ? 40 : 28,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120.0),
              child: Column(
                children: [
                  if (isDesktop)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo + Tagline
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/SariwaBa logo.png',
                              height: 36,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'SariwaBa',
                              style:
                                  AppTypography.brandLogo.copyWith(fontSize: 20),
                            ),
                          ],
                        ),

                        // Footer Quick Links
                        Wrap(
                          spacing: 24,
                          children: [
                            _buildFooterLink('Home', onHome),
                            _buildFooterLink('Features', onFeatures),
                            _buildFooterLink('How it Works', onHowItWorks),
                            _buildFooterLink('Downloads', onDownloads),
                          ],
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/SariwaBa logo.png',
                              height: 32,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'SariwaBa',
                              style:
                                  AppTypography.brandLogo.copyWith(fontSize: 19),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 18,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildFooterLink('Home', onHome),
                            _buildFooterLink('Features', onFeatures),
                            _buildFooterLink('How it Works', onHowItWorks),
                            _buildFooterLink('Downloads', onDownloads),
                          ],
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),
                  const Divider(color: SariwaColors.borderGlass, height: 1),
                  const SizedBox(height: 20),

                  if (isDesktop)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '© 2026 SariwaBa. All rights reserved.',
                          style: AppTypography.caption.copyWith(
                            color: SariwaColors.textMutedLight,
                          ),
                        ),
                        Text(
                          'Standardized AI Fish Freshness Grading',
                          style: AppTypography.caption.copyWith(
                            color: SariwaColors.textSecondaryLight,
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
                            color: SariwaColors.textSecondaryLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '© 2026 SariwaBa. All rights reserved.',
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
        );
      },
    );
  }

  Widget _buildFooterLink(String label, VoidCallback onTap) {
    return _FooterLinkItem(label: label, onTap: onTap);
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
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        hitTestBehavior: HitTestBehavior.opaque,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            child: Text(
              widget.label,
              style: AppTypography.navLink.copyWith(
                fontSize: 13.5,
                color: _isHovered
                    ? SariwaColors.brandLight
                    : SariwaColors.textSecondaryLight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
