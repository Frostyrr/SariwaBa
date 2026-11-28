import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../constants/config/platform_env.dart';
import '../../services/auth/auth_service.dart';
import '../../services/auth/google_sign_in_service.dart';
import 'auth_state.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    final repository = ref.watch(authServiceProvider);
    final googleService = ref.watch(googleSignInServiceProvider);
    return AuthController(repository: repository, googleService: googleService);
  },
);

class AuthController extends StateNotifier<AuthState> {
  final AuthService repository;
  final GoogleSignInService googleService;
  StreamSubscription<GoogleSignInAccount?>? _eventSub;
  late final Future<void> _bootstrapFuture;

  AuthController({required this.repository, required this.googleService})
    : super(const AuthState(viewStatus: AuthViewStatus.initializing)) {
    _init();
  }

  void _init() {
    _bootstrapFuture = bootstrap();
    // Web's Google-rendered button delivers credentials through this stream.
    // Native sign-in is handled by continueWithGoogle, avoiding two exchanges.
    if (!kIsWeb) return;
    _eventSub = googleService.onCurrentUserChanged.listen(
      _handleUserChanged,
      onError: (err) {
        debugPrint('Google Sign-In stream error: $err');
        if (!mounted) return;
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Google Sign-In failed. Please try again.',
        );
      },
    );
  }

  Future<void> _handleUserChanged(GoogleSignInAccount? account) async {
    if (account == null) return;
    await _bootstrapFuture;
    if (!mounted || state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken != null && idToken.isNotEmpty) {
        await _exchangeGoogleIdToken(idToken);
      } else if (mounted) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Could not obtain Google ID token. Please try again.',
        );
      }
    } catch (error) {
      debugPrint('Google credential retrieval failed: $error');
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Google Sign-In failed. Please try again.',
      );
    }
  }

  /// Bootstrap app: check if saved tokens are valid
  Future<void> bootstrap() async {
    state = state.copyWith(
      isLoading: true,
      viewStatus: AuthViewStatus.initializing,
    );
    try {
      final user = await repository.getProfile();
      if (user != null) {
        state = state.copyWith(
          viewStatus: AuthViewStatus.authenticated,
          user: user,
          isLoading: false,
        );
        return;
      }
    } catch (_) {
      // Fallback to landing if network/token check fails
    }

    state = state.copyWith(
      viewStatus: isNativeMobileDevice
          ? AuthViewStatus.login
          : AuthViewStatus.landing,
      clearUser: true,
      isLoading: false,
    );
  }

  /// Open Auth / Login view
  void goToLogin() {
    state = state.copyWith(viewStatus: AuthViewStatus.login, clearError: true);
  }

  /// Return to Landing (Home) on web, or Auth screen on native mobile
  void goToLanding() {
    state = state.copyWith(
      viewStatus: isNativeMobileDevice
          ? AuthViewStatus.login
          : AuthViewStatus.landing,
      clearError: true,
    );
  }

  /// Navigate to Features page
  void goToFeatures() {
    state = state.copyWith(
      viewStatus: AuthViewStatus.features,
      clearError: true,
    );
  }

  /// Navigate to How it Works page
  void goToHowItWorks() {
    state = state.copyWith(
      viewStatus: AuthViewStatus.howItWorks,
      clearError: true,
    );
  }

  /// Navigate to FAQ section on Home page
  void goToFaq() {
    state = state.copyWith(
      viewStatus: AuthViewStatus.faq,
      clearError: true,
    );
  }

  /// Navigate to Downloads page
  void goToDownloads() {
    state = state.copyWith(
      viewStatus: AuthViewStatus.downloads,
      clearError: true,
    );
  }

  /// Navigate to Dashboard view
  void goToDashboard() {
    state = state.copyWith(
      viewStatus: state.user != null
          ? AuthViewStatus.authenticated
          : AuthViewStatus.guestMode,
      clearError: true,
    );
  }

  /// Tapping "Log in with Google" (Android native sign-in or manual invocation)
  Future<void> continueWithGoogle() async {
    if (kIsWeb) {
      // GIS requires its own rendered button for interactive authentication.
      goToLogin();
      return;
    }
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final account = await googleService.signIn();
      if (account != null) {
        final auth = await account.authentication;
        final idToken = auth.idToken;

        if (idToken != null && idToken.isNotEmpty) {
          await _exchangeGoogleIdToken(idToken);
          return;
        }
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Could not obtain Google ID token.',
        );
        return;
      }
      // Cancelled by user
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Google Sign-In failed: ${e.toString()}',
      );
    }
  }

  Future<void> _exchangeGoogleIdToken(
    String idToken, {
    String? accessToken,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await repository.authenticateWithGoogleToken(
        idToken,
        accessToken: accessToken,
      );
      state = state.copyWith(
        isLoading: false,
        viewStatus: AuthViewStatus.authenticated,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Authentication failed. Please try again.',
      );
    }
  }

  /// Tapping "Continue as Guest" — routes directly to Dashboard in guest mode
  /// without creating a fake registered user profile.
  void continueAsGuest() {
    state = state.copyWith(
      viewStatus: AuthViewStatus.guestMode,
      clearUser: true,
      clearError: true,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await repository.signOut();
    state = const AuthState(viewStatus: AuthViewStatus.landing);
  }

  /// Delete the current authenticated user's account
  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await repository.deleteAccount();
      state = const AuthState(viewStatus: AuthViewStatus.landing);
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: msg);
      rethrow;
    }
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }
}
