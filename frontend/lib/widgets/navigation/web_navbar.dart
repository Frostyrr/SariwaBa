import 'dart:ui';
import 'package:flutter/material.dart';
import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';
import '../../models/auth/user_model.dart';
import '../common/app_button.dart';

class WebNavbar extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onLogIn;
  final VoidCallback? onHome;
  final VoidCallback? onFeatures;
  final VoidCallback? onHowItWorks;
  final VoidCallback? onDownloads;
  final VoidCallback? onDashboard;
  final VoidCallback? onSignOut;
  final UserModel? user;
  final bool isLight;
  final bool isScrolled;
  final String activeTab;

  const WebNavbar({
    super.key,
    required this.onGetStarted,
    required this.onLogIn,
    this.onHome,
    this.onFeatures,
    this.onHowItWorks,
    this.onDownloads,
    this.onDashboard,
    this.onSignOut,
    this.user,
    this.isLight = false,
    this.isScrolled = false,
    this.activeTab = 'Home',
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 768;

        final bgColor = isLight
            ? Colors.white.withValues(alpha: isScrolled ? 0.92 : 0.96)
            : SariwaColors.bgAbyssDark
                .withValues(alpha: isScrolled ? 0.85 : 0.65);

        final borderColor =
            isLight ? SariwaColors.borderLightTeal : SariwaColors.borderGlass;

        final linkColor = isLight
            ? SariwaColors.textSecondaryDark
            : SariwaColors.textSecondaryLight;

        return SelectionContainer.disabled(
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                height: 72,
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border(
                    bottom: BorderSide(
                      color: borderColor,
                      width: 1.0,
                    ),
                  ),
                  boxShadow: isScrolled
                      ? [
                          BoxShadow(
                            color: isLight
                                ? const Color(0x0F0A2229)
                                : const Color(0x38000000),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : const [],
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120.0),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left: Brand Logo with Text asset
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            hitTestBehavior: HitTestBehavior.opaque,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
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
                                        style: AppTypography.brandLogo.copyWith(
                                          color: isLight
                                              ? SariwaColors.brandPrimary
                                              : Colors.white,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),

                          // Center: Nav Links for Desktop (Home, Features, How it Works, Downloads, Dashboard)
                          if (isDesktop)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildNavItem(
                                  'Home',
                                  isActive: activeTab == 'Home',
                                  linkColor: linkColor,
                                  onTap: onHome,
                                ),
                                const SizedBox(width: 14),
                                _buildNavItem(
                                  'Features',
                                  isActive: activeTab == 'Features',
                                  linkColor: linkColor,
                                  onTap: onFeatures,
                                ),
                                const SizedBox(width: 14),
                                _buildNavItem(
                                  'How it Works',
                                  isActive: activeTab == 'How it Works',
                                  linkColor: linkColor,
                                  onTap: onHowItWorks,
                                ),
                                const SizedBox(width: 14),
                                _buildNavItem(
                                  'Downloads',
                                  isActive: activeTab == 'Downloads',
                                  linkColor: linkColor,
                                  onTap: onDownloads ?? onGetStarted,
                                ),
                                if (user != null) ...[
                                  const SizedBox(width: 14),
                                  _buildNavItem(
                                    'Dashboard',
                                    isActive: activeTab == 'Dashboard',
                                    linkColor: linkColor,
                                    onTap: onDashboard,
                                  ),
                                ],
                              ],
                            ),

                          // Right: User Profile (when authenticated) or Log In + CTA
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (user != null)
                                _buildUserMenu(context, isDesktop)
                              else ...[
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: TextButton(
                                    onPressed: onLogIn,
                                    style: TextButton.styleFrom(
                                      enabledMouseCursor:
                                          SystemMouseCursors.click,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      foregroundColor: isLight
                                          ? SariwaColors.brandPrimary
                                          : SariwaColors.brandLight,
                                    ),
                                    child: Text(
                                      'Log in',
                                      style: AppTypography.navLink.copyWith(
                                        color: isLight
                                            ? SariwaColors.textPrimaryDark
                                            : SariwaColors.textPrimaryLight,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                AppButton.primary(
                                  label: 'Download App',
                                  height: 38,
                                  width: isDesktop ? 144 : 116,
                                  borderRadius: 19,
                                  onPressed: onDownloads ?? onGetStarted,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    String label, {
    bool isActive = false,
    required Color linkColor,
    VoidCallback? onTap,
  }) {
    return _NavLinkItem(
      label: label,
      isActive: isActive,
      isLight: isLight,
      linkColor: linkColor,
      onTap: onTap,
    );
  }

  Widget _buildUserMenu(BuildContext context, bool isDesktop) {
    final currentUser = user!;

    return PopupMenuButton<String>(
      tooltip: 'Account details',
      offset: const Offset(0, 48),
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: SariwaColors.borderLightTeal, width: 1),
      ),
      onSelected: (value) {
        if (value == 'dashboard' && onDashboard != null) {
          onDashboard!();
        } else if (value == 'home' && onHome != null) {
          onHome!();
        } else if (value == 'logout' && onSignOut != null) {
          onSignOut!();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Row(
            children: [
              _buildAvatar(size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentUser.displayName,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: SariwaColors.textPrimaryDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      currentUser.email,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: SariwaColors.textSecondaryDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'dashboard',
          child: Row(
            children: [
              Icon(Icons.dashboard_outlined,
                  size: 18, color: SariwaColors.brandPrimary),
              SizedBox(width: 10),
              Text(
                'Dashboard',
                style: TextStyle(
                  color: SariwaColors.textPrimaryDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'home',
          child: Row(
            children: [
              Icon(Icons.home_outlined,
                  size: 18, color: SariwaColors.textSecondaryDark),
              SizedBox(width: 10),
              Text(
                'Home Page',
                style: TextStyle(
                  color: SariwaColors.textPrimaryDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_rounded,
                  size: 18, color: SariwaColors.statusSpoiled),
              SizedBox(width: 10),
              Text(
                'Sign out',
                style: TextStyle(
                  color: SariwaColors.statusSpoiled,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: isLight
                ? SariwaColors.bgDashboardSubtle
                : SariwaColors.surfaceGlass,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isLight
                  ? SariwaColors.borderLightTeal
                  : SariwaColors.borderGlass,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAvatar(size: 32),
              if (isDesktop) ...[
                const SizedBox(width: 8),
                Text(
                  currentUser.displayName.split(' ').first,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isLight
                        ? SariwaColors.textPrimaryDark
                        : SariwaColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: isLight
                      ? SariwaColors.textSecondaryDark
                      : SariwaColors.textSecondaryLight,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar({required double size}) {
    final pictureUrl = user?.profilePicture;
    final initial = (user?.displayName.isNotEmpty ?? false)
        ? user!.displayName[0].toUpperCase()
        : 'U';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: SariwaColors.brandPrimary, width: 1.5),
      ),
      child: ClipOval(
        child: pictureUrl != null && pictureUrl.isNotEmpty
            ? Image.network(
                pictureUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildAvatarFallback(size, initial);
                },
              )
            : _buildAvatarFallback(size, initial),
      ),
    );
  }

  Widget _buildAvatarFallback(double size, String initial) {
    return Container(
      width: size,
      height: size,
      color: SariwaColors.brandPrimary,
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.45,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _NavLinkItem extends StatefulWidget {
  final String label;
  final bool isActive;
  final bool isLight;
  final Color linkColor;
  final VoidCallback? onTap;

  const _NavLinkItem({
    required this.label,
    required this.isActive,
    required this.isLight,
    required this.linkColor,
    this.onTap,
  });

  @override
  State<_NavLinkItem> createState() => _NavLinkItemState();
}

class _NavLinkItemState extends State<_NavLinkItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final activeColor =
        widget.isLight ? SariwaColors.brandPrimary : SariwaColors.brandLight;

    final hoverColor =
        widget.isLight ? SariwaColors.brandPrimary : Colors.white;

    final effectiveTextColor = widget.isActive
        ? activeColor
        : (_isHovered ? hoverColor : widget.linkColor);

    final pillBgColor = _isHovered
        ? (widget.isLight
            ? SariwaColors.brandPrimary.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.08))
        : (widget.isActive
            ? (widget.isLight
                ? SariwaColors.brandPrimary.withValues(alpha: 0.06)
                : SariwaColors.brandLight.withValues(alpha: 0.10))
            : Colors.transparent);

    return SelectionContainer.disabled(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        hitTestBehavior: HitTestBehavior.opaque,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
            decoration: BoxDecoration(
              color: pillBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                widget.label,
                style: (widget.isActive
                        ? AppTypography.navLinkActive
                        : AppTypography.navLink)
                    .copyWith(color: effectiveTextColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
