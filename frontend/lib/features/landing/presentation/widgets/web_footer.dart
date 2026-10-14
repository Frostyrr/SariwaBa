import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120.0),
          child: Column(
            children: [
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
                        style: AppTypography.brandLogo.copyWith(fontSize: 20),
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
              ),
              const SizedBox(height: 28),
              const Divider(color: SariwaColors.borderGlass, height: 1),
              const SizedBox(height: 24),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLink(String label, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          label,
          style: AppTypography.navLink.copyWith(
            fontSize: 13.5,
            color: SariwaColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }
}
