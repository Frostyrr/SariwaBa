import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';

/// Glassmorphic desktop sidebar with collapsible/expandable states,
/// navigation items, status indicator, guest evaluation mode card, and user profile.
class DashboardSidebar extends StatelessWidget {
  final dynamic user;
  final bool isGuestUser;
  final int historyCount;
  final String activeNav;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;
  final ValueChanged<String> onNavSelected;
  final VoidCallback onSignOut;
  final VoidCallback onSignIn;
  final VoidCallback onGoHome;
  final VoidCallback onGoDownloads;
  final VoidCallback onConnectGoogle;
  final VoidCallback onOpenGuidelines;

  const DashboardSidebar({
    super.key,
    required this.user,
    required this.isGuestUser,
    required this.historyCount,
    required this.activeNav,
    this.isCollapsed = false,
    this.onToggleCollapse,
    required this.onNavSelected,
    required this.onSignOut,
    required this.onSignIn,
    required this.onGoHome,
    required this.onGoDownloads,
    required this.onConnectGoogle,
    required this.onOpenGuidelines,
  });

  @override
  Widget build(BuildContext context) {
    final firstName = (user?.displayName ?? 'Evaluator')
        .toString()
        .split(' ')
        .first;
    final email = (user?.email ?? 'Guest Session').toString();

    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            border: Border(
              right: BorderSide(
                color: Colors.white.withValues(alpha: 0.85),
                width: 1.2,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 24,
                offset: const Offset(4, 0),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: const Color(0xFF14B8A6).withValues(alpha: 0.04),
                blurRadius: 32,
                offset: const Offset(6, 0),
                spreadRadius: -4,
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(
            isCollapsed ? 12 : 18,
            20,
            isCollapsed ? 12 : 18,
            18,
          ),
          child: Column(
            crossAxisAlignment: isCollapsed
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              // Top Brand & Collapse Header
              _buildTopHeader(),

              const SizedBox(height: 20),

              // Workspace section header or subtle divider
              if (!isCollapsed)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Text(
                    'WORKSPACE',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                )
              else
                const Divider(height: 12, color: Color(0xFFE2E8F0)),

              const SizedBox(height: 4),

              _buildSidebarNavItem(
                icon: CupertinoIcons.viewfinder,
                label: 'Inspection',
                isActive: activeNav == 'Inspection' || activeNav == 'Scanner',
                isCollapsed: isCollapsed,
                onTap: () => onNavSelected('Inspection'),
              ),
              const SizedBox(height: 4),
              _buildSidebarNavItem(
                icon: CupertinoIcons.clock,
                label: 'History',
                badgeCount: historyCount,
                isActive: activeNav == 'History',
                isCollapsed: isCollapsed,
                onTap: () => onNavSelected('History'),
              ),
              const SizedBox(height: 4),
              _buildSidebarNavItem(
                icon: CupertinoIcons.chart_bar_square,
                label: 'Analytics',
                isActive: activeNav == 'Analytics' || activeNav == 'Summary',
                isCollapsed: isCollapsed,
                onTap: () => onNavSelected('Analytics'),
              ),

              const SizedBox(height: 18),

              // General section header or subtle divider
              if (!isCollapsed)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Text(
                    'GENERAL',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                )
              else
                const Divider(height: 12, color: Color(0xFFE2E8F0)),

              const SizedBox(height: 4),

              _buildSidebarNavItem(
                icon: CupertinoIcons.question_circle,
                label: 'Help & Guide',
                isActive: false,
                isCollapsed: isCollapsed,
                onTap: onOpenGuidelines,
              ),
              const SizedBox(height: 4),
              _buildSidebarNavItem(
                icon: CupertinoIcons.device_phone_portrait,
                label: 'Get Mobile App',
                isActive: false,
                isCollapsed: isCollapsed,
                onTap: onGoDownloads,
              ),

              const Spacer(),

              // Guest Evaluation Mode / Tilapia Tip Card
              _buildTipCard(),

              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 12),

              // User Profile Footer
              _buildProfileFooter(firstName, email),
            ],
          ),
        ),
      ),
    );
  }

  /// Top Brand Logo and Collapse / Expand toggle button
  Widget _buildTopHeader() {
    if (isCollapsed) {
      return Column(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onGoHome,
              child: Tooltip(
                message: 'SariwaBa Home',
                child: Image.asset(
                  'assets/images/SariwaBa logo.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    CupertinoIcons.sparkles,
                    color: SariwaColors.brandPrimary,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          if (onToggleCollapse != null) ...[
            const SizedBox(height: 10),
            IconButton(
              tooltip: 'Expand sidebar',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
              icon: const Icon(
                CupertinoIcons.sidebar_right,
                size: 19,
                color: SariwaColors.brandPrimary,
              ),
              onPressed: onToggleCollapse,
            ),
          ],
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onGoHome,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/SariwaBa logo.png',
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      CupertinoIcons.sparkles,
                      color: SariwaColors.brandPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Flexible(
                    child: Text(
                      'SariwaBa',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: AppTypography.defaultLetterSpacing,
                        color: SariwaColors.textPrimaryDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (onToggleCollapse != null)
          IconButton(
            tooltip: 'Collapse sidebar',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            splashRadius: 16,
            icon: const Icon(
              CupertinoIcons.sidebar_left,
              size: 18,
              color: Color(0xFF64748B),
            ),
            onPressed: onToggleCollapse,
          ),
      ],
    );
  }

  /// Guest Mode or Tip card
  Widget _buildTipCard() {
    if (isCollapsed) {
      return Tooltip(
        message: isGuestUser
            ? 'Guest Evaluation Mode • Connect with Google'
            : 'Quick Tilapia Tip',
        preferBelow: false,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isGuestUser ? onConnectGoogle : onOpenGuidelines,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F6F4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFBBE5DF),
                  width: 1.0,
                ),
              ),
              child: Center(
                child: Icon(
                  isGuestUser
                      ? CupertinoIcons.person_crop_circle_badge_exclam
                      : CupertinoIcons.sparkles,
                  size: 20,
                  color: SariwaColors.brandPrimary,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.90),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F6F4),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFBBE5DF),
                width: 0.8,
              ),
            ),
            child: Icon(
              isGuestUser
                  ? CupertinoIcons.person_crop_circle_badge_exclam
                  : CupertinoIcons.sparkles,
              size: 16,
              color: SariwaColors.brandPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isGuestUser
                ? 'Guest Evaluation Mode'
                : 'Quick Tilapia Tip',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              letterSpacing: AppTypography.defaultLetterSpacing,
              color: SariwaColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isGuestUser
                ? 'Sign in with Google to save your freshness scans to your history.'
                : 'Clear, well-lit close-ups of the eye or exposed gill give the best results.',
            style: const TextStyle(
              fontSize: 11.5,
              height: 1.35,
              letterSpacing: AppTypography.defaultLetterSpacing,
              color: SariwaColors.textSecondaryDark,
            ),
          ),
          if (isGuestUser) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: onConnectGoogle,
              child: const Text(
                'Connect with Google',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: AppTypography.defaultLetterSpacing,
                  color: SariwaColors.brandPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Bottom User Profile and Sign out/in
  Widget _buildProfileFooter(String firstName, String email) {
    if (isCollapsed) {
      return Column(
        children: [
          Tooltip(
            message: '$firstName • $email',
            preferBelow: false,
            child: CircleAvatar(
              radius: 17,
              backgroundColor: SariwaColors.brandPrimary.withValues(alpha: 0.14),
              child: Text(
                firstName.isNotEmpty ? firstName[0].toUpperCase() : 'S',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: AppTypography.defaultLetterSpacing,
                  color: SariwaColors.brandPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          IconButton(
            tooltip: isGuestUser ? 'Sign in' : 'Sign out',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: isGuestUser ? onSignIn : onSignOut,
            icon: Icon(
              isGuestUser
                  ? CupertinoIcons.arrow_right_circle
                  : CupertinoIcons.square_arrow_right,
              size: 17,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: SariwaColors.brandPrimary.withValues(alpha: 0.14),
          child: Text(
            firstName.isNotEmpty ? firstName[0].toUpperCase() : 'S',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: AppTypography.defaultLetterSpacing,
              color: SariwaColors.brandPrimary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                firstName,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: AppTypography.defaultLetterSpacing,
                  color: SariwaColors.textPrimaryDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: AppTypography.defaultLetterSpacing,
                  color: SariwaColors.textSecondaryDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isGuestUser
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      isGuestUser ? 'Guest Evaluator' : 'Verified Account',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: AppTypography.defaultLetterSpacing,
                        color: SariwaColors.textSecondaryDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: isGuestUser ? 'Sign in' : 'Sign out',
          onPressed: isGuestUser ? onSignIn : onSignOut,
          icon: Icon(
            isGuestUser
                ? CupertinoIcons.arrow_right_circle
                : CupertinoIcons.square_arrow_right,
            size: 18,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    int? badgeCount,
    bool isCollapsed = false,
  }) {
    if (isCollapsed) {
      return Center(
        child: Tooltip(
          message: badgeCount != null ? '$label ($badgeCount)' : label,
          preferBelow: false,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isActive
                      ? SariwaColors.brandPrimary.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isActive
                      ? Border.all(
                          color: SariwaColors.brandPrimary.withValues(alpha: 0.25),
                          width: 1.2,
                        )
                      : null,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: isActive
                          ? SariwaColors.brandPrimary
                          : const Color(0xFF64748B),
                    ),
                    if (badgeCount != null && badgeCount > 0)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: SariwaColors.brandPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? SariwaColors.brandPrimary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(
                    color: SariwaColors.brandPrimary.withValues(alpha: 0.22),
                    width: 1.0,
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive
                    ? SariwaColors.brandPrimary
                    : const Color(0xFF64748B),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: AppTypography.defaultLetterSpacing,
                    color: isActive
                        ? SariwaColors.brandPrimary
                        : SariwaColors.textPrimaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badgeCount != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: SariwaColors.brandPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    badgeCount.toString(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: AppTypography.defaultLetterSpacing,
                      color: SariwaColors.brandPrimary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
