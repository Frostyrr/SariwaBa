import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../models/auth/user_model.dart';
import '../../services/auth/auth_service.dart';
import '../../services/auth/google_sign_in_service.dart';
import 'auth_state.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final repository = ref.watch(authServiceProvider);
  final googleService = ref.watch(googleSignInServiceProvider);
  return AuthController(
    repository: repository,
    googleService: googleService,
  );
});

class AuthController extends StateNotifier<AuthState> {
  final AuthService repository;
  final GoogleSignInService googleService;
  StreamSubscription<GoogleSignInAccount?>? _eventSub;

  AuthController({
    required this.repository,
    required this.googleService,
  }) : super(const AuthState(viewStatus: AuthViewStatus.initializing)) {
    _init();
  }

  void _init() {
    _eventSub = googleService.onCurrentUserChanged.listen(
      _handleUserChanged,
      onError: (err) {
        debugPrint('Google Sign-In stream error: $err');
      },
    );
    bootstrap();
  }

  Future<void> _handleUserChanged(GoogleSignInAccount? account) async {
    if (account != null) {
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken != null && idToken.isNotEmpty) {
        await _exchangeGoogleIdToken(idToken);
      }
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
      viewStatus: AuthViewStatus.landing,
      user: null,
      isLoading: false,
    );
  }

  /// Open Auth / Login view
  void goToLogin() {
    state = state.copyWith(
      viewStatus: AuthViewStatus.login,
      clearError: true,
    );
  }

  /// Return to Landing (Home)
  void goToLanding() {
    state = state.copyWith(
      viewStatus: AuthViewStatus.landing,
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
      viewStatus: AuthViewStatus.authenticated,
      clearError: true,
    );
  }

  /// Tapping "Log in with Google" (Android native sign-in or manual invocation)
  Future<void> continueWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      var account = await googleService.signIn();
      if (account != null) {
        var auth = await account.authentication;
        var idToken = auth.idToken;

        // Web fallback: GIS sometimes populates tokens after silent refresh
        if (kIsWeb && (idToken == null || idToken.isEmpty)) {
          account = await googleService.signInSilently(reAuthenticate: true);
          if (account != null) {
            auth = await account.authentication;
            idToken = auth.idToken;
          }
        }

        if (idToken != null && idToken.isNotEmpty) {
          await _exchangeGoogleIdToken(idToken);
          return;
        } else {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'Could not obtain Google ID token.',
          );
          return;
        }
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

  Future<void> _exchangeGoogleIdToken(String idToken) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await repository.authenticateWithGoogleToken(idToken);
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

  /// Tapping "Continue as Guest"
  void continueAsGuest() {
    state = state.copyWith(
      viewStatus: AuthViewStatus.guestMode,
      user: const UserModel(
        id: 'guest-trial',
        email: 'guest@sariwaba.ph',
        firstName: 'Guest',
        lastName: 'Evaluator',
        isGuest: true,
        isRegistered: false,
      ),
      clearError: true,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await repository.signOut();
    state = const AuthState(viewStatus: AuthViewStatus.landing);
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }
}
