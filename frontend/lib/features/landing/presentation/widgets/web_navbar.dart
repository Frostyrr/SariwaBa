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
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16),
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/SariwaBa with Text.png',
                    height: 42,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Row(
                        children: [
                          Image.asset(
                            'assets/images/SariwaBa logo.png',
                            height: 36,
                          ),
                          const SizedBox(width: 8),
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
                    child: Text(
                      'Log in',
                      style: AppTypography.navLink.copyWith(
                        color: SariwaColors.textPrimaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AppButton.primary(
                    label: 'Get Started',
                    height: 40,
                    width: isDesktop ? 130 : 110,
                    borderRadius: 20, // Rounded pill
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
