import 'package:flutter/material.dart';
import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';

/// Web Footer Widget
/// Layered with assets/images/backgroundBlurred.jpg and deep abyss gradient overlays,
/// ensuring high-contrast typography and subtle aquatic atmosphere.
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
            // Layer 1: Blurred Underwater Backdrop
            Positioned.fill(
              child: Image.asset(
                'assets/images/backgroundBlurred.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            ),

            // Layer 2: Deep Abyss Gradient Overlay (ensures WCAG AAA legibility)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      SariwaColors.bgAbyssDark.withValues(alpha: 0.88),
                      SariwaColors.bgAbyssDark.withValues(alpha: 0.96),
                    ],
                  ),
                  border: const Border(
                    top: BorderSide(
                      color: Color(0x2BCCEAE6),
                      width: 1.0,
                    ),
                  ),
                ),
              ),
            ),

            // Layer 3: Subtle top luminous line
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 1,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0x0014B8A6),
                      Color(0x5014B8A6),
                      Color(0x0014B8A6),
                    ],
                  ),
                ),
              ),
            ),

            // Layer 4: Foreground Footer Content
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 24 : 16,
                vertical: isDesktop ? 44 : 32,
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
                                  style: AppTypography.brandLogo.copyWith(
                                    fontSize: 20,
                                    letterSpacing: -0.25,
                                  ),
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
                                if (onFaq != null)
                                  _buildFooterLink('FAQ', onFaq!),
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
                                  style: AppTypography.brandLogo.copyWith(
                                    fontSize: 19,
                                    letterSpacing: -0.25,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Wrap(
                              spacing: 18,
                              runSpacing: 10,
                              alignment: WrapAlignment.center,
                              children: [
                                _buildFooterLink('Home', onHome),
                                _buildFooterLink('Features', onFeatures),
                                _buildFooterLink('How it Works', onHowItWorks),
                                if (onFaq != null)
                                  _buildFooterLink('FAQ', onFaq!),
                                _buildFooterLink('Downloads', onDownloads),
                              ],
                            ),
                          ],
                        ),

                      const SizedBox(height: 28),
                      const Divider(color: Color(0x24CCEAE6), height: 1),
                      const SizedBox(height: 22),

                      if (isDesktop)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '© 2026 SariwaBa. All rights reserved.',
                              style: AppTypography.caption.copyWith(
                                color: const Color(0xFF94A3B8),
                                letterSpacing: -0.25,
                              ),
                            ),
                            Text(
                              'Standardized AI Fish Freshness Grading',
                              style: AppTypography.caption.copyWith(
                                color: const Color(0xFFCCEAE6),
                                letterSpacing: -0.25,
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
                                color: const Color(0xFFCCEAE6),
                                letterSpacing: -0.25,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '© 2026 SariwaBa. All rights reserved.',
                              style: AppTypography.caption.copyWith(
                                color: const Color(0xFF94A3B8),
                                letterSpacing: -0.25,
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
