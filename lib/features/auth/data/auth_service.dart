import 'dart:async';

import 'package:flutter/widgets.dart';

/// Signed-in user as the UI sees it, independent of Firebase types.
class AuthUser {
  const AuthUser({required this.uid, required this.email, this.displayName});

  final String uid;
  final String email;
  final String? displayName;
}

/// Outcome of an auth call: either a [user] or a readable [error].
class AuthResult {
  const AuthResult.ok([this.user]) : error = null;
  const AuthResult.failure(String this.error) : user = null;

  final AuthUser? user;
  final String? error;

  bool get isOk => error == null;
}

/// Auth operations the screens need. Firebase backs the real app; tests and
/// previews use [FakeAuthService].
abstract class AuthService {
  AuthUser? get currentUser;

  Stream<AuthUser?> get authStateChanges;

  Future<AuthResult> signInWithEmail(
    String email,
    String password, {
    bool remember = true,
  });

  Future<AuthResult> signUp(String email, String password, {String? fullName});

  Future<AuthResult> signInWithGoogle();

  Future<AuthResult> sendPasswordReset(String email);

  Future<AuthResult> changePassword(String currentPassword, String newPassword);

  Future<AuthResult> updateDisplayName(String name);

  /// Re-authenticates with [password] when given, then deletes the account.
  Future<AuthResult> deleteAccount({String? password});

  Future<void> signOut();
}

/// Accepts any credentials; keeps the UI usable without Firebase.
class FakeAuthService implements AuthService {
  FakeAuthService({this._user, this.password = 'demo123'});

  /// Current password the fake accepts for change-password and delete.
  final String password;

  AuthUser? _user;
  final StreamController<AuthUser?> _controller =
      StreamController<AuthUser?>.broadcast();

  void _set(AuthUser? user) {
    _user = user;
    _controller.add(user);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Stream<AuthUser?> get authStateChanges => _controller.stream;

  @override
  Future<AuthResult> signInWithEmail(
    String email,
    String password, {
    bool remember = true,
  }) async {
    _set(AuthUser(uid: 'fake_uid', email: email));
    return AuthResult.ok(_user);
  }

  @override
  Future<AuthResult> signUp(
    String email,
    String password, {
    String? fullName,
  }) async {
    _set(AuthUser(uid: 'fake_uid', email: email, displayName: fullName));
    return AuthResult.ok(_user);
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    _set(
      const AuthUser(
        uid: 'fake_google_uid',
        email: 'demo@dfile.app',
        displayName: 'Demo User',
      ),
    );
    return AuthResult.ok(_user);
  }

  @override
  Future<AuthResult> sendPasswordReset(String email) async =>
      const AuthResult.ok();

  @override
  Future<AuthResult> changePassword(
    String currentPassword,
    String newPassword,
  ) async => currentPassword == password
      ? const AuthResult.ok()
      : const AuthResult.failure('Invalid credentials.');

  @override
  Future<AuthResult> updateDisplayName(String name) async =>
      const AuthResult.ok();

  @override
  Future<AuthResult> deleteAccount({String? password}) async {
    if (password != this.password) {
      return const AuthResult.failure('Invalid credentials.');
    }
    _set(null);
    return const AuthResult.ok();
  }

  @override
  Future<void> signOut() async => _set(null);
}

/// Provides the [AuthService] to the widget tree.
class AuthScope extends InheritedWidget {
  const AuthScope({super.key, required this.service, required super.child});

  final AuthService service;

  static AuthService of(BuildContext context) {
    final AuthScope? scope = context.getInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'No AuthScope found in context');
    return scope!.service;
  }

  @override
  bool updateShouldNotify(AuthScope oldWidget) => service != oldWidget.service;
}
