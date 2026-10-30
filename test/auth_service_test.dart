import 'package:flutter_test/flutter_test.dart';

import 'package:dfile_mobile/features/auth/data/auth_service.dart';
import 'package:dfile_mobile/features/auth/data/firebase_auth_service.dart';

void main() {
  group('FakeAuthService', () {
    test('sign in, sign up and sign out update the current user', () async {
      final FakeAuthService auth = FakeAuthService();
      expect(auth.currentUser, isNull);

      final AuthResult signIn = await auth.signInWithEmail('a@b.co', 'x');
      expect(signIn.isOk, isTrue);
      expect(auth.currentUser?.email, 'a@b.co');

      await auth.signOut();
      expect(auth.currentUser, isNull);

      await auth.signUp('c@d.co', 'password1', fullName: 'Cee');
      expect(auth.currentUser?.displayName, 'Cee');
    });

    test(
      'change password and delete reject a wrong current password',
      () async {
        final FakeAuthService auth = FakeAuthService(password: 'right');
        expect((await auth.changePassword('wrong', 'newpass')).isOk, isFalse);
        expect((await auth.changePassword('right', 'newpass')).isOk, isTrue);
        expect((await auth.deleteAccount(password: 'wrong')).isOk, isFalse);
        await auth.signInWithEmail('a@b.co', 'x');
        expect((await auth.deleteAccount(password: 'right')).isOk, isTrue);
        expect(auth.currentUser, isNull);
      },
    );
  });

  group('authErrorMessage', () {
    test('maps common Firebase codes', () {
      expect(authErrorMessage('email-already-in-use'), contains('registered'));
      expect(authErrorMessage('invalid-credential'), contains('Invalid'));
      expect(authErrorMessage('network-request-failed'), contains('Network'));
      expect(authErrorMessage('unknown', 'raw'), 'raw');
    });
  });
}
