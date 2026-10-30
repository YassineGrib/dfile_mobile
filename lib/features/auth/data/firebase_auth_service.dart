import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_service.dart';

/// Web client id of the `fintask-app` project (type 3 in google-services.json).
const String _googleServerClientId =
    '401380699771-nv16m7b9p3obra84qudiu2pf6v96u12e.apps.googleusercontent.com';

/// [AuthService] backed by Firebase Auth, the same project the web app uses.
class FirebaseAuthService implements AuthService {
  FirebaseAuthService({fb.FirebaseAuth? auth})
    : _auth = auth ?? fb.FirebaseAuth.instance;

  final fb.FirebaseAuth _auth;
  bool _googleReady = false;

  static AuthUser? _map(fb.User? user) => user == null
      ? null
      : AuthUser(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
        );

  @override
  AuthUser? get currentUser => _map(_auth.currentUser);

  @override
  Stream<AuthUser?> get authStateChanges => _auth.authStateChanges().map(_map);

  @override
  Future<AuthResult> signInWithEmail(
    String email,
    String password, {
    bool remember = true,
  }) async {
    try {
      final fb.UserCredential res = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthResult.ok(_map(res.user));
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult.failure(authErrorMessage(e.code, e.message));
    }
  }

  @override
  Future<AuthResult> signUp(
    String email,
    String password, {
    String? fullName,
  }) async {
    try {
      final fb.UserCredential res = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (fullName != null && fullName.isNotEmpty) {
        try {
          await res.user?.updateDisplayName(fullName);
          await res.user?.reload();
        } on fb.FirebaseAuthException {
          // Account exists; the name can be edited later in Settings.
        }
      }
      return AuthResult.ok(_map(_auth.currentUser ?? res.user));
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult.failure(authErrorMessage(e.code, e.message));
    }
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    try {
      if (!_googleReady) {
        await GoogleSignIn.instance.initialize(
          serverClientId: _googleServerClientId,
        );
        _googleReady = true;
      }
      final GoogleSignInAccount account = await GoogleSignIn.instance
          .authenticate();
      final String? idToken = account.authentication.idToken;
      if (idToken == null) {
        return const AuthResult.failure('Google sign-in failed. Try again.');
      }
      final fb.UserCredential res = await _auth.signInWithCredential(
        fb.GoogleAuthProvider.credential(idToken: idToken),
      );
      return AuthResult.ok(_map(res.user));
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return const AuthResult.failure('Google sign-in was cancelled.');
      }
      return AuthResult.failure('Google sign-in failed. Try again.');
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult.failure(authErrorMessage(e.code, e.message));
    }
  }

  @override
  Future<AuthResult> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return const AuthResult.ok();
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult.failure(authErrorMessage(e.code, e.message));
    }
  }

  @override
  Future<AuthResult> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final fb.User? user = _auth.currentUser;
    if (user == null) return const AuthResult.failure('You are signed out.');
    try {
      final String? email = user.email;
      if (email != null && currentPassword.isNotEmpty) {
        await user.reauthenticateWithCredential(
          fb.EmailAuthProvider.credential(
            email: email,
            password: currentPassword,
          ),
        );
      }
      await user.updatePassword(newPassword);
      return const AuthResult.ok();
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult.failure(authErrorMessage(e.code, e.message));
    }
  }

  @override
  Future<AuthResult> updateDisplayName(String name) async {
    final fb.User? user = _auth.currentUser;
    if (user == null) return const AuthResult.failure('You are signed out.');
    try {
      await user.updateDisplayName(name);
      return const AuthResult.ok();
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult.failure(authErrorMessage(e.code, e.message));
    }
  }

  @override
  Future<AuthResult> deleteAccount({String? password}) async {
    final fb.User? user = _auth.currentUser;
    if (user == null) return const AuthResult.failure('You are signed out.');
    try {
      final String? email = user.email;
      if (email != null && password != null && password.isNotEmpty) {
        await user.reauthenticateWithCredential(
          fb.EmailAuthProvider.credential(email: email, password: password),
        );
      }
      await user.delete();
      return const AuthResult.ok();
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult.failure(authErrorMessage(e.code, e.message));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Not signed in with Google, or the plugin is not initialised.
    }
    await _auth.signOut();
  }
}

/// Maps a Firebase error code to a message for the user (mirrors the web app).
String authErrorMessage(String code, [String? fallback]) {
  switch (code) {
    case 'email-already-in-use':
      return 'This email address is already registered.';
    case 'invalid-email':
      return 'Invalid email address format.';
    case 'weak-password':
      return 'Password is too weak. Use at least 8 characters.';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'Invalid credentials. Check your email and password.';
    case 'user-disabled':
      return 'This account has been disabled.';
    case 'too-many-requests':
      return 'Too many attempts. Try again in a few minutes.';
    case 'requires-recent-login':
      return 'Please sign in again to do this.';
    case 'network-request-failed':
      return 'Network connection failed. Check your internet connection.';
    case 'operation-not-allowed':
      return 'This sign-in method is not enabled for the project.';
    default:
      return fallback ?? 'Authentication error. Try again.';
  }
}
