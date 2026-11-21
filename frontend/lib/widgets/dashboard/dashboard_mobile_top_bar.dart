import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';
import 'organoleptic_guidelines_dialog.dart';

/// Native-feeling mobile top app bar with SafeArea, 44dp+ touch targets,
/// contextual screen title, and optional top tab strip (hidden when using bottom NavigationBar).
class DashboardMobileTopBar extends StatelessWidget {
  final dynamic user;
  final bool isGuestUser;
  final String activeNav;
  final ValueChanged<String> onNavSelected;
  final VoidCallback onGoHome;
  final VoidCallback onSignOut;
  final VoidCallback onSignIn;
  final VoidCallback onSyncHistory;
  final VoidCallback onOpenDrawer;
  final bool showTopTabs;

  const DashboardMobileTopBar({
    super.key,
    required this.user,
    required this.isGuestUser,
    required this.activeNav,
    required this.onNavSelected,
    required this.onGoHome,
    required this.onSignOut,
    required this.onSignIn,
    required this.onSyncHistory,
    required this.onOpenDrawer,
    this.showTopTabs = true,
  });

  String get _screenTitle {
    switch (activeNav) {
      case 'History':
        return 'History';
      case 'Analytics':
      case 'Summary':
        return 'Analytics';
      case 'Settings':
      case 'Account':
        return 'Settings';
      case 'Admin':
        return 'Admin';
      case 'HowItWorks':
      case 'How It Works':
        return 'How It Works';
      case 'Help':
      case 'FAQs':
      case 'Help & FAQs':
        return 'Help & FAQs';
      default:
        return 'Inspect';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.86),
            border: Border(
              bottom: BorderSide(
                color: SariwaColors.borderLightTeal.withValues(alpha: 0.8),
                width: 1.0,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                8,
                6,
                8,
                showTopTabs ? 10 : 6,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(CupertinoIcons.bars, size: 22),
                        color: SariwaColors.textPrimaryDark,
                        tooltip: 'Menu',
                        constraints: const BoxConstraints(
                          minWidth: 44,
                          minHeight: 44,
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          onOpenDrawer();
                        },
                      ),
                      const SizedBox(width: 4),
                      if (showTopTabs)
                        GestureDetector(
                          onTap: onGoHome,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/SariwaBa logo.png',
                                width: 24,
                                height: 24,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => const Icon(
                                  CupertinoIcons.sparkles,
                                  color: SariwaColors.brandPrimary,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'SariwaBa',
                                style: TextStyle(
                                  fontFamily: 'Geist',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing:
                                      AppTypography.defaultLetterSpacing,
                                  color: SariwaColors.textPrimaryDark,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/SariwaBa logo.png',
                              width: 24,
                              height: 24,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const Icon(
                                CupertinoIcons.sparkles,
                                color: SariwaColors.brandPrimary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _screenTitle,
                              style: const TextStyle(
                                fontFamily: 'Geist',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing:
                                    AppTypography.defaultLetterSpacing,
                                color: SariwaColors.textPrimaryDark,
                              ),
                            ),
                          ],
                        ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          CupertinoIcons.question_circle,
                          size: 20,
                          color: Color(0xFF475569),
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          OrganolepticGuidelinesDialog.show(context);
                        },
                        tooltip: 'Tilapia Freshness Guide',
                        constraints: const BoxConstraints(
                          minWidth: 44,
                          minHeight: 44,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isGuestUser
                              ? CupertinoIcons.arrow_right_circle
                              : CupertinoIcons.square_arrow_right,
                          size: 20,
                          color: const Color(0xFF475569),
                        ),
                        tooltip: isGuestUser ? 'Sign in' : 'Sign out',
                        constraints: const BoxConstraints(
                          minWidth: 44,
                          minHeight: 44,
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          (isGuestUser ? onSignIn : onSignOut)();
                        },
                      ),
                      if (showTopTabs)
                        IconButton(
                          icon: const Icon(
                            CupertinoIcons.arrow_clockwise,
                            size: 18,
                            color: Color(0xFF475569),
                          ),
                          onPressed: onSyncHistory,
                          tooltip: 'Sync History',
                          constraints: const BoxConstraints(
                            minWidth: 44,
                            minHeight: 44,
                          ),
                        ),
                    ],
                  ),
                  if (showTopTabs) ...[
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.50),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.75),
                          width: 1.0,
                        ),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildMobileTabButton(
                              label: 'Inspection',
                              isActive: activeNav == 'Inspection' ||
                                  activeNav == 'Scanner',
                              onTap: () => onNavSelected('Inspection'),
                            ),
                          ),
                          Expanded(
                            child: _buildMobileTabButton(
                              label: 'History',
                              isActive: activeNav == 'History',
                              onTap: () => onNavSelected('History'),
                            ),
                          ),
                          Expanded(
                            child: _buildMobileTabButton(
                              label: 'Analytics',
                              isActive: activeNav == 'Analytics' ||
                                  activeNav == 'Summary',
                              onTap: () => onNavSelected('Analytics'),
                            ),
                          ),
                          if (user?.isAdmin == true)
                            Expanded(
                              child: _buildMobileTabButton(
                                label: 'Admin',
                                isActive: activeNav == 'Admin',
                                onTap: () => onNavSelected('Admin'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileTabButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.90)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: AppTypography.defaultLetterSpacing,
            color: isActive
                ? SariwaColors.brandPrimary
                : SariwaColors.textSecondaryDark,
          ),
        ),
      ),
    );
  }
}
