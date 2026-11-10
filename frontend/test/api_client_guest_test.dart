import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/auth/auth_controller.dart';
import 'package:frontend/services/auth/google_sign_in_service.dart';
import 'package:frontend/services/network/api_client.dart';

import 'package:frontend/services/classification/classification_service.dart';
import 'package:frontend/services/storage/token_storage.dart';

import 'widget_test.dart' show FakeGoogleSignInService, kValidPngBytes;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Real provider graph allows requests after guest entry', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [
        googleSignInServiceProvider.overrideWithValue(
          FakeGoogleSignInService(),
        ),
      ],
    );
    addTearDown(container.dispose);
    final auth = container.read(authControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    auth.continueAsGuest();
    final dio = container.read(apiClientProvider);
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response(requestOptions: options, statusCode: 200, data: {}),
          );
        },
      ),
    );
    final response = await dio.post(
      '/api/v1/auth/google/',
      data: {'id_token': 'test'},
    );
    expect(response.statusCode, 200);
    await container
        .read(tokenStorageProvider)
        .saveTokens(accessToken: 'stale-access', refreshToken: 'stale-refresh');
    RequestOptions? captured;
    dio.interceptors.removeLast();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options;
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: <String, dynamic>{
                'label': 'Fresh',
                'confidence': .9,
                'saved': false,
              },
            ),
          );
        },
      ),
    );
    await container
        .read(classificationServiceProvider)
        .classifyImage(bytes: kValidPngBytes, filename: 'eye.png');
    expect(captured!.extra['guestRequest'], isTrue);
    expect(captured!.headers.containsKey('Authorization'), isFalse);
    auth.goToLogin();
    await dio.post('/api/v1/auth/google/', data: {'id_token': 'test'});
    expect(captured!.extra['guestRequest'], isNot(true));
  });
}
