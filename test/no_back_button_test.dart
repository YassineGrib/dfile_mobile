import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The app has no on-screen back buttons: people go back with the system
/// back button or gesture. This keeps one from creeping back in.
void main() {
  test('no screen draws a back arrow or BackButton', () {
    final RegExp backArrow = RegExp(
      r'icon:\s*(?:Icons\.arrow_back|AppIcons\.arrowLeft)\b|BackButton\(',
    );
    final List<String> offenders = <String>[];
    for (final FileSystemEntity f in Directory(
      'lib/features',
    ).listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      // The invisible 1x1 hook in AddFriendScreen is not a visible button.
      if (f.path.endsWith('add_friend_screen.dart')) continue;
      if (backArrow.hasMatch(f.readAsStringSync())) offenders.add(f.path);
    }
    expect(offenders, isEmpty);
  });
}
