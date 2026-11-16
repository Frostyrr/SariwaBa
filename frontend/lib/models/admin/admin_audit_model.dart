class AdminAuditInspector {
  final int id;
  final String email;
  final String name;

  const AdminAuditInspector({
    required this.id,
    required this.email,
    required this.name,
  });

  factory AdminAuditInspector.fromJson(Map<String, dynamic> json) {
    return AdminAuditInspector(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? 'Inspector',
    );
  }
}

class AdminAuditModel {
  final int scanId;
  final AdminAuditInspector inspector;
  final String regionType;
  final String label;
  final double confidence;
  final String? imageUrl;
  final DateTime? createdAt;

  const AdminAuditModel({
    required this.scanId,
    required this.inspector,
    required this.regionType,
    required this.label,
    required this.confidence,
    this.imageUrl,
    this.createdAt,
  });

  factory AdminAuditModel.fromJson(Map<String, dynamic> json) {
    return AdminAuditModel(
      scanId: json['scan_id'] as int? ?? 0,
      inspector: AdminAuditInspector.fromJson(
        json['inspector'] as Map<String, dynamic>? ?? {},
      ),
      regionType: json['region_type'] as String? ?? 'eye',
      label: json['label'] as String? ?? 'Fresh',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  bool get isFresh => label.toLowerCase() == 'fresh';
}
