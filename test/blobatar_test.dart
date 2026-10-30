import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dfile_mobile/core/widgets/blobatar.dart';
import 'package:dfile_mobile/core/widgets/user_avatar.dart';

void main() {
  final List<dynamic> golden = jsonDecode(
    File('test/fixtures/blobatar_golden.json').readAsStringSync(),
  ) as List<dynamic>;

  test('matches the web generator byte for byte on the golden names', () {
    final List<String> mismatches = <String>[];
    for (final dynamic raw in golden) {
      final Map<String, dynamic> entry = raw as Map<String, dynamic>;
      final String name = entry['name'] as String;
      final String expected = entry['svg'] as String;
      final String actual = blobatarSvg(name, size: 40, title: name);
      if (actual != expected) {
        int i = 0;
        while (i < actual.length &&
            i < expected.length &&
            actual[i] == expected[i]) {
          i++;
        }
        mismatches.add('"$name" differs at $i');
      }
    }
    expect(mismatches, isEmpty);
  });

  test('is deterministic and name dependent', () {
    expect(blobatarSvg('Sarah'), blobatarSvg('Sarah'));
    expect(blobatarSvg('Sarah'), isNot(blobatarSvg('Sarah B')));
    expect(blobatarSvg(' SARAH '), blobatarSvg('sarah'));
  });

  testWidgets('UserAvatar renders an svg at several sizes', (
    WidgetTester tester,
  ) async {
    for (final double size in <double>[24, 40, 54]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: UserAvatar(name: 'Sarah Benali', size: size),
            ),
          ),
        ),
      );
      expect(find.byType(SvgPicture), findsOneWidget);
      expect(tester.getSize(find.byType(UserAvatar)), Size(size, size));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('UserAvatar falls back to User for an empty name', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: UserAvatar(name: '  ')),
      ),
    );
    expect(find.byType(SvgPicture), findsOneWidget);
  });
}
