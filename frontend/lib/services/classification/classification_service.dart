import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/config/api_endpoints.dart';
import '../../models/classification/classification_result.dart';
import '../network/api_client.dart';

abstract class ClassificationService {
  Future<ClassificationResult> classifyImage({
    required Uint8List bytes,
    required String filename,
  });

  Future<List<ClassificationResult>> fetchHistory();

  Future<void> deleteScan(int scanId);
}

typedef ClassificationRepository = ClassificationService;

class ClassificationException implements Exception {
  final String message;
  const ClassificationException(this.message);

  @override
  String toString() => message;
}

class ClassificationServiceImpl implements ClassificationService {
  final Dio _dio;

  ClassificationServiceImpl(this._dio);

  @override
  Future<ClassificationResult> classifyImage({
    required Uint8List bytes,
    required String filename,
  }) async {
    if (bytes.length > 5 * 1024 * 1024) {
      throw const ClassificationException('Image must not exceed 5 MB.');
    }
    // Inspect the file signature: filenames from cameras need not have extensions.
    final isJpeg =
        bytes.length >= 3 &&
        bytes[0] == 0xff &&
        bytes[1] == 0xd8 &&
        bytes[2] == 0xff;
    const pngSignature = [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a];
    final isPng =
        bytes.length >= pngSignature.length &&
        Iterable.generate(pngSignature.length)
            .every((index) => bytes[index] == pngSignature[index]);
    if (!isJpeg && !isPng) {
      throw const ClassificationException('Choose a JPEG or PNG image.');
    }
    final formData = FormData.fromMap({
      'image': MultipartFile.fromBytes(
        bytes,
        filename: filename,
        contentType: DioMediaType('image', isJpeg ? 'jpeg' : 'png'),
      ),
    });

    late final Response<dynamic> response;
    try {
      response = await _dio.post(
        ApiEndpoints.classify,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } on DioException catch (error) {
      final data = error.response?.data;
      final detail = data is Map ? data['error'] : null;
      if (detail is Map && detail['code'] == 'LOW_CONFIDENCE') {
        final confidence = data['confidence'];
        final score =
            confidence is num &&
                confidence.isFinite &&
                confidence >= 0 &&
                confidence <= 1
            ? ' (${(confidence * 100).toStringAsFixed(1)}% confidence)'
            : '';
        throw ClassificationException(
          'The model could not confidently classify this image$score. '
          'Try a clearer, well-lit photo with the fish in focus.',
        );
      }
      if (error.response?.statusCode == 400 &&
          detail is Map &&
          detail['message'] is String) {
        throw ClassificationException(detail['message'] as String);
      }
      if (error.response?.statusCode == 401) {
        throw const ClassificationException(
          'Your session has expired. Please sign in again.',
        );
      }
      throw ClassificationException(
        error.response == null
            ? 'Cannot reach the classification service. Check your connection and try again.'
            : 'The classification service is unavailable. Please try again later.',
      );
    }

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      return ClassificationResult.fromJson(
        response.data as Map<String, dynamic>,
      );
    }

    throw Exception('Failed to classify image.');
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
}

final classificationServiceProvider = Provider<ClassificationService>((ref) {
  final dio = ref.watch(apiClientProvider);
  return ClassificationServiceImpl(dio);
});

final classificationRepositoryProvider = classificationServiceProvider;
