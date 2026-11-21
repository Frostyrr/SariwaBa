import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/classification/classification_result.dart';
import 'package:frontend/services/classification/classification_service.dart';
import 'package:frontend/services/storage/guest_history_cache.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final code in [
    'UNSUPPORTED_IMAGE',
    'WHOLE_TILAPIA_CLOSE_UP_REQUIRED',
    'REGION_MISMATCH',
    'CONTENT_UNCERTAIN',
    'FRESHNESS_UNCERTAIN',
    'MODEL_UNAVAILABLE',
  ]) {
    test('$code is surfaced without creating a freshness result', () async {
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
                  statusCode: code == 'MODEL_UNAVAILABLE' ? 503 : 422,
                  data: {
                    'error': {
                      'code': code,
                      'message': 'Please try another photo.',
                    },
                  },
                ),
              ),
            );
          },
        ),
      );
      await expectLater(
        ClassificationServiceImpl(dio).classifyImage(
          bytes: Uint8List.fromList([255, 216, 255, 224]),
          filename: 'photo.jpg',
        ),
        throwsA(
          isA<ClassificationApiException>()
              .having((e) => e.code, 'code', code)
              .having(
                (e) => e.isInputRejection,
                'input rejection',
                code != 'MODEL_UNAVAILABLE',
              ),
        ),
      );
    });
  }

  test('freshness uncertainty has a distinct heading', () {
    expect(
      ClassificationApiException.rejectionTitleForCode('FRESHNESS_UNCERTAIN'),
      'Freshness Could Not Be Determined',
    );
  });

  test('legacy results retain user-selected region wording', () {
    final result = ClassificationResult.fromJson({
      'label': 'Fresh',
      'region_type': 'eye',
    });
    expect(result.selectedRegionLabel, 'Selected region: Eye');
  });

  test(
    'guest cache preserves validation provenance after storage reload',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      final result = ClassificationResult.fromJson({
        'label': 'Fresh',
        'confidence': 0.95,
        'assessment_species': 'Tilapia',
        'region_type': 'gill',
        'region_verified': true,
        'validator_version': 'validator-v1',
      });
      await GuestHistoryCache().addScan(result);
      final restored = (await GuestHistoryCache().getCachedHistory()).single;
      expect(restored.selectedRegionLabel, 'Verified region: Gill');
      expect(restored.validatorVersion, 'validator-v1');
      expect(restored.toJson()['species_verified'], false);
    },
  );
}
