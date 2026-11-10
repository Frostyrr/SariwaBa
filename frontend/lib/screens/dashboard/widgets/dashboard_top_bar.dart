import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../constants/theme/app_colors.dart';
import '../../../constants/theme/app_typography.dart';
import '../../../models/auth/user_model.dart';
import '../../../widgets/common/app_button.dart';
import 'dashboard_charts.dart';

class DashboardTopBar extends StatelessWidget {
  final bool isDesktop;
  final String activeSection;
  final UserModel? user;
  final bool isGuest;
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onOpenDrawer;
  final VoidCallback onSyncHistory;
  final VoidCallback onOpenHome;
  final VoidCallback onSignIn;
  final VoidCallback onSignOut;

  const DashboardTopBar({
    super.key,
    required this.isDesktop,
    required this.activeSection,
    required this.user,
    required this.isGuest,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onOpenDrawer,
    required this.onSyncHistory,
    required this.onOpenHome,
    required this.onSignIn,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final firstName = user != null
        ? user!.displayName.split(' ').first
        : 'Guest';

    return SelectionContainer.disabled(
      child: Container(
        height: 64,
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 28 : 16),
        decoration: const BoxDecoration(
          color: SariwaColors.bgDashboard,
          border: Border(
            bottom: BorderSide(color: SariwaColors.borderLightTeal, width: 0.8),
          ),
        ),
        child: Row(
          children: [
            if (!isDesktop) ...[
              IconButton(
                onPressed: onOpenDrawer,
                icon: const Icon(
                  Icons.menu_rounded,
                  color: SariwaColors.textPrimaryDark,
                ),
                tooltip: 'Open navigation menu',
              ),
              const SizedBox(width: 6),
            ],
            if (isDesktop) ...[
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.2,
                  color: SariwaColors.textMutedDark,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: SariwaColors.textMutedDark,
                ),
              ),
            ],
            Expanded(
              child: Text(
                activeSection == 'Dashboard' ? 'Overview' : activeSection,
                style: const TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.25,
                  color: SariwaColors.textPrimaryDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),

            if (isDesktop)
              Container(
                width: 260,
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: SariwaColors.borderLightTeal),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      size: 17,
                      color: SariwaColors.textMutedDark,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: onSearchChanged,
                        style: const TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.2,
                          color: SariwaColors.textPrimaryDark,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Search scan history...',
                          hintStyle: TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.15,
                            color: SariwaColors.textMutedDark,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: onClearSearch,
                        child: const Icon(
                          Icons.close_rounded,
                          size: 15,
                          color: SariwaColors.textMutedDark,
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(width: 12),

            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onSyncHistory,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: SariwaColors.borderLightTeal),
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    size: 19,
                    color: SariwaColors.textPrimaryDark,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Registered User Menu OR Guest Sign-In Pill
            if (user != null && !isGuest)
              PopupMenuButton<String>(
                tooltip: 'Account menu',
                offset: const Offset(0, 44),
                color: Colors.white,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: SariwaColors.borderLightTeal),
                ),
                onSelected: (val) {
                  if (val == 'home') {
                    onOpenHome();
                  } else if (val == 'logout') {
                    onSignOut();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'home',
                    child: Row(
                      children: [
                        Icon(
                          Icons.home_outlined,
                          size: 17,
                          color: SariwaColors.textSecondaryDark,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Return to Home',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: SariwaColors.textPrimaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          size: 17,
                          color: SariwaColors.statusSpoiled,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Sign out',
                          style: TextStyle(
                            fontSize: 13,
                            color: SariwaColors.statusSpoiled,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.fromLTRB(4, 4, 10, 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: SariwaColors.borderLightTeal),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DashboardUserAvatar(user: user, size: 30),
                      const SizedBox(width: 8),
                      Text(
                        firstName,
                        style: const TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          color: SariwaColors.textPrimaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onSignIn,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: SariwaColors.borderLightTeal),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 16,
                          color: SariwaColors.brandPrimary,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Guest Mode',
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            color: SariwaColors.textPrimaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DashboardGreetingHeader extends StatelessWidget {
  final UserModel? user;
  final bool isGuest;
  final String selectedTimeframe;
  final ValueChanged<String> onTimeframeChanged;
  final VoidCallback onConnectGoogle;

  const DashboardGreetingHeader({
    super.key,
    required this.user,
    required this.isGuest,
    required this.selectedTimeframe,
    required this.onTimeframeChanged,
    required this.onConnectGoogle,
  });

  @override
  Widget build(BuildContext context) {
    final firstName = user != null
        ? user!.displayName.split(' ').first
        : 'Guest';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 12,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGuest ? 'Welcome, Guest!' : 'Welcome back, $firstName!',
                  style: AppTypography.displayLarge.copyWith(
                    color: SariwaColors.textPrimaryDark,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                if (isGuest) ...[
                  const SizedBox(height: 4),
                  const Text(
                    'You are currently exploring as a guest. Sign in to save your fish freshness classification history.',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 13,
                      color: SariwaColors.textSecondaryDark,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PopupMenuButton<String>(
                  initialValue: selectedTimeframe,
                  onSelected: onTimeframeChanged,
                  color: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: SariwaColors.borderLightTeal),
                  ),
                  itemBuilder: (context) => ['Daily', 'Weekly', 'Monthly']
                      .map(
                        (period) => PopupMenuItem(
                          value: period,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                period,
                                style: TextStyle(
                                  fontFamily: 'Geist',
                                  fontSize: 12.5,
                                  fontWeight: selectedTimeframe == period
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  letterSpacing: -0.2,
                                  color: selectedTimeframe == period
                                      ? SariwaColors.brandPrimary
                                      : SariwaColors.textPrimaryDark,
                                ),
                              ),
                              if (selectedTimeframe == period)
                                const Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: SariwaColors.brandPrimary,
                                ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: SariwaColors.borderLightTeal),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selectedTimeframe,
                          style: const TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.2,
                            color: SariwaColors.textPrimaryDark,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: SariwaColors.textSecondaryDark,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: SariwaColors.borderLightTeal),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: SariwaColors.brandPrimary,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '23 Oct, 2026',
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.2,
                          color: SariwaColors.textPrimaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),

        // Prominent Guest Evaluation Mode Callout Banner
        if (isGuest) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: SariwaColors.brandPrimary.withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x080A2229),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: SariwaColors.brandPrimary.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: SariwaColors.brandPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Guest Evaluation Mode',
                            style: TextStyle(
                              fontFamily: 'Geist',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.25,
                              color: SariwaColors.textPrimaryDark,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Your scans are temporary in Guest Mode. Sign in with Google to save your classification history.',
                            style: TextStyle(
                              fontFamily: 'Geist',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.15,
                              color: SariwaColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                AppButton.primary(
                  label: 'Connect with Google',
                  icon: SvgPicture.asset(
                    'assets/icons/google.svg',
                    width: 15,
                    height: 15,
                  ),
                  height: 38,
                  width: 196,
                  borderRadius: 999,
                  onPressed: onConnectGoogle,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
