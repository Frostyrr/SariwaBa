import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/models/user_model.dart';
import 'google_sign_in_service.dart';

class AuthRepository {
  final Dio dio;
  final TokenStorage tokenStorage;
  final GoogleSignInService googleSignInService;

  AuthRepository({
    required this.dio,
    required this.tokenStorage,
    required this.googleSignInService,
  });

  Future<UserModel> authenticateWithGoogleToken(String idToken) async {
    final response = await dio.post(
      '/api/v1/auth/google/',
      data: {'id_token': idToken},
    );

    final data = response.data as Map<String, dynamic>;
    final access = data['access'] as String;
    final refresh = data['refresh'] as String;
    final userJson = data['user'] as Map<String, dynamic>;

    await tokenStorage.saveTokens(
      accessToken: access,
      refreshToken: refresh,
    );

    return UserModel.fromJson(userJson);
  }

  Future<UserModel?> getProfile() async {
    final token = await tokenStorage.getAccessToken();
    if (token == null || token.isEmpty) return null;

    try {
      final response = await dio.get('/api/v1/profile/');
      final data = response.data as Map<String, dynamic>;
      final userJson = data['user'] as Map<String, dynamic>;
      return UserModel.fromJson(userJson);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await tokenStorage.clearTokens();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() async {
    final refresh = await tokenStorage.getRefreshToken();
    if (refresh != null && refresh.isNotEmpty) {
      try {
        await dio.post('/api/v1/auth/logout/', data: {'refresh': refresh});
      } catch (_) {
        // Ignore network failure on logout
      }
    }
    await tokenStorage.clearTokens();
    await googleSignInService.signOut();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    dio: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
    googleSignInService: ref.watch(googleSignInServiceProvider),
  );
});
