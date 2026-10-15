import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../domain/models/classification_result.dart';

abstract class ClassificationRepository {
  Future<ClassificationResult> classifyImage({
    required Uint8List bytes,
    required String filename,
  });

  Future<List<ClassificationResult>> fetchHistory();

  Future<void> deleteScan(int scanId);
}

class ClassificationRepositoryImpl implements ClassificationRepository {
  final Dio _dio;

  ClassificationRepositoryImpl(this._dio);

  @override
  Future<ClassificationResult> classifyImage({
    required Uint8List bytes,
    required String filename,
  }) async {
    final formData = FormData.fromMap({
      'image': MultipartFile.fromBytes(
        bytes,
        filename: filename,
      ),
    });

    final response = await _dio.post(
      '/api/v1/classify/',
      data: formData,
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      return ClassificationResult.fromJson(
        response.data as Map<String, dynamic>,
      );
    }

    throw Exception('Failed to classify image.');
  }

  @override
  Future<List<ClassificationResult>> fetchHistory() async {
    final response = await _dio.get('/api/v1/history/');

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      final list = (response.data['history'] as List<dynamic>? ?? []);
      return list
          .map((item) =>
              ClassificationResult.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  @override
  Future<void> deleteScan(int scanId) async {
    final response = await _dio.delete('/api/v1/history/$scanId/');
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete scan record.');
    }
  }
}

final classificationRepositoryProvider =
    Provider<ClassificationRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return ClassificationRepositoryImpl(dio);
});
