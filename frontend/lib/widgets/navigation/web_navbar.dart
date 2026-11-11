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
  final VoidCallback? onFaq;
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
    this.onFaq,
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

        final linkColor = isLight
            ? SariwaColors.textSecondaryDark
            : SariwaColors.textSecondaryLight;

        return SelectionContainer.disabled(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isDesktop ? 24.0 : 8.0,
                12.0,
                isDesktop ? 24.0 : 8.0,
                6.0,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1140.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A)
                              .withValues(alpha: isScrolled ? 0.06 : 0.03),
                          blurRadius: isScrolled ? 22 : 16,
                          offset: const Offset(0, 4),
                          spreadRadius: -2,
                        ),
                        BoxShadow(
                          color: const Color(0xFF0F172A)
                              .withValues(alpha: isScrolled ? 0.035 : 0.02),
                          blurRadius: isScrolled ? 36 : 28,
                          offset: const Offset(0, 10),
                          spreadRadius: -4,
                        ),
                        BoxShadow(
                          color: const Color(0xFF14B8A6)
                              .withValues(alpha: isScrolled ? 0.05 : 0.025),
                          blurRadius: isScrolled ? 28 : 20,
                          offset: const Offset(0, 6),
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(36),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          height: 58,
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 22.0 : 10.0,
                          ),
                          decoration: BoxDecoration(
                            color: isLight
                                ? Colors.white.withValues(alpha: isScrolled ? 0.75 : 0.62)
                                : SariwaColors.bgAbyssDark
                                    .withValues(alpha: isScrolled ? 0.80 : 0.60),
                            borderRadius: BorderRadius.circular(36),
                            border: Border.all(
                              color: isLight
                                  ? Colors.white.withValues(alpha: 0.85)
                                  : Colors.white.withValues(alpha: 0.16),
                              width: 1.2,
                            ),
                          ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Left: Brand Logo mark alongside Outlined Text Logo
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              hitTestBehavior: HitTestBehavior.opaque,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: onHome,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/SariwaBa logo.png',
                                      height: isDesktop ? 34 : 26,
                                      fit: BoxFit.contain,
                                    ),
                                    SizedBox(width: isDesktop ? 10 : 8),
                                    Image.asset(
                                      'assets/images/SariwaBa Text Only - Original Black.png',
                                      color: isLight ? null : Colors.white,
                                      height: isDesktop ? 22 : 17,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Text(
                                          'SariwaBa',
                                          style: AppTypography.brandLogo.copyWith(
                                            color: isLight
                                                ? const Color(0xFF0A2229)
                                                : Colors.white,
                                            fontSize: isDesktop ? 20 : 16,
                                            letterSpacing: -0.25,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
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
                                  const SizedBox(width: 8),
                                  _buildNavItem(
                                    'Features',
                                    isActive: activeTab == 'Features',
                                    linkColor: linkColor,
                                    onTap: onFeatures,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildNavItem(
                                    'How it Works',
                                    isActive: activeTab == 'How it Works',
                                    linkColor: linkColor,
                                    onTap: onHowItWorks,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildNavItem(
                                    'FAQ',
                                    isActive: activeTab == 'FAQ',
                                    linkColor: linkColor,
                                    onTap: onFaq,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildNavItem(
                                    'Downloads',
                                    isActive: activeTab == 'Downloads',
                                    linkColor: linkColor,
                                    onTap: onDownloads ?? onGetStarted,
                                  ),
                                  if (user != null) ...[
                                    const SizedBox(width: 8),
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
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isDesktop ? 10 : 6,
                                          vertical: 6,
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
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: isDesktop ? 10 : 6),
                                  AppButton.primary(
                                    label: 'Download App',
                                    height: 36,
                                    width: isDesktop ? 138 : 90,
                                    borderRadius: 18,
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
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentUser.displayName,
                      style: const TextStyle(
                        letterSpacing: -0.25,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                        color: SariwaColors.textPrimaryDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      currentUser.email,
                      style: const TextStyle(
                        letterSpacing: -0.25,
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
                  letterSpacing: -0.25,
                  color: SariwaColors.textPrimaryDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
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
                  letterSpacing: -0.25,
                  color: SariwaColors.textPrimaryDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
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
                  letterSpacing: -0.25,
                  color: SariwaColors.statusSpoiled,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
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
                    letterSpacing: -0.25,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
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
            letterSpacing: -0.25,
            color: Colors.white,
            fontSize: size * 0.45,
            fontWeight: FontWeight.w400,
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
