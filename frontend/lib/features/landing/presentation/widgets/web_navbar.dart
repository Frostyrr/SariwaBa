import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';

class WebNavbar extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onLogIn;

  const WebNavbar({
    super.key,
    required this.onGetStarted,
    required this.onLogIn,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 768;

        return Container(
          height: 72,
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 12),
          decoration: BoxDecoration(
            color: SariwaColors.bgAbyssDark.withValues(alpha: 0.5),
            border: const Border(
              bottom: BorderSide(
                color: SariwaColors.borderGlass,
                width: 1.0,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Brand Logo with Text asset
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/SariwaBa with Text.png',
                      height: isDesktop ? 42 : 36,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/SariwaBa logo.png',
                              height: 32,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'SariwaBa',
                              style: AppTypography.brandLogo,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Center: Nav Links for Desktop
              if (isDesktop)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildNavItem('Overview', isActive: true),
                    const SizedBox(width: 24),
                    _buildNavItem('Methodology'),
                    const SizedBox(width: 24),
                    _buildNavItem('Standards'),
                  ],
                ),

              // Right: Auth Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: onLogIn,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Log in',
                      style: AppTypography.navLink.copyWith(
                        color: SariwaColors.textPrimaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppButton.primary(
                    label: 'Download App',
                    height: 38,
                    width: isDesktop ? 140 : 112,
                    borderRadius: 19, // Rounded pill
                    onPressed: onGetStarted,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem(String label, {bool isActive = false}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        child: Text(
          label,
          style: isActive ? AppTypography.navLinkActive : AppTypography.navLink,
        ),
      ),
    );
  }
}
