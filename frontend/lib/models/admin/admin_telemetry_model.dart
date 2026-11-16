class AdminTelemetryTotals {
  final int totalScans;
  final int scansToday;
  final int scans7Days;
  final int totalInspectors;
  final int activeInspectorsToday;

  const AdminTelemetryTotals({
    this.totalScans = 0,
    this.scansToday = 0,
    this.scans7Days = 0,
    this.totalInspectors = 0,
    this.activeInspectorsToday = 0,
  });

  factory AdminTelemetryTotals.fromJson(Map<String, dynamic> json) {
    return AdminTelemetryTotals(
      totalScans: json['total_scans'] as int? ?? 0,
      scansToday: json['scans_today'] as int? ?? 0,
      scans7Days: json['scans_7_days'] as int? ?? 0,
      totalInspectors: json['total_inspectors'] as int? ?? 0,
      activeInspectorsToday: json['active_inspectors_today'] as int? ?? 0,
    );
  }
}

class AdminTelemetryDistribution {
  final int freshCount;
  final int notFreshCount;
  final double freshnessRate;
  final int eyeScans;
  final int gillScans;

  const AdminTelemetryDistribution({
    this.freshCount = 0,
    this.notFreshCount = 0,
    this.freshnessRate = 0.0,
    this.eyeScans = 0,
    this.gillScans = 0,
  });

  factory AdminTelemetryDistribution.fromJson(Map<String, dynamic> json) {
    return AdminTelemetryDistribution(
      freshCount: json['fresh_count'] as int? ?? 0,
      notFreshCount: json['not_fresh_count'] as int? ?? 0,
      freshnessRate: (json['freshness_rate'] as num?)?.toDouble() ?? 0.0,
      eyeScans: json['eye_scans'] as int? ?? 0,
      gillScans: json['gill_scans'] as int? ?? 0,
    );
  }
}

class AdminTelemetryConfidence {
  final double averageConfidence;
  final double freshAvgConfidence;
  final double notFreshAvgConfidence;

  const AdminTelemetryConfidence({
    this.averageConfidence = 0.0,
    this.freshAvgConfidence = 0.0,
    this.notFreshAvgConfidence = 0.0,
  });

  factory AdminTelemetryConfidence.fromJson(Map<String, dynamic> json) {
    return AdminTelemetryConfidence(
      averageConfidence: (json['average_confidence'] as num?)?.toDouble() ?? 0.0,
      freshAvgConfidence: (json['fresh_avg_confidence'] as num?)?.toDouble() ?? 0.0,
      notFreshAvgConfidence: (json['not_fresh_avg_confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AdminTelemetryRejections {
  final int totalRequests;
  final int totalRejections;
  final double rejectionRate;
  final Map<String, int> rejectionsByReason;

  const AdminTelemetryRejections({
    this.totalRequests = 0,
    this.totalRejections = 0,
    this.rejectionRate = 0.0,
    this.rejectionsByReason = const {},
  });

  factory AdminTelemetryRejections.fromJson(Map<String, dynamic> json) {
    final rawReasons = json['rejections_by_reason'] as Map<String, dynamic>? ?? {};
    final parsedReasons = rawReasons.map((k, v) => MapEntry(k, (v as int?) ?? 0));
    return AdminTelemetryRejections(
      totalRequests: json['total_requests'] as int? ?? 0,
      totalRejections: json['total_rejections'] as int? ?? 0,
      rejectionRate: (json['rejection_rate'] as num?)?.toDouble() ?? 0.0,
      rejectionsByReason: parsedReasons,
    );
  }
}

class AdminTelemetryLatency {
  final double averageLatencyMs;
  final double medianLatencyMs;
  final double p95LatencyMs;

  const AdminTelemetryLatency({
    this.averageLatencyMs = 0.0,
    this.medianLatencyMs = 0.0,
    this.p95LatencyMs = 0.0,
  });

  factory AdminTelemetryLatency.fromJson(Map<String, dynamic> json) {
    return AdminTelemetryLatency(
      averageLatencyMs: (json['average_latency_ms'] as num?)?.toDouble() ?? 0.0,
      medianLatencyMs: (json['median_latency_ms'] as num?)?.toDouble() ?? 0.0,
      p95LatencyMs: (json['p95_latency_ms'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AdminTelemetryStatsModel {
  final AdminTelemetryTotals totals;
  final AdminTelemetryDistribution distribution;
  final AdminTelemetryConfidence confidence;
  final AdminTelemetryRejections rejections;
  final AdminTelemetryLatency latency;

  const AdminTelemetryStatsModel({
    this.totals = const AdminTelemetryTotals(),
    this.distribution = const AdminTelemetryDistribution(),
    this.confidence = const AdminTelemetryConfidence(),
    this.rejections = const AdminTelemetryRejections(),
    this.latency = const AdminTelemetryLatency(),
  });

  factory AdminTelemetryStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminTelemetryStatsModel(
      totals: AdminTelemetryTotals.fromJson(
        json['totals'] as Map<String, dynamic>? ?? {},
      ),
      distribution: AdminTelemetryDistribution.fromJson(
        json['distribution'] as Map<String, dynamic>? ?? {},
      ),
      confidence: AdminTelemetryConfidence.fromJson(
        json['confidence'] as Map<String, dynamic>? ?? {},
      ),
      rejections: AdminTelemetryRejections.fromJson(
        json['rejection_metrics'] as Map<String, dynamic>? ?? {},
      ),
      latency: AdminTelemetryLatency.fromJson(
        json['latency_metrics'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
