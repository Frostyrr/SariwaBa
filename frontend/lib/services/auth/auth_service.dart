import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/config/api_endpoints.dart';
import '../../models/auth/user_model.dart';
import '../network/api_client.dart';
import '../storage/token_storage.dart';
import 'google_sign_in_service.dart';

class AuthService {
  final Dio dio;
  final TokenStorage tokenStorage;
  final GoogleSignInService googleSignInService;

  AuthService({
    required this.dio,
    required this.tokenStorage,
    required this.googleSignInService,
  });

  Future<UserModel> authenticateWithGoogleToken(String idToken) async {
    final response = await dio.post(
      ApiEndpoints.googleAuth,
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
      final response = await dio.get(ApiEndpoints.profile);
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
        await dio.post(ApiEndpoints.logout, data: {'refresh': refresh});
      } catch (_) {
        // Ignore network failure on logout
      }
    }
    await tokenStorage.clearTokens();
    await googleSignInService.signOut();
  }

  Future<void> deleteAccount() async {
    try {
      final response = await dio.delete(ApiEndpoints.deleteAccount);
      if (response.statusCode == 200 || response.statusCode == 204) {
        await tokenStorage.clearTokens();
        try {
          await googleSignInService.signOut();
        } catch (_) {}
        return;
      }
      throw Exception('Failed to delete account.');
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['error'] is Map) {
        final err = data['error'] as Map;
        throw Exception(err['message'] ?? 'Account deletion failed.');
      }
      rethrow;
    }
  }
}

typedef AuthRepository = AuthService;

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    dio: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
    googleSignInService: ref.watch(googleSignInServiceProvider),
  );
});

final authRepositoryProvider = authServiceProvider;
