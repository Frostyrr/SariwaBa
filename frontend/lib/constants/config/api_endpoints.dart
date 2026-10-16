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
  static String historyDetail(int scanId) => '/api/v1/history/$scanId/';
}
