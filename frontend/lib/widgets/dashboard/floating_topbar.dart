import 'dart:ui';
import 'package:flutter/material.dart';
import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';
import '../../models/auth/user_model.dart';
import 'organoleptic_guidelines_dialog.dart';

/// Floating Glassmorphic Topbar Component based on Timber Dashboard Design System (v2.0.0).
/// Combines an Apple-inspired floating pill container with crisp typography, live status,
/// notification badge, and user profile management.
class FloatingTopbar extends StatelessWidget {
  final UserModel? user;
  final int alertCount;
  final VoidCallback onHome;
  final VoidCallback onDownloads;
  final VoidCallback onSignOut;
  final VoidCallback? onNotificationTap;

  const FloatingTopbar({
    super.key,
    required this.user,
    this.alertCount = 0,
    required this.onHome,
    required this.onDownloads,
    required this.onSignOut,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(user?.displayName);
    final displayName = (user?.displayName ?? 'Evaluator').split(' ').first;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 640;

        return ClipRRect(
          borderRadius: BorderRadius.circular(9999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 12 : 18,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.90),
                  width: 1.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D0A2229),
                    blurRadius: 18,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Left: Brand Identity
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: onHome,
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: SariwaColors.colorPrimary.withValues(alpha: 0.12),
                              border: Border.all(
                                color: SariwaColors.colorPrimary.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/images/SariwaBa logo.png',
                                width: 24,
                                height: 24,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.set_meal_rounded,
                                  size: 20,
                                  color: SariwaColors.colorPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'SariwaBa',
                                style: AppTypography.brandLogo.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: SariwaColors.colorPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              if (!isCompact)
                                Text(
                                  'Quality Operations',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                    color: SariwaColors.colorMutedInk,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Live PostgreSQL Session Chip
                  if (!isCompact) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: SariwaColors.colorPale,
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(
                          color: SariwaColors.colorPrimary.withValues(alpha: 0.20),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: SariwaColors.statusFresh,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'PostgreSQL Active',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: SariwaColors.colorPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],

                  // Notifications Pill Button with Badge
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: onNotificationTap,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.90),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A0A2229),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Center(
                              child: Icon(
                                Icons.notifications_none_rounded,
                                size: 19,
                                color: SariwaColors.colorMutedInk,
                              ),
                            ),
                            if (alertCount > 0)
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4.5,
                                    vertical: 1.5,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: SariwaColors.statusSpoiled,
                                    borderRadius: BorderRadius.circular(9999),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x33EF4444),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      alertCount > 9 ? '9+' : '$alertCount',
                                      style: const TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        height: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // User Profile Pill with Popup Menu
                  PopupMenuButton<String>(
                    tooltip: 'User menu',
                    offset: const Offset(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: SariwaColors.colorLine),
                    ),
                    color: Colors.white,
                    elevation: 10,
                    onSelected: (value) {
                      switch (value) {
                        case 'home':
                          onHome();
                          break;
                        case 'guidelines':
                          OrganolepticGuidelinesDialog.show(context);
                          break;
                        case 'downloads':
                          onDownloads();
                          break;
                        case 'signout':
                          onSignOut();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        enabled: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName ?? 'Quality Inspector',
                              style: const TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: SariwaColors.colorInk,
                              ),
                            ),
                            Text(
                              user?.email ?? 'active_session@sariwaba.gov',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 11,
                                color: SariwaColors.colorMutedInk,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'guidelines',
                        child: Row(
                          children: [
                            Icon(
                              Icons.verified_user_outlined,
                              size: 17,
                              color: SariwaColors.colorPrimary,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'PNS 67:2008 Protocol',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'downloads',
                        child: Row(
                          children: [
                            Icon(
                              Icons.download_outlined,
                              size: 17,
                              color: SariwaColors.colorMutedInk,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Mobile App & Models',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'home',
                        child: Row(
                          children: [
                            Icon(
                              Icons.home_outlined,
                              size: 17,
                              color: SariwaColors.colorMutedInk,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Public Home Page',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'signout',
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              size: 17,
                              color: SariwaColors.statusSpoiled,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Sign Out',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: SariwaColors.statusSpoiled,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.only(
                        left: 4,
                        right: 10,
                        top: 4,
                        bottom: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.90),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A0A2229),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: SariwaColors.colorPrimary,
                            ),
                            child: Center(
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: SariwaColors.colorInk,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: SariwaColors.colorMutedInk,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return 'EV';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
