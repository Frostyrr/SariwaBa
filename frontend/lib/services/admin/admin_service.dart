import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/config/api_endpoints.dart';
import '../../models/admin/admin_audit_model.dart';
import '../../models/admin/admin_health_model.dart';
import '../../models/admin/admin_security_model.dart';
import '../../models/admin/admin_telemetry_model.dart';
import '../../models/admin/admin_user_model.dart';
import '../network/api_client.dart';

final adminServiceProvider = Provider<AdminService>((ref) {
  final dio = ref.watch(apiClientProvider);
  return AdminService(dio);
});

class AdminService {
  final Dio _dio;

  AdminService(this._dio);

  /// Fetch aggregated classification and inference telemetry metrics
  Future<AdminTelemetryStatsModel> getTelemetryStats() async {
    try {
      final response = await _dio.get(ApiEndpoints.adminStats);
      if (response.statusCode == 200 && response.data is Map) {
        return AdminTelemetryStatsModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw Exception('Failed to load telemetry stats.');
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch registered user directory with optional search, role filter, and suspension filter
  Future<List<AdminUserModel>> getUsers({
    String? search,
    String? role,
    bool? isSuspended,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (role != null && role.isNotEmpty) queryParams['role'] = role;
      if (isSuspended != null) queryParams['is_suspended'] = isSuspended.toString();

      final response = await _dio.get(
        ApiEndpoints.adminUsers,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data is Map) {
        final rawUsers = response.data['users'] as List<dynamic>? ?? [];
        return rawUsers
            .map((u) => AdminUserModel.fromJson(u as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Update user role (admin / user)
  Future<Map<String, dynamic>> updateUserRole({
    required int userId,
    required String role,
  }) async {
    try {
      final response = await _dio.patch(
        ApiEndpoints.adminUserRole(userId.toString()),
        data: {'role': role},
      );
      if (response.statusCode == 200 && response.data is Map) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to update role.');
    } catch (e) {
      rethrow;
    }
  }

  /// Toggle or set account suspension
  Future<Map<String, dynamic>> toggleUserSuspension({
    required int userId,
    bool? isSuspended,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (isSuspended != null) data['is_suspended'] = isSuspended;

      final response = await _dio.post(
        ApiEndpoints.adminUserSuspend(userId.toString()),
        data: data,
      );
      if (response.statusCode == 200 && response.data is Map) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to update suspension status.');
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch security metrics, suspicious events, and login audit logs
  Future<AdminSecurityModel> getSecurityLogs({int limit = 50}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.adminSecurity,
        queryParameters: {'limit': limit},
      );
      if (response.statusCode == 200 && response.data is Map) {
        return AdminSecurityModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw Exception('Failed to load security logs.');
    } catch (e) {
      rethrow;
    }
  }

  /// Live system health check (DB ping, ML model, API throughput)
  Future<AdminHealthModel> getSystemHealth() async {
    try {
      final response = await _dio.get(ApiEndpoints.adminHealth);
      if (response.statusCode == 200 && response.data is Map) {
        return AdminHealthModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw Exception('Failed to load system health.');
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch strictly append-only global audit scan logs across all inspectors
  Future<Map<String, dynamic>> getAudits({
    String? region,
    String? label,
    String? search,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (region != null && region.isNotEmpty) queryParams['region'] = region;
      if (label != null && label.isNotEmpty) queryParams['label'] = label;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get(
        ApiEndpoints.adminAudits,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data is Map) {
        final rawResults = response.data['results'] as List<dynamic>? ?? [];
        final audits = rawResults
            .map((r) => AdminAuditModel.fromJson(r as Map<String, dynamic>))
            .toList();

        return {
          'total': response.data['total'] as int? ?? audits.length,
          'offset': response.data['offset'] as int? ?? offset,
          'limit': response.data['limit'] as int? ?? limit,
          'results': audits,
        };
      }
      return {'total': 0, 'results': <AdminAuditModel>[]};
    } catch (e) {
      rethrow;
    }
  }
}
