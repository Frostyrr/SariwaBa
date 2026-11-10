import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Glassmorphic desktop sidebar with navigation items, status indicator, and user info.
class DashboardSidebar extends StatelessWidget {
  final dynamic user;
  final bool isGuestUser;
  final int historyCount;
  final String activeNav;
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
            color: Colors.white.withValues(alpha: 0.70),
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
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onGoHome,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/SariwaBa logo.png',
                        width: 36,
                        height: 36,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          CupertinoIcons.sparkles,
                          color: SariwaColors.brandPrimary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'SariwaBa',
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: AppTypography.defaultLetterSpacing,
                          color: SariwaColors.textPrimaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
              ),
              const SizedBox(height: 4),
              _buildSidebarNavItem(
                icon: CupertinoIcons.viewfinder,
                label: 'Inspection',
                isActive: activeNav == 'Inspection' || activeNav == 'Scanner',
                onTap: () => onNavSelected('Inspection'),
              ),
              const SizedBox(height: 4),
              _buildSidebarNavItem(
                icon: CupertinoIcons.clock,
                label: 'History',
                badgeCount: historyCount,
                isActive: activeNav == 'History',
                onTap: () => onNavSelected('History'),
              ),
              const SizedBox(height: 4),
              _buildSidebarNavItem(
                icon: CupertinoIcons.chart_bar_square,
                label: 'Analytics',
                isActive: activeNav == 'Analytics' || activeNav == 'Summary',
                onTap: () => onNavSelected('Analytics'),
              ),
              const SizedBox(height: 20),
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
              ),
              const SizedBox(height: 4),
              _buildSidebarNavItem(
                icon: CupertinoIcons.question_circle,
                label: 'Help & Guide',
                isActive: false,
                onTap: onOpenGuidelines,
              ),
              const SizedBox(height: 4),
              _buildSidebarNavItem(
                icon: CupertinoIcons.device_phone_portrait,
                label: 'Get Mobile App',
                isActive: false,
                onTap: onGoDownloads,
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.60),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.85),
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
                        color: SariwaColors.brandPrimary.withValues(
                          alpha: 0.10,
                        ),
                        shape: BoxShape.circle,
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
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: SariwaColors.brandPrimary.withValues(
                      alpha: 0.14,
                    ),
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
                                isGuestUser
                                    ? 'Guest Evaluator'
                                    : 'Verified Account',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing:
                                      AppTypography.defaultLetterSpacing,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
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
