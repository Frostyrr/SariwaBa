class DatabaseHealthModel {
  final String status;
  final double latencyMs;
  final String vendor;

  const DatabaseHealthModel({
    this.status = 'UNKNOWN',
    this.latencyMs = 0.0,
    this.vendor = 'sqlite',
  });

  factory DatabaseHealthModel.fromJson(Map<String, dynamic> json) {
    return DatabaseHealthModel(
      status: json['status'] as String? ?? 'UNKNOWN',
      latencyMs: (json['latency_ms'] as num?)?.toDouble() ?? 0.0,
      vendor: json['vendor'] as String? ?? 'sqlite',
    );
  }

  bool get isHealthy => status.toUpperCase().contains('HEALTHY');
}

class MlModelHealthModel {
  final String status;
  final String architecture;
  final String checkpointName;
  final int checkpointSizeBytes;
  final String? checkpointLastModified;
  final String device;
  final List<String> classes;
  final String inputResolution;

  const MlModelHealthModel({
    this.status = 'UNKNOWN',
    this.architecture = 'MobileNetV3-Small',
    this.checkpointName = '',
    this.checkpointSizeBytes = 0,
    this.checkpointLastModified,
    this.device = 'cpu',
    this.classes = const ['Fresh', 'Not Fresh'],
    this.inputResolution = '224x224 px',
  });

  factory MlModelHealthModel.fromJson(Map<String, dynamic> json) {
    final rawClasses = json['classes'] as List<dynamic>? ?? ['Fresh', 'Not Fresh'];
    return MlModelHealthModel(
      status: json['status'] as String? ?? 'UNKNOWN',
      architecture: json['architecture'] as String? ?? 'MobileNetV3-Small',
      checkpointName: json['checkpoint_name'] as String? ?? '',
      checkpointSizeBytes: json['checkpoint_size_bytes'] as int? ?? 0,
      checkpointLastModified: json['checkpoint_last_modified'] as String?,
      device: json['device'] as String? ?? 'cpu',
      classes: rawClasses.map((c) => c.toString()).toList(),
      inputResolution: json['input_resolution'] as String? ?? '224x224 px',
    );
  }

  bool get isReady => status == 'READY';
}

class ApiThroughputHealthModel {
  final int totalRequestsTracked;
  final int successCount;
  final int clientErrorCount;
  final int serverErrorCount;

  const ApiThroughputHealthModel({
    this.totalRequestsTracked = 0,
    this.successCount = 0,
    this.clientErrorCount = 0,
    this.serverErrorCount = 0,
  });

  factory ApiThroughputHealthModel.fromJson(Map<String, dynamic> json) {
    return ApiThroughputHealthModel(
      totalRequestsTracked: json['total_requests_tracked'] as int? ?? 0,
      successCount: json['success_count'] as int? ?? 0,
      clientErrorCount: json['client_error_count'] as int? ?? 0,
      serverErrorCount: json['server_error_count'] as int? ?? 0,
    );
  }
}

class AdminHealthModel {
  final DatabaseHealthModel database;
  final MlModelHealthModel mlModel;
  final ApiThroughputHealthModel apiThroughput;

  const AdminHealthModel({
    this.database = const DatabaseHealthModel(),
    this.mlModel = const MlModelHealthModel(),
    this.apiThroughput = const ApiThroughputHealthModel(),
  });

  factory AdminHealthModel.fromJson(Map<String, dynamic> json) {
    return AdminHealthModel(
      database: DatabaseHealthModel.fromJson(
        json['database'] as Map<String, dynamic>? ?? {},
      ),
      mlModel: MlModelHealthModel.fromJson(
        json['ml_model'] as Map<String, dynamic>? ?? {},
      ),
      apiThroughput: ApiThroughputHealthModel.fromJson(
        json['api_throughput'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
