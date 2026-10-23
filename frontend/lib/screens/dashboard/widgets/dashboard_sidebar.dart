import 'package:flutter/material.dart';
import '../../../constants/theme/app_colors.dart';
import '../../../models/auth/user_model.dart';
import 'dashboard_charts.dart';

class DashboardSidebar extends StatelessWidget {
  final String activeSection;
  final UserModel? user;
  final bool isGuest;
  final ValueChanged<String> onSelectSection;
  final VoidCallback onQuickScan;
  final VoidCallback onOpenDownloads;
  final VoidCallback onOpenHome;
  final VoidCallback onSignIn;
  final VoidCallback onSignOut;

  const DashboardSidebar({
    super.key,
    required this.activeSection,
    required this.user,
    required this.isGuest,
    required this.onSelectSection,
    required this.onQuickScan,
    required this.onOpenDownloads,
    required this.onOpenHome,
    required this.onSignIn,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return SelectionContainer.disabled(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            right: BorderSide(color: SariwaColors.borderLightTeal, width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand Header Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: SariwaColors.bgDashboard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: SariwaColors.borderLightTeal),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          SariwaColors.brandPrimary,
                          SariwaColors.bgLagoonMid,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset(
                      'assets/images/SariwaBa logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.waves_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SariwaBa AI',
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: SariwaColors.textPrimaryDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Fish Freshness OS',
                          style: TextStyle(
                            fontSize: 11,
                            color: SariwaColors.textMutedDark,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.unfold_more_rounded,
                    size: 18,
                    color: SariwaColors.textMutedDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Navigation Modules
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGroupLabel('Overview'),
                    _buildNavItem(
                      label: 'Dashboard',
                      icon: Icons.grid_view_rounded,
                      isActive: activeSection == 'Dashboard',
                      onTap: () => onSelectSection('Dashboard'),
                    ),
                    _buildNavItem(
                      label: 'Live Scanner',
                      icon: Icons.document_scanner_outlined,
                      isActive: activeSection == 'Live Scanner',
                      onTap: () => onSelectSection('Live Scanner'),
                    ),
                    _buildNavItem(
                      label: 'Scan Logs',
                      icon: Icons.receipt_long_outlined,
                      isActive: activeSection == 'Scan Logs',
                      onTap: () => onSelectSection('Scan Logs'),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(
                        color: SariwaColors.borderLightTeal,
                        height: 1,
                      ),
                    ),

                    _buildGroupLabel('Quality Analytics'),
                    _buildNavItem(
                      label: 'Freshness Trends',
                      icon: Icons.bar_chart_rounded,
                      isActive: activeSection == 'Freshness Trends',
                      onTap: () => onSelectSection('Freshness Trends'),
                    ),
                    _buildNavItem(
                      label: 'Grade Breakdown',
                      icon: Icons.pie_chart_outline_rounded,
                      isActive: activeSection == 'Grade Breakdown',
                      onTap: () => onSelectSection('Grade Breakdown'),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(
                        color: SariwaColors.borderLightTeal,
                        height: 1,
                      ),
                    ),

                    _buildGroupLabel('Platform'),
                    _buildNavItem(
                      label: 'Mobile App',
                      icon: Icons.install_mobile_rounded,
                      isActive: false,
                      onTap: onOpenDownloads,
                    ),
                    _buildNavItem(
                      label: 'Home Page',
                      icon: Icons.home_outlined,
                      isActive: false,
                      onTap: onOpenHome,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Quick AI Inspection Gradient Callout Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0A2229),
                    Color(0xFF168077),
                    Color(0xFF39B5A8),
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: SariwaColors.brandPrimary.withValues(alpha: 0.22),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Quick AI Inspection',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Upload a fish photo for instant freshness grading.',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.35,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 12),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: onQuickScan,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Center(
                          child: Text(
                            'Scan Fish Now',
                            style: TextStyle(
                              fontFamily: 'Geist',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: SariwaColors.textPrimaryDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Bottom Card: Registered User Profile OR Guest Login Prompt (no fake email!)
            if (user != null && !isGuest)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: SariwaColors.borderLightTeal),
                ),
                child: Row(
                  children: [
                    DashboardUserAvatar(user: user, size: 34),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user!.displayName,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: SariwaColors.textPrimaryDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user!.email,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: SariwaColors.textMutedDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onSignOut,
                      icon: const Icon(
                        Icons.logout_rounded,
                        size: 17,
                        color: SariwaColors.textSecondaryDark,
                      ),
                      tooltip: 'Sign out',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SariwaColors.bgDashboard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: SariwaColors.borderLightTeal),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: SariwaColors.brandPrimary.withValues(
                          alpha: 0.12,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        size: 18,
                        color: SariwaColors.brandPrimary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Browsing as Guest',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: SariwaColors.textPrimaryDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'History not saved',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: SariwaColors.textMutedDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onSignIn,
                      icon: const Icon(
                        Icons.login_rounded,
                        size: 18,
                        color: SariwaColors.brandPrimary,
                      ),
                      tooltip: 'Sign in to save history',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 6, top: 2),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: SariwaColors.textMutedDark,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: isActive
                  ? SariwaColors.bgDashboardSubtle
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isActive
                      ? SariwaColors.brandPrimary
                      : SariwaColors.textSecondaryDark,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive
                          ? SariwaColors.textPrimaryDark
                          : SariwaColors.textSecondaryDark,
                    ),
                    overflow: TextOverflow.ellipsis,
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
