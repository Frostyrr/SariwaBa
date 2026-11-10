import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/classification/classification_service.dart';

void main() {
  final jpeg = Uint8List.fromList([255, 216, 255, 224]);
  final png = Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10]);

  for (final entry in {'jpeg': jpeg, 'png': png}.entries) {
    test('uploads ${entry.key} with its actual MIME type', () async {
      final dio = Dio(BaseOptions(contentType: 'application/json'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.contentType, 'multipart/form-data');
            final file = (options.data as FormData).files.single;
            expect(file.key, 'image');
            expect(file.value.contentType.toString(), 'image/${entry.key}');
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'label': 'Fresh', 'confidence': .9, 'saved': false},
              ),
            );
          },
        ),
      );
      final result = await ClassificationServiceImpl(dio)
          .classifyImage(bytes: entry.value, filename: 'camera_file');
      expect(result.label, 'Fresh');
    });
  }

  test('low confidence is a readable rejection, not a prediction', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.badResponse,
              response: Response(
                requestOptions: options,
                statusCode: 400,
                data: {
                  'error': {'code': 'LOW_CONFIDENCE'},
                  'confidence': .6515305,
                },
              ),
            ),
          );
        },
      ),
    );
    await expectLater(
      ClassificationServiceImpl(dio)
          .classifyImage(bytes: jpeg, filename: '0029.jpg'),
      throwsA(
        isA<ClassificationException>().having(
          (e) => e.message,
          'message',
          allOf(contains('65.2%'), contains('Try a clearer')),
        ),
      ),
    );
  });

  test('rejects unsupported data even if named jpg', () async {
    await expectLater(
      ClassificationServiceImpl(Dio()).classifyImage(
        bytes: Uint8List.fromList([1, 2, 3]),
        filename: 'fake.jpg',
      ),
      throwsA(isA<ClassificationException>()),
    );
  });
}
