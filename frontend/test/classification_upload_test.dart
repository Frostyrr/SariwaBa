import 'dart:typed_data';
import 'dart:ui' show Offset, Rect;

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/classification/classification_controller.dart';
import 'package:frontend/models/classification/classification_result.dart';
import 'package:frontend/services/classification/classification_service.dart';

import 'widget_test.dart' show FakeClassificationRepository, kValidPngBytes;

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

  test('strict ftyp brand check accepts HEIC but rejects MP4 and AVIF', () async {
    final mp4Header = Uint8List.fromList([
      0, 0, 0, 20, // size = 20
      0x66, 0x74, 0x79, 0x70, // 'ftyp'
      0x69, 0x73, 0x6F, 0x6D, // 'isom'
      0, 0, 2, 0,
      0x6D, 0x70, 0x34, 0x31, // 'mp41'
    ]);
    final avifHeader = Uint8List.fromList([
      0, 0, 0, 16,
      0x66, 0x74, 0x79, 0x70, // 'ftyp'
      0x61, 0x76, 0x69, 0x66, // 'avif'
      0, 0, 0, 0,
    ]);
    final heicHeader = Uint8List.fromList([
      0, 0, 0, 24,
      0x66, 0x74, 0x79, 0x70, // 'ftyp'
      0x68, 0x65, 0x69, 0x63, // 'heic'
      0, 0, 0, 0,
      0x6D, 0x69, 0x66, 0x31, // 'mif1'
      0x68, 0x65, 0x69, 0x63, // 'heic'
    ]);

    expect(ClassificationServiceImpl.isHeicBytes(mp4Header), isFalse);
    expect(ClassificationServiceImpl.isHeicBytes(avifHeader), isFalse);
    expect(ClassificationServiceImpl.isHeicBytes(heicHeader), isTrue);

    await expectLater(
      ClassificationServiceImpl(Dio()).classifyImage(
        bytes: mp4Header,
        filename: 'clip.mp4',
      ),
      throwsA(isA<ClassificationException>()),
    );
  });

  test(
    'manual crop and full close-up clear stale selectedEyeProposalIndex so gill region is preserved',
    () async {
      String? submittedRegion;
      final service = _RecordingClassificationRepo(
        onClassify: (region) => submittedRegion = region,
      );
      final controller = ClassificationController(
        service,
        isAuthenticated: false,
      );
      addTearDown(controller.dispose);

      controller.state = ClassificationState(
        selectedImageBytes: kValidPngBytes,
        selectedImageName: 'whole.png',
        selectedRegion: AnatomicalRegion.gill,
        eyeProposals: [
          (
            bytes: kValidPngBytes,
            rect: const Rect.fromLTWH(0.1, 0.1, 0.2, 0.2),
            eyeCenter: const Offset(0.2, 0.2),
          ),
        ],
        selectedEyeProposalIndex: 0,
      );

      controller.confirmCroppedRegion(kValidPngBytes);
      expect(controller.state.selectedEyeProposalIndex, isNull);
      await controller.classify();
      expect(submittedRegion, 'gill');
    },
  );
}

class _RecordingClassificationRepo extends FakeClassificationRepository {
  final void Function(String regionType) onClassify;

  _RecordingClassificationRepo({required this.onClassify});

  @override
  Future<ClassificationResult> classifyImage({
    required Uint8List bytes,
    required String filename,
    String regionType = 'eye',
  }) async {
    onClassify(regionType);
    return super.classifyImage(
      bytes: bytes,
      filename: filename,
      regionType: regionType,
    );
  }
}
