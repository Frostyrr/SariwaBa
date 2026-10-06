import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_model.dart';
import 'auth_state.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController();
});

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(const AuthState());

  /// Open Resend-style Auth / Login view
  void goToLogin() {
    state = state.copyWith(
      viewStatus: AuthViewStatus.login,
      clearError: true,
    );
  }

  /// Return to Landing
  void goToLanding() {
    state = const AuthState();
  }

  /// Tapping "Log in with Google"
  Future<void> continueWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future.delayed(const Duration(milliseconds: 600));

    state = state.copyWith(
      isLoading: false,
      viewStatus: AuthViewStatus.authenticated,
      user: const UserModel(
        id: 'usr-google-8821',
        email: 'seafood.grader@gmail.com',
        firstName: 'Juan',
        lastName: 'Dela Cruz',
        username: 'juandc',
        isGuest: false,
        isRegistered: true,
      ),
    );
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
  void signOut() {
    state = const AuthState();
  }
}
