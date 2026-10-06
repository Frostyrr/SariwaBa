import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
          height: 64,
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 28 : 16),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.borderSubtle,
                width: 1.0,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Brand Logo
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.border,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: SvgPicture.asset(
                      'assets/icons/logo.svg',
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'SariwaBa',
                    style: AppTypography.brandLogo,
                  ),
                ],
              ),

              // Center: Desktop Navigation Links
              if (isDesktop)
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildNavItem('Overview'),
                          const SizedBox(width: 20),
                          _buildNavItem('Methodology'),
                          const SizedBox(width: 20),
                          _buildNavItem('Standards'),
                          const SizedBox(width: 20),
                          _buildNavItem('Documentation'),
                        ],
                      ),
                    ),
                  ),
                ),

              // Right: Log In (on Desktop) & Get Started
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isDesktop) ...[
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: onLogIn,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          child: Text(
                            'Log in',
                            style: AppTypography.navLink.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  AppButton.primary(
                    label: 'Get Started',
                    height: 36,
                    width: isDesktop ? 100 : 92,
                    borderRadius: 8,
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

  Widget _buildNavItem(String label) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Text(
        label,
        style: AppTypography.navLink,
      ),
    );
  }
}
