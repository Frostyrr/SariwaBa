import '../../controllers/auth/auth_controller.dart';

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/config/api_endpoints.dart';
import '../../models/classification/classification_result.dart';
import '../network/api_client.dart';

class ClassificationApiException implements Exception {
  final String code;
  final String message;
  final int? statusCode;

  /// Future backend Model A / content-validation rejection codes.
  static const Set<String> futureModelARejectionCodes = {
    'UNSUPPORTED_IMAGE',
    'REGION_MISMATCH',
    'CONTENT_UNCERTAIN',
    'POOR_IMAGE_QUALITY',
  };

  /// Current backend file/input validation rejection codes.
  static const Set<String> fileValidationCodes = {
    'MISSING_IMAGE',
    'INVALID_REGION_TYPE',
    'EMPTY_IMAGE',
    'IMAGE_TOO_LARGE',
    'UNSUPPORTED_IMAGE_TYPE',
    'INVALID_IMAGE',
    'INVALID_IMAGE_DIMENSIONS',
  };

  /// Technical / infrastructure error codes.
  static const Set<String> technicalFailureCodes = {
    'MODEL_UNAVAILABLE',
    'INFERENCE_FAILED',
    'NETWORK_ERROR',
    'AUTH_ERROR',
    'REQUEST_FAILED',
    'UNEXPECTED_RESPONSE',
  };

  const ClassificationApiException({
    required this.code,
    required this.message,
    this.statusCode,
  });

  /// True when the error represents rejected user input (file validation or future Model A content/quality rejection).
  bool get isInputRejection =>
      futureModelARejectionCodes.contains(code) ||
      fileValidationCodes.contains(code);

  /// True when the error represents a technical, model, auth, or network failure.
  bool get isTechnicalFailure => !isInputRejection;

  /// Standard rejection heading for unsupported or invalid image submissions.
  static String rejectionTitleForCode(String? code) {
    switch (code) {
      case 'REGION_MISMATCH':
        return 'Image Not Supported — Region Mismatch';
      case 'POOR_IMAGE_QUALITY':
        return 'Image Not Supported — Poor Image Quality';
      case 'INVALID_IMAGE':
      case 'UNSUPPORTED_IMAGE_TYPE':
      case 'EMPTY_IMAGE':
      case 'IMAGE_TOO_LARGE':
      case 'INVALID_IMAGE_DIMENSIONS':
        return 'Image Not Supported — Invalid Image File';
      default:
        return 'Image Not Supported';
    }
  }

  /// Contextual recovery guidance based on the actual backend rejection code.
  static String contextualGuidanceForCode(String? code) {
    switch (code) {
      case 'UNSUPPORTED_IMAGE':
      case 'CONTENT_UNCERTAIN':
        return 'Please upload a clear photograph of a fish eye or exposed gills.';
      case 'REGION_MISMATCH':
        return 'The selected region does not match the uploaded image. Please review your selection.';
      case 'POOR_IMAGE_QUALITY':
        return 'The image is too blurry or poorly illuminated. Please upload a clearer photograph.';
      case 'INVALID_IMAGE':
      case 'UNSUPPORTED_IMAGE_TYPE':
      case 'EMPTY_IMAGE':
      case 'IMAGE_TOO_LARGE':
      case 'INVALID_IMAGE_DIMENSIONS':
        return 'This image could not be processed. Please select a valid JPG or PNG file.';
      default:
        return 'The uploaded image could not be verified as a supported fish eye or exposed-gill photograph.';
    }
  }

  /// Actionable recovery guidance tailored to the error code while respecting the server message.
  String get actionableMessage {
    final trimmed = message.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
    if (isInputRejection) {
      return contextualGuidanceForCode(code);
    }
    return 'Unable to complete classification. Please try again.';
  }

  @override
  String toString() => actionableMessage;
}

abstract class ClassificationService {
  Future<ClassificationResult> classifyImage({
    required Uint8List bytes,
    required String filename,
    String regionType = 'eye',
  });

  Future<List<ClassificationResult>> fetchHistory();

  Future<void> deleteScan(int scanId);

  Future<List<int>> bulkDeleteScans(List<int> scanIds);

  Future<void> clearAllHistory();
}

typedef ClassificationRepository = ClassificationService;
typedef ClassificationException = ClassificationApiException;

class ClassificationServiceImpl implements ClassificationService {
  final Dio _dio;

  final bool guestRequest;

  ClassificationServiceImpl(this._dio, {this.guestRequest = false});

  static DioMediaType _detectMediaType(Uint8List bytes, String filename) {
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return DioMediaType('image', 'png');
    }
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return DioMediaType('image', 'jpeg');
    }
    final lower = filename.toLowerCase();
    if (bytes.length >= 12 &&
        bytes[4] == 0x66 &&
        bytes[5] == 0x74 &&
        bytes[6] == 0x79 &&
        bytes[7] == 0x70) {
      if (lower.endsWith('.heif')) {
        return DioMediaType('image', 'heif');
      }
      return DioMediaType('image', 'heic');
    }
    if (lower.endsWith('.heic')) {
      return DioMediaType('image', 'heic');
    }
    if (lower.endsWith('.heif')) {
      return DioMediaType('image', 'heif');
    }
    if (lower.endsWith('.png')) {
      return DioMediaType('image', 'png');
    }
    return DioMediaType('image', 'jpeg');
  }

  @override
  Future<ClassificationResult> classifyImage({
    required Uint8List bytes,
    required String filename,
    String regionType = 'eye',
  }) async {
    final isPng =
        bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47;
    final isJpeg =
        bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF;
    final isHeic =
        bytes.length >= 12 &&
        bytes[4] == 0x66 &&
        bytes[5] == 0x74 &&
        bytes[6] == 0x79 &&
        bytes[7] == 0x70;
    if (!isPng && !isJpeg && !isHeic) {
      throw const ClassificationApiException(
        code: 'UNSUPPORTED_IMAGE_TYPE',
        message: 'Unsupported image format. Only JPG, JPEG, PNG, and HEIC images are allowed.',
      );
    }
    final mediaType = _detectMediaType(bytes, filename);
    final formData = FormData.fromMap({
      'image': MultipartFile.fromBytes(
        bytes,
        filename: filename,
        contentType: mediaType,
      ),
      'region_type': regionType.trim().toLowerCase(),
    });

    try {
      final response = await _dio.post(
        ApiEndpoints.classify,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          extra: {'guestRequest': guestRequest},
        ),
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return ClassificationResult.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      throw const ClassificationApiException(
        code: 'UNEXPECTED_RESPONSE',
        message: 'Unexpected response received from classification server.',
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;

      if (data is Map<String, dynamic> && data['error'] is Map) {
        final errMap = data['error'] as Map;
        final code = (errMap['code'] ?? 'API_ERROR').toString();
        String msg;
        if (errMap['message'] != null &&
            errMap['message'].toString().trim().isNotEmpty) {
          msg = errMap['message'].toString();
        } else if (code == 'LOW_CONFIDENCE' && data['confidence'] is num) {
          final conf = (data['confidence'] as num).toDouble();
          msg =
              'Low confidence (${(conf * 100).toStringAsFixed(1)}%). Try a clearer close-up photo of the Tilapia eye or exposed gill.';
        } else {
          msg = 'Request validation failed.';
        }
        throw ClassificationApiException(
          code: code,
          message: msg,
          statusCode: statusCode,
        );
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const ClassificationApiException(
          code: 'NETWORK_ERROR',
          message: 'Unable to reach the classification server. Please check your connection and try again.',
        );
      }

      if (statusCode == 401 || statusCode == 403) {
        throw ClassificationApiException(
          code: 'AUTH_ERROR',
          message: 'Authentication session expired or invalid. Please sign in again.',
          statusCode: statusCode,
        );
      }

      throw ClassificationApiException(
        code: 'REQUEST_FAILED',
        message:
            'Classification request failed (${statusCode ?? 'network error'}).',
        statusCode: statusCode,
      );
    }
  }

  @override
  Future<List<ClassificationResult>> fetchHistory() async {
    final response = await _dio.get(ApiEndpoints.history);

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      final list = (response.data['history'] as List<dynamic>? ?? []);
      return list
          .map(
            (item) =>
                ClassificationResult.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    return [];
  }

  @override
  Future<void> deleteScan(int scanId) async {
    final response = await _dio.delete(ApiEndpoints.historyDetail(scanId));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete scan record.');
    }
  }

  @override
  Future<List<int>> bulkDeleteScans(List<int> scanIds) async {
    if (scanIds.isEmpty) return [];
    try {
      final response = await _dio.delete(
        ApiEndpoints.historyBulkDelete,
        data: {'scan_ids': scanIds},
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final list = (response.data['deleted_ids'] as List<dynamic>? ?? []);
        return list.map((e) => (e as num).toInt()).toList();
      }
      return scanIds;
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<void> clearAllHistory() async {
    final response = await _dio.delete(ApiEndpoints.historyClearAll);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to clear classification history.');
    }
  }
}

final classificationServiceProvider = Provider<ClassificationService>((ref) {
  final dio = ref.watch(apiClientProvider);
  final isGuest = ref.watch(
    authControllerProvider.select((state) => state.isGuest),
  );
  return ClassificationServiceImpl(dio, guestRequest: isGuest);
});

final classificationRepositoryProvider = classificationServiceProvider;
