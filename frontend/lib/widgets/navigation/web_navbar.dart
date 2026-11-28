import 'dart:ui';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import '../../constants/config/app_breakpoints.dart';
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
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = AppBreakpoints.isDesktop(constraints.maxWidth);
          final linkColor = isLight
              ? SariwaColors.textSecondaryDark
              : SariwaColors.textSecondaryLight;

          return SelectionContainer.disabled(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isDesktop ? 24.0 : 12.0,
                  12.0,
                  isDesktop ? 24.0 : 12.0,
                  8.0,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1140.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: isScrolled
                            ? const [
                                BoxShadow(
                                  color: SariwaColors.shadowSubtle,
                                  blurRadius: 20,
                                  offset: Offset(0, 6),
                                  spreadRadius: -2,
                                ),
                              ]
                            : const [
                                BoxShadow(
                                  color: SariwaColors.shadowHairline,
                                  blurRadius: 12,
                                  offset: Offset(0, 3),
                                ),
                              ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutCubic,
                            height: 56,
                            padding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 20.0 : 12.0,
                            ),
                            decoration: BoxDecoration(
                              color: isLight
                                  ? SariwaColors.cardSurfaceLight.withValues(
                                      alpha: isScrolled ? 0.88 : 0.80,
                                    )
                                  : SariwaColors.bgAbyssDark.withValues(
                                      alpha: isScrolled ? 0.88 : 0.74,
                                    ),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: isLight
                                    ? SariwaColors.colorLine
                                    : SariwaColors.borderGlass,
                                width: 1.0,
                              ),
                            ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Left: Brand Logo mark + Wordmark
                              Semantics(
                                button: true,
                                label: 'SariwaBa Home',
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: onHome,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Image.asset(
                                            'assets/images/SariwaBa logo.png',
                                            height: isDesktop ? 32 : 26,
                                            fit: BoxFit.contain,
                                            semanticLabel: 'SariwaBa logo',
                                          ),
                                          const SizedBox(width: 8),
                                          Image.asset(
                                            'assets/images/SariwaBa Text Only - Original Black.png',
                                            color: isLight
                                                ? null
                                                : Colors.white,
                                            height: isDesktop ? 20 : 16,
                                            fit: BoxFit.contain,
                                            semanticLabel: 'SariwaBa',
                                            errorBuilder: (_, _, _) {
                                              return Text(
                                                'SariwaBa',
                                                style: AppTypography.brandLogo
                                                    .copyWith(
                                                      color: isLight
                                                          ? SariwaColors
                                                                .textPrimaryDark
                                                          : Colors.white,
                                                      fontSize: isDesktop
                                                          ? 20
                                                          : 16,
                                                      letterSpacing: -0.25,
                                                    ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Center: Desktop Nav Links
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
                                    const SizedBox(width: 4),
                                    _buildNavItem(
                                      'Features',
                                      isActive: activeTab == 'Features',
                                      linkColor: linkColor,
                                      onTap: onFeatures,
                                    ),
                                    const SizedBox(width: 4),
                                    _buildNavItem(
                                      'How it Works',
                                      isActive: activeTab == 'How it Works',
                                      linkColor: linkColor,
                                      onTap: onHowItWorks,
                                    ),
                                    if (onFaq != null) ...[
                                      const SizedBox(width: 4),
                                      _buildNavItem(
                                        'FAQ',
                                        isActive: activeTab == 'FAQ',
                                        linkColor: linkColor,
                                        onTap: onFaq,
                                      ),
                                    ],
                                    const SizedBox(width: 4),
                                    _buildNavItem(
                                      'Downloads',
                                      isActive: activeTab == 'Downloads',
                                      linkColor: linkColor,
                                      onTap: onDownloads ?? onGetStarted,
                                    ),
                                    if (user != null) ...[
                                      const SizedBox(width: 4),
                                      _buildNavItem(
                                        'Dashboard',
                                        isActive: activeTab == 'Dashboard',
                                        linkColor: linkColor,
                                        onTap: onDashboard,
                                      ),
                                    ],
                                  ],
                                ),

                              // Right: User Profile / Auth Actions + Mobile Section Menu
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (user != null)
                                    _buildUserMenu(context, isDesktop)
                                  else ...[
                                    TextButton(
                                      onPressed: onLogIn,
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isDesktop ? 12 : 8,
                                          vertical: 8,
                                        ),
                                        minimumSize: const Size(44, 40),
                                        foregroundColor: isLight
                                            ? SariwaColors.brandPrimary
                                            : SariwaColors.brandLight,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
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
                                    if (isDesktop) ...[
                                      const SizedBox(width: 8),
                                      AppButton.primary(
                                        label: 'Download App',
                                        height: 36,
                                        width: 136,
                                        borderRadius: 999,
                                        onPressed: onDownloads ?? onGetStarted,
                                      ),
                                    ],
                                  ],
                                  if (!isDesktop) ...[
                                    const SizedBox(width: 4),
                                    _buildMobileSectionMenu(),
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
      ),
    );
  }

  Widget _buildMobileSectionMenu() {
    return PopupMenuButton<String>(
      tooltip: 'Navigation menu',
      offset: const Offset(0, 48),
      color: SariwaColors.cardSurfaceLight,
      surfaceTintColor: Colors.transparent,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: SariwaColors.colorLine),
      ),
      icon: Icon(
        CupertinoIcons.bars,
        size: 20,
        color: isLight
            ? SariwaColors.textPrimaryDark
            : SariwaColors.textPrimaryLight,
      ),
      onSelected: (value) {
        switch (value) {
          case 'home':
            onHome?.call();
            break;
          case 'features':
            onFeatures?.call();
            break;
          case 'how':
            onHowItWorks?.call();
            break;
          case 'faq':
            onFaq?.call();
            break;
          case 'downloads':
            (onDownloads ?? onGetStarted).call();
            break;
          case 'dashboard':
            onDashboard?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        _buildMobileMenuItem('home', 'Home', activeTab == 'Home'),
        if (onFeatures != null)
          _buildMobileMenuItem('features', 'Features', activeTab == 'Features'),
        if (onHowItWorks != null)
          _buildMobileMenuItem(
            'how',
            'How it Works',
            activeTab == 'How it Works',
          ),
        if (onFaq != null)
          _buildMobileMenuItem('faq', 'FAQ', activeTab == 'FAQ'),
        _buildMobileMenuItem(
          'downloads',
          'Downloads',
          activeTab == 'Downloads',
        ),
        if (user != null && onDashboard != null)
          _buildMobileMenuItem(
            'dashboard',
            'Dashboard',
            activeTab == 'Dashboard',
          ),
      ],
    );
  }

  PopupMenuItem<String> _buildMobileMenuItem(
    String value,
    String label,
    bool isActive,
  ) {
    return PopupMenuItem<String>(
      value: value,
      height: 44,
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 14,
          fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
          color: isActive
              ? SariwaColors.brandPrimary
              : SariwaColors.textPrimaryDark,
        ),
      ),
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
      color: SariwaColors.cardSurfaceLight,
      surfaceTintColor: Colors.transparent,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: SariwaColors.colorLine, width: 1),
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
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: SariwaColors.textPrimaryDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      currentUser.email,
                      style: const TextStyle(
                        letterSpacing: -0.25,
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
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
        if (currentUser.isAdmin) ...[
          const PopupMenuItem<String>(
            value: 'dashboard',
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.shield_fill,
                  size: 16,
                  color: SariwaColors.brandPrimary,
                ),
                SizedBox(width: 12),
                Text(
                  'Admin Console',
                  style: TextStyle(
                    letterSpacing: -0.25,
                    color: SariwaColors.brandPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
        const PopupMenuItem<String>(
          value: 'dashboard',
          child: Row(
            children: [
              Icon(
                CupertinoIcons.square_grid_2x2,
                size: 16,
                color: SariwaColors.brandPrimary,
              ),
              SizedBox(width: 12),
              Text(
                'Dashboard',
                style: TextStyle(
                  letterSpacing: -0.25,
                  color: SariwaColors.textPrimaryDark,
                  fontSize: 14,
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
              Icon(
                CupertinoIcons.house,
                size: 16,
                color: SariwaColors.textSecondaryDark,
              ),
              SizedBox(width: 12),
              Text(
                'Home Page',
                style: TextStyle(
                  letterSpacing: -0.25,
                  color: SariwaColors.textPrimaryDark,
                  fontSize: 14,
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
              Icon(
                CupertinoIcons.square_arrow_right,
                size: 16,
                color: SariwaColors.statusSpoiled,
              ),
              SizedBox(width: 12),
              Text(
                'Sign out',
                style: TextStyle(
                  letterSpacing: -0.25,
                  color: SariwaColors.statusSpoiled,
                  fontSize: 14,
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isLight
                ? SariwaColors.colorSurface
                : SariwaColors.surfaceGlass,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isLight ? SariwaColors.colorLine : SariwaColors.borderGlass,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: isLight
                        ? SariwaColors.textPrimaryDark
                        : SariwaColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  CupertinoIcons.chevron_down,
                  size: 12,
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
        border: Border.all(color: SariwaColors.brandPrimary, width: 1.2),
      ),
      child: ClipOval(
        child: pictureUrl != null && pictureUrl.isNotEmpty
            ? Image.network(
                pictureUrl,
                webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
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
            fontSize: size * 0.44,
            fontWeight: FontWeight.w500,
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
    final activeColor = widget.isLight
        ? SariwaColors.brandPrimary
        : SariwaColors.brandLight;
    final hoverColor = widget.isLight
        ? SariwaColors.textPrimaryDark
        : Colors.white;
    final effectiveTextColor = widget.isActive
        ? activeColor
        : (_isHovered ? hoverColor : widget.linkColor);

    final pillBgColor = widget.isActive
        ? (widget.isLight
              ? SariwaColors.colorPale
              : SariwaColors.brandLight.withValues(alpha: 0.12))
        : (_isHovered
              ? (widget.isLight
                    ? SariwaColors.colorSurface
                    : SariwaColors.cardSurfaceLight.withValues(alpha: 0.08))
              : Colors.transparent);

    return SelectionContainer.disabled(
      child: Semantics(
        button: true,
        selected: widget.isActive,
        label: widget.label,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(999),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: pillBgColor,
                  borderRadius: BorderRadius.circular(999),
                ),
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
      ),
    );
  }
}
