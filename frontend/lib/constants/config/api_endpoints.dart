/// Centralized backend API endpoint routes for SariwaBa.
class ApiEndpoints {
  const ApiEndpoints._();

  // Authentication & User Profile
  static const String googleAuth = '/api/v1/auth/google/';
  static const String tokenRefresh = '/api/v1/auth/token/refresh/';
  static const String logout = '/api/v1/auth/logout/';
  static const String profile = '/api/v1/profile/';

  // Fish Freshness Classification & Audit History
  static const String classify = '/api/v1/classify/';
  static const String history = '/api/v1/history/';
  static const String historyBulkDelete = '/api/v1/history/bulk/';
  static String historyDetail(int scanId) => '/api/v1/history/$scanId/';

  // Admin & RBAC Endpoints
  static const String adminStats = '/api/v1/admin/stats/';
  static const String adminUsers = '/api/v1/admin/users/';
  static String adminUserRole(String userId) => '/api/v1/admin/users/$userId/role/';
  static String adminUserSuspend(String userId) => '/api/v1/admin/users/$userId/suspend/';
  static const String adminSecurity = '/api/v1/admin/security/';
  static const String adminHealth = '/api/v1/admin/health/';
  static const String adminAudits = '/api/v1/admin/audits/';
}
