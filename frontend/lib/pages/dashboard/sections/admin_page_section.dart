import 'dart:ui' as ui;
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/theme/app_colors.dart';
import '../../../controllers/admin/admin_controller.dart';
import '../../../controllers/auth/auth_controller.dart';
import '../../../models/admin/admin_user_model.dart';
import '../../../widgets/common/sariwa_scrollbar.dart';
import '../../../widgets/dashboard/frosted_glass_card.dart';

class AdminPageSection extends ConsumerStatefulWidget {
  final bool isDesktop;
  final ScrollController? scrollController;

  const AdminPageSection({
    super.key,
    required this.isDesktop,
    this.scrollController,
  });

  @override
  ConsumerState<AdminPageSection> createState() => _AdminPageSectionState();
}

class _AdminPageSectionState extends ConsumerState<AdminPageSection> {
  final TextEditingController _userSearchCtrl = TextEditingController();
  final TextEditingController _auditSearchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminControllerProvider.notifier).loadDashboard();
    });
  }

  @override
  void dispose() {
    _userSearchCtrl.dispose();
    _auditSearchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminControllerProvider);
    final adminCtrl = ref.read(adminControllerProvider.notifier);
    final currentUser = ref.watch(authControllerProvider).user;

    // Show error snackbar if any
    if (adminState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(adminState.errorMessage!),
            backgroundColor: SariwaColors.statusSpoiled,
          ),
        );
        adminCtrl.clearMessages();
      });
    }

    if (adminState.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(adminState.successMessage!),
            backgroundColor: SariwaColors.statusFresh,
          ),
        );
        adminCtrl.clearMessages();
      });
    }

    return SingleChildScrollView(
      controller: widget.scrollController,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        widget.isDesktop ? 36 : 16,
        widget.isDesktop ? 28 : 16,
        widget.isDesktop ? 36 : 16,
        widget.isDesktop ? 28 : 104,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Atmospheric Banner
              _buildAtmosphericBanner(adminState, adminCtrl),

              const SizedBox(height: 24),

              // Bento Top KPI Metric Row
              _buildBentoKpiRow(adminState),

              const SizedBox(height: 24),

              // Segmented Sub-Navigation Switcher
              _buildSegmentedTabSwitcher(adminState, adminCtrl),

              const SizedBox(height: 20),

              // Active Tab Content
              if (adminState.isLoading && adminState.stats == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: SariwaColors.brandPrimary,
                    ),
                  ),
                )
              else
                _buildActiveTabContent(adminState, adminCtrl, currentUser),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top Clinical Console Header
  // ---------------------------------------------------------------------------
  Widget _buildAtmosphericBanner(AdminState state, AdminController ctrl) {
    return Container(
      padding: EdgeInsets.all(widget.isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        color: SariwaColors.cardSurfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SariwaColors.colorLine),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 600;
          final headerInfo = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: widget.isDesktop ? 28 : 20,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.5,
                  height: 1.15,
                  color: SariwaColors.inkSlate,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Users, scan activity, and system status.',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  height: 1.4,
                  color: SariwaColors.inkSlateMuted,
                ),
              ),
            ],
          );

          final refreshButton = OutlinedButton.icon(
            onPressed: state.isLoading ? null : () => ctrl.loadDashboard(),
            icon: state.isLoading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.8,
                      color: SariwaColors.brandPrimary,
                    ),
                  )
                : const Icon(
                    CupertinoIcons.arrow_clockwise,
                    size: 14,
                    color: SariwaColors.inkSlateSecondary,
                  ),
            label: Text(state.isLoading ? 'Syncing' : 'Refresh'),
            style: OutlinedButton.styleFrom(
              foregroundColor: SariwaColors.inkSlate,
              backgroundColor: SariwaColors.colorSurface,
              side: const BorderSide(color: SariwaColors.colorLine),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: const StadiumBorder(),
              textStyle: const TextStyle(
                fontFamily: 'Geist',
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          );

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: headerInfo),
                const SizedBox(width: 16),
                refreshButton,
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              headerInfo,
              const SizedBox(height: 16),
              refreshButton,
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bento Top KPI Metric Row
  // ---------------------------------------------------------------------------
  Widget _buildBentoKpiRow(AdminState state) {
    final totals = state.stats?.totals;
    final dist = state.stats?.distribution;
    final latency = state.stats?.latency;
    final health = state.health;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1000;
        final isMedium = constraints.maxWidth >= 640 && !isWide;

        final items = [
          _buildBentoKpiCard(
            eyebrow: 'USERS',
            value: totals?.totalInspectors.toString() ?? '—',
            subtitle: '${totals?.activeInspectorsToday ?? 0} active today',
            icon: CupertinoIcons.person_2_fill,
            iconColor: SariwaColors.infoText,
          ),
          _buildBentoKpiCard(
            eyebrow: 'TOTAL SCANS',
            value: totals?.totalScans.toString() ?? '—',
            subtitle: '${totals?.scansToday ?? 0} today',
            icon: CupertinoIcons.viewfinder_circle_fill,
            iconColor: SariwaColors.brandPrimary,
          ),
          _buildBentoKpiCard(
            eyebrow: 'FRESH RATE',
            value: '${dist?.freshnessRate.toStringAsFixed(0) ?? '—'}%',
            subtitle:
                '${dist?.freshCount ?? 0} Fresh · ${dist?.notFreshCount ?? 0} Not Fresh',
            icon: CupertinoIcons.checkmark_seal_fill,
            iconColor: SariwaColors.statusFresh,
          ),
          _buildBentoKpiCard(
            eyebrow: 'AVG. SPEED',
            value: '${latency?.averageLatencyMs.toStringAsFixed(0) ?? '—'} ms',
            subtitle: 'Response time',
            icon: CupertinoIcons.speedometer,
            iconColor: SariwaColors.statusModerate,
          ),
          _buildBentoKpiCard(
            eyebrow: 'STATUS',
            value: health?.database.isHealthy == true ? 'Online' : 'Ready',
            subtitle: 'Database & scanner',
            icon: CupertinoIcons.heart_fill,
            iconColor: SariwaColors.brandGlow,
          ),
        ];

        if (isWide) {
          return Row(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                Expanded(child: items[i]),
                if (i < items.length - 1) const SizedBox(width: 12),
              ],
            ],
          );
        } else if (isMedium) {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: items
                .map((card) => SizedBox(
                      width: (constraints.maxWidth - 12) / 2,
                      child: card,
                    ))
                .toList(),
          );
        } else {
          return Column(
            children: items
                .map((card) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: card,
                    ))
                .toList(),
          );
        }
      },
    );
  }

  Widget _buildBentoKpiCard({
    required String eyebrow,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SariwaColors.cardSurfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SariwaColors.colorLine),
        boxShadow: const [
          BoxShadow(
            color: SariwaColors.shadowHairline,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  eyebrow,
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.6,
                    color: SariwaColors.inkSlateMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Geist',
              fontSize: 28,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.8,
              height: 1.05,
              color: SariwaColors.inkSlate,
              fontFeatures: [ui.FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Geist',
              fontSize: 12,
              fontWeight: FontWeight.w300,
              color: SariwaColors.inkSlateMuted,
              fontFeatures: [ui.FontFeature.tabularFigures()],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Segmented Sub-Navigation Switcher
  // ---------------------------------------------------------------------------
  Widget _buildSegmentedTabSwitcher(AdminState state, AdminController ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: SariwaColors.colorSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SariwaColors.colorLine),
      ),
      padding: const EdgeInsets.all(4),
      child: SariwaScrollbar(
        alwaysVisible: false,
        builder: (context, controller) => SingleChildScrollView(
          controller: controller,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildTabPill(
                label: 'Users',
                icon: CupertinoIcons.person_2,
                isActive: state.activeTab == AdminTab.inspectors,
                onTap: () => ctrl.setTab(AdminTab.inspectors),
              ),
              _buildTabPill(
                label: 'Activity',
                icon: CupertinoIcons.waveform_path_ecg,
                isActive: state.activeTab == AdminTab.telemetry,
                onTap: () => ctrl.setTab(AdminTab.telemetry),
              ),
              _buildTabPill(
                label: 'Security',
                icon: CupertinoIcons.shield,
                isActive: state.activeTab == AdminTab.security,
                badgeCount:
                    state.security?.metrics.suspiciousPatternDetected == true
                        ? 1
                        : null,
                onTap: () => ctrl.setTab(AdminTab.security),
              ),
              _buildTabPill(
                label: 'System',
                icon: CupertinoIcons.heart,
                isActive: state.activeTab == AdminTab.health,
                onTap: () => ctrl.setTab(AdminTab.health),
              ),
              _buildTabPill(
                label: 'Scan Log',
                icon: CupertinoIcons.doc_text_search,
                isActive: state.activeTab == AdminTab.audits,
                onTap: () => ctrl.setTab(AdminTab.audits),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabPill({
    required String label,
    required IconData icon,
    required bool isActive,
    int? badgeCount,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? SariwaColors.cardSurfaceLight
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isActive
                  ? Border.all(color: SariwaColors.colorLine)
                  : Border.all(color: Colors.transparent),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isActive
                      ? SariwaColors.brandPrimary
                      : SariwaColors.inkSlateMuted,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                    color: isActive
                        ? SariwaColors.inkSlate
                        : SariwaColors.inkSlateMuted,
                  ),
                ),
                if (badgeCount != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: SariwaColors.dangerBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: SariwaColors.dangerBorder),
                    ),
                    child: const Text(
                      'ALERT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: SariwaColors.dangerText,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Active Tab Content Router
  // ---------------------------------------------------------------------------
  Widget _buildActiveTabContent(
    AdminState state,
    AdminController ctrl,
    dynamic currentUser,
  ) {
    switch (state.activeTab) {
      case AdminTab.inspectors:
        return _buildInspectorsTab(state, ctrl, currentUser);
      case AdminTab.telemetry:
        return _buildTelemetryTab(state);
      case AdminTab.security:
        return _buildSecurityTab(state);
      case AdminTab.health:
        return _buildHealthTab(state);
      case AdminTab.audits:
        return _buildAuditsTab(state, ctrl);
    }
  }

  // ---------------------------------------------------------------------------
  // Tab 1: Inspectors & Access Management
  // ---------------------------------------------------------------------------
  Widget _buildInspectorsTab(
    AdminState state,
    AdminController ctrl,
    dynamic currentUser,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search & Filter Bar
        FrostedGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.search,
                size: 16,
                color: SariwaColors.inkSlateMuted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _userSearchCtrl,
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: SariwaColors.inkSlate,
                  ),
                  cursorColor: SariwaColors.brandPrimary,
                  onChanged: (val) => ctrl.searchUsers(val),
                  decoration: const InputDecoration(
                    hintText: 'Search by inspector name, email, or username...',
                    hintStyle: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: SariwaColors.inkSlateSubtle,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (_userSearchCtrl.text.isNotEmpty)
                IconButton(
                  icon: const Icon(CupertinoIcons.clear_circled, size: 15),
                  color: SariwaColors.inkSlateSubtle,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                  onPressed: () {
                    _userSearchCtrl.clear();
                    ctrl.searchUsers('');
                  },
                ),
              const SizedBox(width: 12),
              // Filter by role
              _buildFilterDropdown(
                value: state.selectedRoleFilter == 'admin'
                    ? 'Admins'
                    : state.selectedRoleFilter == 'user'
                        ? 'Inspectors'
                        : 'All Roles',
                items: const ['All Roles', 'Admins', 'Inspectors'],
                icon: CupertinoIcons.person_2,
                onChanged: (val) {
                  if (val == 'All Roles') {
                    ctrl.filterUsersByRole(null);
                  } else if (val == 'Admins') {
                    ctrl.filterUsersByRole('admin');
                  } else {
                    ctrl.filterUsersByRole('user');
                  }
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // User Directory List / Table
        FrostedGlassCard(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Registered Inspectors (${state.users.length})',
                      style: const TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: SariwaColors.inkSlate,
                      ),
                    ),
                    const Text(
                      'Protected against self-demotion & self-suspension',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: SariwaColors.inkSlateMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: SariwaColors.surfaceSlateSubtle),

              if (state.users.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'No matching inspectors found.',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: SariwaColors.inkSlateSubtle,
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.users.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: SariwaColors.surfaceSlateWash),
                  itemBuilder: (context, index) {
                    final user = state.users[index];
                    final isSelf = currentUser?.id != null && user.id.toString() == currentUser.id.toString();

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: user.isAdmin
                            ? SariwaColors.brandPrimary.withValues(alpha: 0.15)
                            : SariwaColors.inkSlateMuted.withValues(alpha: 0.15),
                        child: Text(
                          user.initials,
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: user.isAdmin ? SariwaColors.brandPrimary : SariwaColors.inkSlateSecondary,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.displayName,
                              style: const TextStyle(
                                fontFamily: 'Geist',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: SariwaColors.inkSlate,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelf) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: SariwaColors.infoText.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'YOU',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: SariwaColors.infoText,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.email,
                              style: const TextStyle(
                                fontFamily: 'Geist',
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                color: SariwaColors.inkSlateMuted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '· ${user.scanCount} scans',
                            style: const TextStyle(
                              fontFamily: 'Geist',
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              color: SariwaColors.inkSlateSubtle,
                              fontFeatures: [ui.FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Role Pill
                          _buildRoleBadge(user.role),
                          const SizedBox(width: 8),
                          // Suspension Pill
                          _buildSuspensionBadge(user.isSuspended),
                          const SizedBox(width: 12),
                          // Actions Dropdown Menu
                          _buildUserActionMenu(user, isSelf, ctrl),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleBadge(String role) {
    final isAdmin = role.toLowerCase() == 'admin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAdmin
            ? SariwaColors.brandPrimary.withValues(alpha: 0.12)
            : SariwaColors.surfaceSlateWash,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAdmin
              ? SariwaColors.brandPrimary.withValues(alpha: 0.25)
              : SariwaColors.surfaceSlateSubtle,
          width: 1,
        ),
      ),
      child: Text(
        isAdmin ? 'ADMIN' : 'INSPECTOR',
        style: TextStyle(
          fontFamily: 'Geist',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
          color: isAdmin ? SariwaColors.brandPrimary : SariwaColors.inkSlateMuted,
        ),
      ),
    );
  }

  Widget _buildSuspensionBadge(bool isSuspended) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSuspended
            ? SariwaColors.statusSpoiled.withValues(alpha: 0.12)
            : SariwaColors.statusFresh.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isSuspended ? 'SUSPENDED' : 'ACTIVE',
        style: TextStyle(
          fontFamily: 'Geist',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
          color: isSuspended ? SariwaColors.statusSpoiled : SariwaColors.freshText,
        ),
      ),
    );
  }

  Widget _buildUserActionMenu(
    AdminUserModel user,
    bool isSelf,
    AdminController ctrl,
  ) {
    return PopupMenuButton<String>(
      icon: const Icon(CupertinoIcons.ellipsis_vertical, size: 16, color: SariwaColors.inkSlateMuted),
      tooltip: isSelf ? 'Protected Self Account' : 'Manage Inspector',
      elevation: 12,
      shadowColor: SariwaColors.inkSlate.withValues(alpha: 0.12),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: SariwaColors.surfaceSlateSubtle, width: 1.0),
      ),
      offset: const Offset(0, 36),
      onSelected: (action) {
        if (action == 'self_notice') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Your own administrator account is protected against self-demotion and self-suspension.',
                style: TextStyle(fontFamily: 'Geist'),
              ),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }
        if (action == 'toggle_role') {
          final newRole = user.isAdmin ? 'user' : 'admin';
          _confirmRoleChange(user, newRole, ctrl);
        } else if (action == 'toggle_suspension') {
          _confirmSuspensionChange(user, !user.isSuspended, ctrl);
        }
      },
      itemBuilder: (context) {
        if (isSelf) {
          return [
            PopupMenuItem(
              value: 'self_notice',
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: SariwaColors.brandPrimary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      CupertinoIcons.shield_fill,
                      size: 15,
                      color: SariwaColors.brandPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Your Account (Admin)',
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: SariwaColors.inkSlate,
                          ),
                        ),
                        Text(
                          'Self-demotion & suspension protected',
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: SariwaColors.inkSlateMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(height: 1),
            PopupMenuItem(
              value: 'self_notice',
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.lock_fill,
                    size: 14,
                    color: SariwaColors.inkSlateMuted,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Demote to Inspector',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: SariwaColors.inkSlateMuted,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: SariwaColors.surfaceSlateWash,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Locked',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: SariwaColors.inkSlateMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'self_notice',
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.lock_fill,
                    size: 14,
                    color: SariwaColors.inkSlateMuted,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Suspend Account',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: SariwaColors.inkSlateMuted,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: SariwaColors.surfaceSlateWash,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Locked',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: SariwaColors.inkSlateMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ];
        }

        return [
          PopupMenuItem(
            value: 'toggle_role',
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  user.isAdmin ? CupertinoIcons.person_badge_minus : CupertinoIcons.shield_fill,
                  size: 16,
                  color: user.isAdmin ? SariwaColors.inkSlateSecondary : SariwaColors.brandPrimary,
                ),
                const SizedBox(width: 12),
                Text(
                  user.isAdmin ? 'Demote to Inspector' : 'Promote to Admin',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: user.isAdmin ? SariwaColors.notFreshCardBgDark : SariwaColors.brandPrimary,
                  ),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(height: 1),
          PopupMenuItem(
            value: 'toggle_suspension',
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  user.isSuspended ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.slash_circle_fill,
                  size: 16,
                  color: user.isSuspended ? SariwaColors.statusFresh : SariwaColors.statusSpoiled,
                ),
                const SizedBox(width: 12),
                Text(
                  user.isSuspended ? 'Reactivate Account' : 'Suspend Account',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: user.isSuspended ? SariwaColors.statusFresh : SariwaColors.statusSpoiled,
                  ),
                ),
              ],
            ),
          ),
        ];
      },
    );
  }

  void _confirmRoleChange(
    AdminUserModel user,
    String newRole,
    AdminController ctrl,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          newRole == 'admin' ? 'Promote to Admin?' : 'Demote to Inspector?',
          style: const TextStyle(
            fontFamily: 'Geist',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: Text(
          'Are you sure you want to change ${user.displayName}\'s role to $newRole?',
          style: const TextStyle(
            fontFamily: 'Geist',
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SariwaColors.brandPrimary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ctrl.updateUserRole(user.id, newRole);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _confirmSuspensionChange(
    AdminUserModel user,
    bool suspend,
    AdminController ctrl,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          suspend ? 'Suspend Account?' : 'Reactivate Account?',
          style: const TextStyle(
            fontFamily: 'Geist',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: Text(
          suspend
              ? 'Suspending ${user.displayName} will immediately revoke their authentication access and block future logins.'
              : 'Reactivating will restore authentication and inspection capabilities for ${user.displayName}.',
          style: const TextStyle(
            fontFamily: 'Geist',
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: suspend ? SariwaColors.statusSpoiled : SariwaColors.statusFresh,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ctrl.toggleUserSuspension(user.id, suspend: suspend);
            },
            child: Text(suspend ? 'Suspend' : 'Reactivate'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 2: Classification Telemetry & Latency
  // ---------------------------------------------------------------------------
  Widget _buildTelemetryTab(AdminState state) {
    final dist = state.stats?.distribution;
    final conf = state.stats?.confidence;
    final rej = state.stats?.rejections;
    final latency = state.stats?.latency;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fresh vs Not Fresh Distribution Card
        FrostedGlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Diagnostic Freshness Distribution',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: SariwaColors.inkSlate,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Distribution ratio across all neural network predictions.',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: SariwaColors.inkSlateMuted,
                ),
              ),
              const SizedBox(height: 16),
              // Distribution Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 16,
                  child: Row(
                    children: [
                      Expanded(
                        flex: (dist?.freshCount ?? 1).clamp(1, 100000),
                        child: Container(color: SariwaColors.statusFresh),
                      ),
                      Expanded(
                        flex: (dist?.notFreshCount ?? 1).clamp(1, 100000),
                        child: Container(color: SariwaColors.statusSpoiled),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: SariwaColors.statusFresh,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Fresh: ${dist?.freshCount ?? 0} (${dist?.freshnessRate.toStringAsFixed(1) ?? 0}%)',
                        style: const TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: SariwaColors.inkSlate,
                          fontFeatures: [ui.FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: SariwaColors.statusSpoiled,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Not Fresh: ${dist?.notFreshCount ?? 0}',
                        style: const TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: SariwaColors.inkSlate,
                          fontFeatures: [ui.FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Eye: ${dist?.eyeScans ?? 0} · Gill: ${dist?.gillScans ?? 0}',
                    style: const TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: SariwaColors.inkSlateMuted,
                      fontFeatures: [ui.FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Grid for Rejections & Latency
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;
            final rejCard = FrostedGlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Unsupported Image Rejections',
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: SariwaColors.inkSlate,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: SariwaColors.statusModerate.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${rej?.rejectionRate.toStringAsFixed(1) ?? '0.0'}% rate',
                          style: const TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: SariwaColors.warningText,
                            fontFeatures: [ui.FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total validation rejections: ${rej?.totalRejections ?? 0} / ${rej?.totalRequests ?? 0} requests',
                    style: const TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: SariwaColors.inkSlateMuted,
                      fontFeatures: [ui.FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRejectionRow('Unsupported File Type / MIME', rej?.rejectionsByReason['unsupported_type'] ?? 0),
                  _buildRejectionRow('Dimensions Out of Range (<32px or >4096px)', rej?.rejectionsByReason['dimensions'] ?? 0),
                  _buildRejectionRow('File Exceeds Size Limit (>5MB)', rej?.rejectionsByReason['size'] ?? 0),
                  _buildRejectionRow('Corrupted / Unidentifiable Stream', rej?.rejectionsByReason['corrupted'] ?? 0),
                  _buildRejectionRow('Invalid Anatomical Region Type', rej?.rejectionsByReason['invalid_region'] ?? 0),
                ],
              ),
            );

            final latencyCard = FrostedGlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Inference Latency & Confidence',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: SariwaColors.inkSlate,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'PyTorch runtime latency and average model certainty.',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: SariwaColors.inkSlateMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMetricTile('Average Latency', '${latency?.averageLatencyMs.toStringAsFixed(1) ?? '—'} ms'),
                  _buildMetricTile('Median Latency', '${latency?.medianLatencyMs.toStringAsFixed(1) ?? '—'} ms'),
                  _buildMetricTile('95th Percentile (p95)', '${latency?.p95LatencyMs.toStringAsFixed(1) ?? '—'} ms'),
                  const Divider(height: 20, color: SariwaColors.surfaceSlateSubtle),
                  _buildMetricTile('Overall Avg Confidence', '${((conf?.averageConfidence ?? 0) * 100).toStringAsFixed(1)}%'),
                  _buildMetricTile('Fresh Avg Confidence', '${((conf?.freshAvgConfidence ?? 0) * 100).toStringAsFixed(1)}%'),
                  _buildMetricTile('Not Fresh Avg Confidence', '${((conf?.notFreshAvgConfidence ?? 0) * 100).toStringAsFixed(1)}%'),
                ],
              ),
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: rejCard),
                  const SizedBox(width: 16),
                  Expanded(child: latencyCard),
                ],
              );
            } else {
              return Column(
                children: [
                  rejCard,
                  const SizedBox(height: 16),
                  latencyCard,
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildRejectionRow(String reason, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              reason,
              style: const TextStyle(
                fontFamily: 'Geist',
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: SariwaColors.inkSlateSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            count.toString(),
            style: const TextStyle(
              fontFamily: 'Geist',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: SariwaColors.inkSlate,
              fontFeatures: [ui.FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Geist',
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: SariwaColors.inkSlateSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Geist',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: SariwaColors.inkSlate,
              fontFeatures: [ui.FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 3: Security Monitoring & Append-Only Audits
  // ---------------------------------------------------------------------------
  Widget _buildSecurityTab(AdminState state) {
    final sec = state.security;
    final metrics = sec?.metrics;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Suspicious Pattern Warning Banner
        if (metrics?.suspiciousPatternDetected == true)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SariwaColors.notFreshIconBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SariwaColors.notFreshBorder, width: 1.2),
            ),
            child: Row(
              children: [
                const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: SariwaColors.statusSpoiled, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Suspicious Authentication Patterns Detected',
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: SariwaColors.notFreshText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Detected ${sec?.suspiciousEvents.length ?? 0} security incident(s) (rapid failed attempts from same IP or account).',
                        style: const TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          color: SariwaColors.notFreshText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SariwaColors.freshIconBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SariwaColors.freshBorder, width: 1),
            ),
            child: const Row(
              children: [
                Icon(
                  CupertinoIcons.checkmark_shield_fill,
                  color: SariwaColors.statusFresh,
                  size: 18,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No suspicious login anomalies detected. Authentication surface is stable.',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: SariwaColors.freshText,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Security Metrics Bento (responsive for mobile & desktop)
        FrostedGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stats = [
                _buildSecurityStat(
                  'Total Logins',
                  metrics?.totalAttempts.toString() ?? '0',
                ),
                _buildSecurityStat(
                  'Successful',
                  metrics?.successfulAttempts.toString() ?? '0',
                  color: SariwaColors.statusFresh,
                ),
                _buildSecurityStat(
                  'Failed (Total)',
                  metrics?.failedAttempts.toString() ?? '0',
                  color: SariwaColors.statusSpoiled,
                ),
                _buildSecurityStat(
                  'Failed (24h)',
                  metrics?.failedLast24h.toString() ?? '0',
                  color: SariwaColors.warningText,
                ),
                _buildSecurityStat(
                  'Failure Rate',
                  '${metrics?.failureRate.toStringAsFixed(1) ?? '0.0'}%',
                ),
              ];
              if (constraints.maxWidth >= 680) {
                return Row(
                  children: stats.map((s) => Expanded(child: s)).toList(),
                );
              }
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: stats
                    .map(
                      (s) => SizedBox(
                        width: (constraints.maxWidth - 16) / 2,
                        child: s,
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Append-Only Login Audit Log Table
        FrostedGlassCard(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Append-Only Login Audit Trail',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: SariwaColors.inkSlate,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: SariwaColors.infoText.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'ZERO CREDENTIAL PERSISTENCE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: SariwaColors.infoText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: SariwaColors.surfaceSlateSubtle),

              if (sec?.recentLogs.isEmpty ?? true)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 36),
                  child: Center(
                    child: Text(
                      'No login audit events recorded yet.',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: SariwaColors.inkSlateSubtle,
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sec!.recentLogs.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: SariwaColors.surfaceSlateWash),
                  itemBuilder: (context, index) {
                    final log = sec.recentLogs[index];
                    final isSuccess = log.isSuccess;
                    final isSuspended = log.isSuspendedBlocked;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        children: [
                          Icon(
                            isSuccess
                                ? CupertinoIcons.checkmark_alt_circle
                                : (isSuspended
                                    ? CupertinoIcons.slash_circle
                                    : CupertinoIcons.exclamationmark_circle),
                            size: 16,
                            color: isSuccess
                                ? SariwaColors.statusFresh
                                : (isSuspended
                                    ? SariwaColors.statusModerate
                                    : SariwaColors.statusSpoiled),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  log.email.isNotEmpty ? log.email : 'Anonymous',
                                  style: const TextStyle(
                                    fontFamily: 'Geist',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: SariwaColors.inkSlate,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'IP: ${log.ipAddress ?? '127.0.0.1'} · ${log.failureReason.isNotEmpty ? log.failureReason : 'Google OAuth Verify'}',
                                  style: const TextStyle(
                                    fontFamily: 'Geist',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: SariwaColors.inkSlateMuted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSuccess
                                  ? SariwaColors.successBg
                                  : (isSuspended
                                      ? SariwaColors.warningBg
                                      : SariwaColors.dangerBg),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              log.status,
                              style: TextStyle(
                                fontFamily: 'Geist',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isSuccess
                                    ? SariwaColors.successText
                                    : (isSuspended
                                        ? SariwaColors.warningText
                                        : SariwaColors.dangerText),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _formatDate(log.createdAt),
                            style: const TextStyle(
                              fontFamily: 'Geist',
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              color: SariwaColors.inkSlateSubtle,
                              fontFeatures: [ui.FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityStat(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Geist',
            fontSize: 24,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.5,
            color: color ?? SariwaColors.inkSlate,
            fontFeatures: const [ui.FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Geist',
            fontSize: 12,
            fontWeight: FontWeight.w300,
            color: SariwaColors.inkSlateMuted,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 4: System Health Monitoring
  // ---------------------------------------------------------------------------
  Widget _buildHealthTab(AdminState state) {
    final health = state.health;
    final db = health?.database;
    final ml = health?.mlModel;
    final api = health?.apiThroughput;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Database & Infrastructure Card
        FrostedGlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        db?.isHealthy == true ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.exclamationmark_triangle_fill,
                        color: db?.isHealthy == true ? SariwaColors.statusFresh : SariwaColors.statusSpoiled,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Database Engine Health',
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: SariwaColors.inkSlate,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (db?.isHealthy == true ? SariwaColors.statusFresh : SariwaColors.statusSpoiled).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      db?.status ?? 'UNKNOWN',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: db?.isHealthy == true ? SariwaColors.freshText : SariwaColors.statusSpoiled,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildMetricTile('Vendor / Driver', db?.vendor.toUpperCase() ?? 'SQLITE'),
              _buildMetricTile('Connection Ping Latency', '${db?.latencyMs.toStringAsFixed(2) ?? '0.0'} ms'),
              _buildMetricTile('Connection Pool Status', 'Active & Connected'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ML Engine Card
        FrostedGlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(CupertinoIcons.circle_grid_hex_fill, color: SariwaColors.brandPrimary, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Machine Learning Model Bundle',
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: SariwaColors.inkSlate,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: SariwaColors.brandPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      ml?.status ?? 'READY',
                      style: const TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: SariwaColors.brandPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildMetricTile('Neural Architecture', ml?.architecture ?? 'MobileNetV3-Small'),
              _buildMetricTile('Checkpoint Checksum', ml?.checkpointName ?? 'sariwaba_mobilenetv3_best.pth'),
              _buildMetricTile('Hardware Device', ml?.device.toUpperCase() ?? 'CPU'),
              _buildMetricTile('Input Tensor Shape', ml?.inputResolution ?? '224x224 px'),
              _buildMetricTile('Classes Output', (ml?.classes ?? ['Fresh', 'Not Fresh']).join(' · ')),
              _buildMetricTile('File Size on Disk', '${((ml?.checkpointSizeBytes ?? 0) / (1024 * 1024)).toStringAsFixed(2)} MB'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // API Throughput Summary
        FrostedGlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'API Request Volume & Error Distribution',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: SariwaColors.inkSlate,
                ),
              ),
              const SizedBox(height: 16),
              _buildMetricTile('Total Tracked Telemetry Calls', api?.totalRequestsTracked.toString() ?? '0'),
              _buildMetricTile('HTTP 2xx (Success)', api?.successCount.toString() ?? '0'),
              _buildMetricTile('HTTP 4xx (Client / Validation Rejections)', api?.clientErrorCount.toString() ?? '0'),
              _buildMetricTile('HTTP 5xx (Server / Inference Errors)', api?.serverErrorCount.toString() ?? '0'),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 5: Strictly Append-Only Global Scan Trail
  // ---------------------------------------------------------------------------
  Widget _buildAuditsTab(AdminState state, AdminController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter bar
        FrostedGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.search,
                size: 16,
                color: SariwaColors.inkSlateMuted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _auditSearchCtrl,
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: SariwaColors.inkSlate,
                  ),
                  cursorColor: SariwaColors.brandPrimary,
                  onChanged: (val) => ctrl.filterAudits(search: val),
                  decoration: InputDecoration(
                    hintText: 'Search audits by inspector email or name...',
                    hintStyle: const TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: SariwaColors.inkSlateSubtle,
                    ),
                    suffixIcon: _auditSearchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(CupertinoIcons.clear_circled, size: 15),
                            color: SariwaColors.inkSlateSubtle,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                            onPressed: () {
                              _auditSearchCtrl.clear();
                              ctrl.filterAudits(search: '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildFilterDropdown(
                value: state.auditRegionFilter != null
                    ? (state.auditRegionFilter == 'eye'
                        ? 'Eye'
                        : state.auditRegionFilter == 'gill'
                            ? 'Gill'
                            : state.auditRegionFilter!)
                    : 'All Regions',
                items: const ['All Regions', 'Eye', 'Gill'],
                onChanged: (val) {
                  if (val == 'All Regions') {
                    ctrl.filterAudits(region: null);
                  } else {
                    ctrl.filterAudits(region: val?.toLowerCase());
                  }
                },
              ),
              const SizedBox(width: 8),
              _buildFilterDropdown(
                value: state.auditLabelFilter ?? 'All Results',
                items: const ['All Results', 'Fresh', 'Not Fresh'],
                onChanged: (val) {
                  if (val == 'All Results') {
                    ctrl.filterAudits(label: null);
                  } else {
                    ctrl.filterAudits(label: val);
                  }
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Global Audits List
        FrostedGlassCard(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Global Inspection Logs (${state.totalAudits})',
                      style: const TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: SariwaColors.inkSlate,
                      ),
                    ),
                    const Text(
                      'Append-Only · Deletion Protected',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: SariwaColors.brandPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: SariwaColors.surfaceSlateSubtle),

              if (state.audits.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'No classification audits match the criteria.',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: SariwaColors.inkSlateSubtle,
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.audits.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: SariwaColors.surfaceSlateWash),
                  itemBuilder: (context, index) {
                    final audit = state.audits[index];
                    final isFresh = audit.isFresh;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isFresh
                              ? SariwaColors.freshIconBg
                              : SariwaColors.notFreshIconBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isFresh
                              ? CupertinoIcons.checkmark_seal_fill
                              : CupertinoIcons.xmark_seal_fill,
                          size: 18,
                          color: isFresh
                              ? SariwaColors.statusFresh
                              : SariwaColors.statusSpoiled,
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            'Scan #${audit.scanId}',
                            style: const TextStyle(
                              fontFamily: 'Geist',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: SariwaColors.inkSlate,
                              fontFeatures: [ui.FontFeature.tabularFigures()],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: SariwaColors.surfaceSlateWash,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              audit.regionType.toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'Geist',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: SariwaColors.inkSlateSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        'Inspector: ${audit.inspector.name} (${audit.inspector.email})',
                        style: const TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          color: SariwaColors.inkSlateMuted,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isFresh
                                  ? SariwaColors.freshIconBg
                                  : SariwaColors.notFreshIconBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${audit.label} · ${(audit.confidence * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontFamily: 'Geist',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isFresh
                                    ? SariwaColors.freshText
                                    : SariwaColors.notFreshText,
                                fontFeatures: const [
                                  ui.FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _formatDate(audit.createdAt),
                            style: const TextStyle(
                              fontFamily: 'Geist',
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              color: SariwaColors.inkSlateSubtle,
                              fontFeatures: [ui.FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    IconData? icon,
  }) {
    return PopupMenuButton<String>(
      tooltip: 'Filter options',
      elevation: 12,
      shadowColor: SariwaColors.inkSlate.withValues(alpha: 0.12),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: SariwaColors.surfaceSlateSubtle, width: 1.0),
      ),
      offset: const Offset(0, 36),
      onSelected: onChanged,
      itemBuilder: (context) => items.map((i) {
        final isSelected = i == value;
        return PopupMenuItem<String>(
          value: i,
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                isSelected ? CupertinoIcons.checkmark_alt : null,
                size: 14,
                color: isSelected ? SariwaColors.brandPrimary : Colors.transparent,
              ),
              const SizedBox(width: 8),
              Text(
                i,
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  color: isSelected
                      ? SariwaColors.brandPrimary
                      : SariwaColors.notFreshCardBgDark,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: SariwaColors.cardSurfaceLight.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: SariwaColors.surfaceSlateSubtle,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: SariwaColors.inkSlate.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: SariwaColors.inkSlateMuted),
                const SizedBox(width: 8),
              ],
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: SariwaColors.inkSlateSecondary,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                CupertinoIcons.chevron_down,
                size: 11,
                color: SariwaColors.inkSlateMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    return '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
