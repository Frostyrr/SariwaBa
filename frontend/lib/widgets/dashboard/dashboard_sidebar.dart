import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';
import '../../models/auth/user_model.dart';
import 'profile_popover_menu.dart';

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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: Color(0x14171717),
            width: 1.0,
          ),
        ),
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
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.8,
                      color: SariwaColors.inkSlateSubtle,
                    ),
                  ),
                )
              else
                const Divider(height: 12, color: SariwaColors.surfaceSlateSubtle),

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
                label: 'History & Insights',
                badgeCount: historyCount,
                isActive: activeNav == 'History' ||
                    activeNav == 'Analytics' ||
                    activeNav == 'Summary',
                isCollapsed: isCollapsed,
                onTap: () => onNavSelected('History'),
              ),

              if (user?.isAdmin == true) ...[
                const SizedBox(height: 16),
                if (!isCollapsed)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Text(
                      'ADMINISTRATION',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.8,
                        color: SariwaColors.inkSlateSubtle,
                      ),
                    ),
                  )
                else
                  const Divider(height: 12, color: SariwaColors.surfaceSlateSubtle),
                const SizedBox(height: 4),
                _buildSidebarNavItem(
                  icon: CupertinoIcons.shield_fill,
                  label: 'Admin Console',
                  isActive: activeNav == 'Admin',
                  isCollapsed: isCollapsed,
                  onTap: () => onNavSelected('Admin'),
                ),
              ],

              const SizedBox(height: 16),

              // General section header or subtle divider
              if (!isCollapsed)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Text(
                    'GENERAL',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.8,
                      color: SariwaColors.inkSlateSubtle,
                    ),
                  ),
                )
              else
                const Divider(height: 12, color: SariwaColors.surfaceSlateSubtle),

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

              const SizedBox(height: 16),
              const Divider(height: 1, color: SariwaColors.surfaceSlateSubtle),
              const SizedBox(height: 12),

              // User Profile Footer with Popover Menu
              ProfilePopoverButton(
                user: user is UserModel ? user : null,
                isGuestUser: isGuestUser,
                isCollapsed: isCollapsed,
                onNavSelected: onNavSelected,
                onSignOut: onSignOut,
                onSignIn: onSignIn,
              ),
            ],
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
            const SizedBox(height: 12),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
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
              color: SariwaColors.inkSlateMuted,
            ),
            onPressed: onToggleCollapse,
          ),
      ],
    );
  }

  /// Quiet neutral Guest Mode / Tip card (zero legacy dark-teal block)
  Widget _buildTipCard() {
    if (isCollapsed) {
      return Tooltip(
        message: isGuestUser
            ? 'Guest Evaluation Mode • Connect with Google'
            : 'Quick Tilapia Tip',
        preferBelow: false,
        child: Material(
          color: const Color(0xCCF5F5F5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0x0D171717)),
          ),
          child: InkWell(
            onTap: isGuestUser ? onConnectGoogle : onOpenGuidelines,
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                isGuestUser
                    ? CupertinoIcons.person_crop_circle_badge_exclam
                    : CupertinoIcons.sparkles,
                size: 18,
                color: const Color(0xFF111111),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xCCF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x0D171717), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                isGuestUser
                    ? CupertinoIcons.person_crop_circle_badge_exclam
                    : CupertinoIcons.sparkles,
                size: 16,
                color: const Color(0xFF111111),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isGuestUser ? 'Guest Evaluation Mode' : 'Quick Tilapia Tip',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
                    color: Color(0xFF111111),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isGuestUser
                ? 'Sign in with Google to sync and archive your scan history.'
                : 'Clear, well-lit close-ups of the eye or exposed gill give the best results.',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.45,
              color: Color(0xFF737373),
            ),
          ),
          if (isGuestUser) ...[
            const SizedBox(height: 12),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onConnectGoogle,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Connect with Google',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111111),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      CupertinoIcons.arrow_right,
                      size: 12,
                      color: Color(0xFF111111),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
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
                      ? const Color(0xFFF5F5F5)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: isActive
                          ? const Color(0xFF111111)
                          : const Color(0xFF737373),
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
                            color: Color(0xFF111111),
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFF5F5F5)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive
                    ? const Color(0xFF111111)
                    : const Color(0xFF737373),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                    letterSpacing: AppTypography.defaultLetterSpacing,
                    color: isActive
                        ? const Color(0xFF111111)
                        : const Color(0xFF525252),
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
                    color: const Color(0xFFE5E5E5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badgeCount.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: AppTypography.defaultLetterSpacing,
                      color: Color(0xFF404040),
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
