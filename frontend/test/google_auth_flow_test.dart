import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/auth/auth_controller.dart';
import 'package:frontend/controllers/auth/auth_state.dart';
import 'package:frontend/models/auth/user_model.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:frontend/services/auth/google_sign_in_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FakeCredentials implements GoogleSignInAuthentication {
  @override
  final String? idToken;
  FakeCredentials(this.idToken);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAccount implements GoogleSignInAccount {
  final String? token;
  FakeAccount(this.token);
  @override
  Future<GoogleSignInAuthentication> get authentication async =>
      FakeCredentials(token);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeGoogleService implements GoogleSignInService {
  final events = StreamController<GoogleSignInAccount?>.broadcast();
  GoogleSignInAccount? account = FakeAccount('google-id-token');
  int signInCalls = 0;
  @override
  Stream<GoogleSignInAccount?> get onCurrentUserChanged => events.stream;
  @override
  Future<GoogleSignInAccount?> signIn() async {
    signInCalls++;
    events.add(account);
    return account;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeRepository implements AuthService {
  final tokens = <String>[];
  bool reject = false;
  Completer<UserModel?>? profile;
  @override
  Future<UserModel?> getProfile() async => profile?.future;
  @override
  Future<UserModel> authenticateWithGoogleToken(
    String idToken, {
    String? accessToken,
  }) async {
    tokens.add(idToken);
    if (reject) throw Exception('Backend rejected token');
    return const UserModel(id: 'user-1', email: 'user@example.com');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeGoogleService google;
  late FakeRepository repository;
  late AuthController controller;

  setUp(() async {
    google = FakeGoogleService();
    repository = FakeRepository();
    controller = AuthController(repository: repository, googleService: google);
    await Future<void>.delayed(Duration.zero);
  });
  tearDown(() async {
    controller.dispose();
    await google.events.close();
  });

  test('web entry opens login without invoking deprecated signIn', () async {
    await controller.continueWithGoogle();
    expect(google.signInCalls, kIsWeb ? 0 : 1);
    expect(
      controller.state.viewStatus,
      kIsWeb ? AuthViewStatus.login : AuthViewStatus.authenticated,
    );
    expect(repository.tokens, kIsWeb ? isEmpty : ['google-id-token']);
  });

  Future<void> authenticate() async {
    if (kIsWeb) {
      google.events.add(google.account);
    } else {
      await controller.continueWithGoogle();
    }
    await Future<void>.delayed(Duration.zero);
  }

  test('credential exchanges once despite native account event', () async {
    await authenticate();
    expect(repository.tokens, ['google-id-token']);
    expect(controller.state.isAuthenticated, isTrue);
    expect(controller.state.isLoading, isFalse);
  });

  test('missing ID token does not call backend', () async {
    google.account = FakeAccount(null);
    await authenticate();
    expect(repository.tokens, isEmpty);
    expect(controller.state.errorMessage, contains('Google ID token'));
    expect(controller.state.isLoading, isFalse);
  });

  test('backend rejection leaves retryable login error', () async {
    repository.reject = true;
    await authenticate();
    expect(controller.state.isAuthenticated, isFalse);
    expect(controller.state.errorMessage, contains('Authentication failed'));
    expect(controller.state.isLoading, isFalse);
  });

  test('web stream errors are surfaced', () async {
    if (!kIsWeb) return;
    google.events.addError(Exception('Google failed'));
    await Future<void>.delayed(Duration.zero);
    expect(controller.state.errorMessage, contains('Google Sign-In failed'));
    expect(controller.state.isLoading, isFalse);
  });

  test(
    'web credential waits for bootstrap before establishing session',
    () async {
      if (!kIsWeb) return;
      controller.dispose();
      repository.profile = Completer<UserModel?>();
      controller = AuthController(
        repository: repository,
        googleService: google,
      );
      google.events.add(google.account);
      await Future<void>.delayed(Duration.zero);
      expect(repository.tokens, isEmpty);
      repository.profile!.complete(null);
      await Future<void>.delayed(Duration.zero);
      expect(controller.state.isAuthenticated, isTrue);
    },
  );
}
