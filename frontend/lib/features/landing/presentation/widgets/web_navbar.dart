import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';

class WebNavbar extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onLogIn;
  final VoidCallback? onHome;
  final VoidCallback? onFeatures;
  final VoidCallback? onHowItWorks;
  final VoidCallback? onDownloads;
  final String activeTab;

  const WebNavbar({
    super.key,
    required this.onGetStarted,
    required this.onLogIn,
    this.onHome,
    this.onFeatures,
    this.onHowItWorks,
    this.onDownloads,
    this.activeTab = 'Home',
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 768;

        return Container(
          height: 72,
          decoration: BoxDecoration(
            color: SariwaColors.bgAbyssDark.withValues(alpha: 0.65),
            border: const Border(
              bottom: BorderSide(
                color: SariwaColors.borderGlass,
                width: 1.0,
              ),
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              // Inset inward to align with page margin
              constraints: const BoxConstraints(maxWidth: 1120.0),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left: Brand Logo with Text asset
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: onHome,
                        child: Image.asset(
                          'assets/images/SariwaBa with Text.png',
                          height: isDesktop ? 40 : 34,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/images/SariwaBa logo.png',
                                  height: 32,
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
                      ),
                    ),

                    // Center: Nav Links for Desktop (Home, Features, How it Works)
                    if (isDesktop)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildNavItem(
                            'Home',
                            isActive: activeTab == 'Home',
                            onTap: onHome,
                          ),
                          const SizedBox(width: 28),
                          _buildNavItem(
                            'Features',
                            isActive: activeTab == 'Features',
                            onTap: onFeatures,
                          ),
                          const SizedBox(width: 28),
                          _buildNavItem(
                            'How it Works',
                            isActive: activeTab == 'How it Works',
                            onTap: onHowItWorks,
                          ),
                          const SizedBox(width: 28),
                          _buildNavItem(
                            'Downloads',
                            isActive: activeTab == 'Downloads',
                            onTap: onDownloads ?? onGetStarted,
                          ),
                        ],
                      ),

                    // Right: Auth Action Buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: onLogIn,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
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
                        const SizedBox(width: 10),
                        AppButton.primary(
                          label: 'Download App',
                          height: 38,
                          width: isDesktop ? 144 : 116,
                          borderRadius: 19, // Rounded pill
                          onPressed: onDownloads ?? onGetStarted,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(String label, {bool isActive = false, VoidCallback? onTap}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Text(
            label,
            style: isActive ? AppTypography.navLinkActive : AppTypography.navLink,
          ),
        ),
      ),
    );
  }
}
