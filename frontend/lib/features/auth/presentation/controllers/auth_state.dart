import '../../domain/models/user_model.dart';

enum AuthViewStatus {
  landing,
  login,
  authenticated,
  guestMode,
}

class AuthState {
  final AuthViewStatus viewStatus;
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.viewStatus = AuthViewStatus.landing,
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated =>
      viewStatus == AuthViewStatus.authenticated && user != null;

  bool get isGuest =>
      viewStatus == AuthViewStatus.guestMode || (user?.isGuest ?? false);

  AuthState copyWith({
    AuthViewStatus? viewStatus,
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      viewStatus: viewStatus ?? this.viewStatus,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
