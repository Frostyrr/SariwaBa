import '../../controllers/auth/auth_controller.dart';

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' show Offset, Rect, Size;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/config/api_endpoints.dart';
import '../../models/classification/classification_result.dart';
import '../network/api_client.dart';

class ClassificationApiException implements Exception {
  final String code;
  final String message;
  final int? statusCode;

  /// Supported-input and freshness abstention responses from the backend.
  static const Set<String> contentRejectionCodes = {
    'UNSUPPORTED_IMAGE',
    'WHOLE_TILAPIA_CLOSE_UP_REQUIRED',
    'REGION_MISMATCH',
    'CONTENT_UNCERTAIN',
    'POOR_IMAGE_QUALITY',
    'FRESHNESS_UNCERTAIN',
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
      contentRejectionCodes.contains(code) ||
      fileValidationCodes.contains(code);

  /// True when the error represents a technical, model, auth, or network failure.
  bool get isTechnicalFailure => !isInputRejection;

  /// Standard rejection heading for unsupported or invalid image submissions.
  static String rejectionTitleForCode(String? code) {
    switch (code) {
      case 'WHOLE_TILAPIA_CLOSE_UP_REQUIRED':
        return 'Close-Up Required';
      case 'FRESHNESS_UNCERTAIN':
        return 'Unclear Freshness — Try Another Photo';
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
        return 'Tilapia Eye or Gill Not Detected';
    }
  }

  /// Contextual recovery guidance based on the actual backend rejection code.
  static String contextualGuidanceForCode(String? code) {
    switch (code) {
      case 'WHOLE_TILAPIA_CLOSE_UP_REQUIRED':
        return 'Take a close-up of one eye or the exposed gill, then select its matching region.';
      case 'FRESHNESS_UNCERTAIN':
        return 'We couldn\'t get a clear reading from this angle. Try a brighter, closer photo.';
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

typedef EyeCropProposal = ({Uint8List bytes, Rect rect, Offset eyeCenter});
typedef EyeProposalResult = ({
  bool alreadyEye,
  List<EyeCropProposal> proposals,
});

abstract interface class EyeProposalService {
  Future<EyeProposalResult> findEyes(Uint8List bytes, String filename);
}

class ClassificationServiceImpl
    implements ClassificationService, EyeProposalService {
  final Dio _dio;

  final bool guestRequest;

  ClassificationServiceImpl(this._dio, {this.guestRequest = false});

  static const Set<String> _explicitHeicBrands = {
    'heic',
    'heix',
    'hevc',
    'hevx',
    'heim',
    'heis',
    'hevm',
    'hevs',
  };

  static const Set<String> _nonHeicMajorBrands = {
    'avif',
    'avis',
    'mp41',
    'mp42',
    'isom',
    'iso2',
    'avc1',
    'qt  ',
    'm4a ',
    'm4v ',
    '3gp4',
    '3gp5',
  };

  /// Strictly checks ISO-BMFF `ftyp` major & 4-byte aligned compatible brands
  /// so MP4/MOV/AVIF files are never misclassified as HEIC/HEIF.
  static bool isHeicBytes(Uint8List bytes) {
    if (bytes.length < 12) return false;
    if (bytes[4] != 0x66 ||
        bytes[5] != 0x74 ||
        bytes[6] != 0x79 ||
        bytes[7] != 0x70) {
      return false;
    }
    final boxSize =
        (bytes[0] << 24) | (bytes[1] << 16) | (bytes[2] << 8) | bytes[3];
    final end = boxSize >= 16 && boxSize <= bytes.length
        ? (boxSize > 64 ? 64 : boxSize)
        : (bytes.length > 36 ? 36 : bytes.length);

    final majorBrand = String.fromCharCodes(bytes.sublist(8, 12)).toLowerCase();
    if (_explicitHeicBrands.contains(majorBrand)) {
      return true;
    }

    final compatBrands = <String>{};
    for (int offset = 16; offset + 4 <= end; offset += 4) {
      compatBrands.add(
        String.fromCharCodes(bytes.sublist(offset, offset + 4)).toLowerCase(),
      );
    }
    if (compatBrands.any(_explicitHeicBrands.contains)) {
      return true;
    }
    if (_nonHeicMajorBrands.contains(majorBrand) ||
        compatBrands.contains('avif') ||
        compatBrands.contains('avis')) {
      return false;
    }
    if (majorBrand == 'mif1' || majorBrand == 'msf1') {
      return true;
    }
    return false;
  }

  Future<({bool alreadyEye, List<EyeCropProposal> proposals, Size? imageSize})>
  findEyesDetailed(Uint8List bytes, String filename) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '${ApiEndpoints.classify}eye-proposals/',
      data: FormData.fromMap({
        'image': MultipartFile.fromBytes(
          bytes,
          filename: filename,
          contentType: _detectMediaType(bytes, filename),
        ),
      }),
      options: Options(
        extra: {'guestRequest': guestRequest},
        validateStatus: (status) =>
            status == 200 || status == 400 || status == 413 || status == 422,
      ),
    );
    final data = response.data ?? const <String, dynamic>{};
    if (response.statusCode != 200) {
      final error = data['error'];
      if (error is Map) {
        throw ClassificationApiException(
          code: (error['code'] ?? 'INVALID_IMAGE').toString(),
          message: (error['message'] ?? 'Could not process this photo.')
              .toString(),
          statusCode: response.statusCode,
        );
      }
      throw ClassificationApiException(
        code: 'INVALID_IMAGE',
        message: 'Could not process this photo.',
        statusCode: response.statusCode,
      );
    }
    final width = (data['image_width'] as num?)?.toDouble();
    final height = (data['image_height'] as num?)?.toDouble();
    final imageSize =
        (width != null && height != null && width > 0 && height > 0)
        ? Size(width, height)
        : null;
    final proposals = (data['proposals'] as List<dynamic>)
        .map<EyeCropProposal>((proposal) {
          final rect = (proposal['rect'] as List<dynamic>).cast<num>();
          final crop = Rect.fromLTRB(
            rect[0].toDouble(),
            rect[1].toDouble(),
            rect[2].toDouble(),
            rect[3].toDouble(),
          );
          final center = (proposal['eye_center'] as List<dynamic>?)?.cast<num>();
          return (
            bytes: base64Decode(proposal['crop_base64'] as String),
            rect: crop,
            eyeCenter: center == null
                ? crop.center
                : Offset(center[0].toDouble(), center[1].toDouble()),
          );
        })
        .toList();
    return (
      alreadyEye: data['already_eye'] == true,
      proposals: proposals,
      imageSize: imageSize,
    );
  }

  @override
  Future<EyeProposalResult> findEyes(Uint8List bytes, String filename) async {
    final detailed = await findEyesDetailed(bytes, filename);
    return (alreadyEye: detailed.alreadyEye, proposals: detailed.proposals);
  }

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
    if (isHeicBytes(bytes)) {
      if (lower.endsWith('.heif')) {
        return DioMediaType('image', 'heif');
      }
      return DioMediaType('image', 'heic');
    }
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return DioMediaType('image', 'webp');
    }
    if (lower.endsWith('.heic')) {
      return DioMediaType('image', 'heic');
    }
    if (lower.endsWith('.heif')) {
      return DioMediaType('image', 'heif');
    }
    if (lower.endsWith('.webp')) {
      return DioMediaType('image', 'webp');
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
    final isHeic = isHeicBytes(bytes);
    final isWebp =
        bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50;
    if (!isPng && !isJpeg && !isWebp && !isHeic) {
      throw const ClassificationApiException(
        code: 'UNSUPPORTED_IMAGE_TYPE',
        message: 'Unsupported image format. Only JPG, JPEG, PNG, WebP, and HEIC images are allowed.',
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
