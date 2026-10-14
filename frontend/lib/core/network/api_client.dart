import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../storage/token_storage.dart';

final apiClientProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final accessToken = await tokenStorage.getAccessToken();
        if (accessToken != null && accessToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        if (error.response?.statusCode == 401 &&
            !error.requestOptions.path.contains('/auth/token/refresh/')) {
          final refreshToken = await tokenStorage.getRefreshToken();
          if (refreshToken != null && refreshToken.isNotEmpty) {
            try {
              final refreshDio = Dio(
                BaseOptions(baseUrl: AppConfig.apiBaseUrl),
              );
              final refreshResponse = await refreshDio.post(
                '/api/v1/auth/token/refresh/',
                data: {'refresh': refreshToken},
              );

              if (refreshResponse.statusCode == 200 &&
                  refreshResponse.data is Map) {
                final newAccess = refreshResponse.data['access'] as String?;
                final newRefresh =
                    refreshResponse.data['refresh'] as String? ?? refreshToken;

                if (newAccess != null) {
                  await tokenStorage.saveTokens(
                    accessToken: newAccess,
                    refreshToken: newRefresh,
                  );

                  // Retry the original request with new token
                  final options = error.requestOptions;
                  options.headers['Authorization'] = 'Bearer $newAccess';
                  final retryResponse = await dio.fetch(options);
                  return handler.resolve(retryResponse);
                }
              }
            } catch (_) {
              await tokenStorage.clearTokens();
            }
          }
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
});
