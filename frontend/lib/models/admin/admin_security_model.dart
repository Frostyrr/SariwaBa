class SecurityMetricsModel {
  final int totalAttempts;
  final int successfulAttempts;
  final int failedAttempts;
  final int failedLast24h;
  final double failureRate;
  final bool suspiciousPatternDetected;

  const SecurityMetricsModel({
    this.totalAttempts = 0,
    this.successfulAttempts = 0,
    this.failedAttempts = 0,
    this.failedLast24h = 0,
    this.failureRate = 0.0,
    this.suspiciousPatternDetected = false,
  });

  factory SecurityMetricsModel.fromJson(Map<String, dynamic> json) {
    return SecurityMetricsModel(
      totalAttempts: json['total_attempts'] as int? ?? 0,
      successfulAttempts: json['successful_attempts'] as int? ?? 0,
      failedAttempts: json['failed_attempts'] as int? ?? 0,
      failedLast24h: json['failed_last_24h'] as int? ?? 0,
      failureRate: (json['failure_rate'] as num?)?.toDouble() ?? 0.0,
      suspiciousPatternDetected:
          json['suspicious_pattern_detected'] as bool? ?? false,
    );
  }
}

class SuspiciousEventModel {
  final String type;
  final String target;
  final int failureCount;
  final String window;
  final String severity;

  const SuspiciousEventModel({
    required this.type,
    required this.target,
    required this.failureCount,
    required this.window,
    required this.severity,
  });

  factory SuspiciousEventModel.fromJson(Map<String, dynamic> json) {
    return SuspiciousEventModel(
      type: json['type'] as String? ?? 'UNKNOWN',
      target: json['target'] as String? ?? 'N/A',
      failureCount: json['failure_count'] as int? ?? 0,
      window: json['window'] as String? ?? '15m',
      severity: json['severity'] as String? ?? 'MEDIUM',
    );
  }
}

class LoginAuditModel {
  final int id;
  final String email;
  final String? ipAddress;
  final String userAgent;
  final String status;
  final String failureReason;
  final DateTime? createdAt;

  const LoginAuditModel({
    required this.id,
    required this.email,
    this.ipAddress,
    this.userAgent = '',
    required this.status,
    this.failureReason = '',
    this.createdAt,
  });

  factory LoginAuditModel.fromJson(Map<String, dynamic> json) {
    return LoginAuditModel(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      ipAddress: json['ip_address'] as String?,
      userAgent: json['user_agent'] as String? ?? '',
      status: json['status'] as String? ?? 'UNKNOWN',
      failureReason: json['failure_reason'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  bool get isSuccess => status == 'SUCCESS';
  bool get isSuspendedBlocked => status == 'SUSPENDED_BLOCKED';
}

class AdminSecurityModel {
  final SecurityMetricsModel metrics;
  final List<SuspiciousEventModel> suspiciousEvents;
  final List<LoginAuditModel> recentLogs;

  const AdminSecurityModel({
    this.metrics = const SecurityMetricsModel(),
    this.suspiciousEvents = const [],
    this.recentLogs = const [],
  });

  factory AdminSecurityModel.fromJson(Map<String, dynamic> json) {
    final rawEvents = json['suspicious_events'] as List<dynamic>? ?? [];
    final rawLogs = json['recent_logs'] as List<dynamic>? ?? [];

    return AdminSecurityModel(
      metrics: SecurityMetricsModel.fromJson(
        json['metrics'] as Map<String, dynamic>? ?? {},
      ),
      suspiciousEvents: rawEvents
          .map((e) => SuspiciousEventModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentLogs: rawLogs
          .map((l) => LoginAuditModel.fromJson(l as Map<String, dynamic>))
          .toList(),
    );
  }
}
