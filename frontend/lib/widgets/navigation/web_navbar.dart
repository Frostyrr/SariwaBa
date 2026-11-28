import 'dart:ui';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import '../../constants/config/app_breakpoints.dart';
import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';
import '../../models/auth/user_model.dart';

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
              ? const Color(0xFF737373)
              : SariwaColors.textSecondaryLight;

          return SelectionContainer.disabled(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: isScrolled ? 12 : 0,
                  sigmaY: isScrolled ? 12 : 0,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isScrolled
                        ? (isLight
                            ? const Color(0xCCF5F5F7)
                            : SariwaColors.bgAbyssDark.withValues(alpha: 0.85))
                        : Colors.transparent,
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1180.0),
                        child: Container(
                          height: 72,
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 24.0 : 16.0,
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
                                  else if (isDesktop) ...[
                                    OutlinedButton(
                                      onPressed: onLogIn,
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor:
                                            const Color(0xFF111111),
                                        side: const BorderSide(
                                          color: Color(0x1A171717),
                                        ),
                                        elevation: 0,
                                        minimumSize: const Size(0, 38),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 18,
                                        ),
                                        shape: const StadiumBorder(),
                                        textStyle: const TextStyle(
                                          fontFamily: AppTypography.fontFamily,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: -0.1,
                                        ),
                                      ),
                                      child: const Text('Log in'),
                                    ),
                                    const SizedBox(width: 8),
                                    FilledButton(
                                      onPressed: onDownloads ?? onGetStarted,
                                      style: FilledButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF111111),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        minimumSize: const Size(0, 38),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 18,
                                        ),
                                        shape: const StadiumBorder(),
                                        textStyle: const TextStyle(
                                          fontFamily: AppTypography.fontFamily,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: -0.1,
                                        ),
                                      ),
                                      child: const Text('Download App'),
                                    ),
                                  ],
                                  if (!isDesktop) ...[
                                    const SizedBox(width: 4),
                                    _buildMobileMenuTrigger(context),
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
          );
        },
      ),
    );
  }

  /// Clean menu button opening a slide-down mobile nav drawer on `< md`.
  Widget _buildMobileMenuTrigger(BuildContext context) {
    return IconButton(
      tooltip: 'Open navigation menu',
      onPressed: () => _openMobileNavDrawer(context),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111111),
        side: const BorderSide(color: Color(0x14171717)),
        shape: const CircleBorder(),
        minimumSize: const Size(40, 40),
      ),
      icon: const Icon(CupertinoIcons.bars, size: 18),
    );
  }

  void _openMobileNavDrawer(BuildContext context) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close navigation menu',
      barrierColor: Colors.black.withValues(alpha: 0.28),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (dialogContext, _, _) {
        void runAndClose(VoidCallback? action) {
          Navigator.of(dialogContext).pop();
          action?.call();
        }

        Widget navRow(String label, VoidCallback? action) {
          final isCurrent = activeTab == label;
          return InkWell(
            onTap: () => runAndClose(action),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 15,
                      fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                      color: isCurrent
                          ? const Color(0xFF111111)
                          : const Color(0xFF525252),
                    ),
                  ),
                  if (isCurrent)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: SariwaColors.brandPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        }

        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
            elevation: 12,
            shadowColor: const Color(0x22000000),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/SariwaBa logo.png',
                              height: 26,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'SariwaBa',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.25,
                                color: Color(0xFF111111),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          tooltip: 'Close menu',
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          icon: const Icon(
                            CupertinoIcons.xmark,
                            size: 18,
                            color: Color(0xFF111111),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1, color: Color(0x12171717)),
                    const SizedBox(height: 8),
                    navRow('Home', onHome),
                    navRow('Features', onFeatures),
                    navRow('How it Works', onHowItWorks),
                    if (onFaq != null) navRow('FAQ', onFaq),
                    navRow('Downloads', onDownloads ?? onGetStarted),
                    if (user != null) navRow('Dashboard', onDashboard),
                    const SizedBox(height: 16),
                    if (user == null)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => runAndClose(onLogIn),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF111111),
                                side: const BorderSide(
                                  color: Color(0x1A171717),
                                ),
                                minimumSize: const Size(0, 44),
                                shape: const StadiumBorder(),
                              ),
                              child: const Text('Log in'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton(
                              onPressed: () =>
                                  runAndClose(onDownloads ?? onGetStarted),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF111111),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 44),
                                shape: const StadiumBorder(),
                              ),
                              child: const Text('Download App'),
                            ),
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
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
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
    final activeColor = widget.isLight ? const Color(0xFF111111) : Colors.white;
    final hoverColor = widget.isLight ? const Color(0xFF111111) : Colors.white;
    final effectiveTextColor = widget.isActive
        ? activeColor
        : (_isHovered ? hoverColor : widget.linkColor);

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
              borderRadius: BorderRadius.circular(8),
              hoverColor: widget.isLight
                  ? Colors.black.withValues(alpha: 0.04)
                  : Colors.white.withValues(alpha: 0.08),
              splashColor: widget.isLight
                  ? Colors.black.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.12),
              highlightColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 14,
                    fontWeight:
                        widget.isActive ? FontWeight.w500 : FontWeight.w400,
                    letterSpacing: -0.1,
                    color: effectiveTextColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
