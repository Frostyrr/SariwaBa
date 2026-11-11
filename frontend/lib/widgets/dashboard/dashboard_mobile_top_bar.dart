import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';
import 'organoleptic_guidelines_dialog.dart';

/// Glassmorphic mobile top navigation bar with brand icon, hamburger menu, actions, and tab selector.
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
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.85),
                width: 1.2,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: const Color(0xFF14B8A6).withValues(alpha: 0.04),
                blurRadius: 28,
                offset: const Offset(0, 6),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(CupertinoIcons.bars, size: 18),
                    color: SariwaColors.textPrimaryDark,
                    tooltip: 'Menu',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    visualDensity: VisualDensity.compact,
                    onPressed: onOpenDrawer,
                  ),
                  const SizedBox(width: 6),
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
                            letterSpacing: AppTypography.defaultLetterSpacing,
                            color: SariwaColors.textPrimaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      CupertinoIcons.question_circle,
                      size: 17,
                      color: Color(0xFF64748B),
                    ),
                    onPressed: () => OrganolepticGuidelinesDialog.show(context),
                    tooltip: 'Tilapia Freshness Guide',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: Icon(
                      isGuestUser
                          ? CupertinoIcons.arrow_right_circle
                          : CupertinoIcons.square_arrow_right,
                      size: 17,
                      color: const Color(0xFF64748B),
                    ),
                    tooltip: isGuestUser ? 'Sign in' : 'Sign out',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    visualDensity: VisualDensity.compact,
                    onPressed: isGuestUser ? onSignIn : onSignOut,
                  ),
                  IconButton(
                    icon: const Icon(
                      CupertinoIcons.arrow_clockwise,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    onPressed: onSyncHistory,
                    tooltip: 'Sync History',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
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
                        isActive:
                            activeNav == 'Inspection' || activeNav == 'Scanner',
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
                        isActive:
                            activeNav == 'Analytics' || activeNav == 'Summary',
                        onTap: () => onNavSelected('Analytics'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
