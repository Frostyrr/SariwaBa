import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/theme/app_colors.dart';
import '../../../controllers/admin/admin_controller.dart';
import '../../../controllers/auth/auth_controller.dart';
import '../../../models/admin/admin_user_model.dart';
import '../../../widgets/dashboard/dashboard_atmospheric_banner.dart';
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
            backgroundColor: const Color(0xFFEF4444),
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
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        adminCtrl.clearMessages();
      });
    }

    return SingleChildScrollView(
      controller: widget.scrollController,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: widget.isDesktop ? 36 : 18,
        vertical: widget.isDesktop ? 28 : 20,
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
  // Top Banner
  // ---------------------------------------------------------------------------
  Widget _buildAtmosphericBanner(AdminState state, AdminController ctrl) {
    return DashboardAtmosphericBanner(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'RBAC ADMINISTRATION',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.8,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.50),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'STRICT APPEND-ONLY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.8,
                          color: Color(0xFFD1FAE5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Admin Console & Telemetry',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.02,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'System oversight, user directory access, classification telemetry, security audits, and ML engine health.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFFD1FAF4),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: state.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(CupertinoIcons.arrow_clockwise, color: Colors.white, size: 20),
            tooltip: 'Refresh Telemetry',
            onPressed: () => ctrl.loadDashboard(),
          ),
        ],
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
            eyebrow: 'INSPECTORS',
            value: totals?.totalInspectors.toString() ?? '—',
            subtitle: '${totals?.activeInspectorsToday ?? 0} active today',
            icon: CupertinoIcons.person_2_fill,
            iconColor: const Color(0xFF0284C7),
          ),
          _buildBentoKpiCard(
            eyebrow: 'GLOBAL INFERENCES',
            value: totals?.totalScans.toString() ?? '—',
            subtitle: '${totals?.scansToday ?? 0} in last 24h',
            icon: CupertinoIcons.viewfinder_circle_fill,
            iconColor: const Color(0xFF0D9488),
          ),
          _buildBentoKpiCard(
            eyebrow: 'FRESHNESS COMPLIANCE',
            value: '${dist?.freshnessRate.toStringAsFixed(1) ?? '—'}%',
            subtitle: '${dist?.freshCount ?? 0} Fresh · ${dist?.notFreshCount ?? 0} Not Fresh',
            icon: CupertinoIcons.checkmark_seal_fill,
            iconColor: const Color(0xFF10B981),
          ),
          _buildBentoKpiCard(
            eyebrow: 'INFERENCE LATENCY',
            value: '${latency?.averageLatencyMs.toStringAsFixed(0) ?? '—'} ms',
            subtitle: 'p95: ${latency?.p95LatencyMs.toStringAsFixed(0) ?? '—'} ms',
            icon: CupertinoIcons.speedometer,
            iconColor: const Color(0xFFF59E0B),
          ),
          _buildBentoKpiCard(
            eyebrow: 'SYSTEM HEALTH',
            value: health?.database.isHealthy == true ? 'HEALTHY' : 'READY',
            subtitle: 'DB: ${health?.database.latencyMs.toStringAsFixed(1) ?? '1.2'}ms · ML Ready',
            icon: CupertinoIcons.heart_fill,
            iconColor: const Color(0xFF14B8A6),
          ),
        ];

        if (isWide) {
          return Row(
            children: items
                .map((card) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: card,
                      ),
                    ))
                .toList(),
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
                      padding: const EdgeInsets.only(bottom: 10),
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 16,
            offset: Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.85),
                width: 1.2,
              ),
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
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.8,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(icon, size: 16, color: iconColor),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.03,
                    color: Color(0xFF0F172A),
                    fontFeatures: [ui.FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 11,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF64748B),
                    fontFeatures: [ui.FontFeature.tabularFigures()],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Segmented Sub-Navigation Switcher
  // ---------------------------------------------------------------------------
  Widget _buildSegmentedTabSwitcher(AdminState state, AdminController ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.80),
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTabPill(
              label: 'Inspectors & Access',
              icon: CupertinoIcons.person_2_fill,
              isActive: state.activeTab == AdminTab.inspectors,
              onTap: () => ctrl.setTab(AdminTab.inspectors),
            ),
            _buildTabPill(
              label: 'Classification Telemetry',
              icon: CupertinoIcons.waveform_path_ecg,
              isActive: state.activeTab == AdminTab.telemetry,
              onTap: () => ctrl.setTab(AdminTab.telemetry),
            ),
            _buildTabPill(
              label: 'Security & Audits',
              icon: CupertinoIcons.shield_fill,
              isActive: state.activeTab == AdminTab.security,
              badgeCount: state.security?.metrics.suspiciousPatternDetected == true ? 1 : null,
              onTap: () => ctrl.setTab(AdminTab.security),
            ),
            _buildTabPill(
              label: 'System Health',
              icon: CupertinoIcons.heart_fill,
              isActive: state.activeTab == AdminTab.health,
              onTap: () => ctrl.setTab(AdminTab.health),
            ),
            _buildTabPill(
              label: 'Global Scan Trail',
              icon: CupertinoIcons.doc_text_search,
              isActive: state.activeTab == AdminTab.audits,
              onTap: () => ctrl.setTab(AdminTab.audits),
            ),
          ],
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive
                  ? const Color(0xFF0D9488)
                  : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Geist',
                fontSize: 12.5,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                color: isActive
                    ? const Color(0xFF0F172A)
                    : const Color(0xFF64748B),
              ),
            ),
            if (badgeCount != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'ALERT',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _userSearchCtrl,
                  style: const TextStyle(fontFamily: 'Geist', fontSize: 13, color: Color(0xFF0F172A)),
                  cursorColor: const Color(0xFF0F766E),
                  onChanged: (val) => ctrl.searchUsers(val),
                  decoration: InputDecoration(
                    hintText: 'Search by inspector name, email, or username...',
                    hintStyle: const TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFF94A3B8),
                    ),
                    prefixIcon: const Icon(CupertinoIcons.search, size: 16, color: Color(0xFF64748B)),
                    suffixIcon: _userSearchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(CupertinoIcons.clear_circled, size: 14),
                            onPressed: () {
                              _userSearchCtrl.clear();
                              ctrl.searchUsers('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Filter by role
              _buildFilterDropdown(
                value: state.selectedRoleFilter == 'admin'
                    ? 'Admins'
                    : state.selectedRoleFilter == 'user' ? 'Inspectors' : 'All Roles',
                items: const ['All Roles', 'Admins', 'Inspectors'],
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Registered Inspectors (${state.users.length})',
                      style: const TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const Text(
                      'Protected against self-demotion & self-suspension',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 11,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              if (state.users.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'No matching inspectors found.',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.users.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  itemBuilder: (context, index) {
                    final user = state.users[index];
                    final isSelf = currentUser?.id != null && user.id.toString() == currentUser.id.toString();

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: user.isAdmin
                            ? const Color(0xFF0D9488).withValues(alpha: 0.15)
                            : const Color(0xFF64748B).withValues(alpha: 0.15),
                        child: Text(
                          user.initials,
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: user.isAdmin ? const Color(0xFF0D9488) : const Color(0xFF475569),
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
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelf) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'YOU',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0284C7),
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
                                color: Color(0xFF64748B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '· ${user.scanCount} scans',
                            style: const TextStyle(
                              fontFamily: 'Geist',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w300,
                              color: Color(0xFF94A3B8),
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: isAdmin
            ? const Color(0xFF0D9488).withValues(alpha: 0.12)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isAdmin
              ? const Color(0xFF0D9488).withValues(alpha: 0.25)
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Text(
        isAdmin ? 'ADMIN' : 'INSPECTOR',
        style: TextStyle(
          fontFamily: 'Geist',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
          color: isAdmin ? const Color(0xFF0D9488) : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildSuspensionBadge(bool isSuspended) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: isSuspended
            ? const Color(0xFFEF4444).withValues(alpha: 0.12)
            : const Color(0xFF10B981).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isSuspended ? 'SUSPENDED' : 'ACTIVE',
        style: TextStyle(
          fontFamily: 'Geist',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
          color: isSuspended ? const Color(0xFFDC2626) : const Color(0xFF059669),
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
      icon: const Icon(CupertinoIcons.ellipsis_vertical, size: 16, color: Color(0xFF64748B)),
      tooltip: isSelf ? 'Protected Self Account' : 'Manage Inspector',
      onSelected: (action) {
        if (action == 'toggle_role') {
          final newRole = user.isAdmin ? 'user' : 'admin';
          _confirmRoleChange(user, newRole, ctrl);
        } else if (action == 'toggle_suspension') {
          _confirmSuspensionChange(user, !user.isSuspended, ctrl);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'toggle_role',
          enabled: !isSelf,
          child: Row(
            children: [
              Icon(
                user.isAdmin ? CupertinoIcons.person : CupertinoIcons.shield,
                size: 15,
                color: isSelf ? Colors.grey : const Color(0xFF0F172A),
              ),
              const SizedBox(width: 8),
              Text(
                user.isAdmin ? 'Demote to Inspector' : 'Promote to Admin',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: isSelf ? Colors.grey : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'toggle_suspension',
          enabled: !isSelf,
          child: Row(
            children: [
              Icon(
                user.isSuspended ? CupertinoIcons.check_mark_circled : CupertinoIcons.slash_circle,
                size: 15,
                color: isSelf
                    ? Colors.grey
                    : (user.isSuspended ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
              ),
              const SizedBox(width: 8),
              Text(
                user.isSuspended ? 'Reactivate Account' : 'Suspend Account',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: isSelf
                      ? Colors.grey
                      : (user.isSuspended ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                ),
              ),
            ],
          ),
        ),
      ],
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
            fontSize: 13,
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
              backgroundColor: const Color(0xFF0D9488),
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
            fontSize: 13,
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
              backgroundColor: suspend ? const Color(0xFFEF4444) : const Color(0xFF10B981),
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
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Diagnostic Freshness Distribution',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Distribution ratio across all neural network predictions.',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 18),
              // Distribution Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 16,
                  child: Row(
                    children: [
                      Expanded(
                        flex: (dist?.freshCount ?? 1).clamp(1, 100000),
                        child: Container(color: const Color(0xFF10B981)),
                      ),
                      Expanded(
                        flex: (dist?.notFreshCount ?? 1).clamp(1, 100000),
                        child: Container(color: const Color(0xFFF43F5E)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Fresh: ${dist?.freshCount ?? 0} (${dist?.freshnessRate.toStringAsFixed(1) ?? 0}%)',
                        style: const TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0F172A),
                          fontFeatures: [ui.FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF43F5E),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Not Fresh: ${dist?.notFreshCount ?? 0}',
                        style: const TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0F172A),
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
                      color: Color(0xFF64748B),
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
              padding: const EdgeInsets.all(22),
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
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${rej?.rejectionRate.toStringAsFixed(1) ?? '0.0'}% rate',
                          style: const TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFD97706),
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
                      color: Color(0xFF64748B),
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
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Inference Latency & Confidence',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'PyTorch runtime latency and average model certainty.',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMetricTile('Average Latency', '${latency?.averageLatencyMs.toStringAsFixed(1) ?? '—'} ms'),
                  _buildMetricTile('Median Latency', '${latency?.medianLatencyMs.toStringAsFixed(1) ?? '—'} ms'),
                  _buildMetricTile('95th Percentile (p95)', '${latency?.p95LatencyMs.toStringAsFixed(1) ?? '—'} ms'),
                  const Divider(height: 20, color: Color(0xFFE2E8F0)),
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
                color: Color(0xFF334155),
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
              color: Color(0xFF0F172A),
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
              fontSize: 12.5,
              fontWeight: FontWeight.w300,
              color: Color(0xFF475569),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Geist',
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0F172A),
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
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFCA5A5), width: 1.2),
            ),
            child: Row(
              children: [
                const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: Color(0xFFDC2626), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Suspicious Authentication Patterns Detected',
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF991B1B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Detected ${sec?.suspiciousEvents.length ?? 0} security incident(s) (rapid failed attempts from same IP or account).',
                        style: const TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          color: Color(0xFFB91C1C),
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
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBBF7D0), width: 1.2),
            ),
            child: const Row(
              children: [
                Icon(CupertinoIcons.checkmark_shield_fill, color: Color(0xFF16A34A), size: 20),
                SizedBox(width: 10),
                Text(
                  'No suspicious login anomalies detected. Authentication surface is stable.',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF166534),
                  ),
                ),
              ],
            ),
          ),

        // Security Metrics Bento
        FrostedGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              Expanded(child: _buildSecurityStat('Total Logins', metrics?.totalAttempts.toString() ?? '0')),
              Expanded(child: _buildSecurityStat('Successful', metrics?.successfulAttempts.toString() ?? '0', color: const Color(0xFF16A34A))),
              Expanded(child: _buildSecurityStat('Failed (Total)', metrics?.failedAttempts.toString() ?? '0', color: const Color(0xFFDC2626))),
              Expanded(child: _buildSecurityStat('Failed (24h)', metrics?.failedLast24h.toString() ?? '0', color: const Color(0xFFD97706))),
              Expanded(child: _buildSecurityStat('Failure Rate', '${metrics?.failureRate.toStringAsFixed(1) ?? '0.0'}%')),
            ],
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Append-Only Login Audit Trail',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'ZERO CREDENTIAL PERSISTENCE',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              if (sec?.recentLogs.isEmpty ?? true)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 36),
                  child: Center(
                    child: Text(
                      'No login audit events recorded yet.',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sec!.recentLogs.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  itemBuilder: (context, index) {
                    final log = sec.recentLogs[index];
                    final isSuccess = log.isSuccess;
                    final isSuspended = log.isSuspendedBlocked;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                                ? const Color(0xFF10B981)
                                : (isSuspended ? const Color(0xFF8B5CF6) : const Color(0xFFEF4444)),
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
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'IP: ${log.ipAddress ?? '127.0.0.1'} · ${log.failureReason.isNotEmpty ? log.failureReason : 'Google OAuth Verify'}',
                                  style: const TextStyle(
                                    fontFamily: 'Geist',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w300,
                                    color: Color(0xFF64748B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: isSuccess
                                  ? const Color(0xFF10B981).withValues(alpha: 0.12)
                                  : (isSuspended
                                      ? const Color(0xFF8B5CF6).withValues(alpha: 0.12)
                                      : const Color(0xFFEF4444).withValues(alpha: 0.12)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              log.status,
                              style: TextStyle(
                                fontFamily: 'Geist',
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: isSuccess
                                    ? const Color(0xFF059669)
                                    : (isSuspended ? const Color(0xFF7C3AED) : const Color(0xFFDC2626)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _formatDate(log.createdAt),
                            style: const TextStyle(
                              fontFamily: 'Geist',
                              fontSize: 11,
                              fontWeight: FontWeight.w300,
                              color: Color(0xFF94A3B8),
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
            fontSize: 20,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.02,
            color: color ?? const Color(0xFF0F172A),
            fontFeatures: const [ui.FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Geist',
            fontSize: 11.5,
            fontWeight: FontWeight.w300,
            color: Color(0xFF64748B),
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
          padding: const EdgeInsets.all(22),
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
                        color: db?.isHealthy == true ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Database Engine Health',
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (db?.isHealthy == true ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      db?.status ?? 'UNKNOWN',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: db?.isHealthy == true ? const Color(0xFF059669) : const Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildMetricTile('Vendor / Driver', db?.vendor.toUpperCase() ?? 'SQLITE'),
              _buildMetricTile('Connection Ping Latency', '${db?.latencyMs.toStringAsFixed(2) ?? '0.0'} ms'),
              _buildMetricTile('Connection Pool Status', 'Active & Connected'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ML Engine Card
        FrostedGlassCard(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(CupertinoIcons.circle_grid_hex_fill, color: Color(0xFF0D9488), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Machine Learning Model Bundle',
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      ml?.status ?? 'READY',
                      style: const TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0D9488),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
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
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'API Request Volume & Error Distribution',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 14),
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _auditSearchCtrl,
                  onChanged: (val) => ctrl.filterAudits(search: val),
                  decoration: InputDecoration(
                    hintText: 'Search audits by inspector email or name...',
                    hintStyle: const TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFF94A3B8),
                    ),
                    prefixIcon: const Icon(CupertinoIcons.search, size: 16, color: Color(0xFF64748B)),
                    suffixIcon: _auditSearchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(CupertinoIcons.clear_circled, size: 14),
                            onPressed: () {
                              _auditSearchCtrl.clear();
                              ctrl.filterAudits(search: '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildFilterDropdown(
                value: state.auditRegionFilter ?? 'All Regions',
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Global Inspection Logs (${state.totalAudits})',
                      style: const TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const Text(
                      'Append-Only · Deletion Protected',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 11,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF0D9488),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              if (state.audits.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'No classification audits match the criteria.',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.audits.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
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
                              ? const Color(0xFF10B981).withValues(alpha: 0.12)
                              : const Color(0xFFF43F5E).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isFresh ? CupertinoIcons.checkmark_seal_fill : CupertinoIcons.xmark_seal_fill,
                          size: 18,
                          color: isFresh ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            'Scan #${audit.scanId}',
                            style: const TextStyle(
                              fontFamily: 'Geist',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF0F172A),
                              fontFeatures: [ui.FontFeature.tabularFigures()],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              audit.regionType.toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'Geist',
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        'Inspector: ${audit.inspector.name} (${audit.inspector.email})',
                        style: const TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w300,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isFresh
                                  ? const Color(0xFF10B981).withValues(alpha: 0.12)
                                  : const Color(0xFFF43F5E).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${audit.label} · ${(audit.confidence * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontFamily: 'Geist',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isFresh ? const Color(0xFF059669) : const Color(0xFFE11D48),
                                fontFeatures: const [ui.FontFeature.tabularFigures()],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _formatDate(audit.createdAt),
                            style: const TextStyle(
                              fontFamily: 'Geist',
                              fontSize: 11,
                              fontWeight: FontWeight.w300,
                              color: Color(0xFF94A3B8),
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: const Color(0xFAFFFFFF),
          borderRadius: BorderRadius.circular(14),
          elevation: 8,
          value: items.contains(value) ? value : items.first,
          isDense: true,
          style: const TextStyle(
            fontFamily: 'Geist',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF334155),
          ),
          icon: const Icon(CupertinoIcons.chevron_down, size: 12, color: Color(0xFF64748B)),
          items: items
              .map((i) => DropdownMenuItem(value: i, child: Text(i)))
              .toList(),
          onChanged: onChanged,
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
