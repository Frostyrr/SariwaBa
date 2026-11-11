import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';
import '../../models/auth/user_model.dart';

/// Reusable profile button and anchored popover menu inspired by ChatGPT's
/// bottom-left sidebar account menu pattern.
class ProfilePopoverButton extends StatefulWidget {
  final UserModel? user;
  final bool isGuestUser;
  final bool isCollapsed;
  final ValueChanged<String> onNavSelected;
  final VoidCallback onSignOut;
  final VoidCallback onSignIn;

  const ProfilePopoverButton({
    super.key,
    required this.user,
    required this.isGuestUser,
    this.isCollapsed = false,
    required this.onNavSelected,
    required this.onSignOut,
    required this.onSignIn,
  });

  @override
  State<ProfilePopoverButton> createState() => _ProfilePopoverButtonState();
}

class _ProfilePopoverButtonState extends State<ProfilePopoverButton> {
  final GlobalKey _buttonKey = GlobalKey();
  bool _isOpen = false;
  bool _isButtonHovered = false;

  void _togglePopover() {
    if (_isOpen) return;

    final renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    setState(() => _isOpen = true);

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Profile Menu',
      barrierColor: Colors.transparent,
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        final mediaQuery = MediaQuery.of(dialogContext);
        final screenWidth = mediaQuery.size.width;
        final screenHeight = mediaQuery.size.height;

        const double menuWidth = 260.0;
        final left = offset.dx.clamp(12.0, screenWidth - menuWidth - 12.0);

        // Prefer opening upwards above the profile button
        final fitsAbove = offset.dy >= 280;
        final double? bottom = fitsAbove
            ? (screenHeight - offset.dy + 8.0)
            : null;
        final double? top = fitsAbove
            ? null
            : (offset.dy + size.height + 8.0).clamp(12.0, screenHeight - 280.0);

        return Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              bottom: bottom,
              child: Material(
                color: Colors.transparent,
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                  child: ScaleTransition(
                    scale: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                    alignment: fitsAbove
                        ? Alignment.bottomLeft
                        : Alignment.topLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: menuWidth,
                        maxHeight: math.min(380.0, screenHeight - 32.0),
                      ),
                      child: _ProfilePopoverCard(
                        user: widget.user,
                        isGuestUser: widget.isGuestUser,
                        onClose: () => Navigator.of(dialogContext).pop(),
                        onNavSelected: (nav) {
                          Navigator.of(dialogContext).pop();
                          widget.onNavSelected(nav);
                        },
                        onSignOut: () {
                          Navigator.of(dialogContext).pop();
                          widget.onSignOut();
                        },
                        onSignIn: () {
                          Navigator.of(dialogContext).pop();
                          widget.onSignIn();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ).then((_) {
      if (mounted) {
        setState(() => _isOpen = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.user?.displayName ?? 'Evaluator';
    final firstName = displayName.split(' ').first;
    final email = widget.user?.email ?? 'Guest Session';

    if (widget.isCollapsed) {
      return Center(
        child: Tooltip(
          message: widget.isGuestUser ? 'Guest Mode (Click for menu)' : '$displayName (Click for menu)',
          preferBelow: false,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isButtonHovered = true),
            onExit: (_) => setState(() => _isButtonHovered = false),
            child: InkWell(
              key: _buttonKey,
              onTap: _togglePopover,
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isOpen || _isButtonHovered
                      ? SariwaColors.brandPrimary.withValues(alpha: 0.16)
                      : Colors.transparent,
                  border: Border.all(
                    color: _isOpen
                        ? SariwaColors.brandPrimary.withValues(alpha: 0.4)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      SariwaColors.brandPrimary.withValues(alpha: 0.14),
                  backgroundImage: widget.user?.profilePicture != null &&
                          widget.user!.profilePicture!.isNotEmpty
                      ? NetworkImage(widget.user!.profilePicture!)
                      : null,
                  child: widget.user?.profilePicture == null ||
                          widget.user!.profilePicture!.isEmpty
                      ? Text(
                          firstName.isNotEmpty ? firstName[0].toUpperCase() : 'S',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: AppTypography.defaultLetterSpacing,
                            color: SariwaColors.brandPrimary,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isButtonHovered = true),
      onExit: (_) => setState(() => _isButtonHovered = false),
      child: InkWell(
        key: _buttonKey,
        onTap: _togglePopover,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: _isOpen
                ? SariwaColors.brandPrimary.withValues(alpha: 0.12)
                : _isButtonHovered
                    ? Colors.white.withValues(alpha: 0.6)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isOpen
                  ? SariwaColors.brandPrimary.withValues(alpha: 0.3)
                  : _isButtonHovered
                      ? const Color(0xFFE2E8F0)
                      : Colors.transparent,
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor:
                    SariwaColors.brandPrimary.withValues(alpha: 0.14),
                backgroundImage: widget.user?.profilePicture != null &&
                        widget.user!.profilePicture!.isNotEmpty
                    ? NetworkImage(widget.user!.profilePicture!)
                    : null,
                child: widget.user?.profilePicture == null ||
                        widget.user!.profilePicture!.isEmpty
                    ? Text(
                        firstName.isNotEmpty ? firstName[0].toUpperCase() : 'S',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: AppTypography.defaultLetterSpacing,
                          color: SariwaColors.brandPrimary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: AppTypography.defaultLetterSpacing,
                        color: SariwaColors.textPrimaryDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      email,
                      style: const TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 11,
                        fontWeight: FontWeight.w300,
                        letterSpacing: AppTypography.defaultLetterSpacing,
                        color: SariwaColors.textSecondaryDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                _isOpen
                    ? CupertinoIcons.chevron_down
                    : CupertinoIcons.chevron_up,
                size: 14,
                color: const Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The floating anchored popover card containing user profile info and actions.
class _ProfilePopoverCard extends StatelessWidget {
  final UserModel? user;
  final bool isGuestUser;
  final VoidCallback onClose;
  final ValueChanged<String> onNavSelected;
  final VoidCallback onSignOut;
  final VoidCallback onSignIn;

  const _ProfilePopoverCard({
    required this.user,
    required this.isGuestUser,
    required this.onClose,
    required this.onNavSelected,
    required this.onSignOut,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName ?? 'Guest Evaluator';
    final email = user?.email ?? 'Session active on device';
    final isAdmin = user?.isAdmin ?? false;

    return FocusScope(
      autofocus: true,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 10),
              spreadRadius: -2,
            ),
            BoxShadow(
              color: const Color(0xFF14B8A6).withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                displayName,
                                style: const TextStyle(
                                  fontFamily: 'Geist',
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: AppTypography.defaultLetterSpacing,
                                  color: SariwaColors.textPrimaryDark,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isAdmin
                                    ? const Color(0xFF8B5CF6).withValues(alpha: 0.12)
                                    : isGuestUser
                                        ? const Color(0xFFF59E0B).withValues(alpha: 0.12)
                                        : const Color(0xFF10B981).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isAdmin
                                    ? 'Admin'
                                    : isGuestUser
                                        ? 'Guest'
                                        : 'Inspector',
                                style: TextStyle(
                                  fontFamily: 'Geist',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                  color: isAdmin
                                      ? const Color(0xFF7C3AED)
                                      : isGuestUser
                                          ? const Color(0xFFD97706)
                                          : const Color(0xFF059669),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          style: const TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w300,
                            letterSpacing: AppTypography.defaultLetterSpacing,
                            color: SariwaColors.textSecondaryDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 12, thickness: 1, color: Color(0xFFF1F5F9)),

                  // Menu Option 1: Account Settings
                  _PopoverMenuItem(
                    key: const Key('popover_account_settings'),
                    icon: CupertinoIcons.gear_alt,
                    title: 'Account Settings',
                    onTap: () => onNavSelected('Settings'),
                  ),

                  // Menu Option 2: How It Works
                  _PopoverMenuItem(
                    key: const Key('popover_how_it_works'),
                    icon: CupertinoIcons.lightbulb,
                    title: 'How It Works',
                    onTap: () => onNavSelected('HowItWorks'),
                  ),

                  // Menu Option 3: Help & FAQs
                  _PopoverMenuItem(
                    key: const Key('popover_help_faqs'),
                    icon: CupertinoIcons.question_circle,
                    title: 'Help & FAQs',
                    onTap: () => onNavSelected('Help'),
                  ),

                  const Divider(height: 12, thickness: 1, color: Color(0xFFF1F5F9)),

                  // Menu Option 4: Log Out / Sign In
                  if (isGuestUser)
                    _PopoverMenuItem(
                      key: const Key('popover_sign_in'),
                      icon: CupertinoIcons.arrow_right_circle,
                      title: 'Sign In with Google',
                      iconColor: SariwaColors.brandPrimary,
                      textColor: SariwaColors.brandPrimary,
                      hoverColor: const Color(0xFFF0FDFA),
                      onTap: onSignIn,
                    )
                  else
                    _PopoverMenuItem(
                      key: const Key('popover_log_out'),
                      icon: CupertinoIcons.square_arrow_right,
                      title: 'Log Out',
                      iconColor: const Color(0xFFDC2626),
                      textColor: const Color(0xFFDC2626),
                      hoverColor: const Color(0xFFFEF2F2),
                      onTap: onSignOut,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PopoverMenuItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final Color? hoverColor;

  const _PopoverMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.textColor,
    this.hoverColor,
  });

  @override
  State<_PopoverMenuItem> createState() => _PopoverMenuItemState();
}

class _PopoverMenuItemState extends State<_PopoverMenuItem> {
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final effectiveHover = _isHovered || _isFocused;
    final defaultHover = const Color(0xFFF8FAFC);
    final bg = effectiveHover ? (widget.hoverColor ?? defaultHover) : Colors.transparent;

    return FocusableActionDetector(
      onShowFocusHighlight: (val) => setState(() => _isFocused = val),
      onShowHoverHighlight: (val) => setState(() => _isHovered = val),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          child: Container(
            color: bg,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: 16,
                  color: widget.iconColor ?? const Color(0xFF64748B),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: AppTypography.defaultLetterSpacing,
                      color: widget.textColor ?? SariwaColors.textPrimaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
