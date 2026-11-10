import 'package:flutter/material.dart';
import '../../constants/theme/app_colors.dart';

/// Supported Tilapia anatomical regions for ROI selection and MobileNetV3 inference.
enum AnatomicalRegion {
    eye,
    gill;

  String get apiValue => name;

  String get displayName {
    switch (this) {
      case AnatomicalRegion.eye:
        return 'Eye';
      case AnatomicalRegion.gill:
        return 'Gill';
    }
  }

  String get tagalogName {
    switch (this) {
      case AnatomicalRegion.eye:
        return 'Mata (Eye)';
      case AnatomicalRegion.gill:
        return 'Hasang (Exposed Gill)';
    }
  }

  String get guidance {
    switch (this) {
      case AnatomicalRegion.eye:
        return "Select the fish's visible eye and surrounding area.";
      case AnatomicalRegion.gill:
        return 'Select exposed gill tissue, not the external gill cover.';
    }
  }

  static AnatomicalRegion? fromString(String? raw) {
    if (raw == null) return null;
    switch (raw.trim().toLowerCase()) {
      case 'eye':
      case 'eyes':
        return AnatomicalRegion.eye;
      case 'gill':
      case 'gills':
        return AnatomicalRegion.gill;
      default:
        return null;
    }
  }
}

class ClassificationResult {
  final int? scanId;
  final String label;
  final double confidence;
  final String? regionType;
  final String species;
  final String disclaimer;
  final bool saved;
  final String? imageUrl;
  final DateTime? createdAt;
  final String? modelVersion;
  final bool? regionVerified;

  static const String defaultDisclaimer =
      'This is a preliminary visual freshness assessment and does not guarantee food safety.';

  static const String confidenceExplanation =
      'Confidence is a model prediction score, not a freshness percentage.';

  const ClassificationResult({
    this.scanId,
    required this.label,
    required this.confidence,
    this.regionType,
    this.species = 'Tilapia',
    this.disclaimer = defaultDisclaimer,
    this.saved = false,
    this.imageUrl,
    this.createdAt,
    this.modelVersion,
    this.regionVerified,
  });

  factory ClassificationResult.fromJson(Map<String, dynamic> json) {
    final rawLabel =
        (json['classification'] ?? json['label']) as String? ?? 'Fresh';
    final rawRegion = json['region_type'] as String?;
    final normalizedRegion =
        (rawRegion != null && rawRegion.trim().isNotEmpty)
            ? (AnatomicalRegion.fromString(rawRegion)?.apiValue ??
                rawRegion.trim().toLowerCase())
            : null;

    return ClassificationResult(
      scanId: json['scan_id'] as int?,
      label: rawLabel,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      regionType: normalizedRegion,
      species: (json['species'] as String?) ?? 'Tilapia',
      disclaimer: (json['disclaimer'] as String?) ?? defaultDisclaimer,
      saved: json['saved'] as bool? ?? false,
      imageUrl: (json['image_url'] ?? json['image']) as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      modelVersion: json['model_version'] as String?,
      regionVerified: json['region_verified'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scan_id': scanId,
      'classification': label,
      'label': label,
      'confidence': confidence,
      'region_type': regionType,
      'species': species,
      'disclaimer': disclaimer,
      'saved': saved,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
      if (modelVersion != null) 'model_version': modelVersion,
      if (regionVerified != null) 'region_verified': regionVerified,
    };
  }

  /// Parsed anatomical region if present in the response/history record.
  /// Returns null for older history records that do not have region metadata.
  AnatomicalRegion? get anatomicalRegion =>
      AnatomicalRegion.fromString(regionType);

  /// Display name ('Eye' or 'Gill') when region metadata is present; null otherwise.
  String? get regionDisplayName => anatomicalRegion?.displayName;

  /// Truthful user-selected region label ('Selected region: Eye' or 'Selected region: Gill').
  /// Never claims 'Verified' unless the backend explicitly returns region_verified == true.
  String? get selectedRegionLabel {
    final name = regionDisplayName;
    if (name == null) return null;
    return 'Selected region: $name';
  }

  /// Describes Tilapia as the intended assessment scope without claiming automatic species detection.
  String get assessmentScopeLabel => 'Assessment scope: $species';

  /// Alias retained for compatibility.
  String get supportedInputLabel => assessmentScopeLabel;

  /// Actual persistence status for the scan.
  String get saveStatusLabel {
    if (saved) {
      return scanId != null
          ? 'Saved to History (Scan #$scanId)'
          : 'Saved to History';
    }
    return 'Not Saved to History (Guest Session)';
  }

  /// Formatted timestamp when createdAt is present.
  String? get formattedTimestamp {
    final dt = createdAt?.toLocal();
    if (dt == null) return null;
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.year}-$month-$day $hour:$minute';
  }

  bool get isFresh =>
      label.toLowerCase().contains('fresh') &&
      !label.toLowerCase().contains('not') &&
      !label.toLowerCase().contains('non');

  Color get statusColor {
    if (isFresh) return SariwaColors.statusFresh;
    return SariwaColors.statusSpoiled;
  }

  String get formattedConfidence => '${(confidence * 100).toStringAsFixed(1)}%';
}
