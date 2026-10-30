import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dfile_mobile/core/sync_status.dart';
import 'package:dfile_mobile/core/widgets/sync_banner.dart';

class _Source extends ChangeNotifier {
  Object? error;

  void fail(Object e) {
    error = e;
    notifyListeners();
  }

  void clear() {
    error = null;
    notifyListeners();
  }
}

void main() {
  test('reports offline from the probe and recovers', () async {
    bool reachable = false;
    final _Source source = _Source();
    final SyncStatus status = SyncStatus(
      sources: <Listenable>[source],
      errorOf: () => source.error,
      probe: () async => reachable,
      interval: const Duration(milliseconds: 20),
    )..start();
    addTearDown(status.dispose);

    await Future<void>.delayed(const Duration(milliseconds: 5));
    expect(status.offline, isTrue);
    expect(status.message, contains('No connection'));

    reachable = true;
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(status.offline, isFalse);
    expect(status.message, isNull);
  });

  test('turns repository errors into a message and clears them', () async {
    final _Source source = _Source();
    final SyncStatus status = SyncStatus(
      sources: <Listenable>[source],
      errorOf: () => source.error,
      probe: () async => true,
    )..start();
    addTearDown(status.dispose);
    await Future<void>.delayed(Duration.zero);

    source.fail('[cloud_firestore/permission-denied] nope');
    expect(status.message, contains('refused'));

    source.fail('boom');
    expect(status.message, contains('could not be synced'));

    source.clear();
    expect(status.message, isNull);
  });

  test('a probe that throws counts as offline', () async {
    final SyncStatus status = SyncStatus(
      sources: const <Listenable>[],
      errorOf: () => null,
      probe: () async => throw Exception('dns'),
    )..start();
    addTearDown(status.dispose);
    await Future<void>.delayed(const Duration(milliseconds: 5));
    expect(status.offline, isTrue);
  });

  testWidgets('the banner appears only when there is a problem', (
    WidgetTester tester,
  ) async {
    final _Source source = _Source();
    final SyncStatus status = SyncStatus(
      sources: <Listenable>[source],
      errorOf: () => source.error,
      probe: () async => true,
      interval: const Duration(hours: 1),
    );
    status.start();

    await tester.pumpWidget(
      MaterialApp(
        home: SyncBanner(
          status: status,
          child: const Scaffold(body: Text('content')),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('content'), findsOneWidget);
    expect(find.textContaining('No connection'), findsNothing);

    source.fail('unavailable');
    await tester.pump();
    expect(find.textContaining('unreachable'), findsOneWidget);
    expect(find.text('content'), findsOneWidget);

    source.clear();
    await tester.pump();
    expect(find.textContaining('unreachable'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    status.dispose();
  });
}
