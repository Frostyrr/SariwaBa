import 'package:flutter/material.dart';

import '../../constants/theme/app_colors.dart';

class ClassificationResult {
  final int? scanId;
  final String label;
  final double confidence;
  final bool saved;
  final String? imageUrl;
  final DateTime? createdAt;

  const ClassificationResult({
    this.scanId,
    required this.label,
    required this.confidence,
    this.saved = false,
    this.imageUrl,
    this.createdAt,
  });

  factory ClassificationResult.fromJson(Map<String, dynamic> json) {
    return ClassificationResult(
      scanId: json['scan_id'] as int?,
      label: json['label'] as String? ?? 'Unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      saved: json['saved'] as bool? ?? false,
      imageUrl: (json['image_url'] ?? json['image']) as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scan_id': scanId,
      'label': label,
      'confidence': confidence,
      'saved': saved,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  bool get isFresh => label.trim().toLowerCase() == 'fresh';

  bool get isNotFresh => const {
    'not fresh',
    'nonfresh',
    'non-fresh',
  }.contains(label.trim().toLowerCase());

  Color get statusColor => isFresh
      ? SariwaColors.statusFresh
      : isNotFresh
      ? SariwaColors.statusSpoiled
      : SariwaColors.textMutedDark;

  String get formattedConfidence => '${(confidence * 100).toStringAsFixed(1)}%';
}
