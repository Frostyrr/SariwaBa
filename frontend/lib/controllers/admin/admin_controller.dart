import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/admin/admin_audit_model.dart';
import '../../models/admin/admin_health_model.dart';
import '../../models/admin/admin_security_model.dart';
import '../../models/admin/admin_telemetry_model.dart';
import '../../models/admin/admin_user_model.dart';
import '../../services/admin/admin_service.dart';

enum AdminTab {
  inspectors,
  telemetry,
  security,
  health,
  audits,
}

class AdminState {
  final bool isLoading;
  final bool isActionLoading;
  final String? errorMessage;
  final String? successMessage;
  final AdminTab activeTab;
  final AdminTelemetryStatsModel? stats;
  final List<AdminUserModel> users;
  final AdminSecurityModel? security;
  final AdminHealthModel? health;
  final List<AdminAuditModel> audits;
  final int totalAudits;
  final String userSearchQuery;
  final String? selectedRoleFilter;
  final bool? selectedSuspensionFilter;
  final String? auditRegionFilter;
  final String? auditLabelFilter;
  final String auditSearchQuery;

  const AdminState({
    this.isLoading = false,
    this.isActionLoading = false,
    this.errorMessage,
    this.successMessage,
    this.activeTab = AdminTab.inspectors,
    this.stats,
    this.users = const [],
    this.security,
    this.health,
    this.audits = const [],
    this.totalAudits = 0,
    this.userSearchQuery = '',
    this.selectedRoleFilter,
    this.selectedSuspensionFilter,
    this.auditRegionFilter,
    this.auditLabelFilter,
    this.auditSearchQuery = '',
  });

  AdminState copyWith({
    bool? isLoading,
    bool? isActionLoading,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    AdminTab? activeTab,
    AdminTelemetryStatsModel? stats,
    List<AdminUserModel>? users,
    AdminSecurityModel? security,
    AdminHealthModel? health,
    List<AdminAuditModel>? audits,
    int? totalAudits,
    String? userSearchQuery,
    String? selectedRoleFilter,
    bool clearRoleFilter = false,
    bool? selectedSuspensionFilter,
    bool clearSuspensionFilter = false,
    String? auditRegionFilter,
    bool clearAuditRegionFilter = false,
    String? auditLabelFilter,
    bool clearAuditLabelFilter = false,
    String? auditSearchQuery,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      activeTab: activeTab ?? this.activeTab,
      stats: stats ?? this.stats,
      users: users ?? this.users,
      security: security ?? this.security,
      health: health ?? this.health,
      audits: audits ?? this.audits,
      totalAudits: totalAudits ?? this.totalAudits,
      userSearchQuery: userSearchQuery ?? this.userSearchQuery,
      selectedRoleFilter: clearRoleFilter
          ? null
          : (selectedRoleFilter ?? this.selectedRoleFilter),
      selectedSuspensionFilter: clearSuspensionFilter
          ? null
          : (selectedSuspensionFilter ?? this.selectedSuspensionFilter),
      auditRegionFilter: clearAuditRegionFilter
          ? null
          : (auditRegionFilter ?? this.auditRegionFilter),
      auditLabelFilter: clearAuditLabelFilter
          ? null
          : (auditLabelFilter ?? this.auditLabelFilter),
      auditSearchQuery: auditSearchQuery ?? this.auditSearchQuery,
    );
  }
}

final adminControllerProvider =
    StateNotifierProvider<AdminController, AdminState>((ref) {
  final service = ref.watch(adminServiceProvider);
  return AdminController(service);
});

class AdminController extends StateNotifier<AdminState> {
  final AdminService _service;

  AdminController(this._service) : super(const AdminState());

  void setTab(AdminTab tab) {
    state = state.copyWith(activeTab: tab);
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final statsFuture = _service.getTelemetryStats();
      final usersFuture = _service.getUsers(
        search: state.userSearchQuery,
        role: state.selectedRoleFilter,
        isSuspended: state.selectedSuspensionFilter,
      );
      final secFuture = _service.getSecurityLogs();
      final healthFuture = _service.getSystemHealth();
      final auditsFuture = _service.getAudits(
        region: state.auditRegionFilter,
        label: state.auditLabelFilter,
        search: state.auditSearchQuery,
      );

      final results = await Future.wait([
        statsFuture,
        usersFuture,
        secFuture,
        healthFuture,
        auditsFuture,
      ]);

      final auditsMap = results[4] as Map<String, dynamic>;

      state = state.copyWith(
        isLoading: false,
        stats: results[0] as AdminTelemetryStatsModel,
        users: results[1] as List<AdminUserModel>,
        security: results[2] as AdminSecurityModel,
        health: results[3] as AdminHealthModel,
        audits: auditsMap['results'] as List<AdminAuditModel>? ?? [],
        totalAudits: auditsMap['total'] as int? ?? 0,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load administrative telemetry: $e',
      );
    }
  }

  Future<void> searchUsers(String query) async {
    state = state.copyWith(userSearchQuery: query);
    try {
      final users = await _service.getUsers(
        search: query,
        role: state.selectedRoleFilter,
        isSuspended: state.selectedSuspensionFilter,
      );
      state = state.copyWith(users: users);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Search failed: $e');
    }
  }

  Future<void> filterUsersByRole(String? role) async {
    state = state.copyWith(
      selectedRoleFilter: role,
      clearRoleFilter: role == null,
    );
    try {
      final users = await _service.getUsers(
        search: state.userSearchQuery,
        role: role,
        isSuspended: state.selectedSuspensionFilter,
      );
      state = state.copyWith(users: users);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Filter failed: $e');
    }
  }

  Future<void> filterUsersBySuspension(bool? isSuspended) async {
    state = state.copyWith(
      selectedSuspensionFilter: isSuspended,
      clearSuspensionFilter: isSuspended == null,
    );
    try {
      final users = await _service.getUsers(
        search: state.userSearchQuery,
        role: state.selectedRoleFilter,
        isSuspended: isSuspended,
      );
      state = state.copyWith(users: users);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Filter failed: $e');
    }
  }

  Future<bool> updateUserRole(int userId, String newRole) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    try {
      final res = await _service.updateUserRole(
        userId: userId,
        role: newRole,
      );

      // Update in local user list
      final updatedList = state.users.map((u) {
        if (u.id == userId) {
          return u.copyWith(role: newRole, isAdmin: newRole == 'admin');
        }
        return u;
      }).toList();

      state = state.copyWith(
        isActionLoading: false,
        users: updatedList,
        successMessage: res['message']?.toString() ?? 'User role updated successfully.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: 'Role update failed: $e',
      );
      return false;
    }
  }

  Future<bool> toggleUserSuspension(int userId, {bool? suspend}) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    try {
      final res = await _service.toggleUserSuspension(
        userId: userId,
        isSuspended: suspend,
      );

      final updatedList = state.users.map((u) {
        if (u.id == userId) {
          final newSuspended = suspend ?? !u.isSuspended;
          return u.copyWith(
            isSuspended: newSuspended,
            suspendedAt: newSuspended ? DateTime.now() : null,
          );
        }
        return u;
      }).toList();

      // Refresh security logs to capture the audit trail entry
      final security = await _service.getSecurityLogs();

      state = state.copyWith(
        isActionLoading: false,
        users: updatedList,
        security: security,
        successMessage: res['message']?.toString() ?? 'Account status updated.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: 'Suspension toggle failed: $e',
      );
      return false;
    }
  }

  Future<void> filterAudits({
    String? region,
    String? label,
    String? search,
  }) async {
    state = state.copyWith(
      auditRegionFilter: region,
      clearAuditRegionFilter: region == null,
      auditLabelFilter: label,
      clearAuditLabelFilter: label == null,
      auditSearchQuery: search ?? state.auditSearchQuery,
    );

    try {
      final auditsMap = await _service.getAudits(
        region: state.auditRegionFilter,
        label: state.auditLabelFilter,
        search: state.auditSearchQuery,
      );
      state = state.copyWith(
        audits: auditsMap['results'] as List<AdminAuditModel>? ?? [],
        totalAudits: auditsMap['total'] as int? ?? 0,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to load audits: $e');
    }
  }
}
