import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:dfile_mobile/core/motion.dart';
import 'package:dfile_mobile/core/widgets/motion_widgets.dart';

Widget host(Widget child, {bool disableAnimations = false}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Scaffold(body: child),
    ),
  );
}

double opacityOf(WidgetTester tester, Finder inside) => tester
    .widget<Opacity>(
      find.ancestor(of: inside, matching: find.byType(Opacity)).first,
    )
    .opacity;

void main() {
  group('FadeSlideIn', () {
    testWidgets('starts hidden and low, then settles in place', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const Center(child: FadeSlideIn(child: Text('card')))),
      );
      final Finder text = find.text('card');
      final double startY = tester.getTopLeft(text).dy;
      expect(opacityOf(tester, text), 0);

      await tester.pump(AppMotion.entrance ~/ 2);
      expect(opacityOf(tester, text), inExclusiveRange(0, 1));

      await tester.pumpAndSettle();
      expect(opacityOf(tester, text), 1);
      expect(tester.getTopLeft(text).dy, lessThan(startY));
    });

    testWidgets('later items start later than the first', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const Column(
            children: <Widget>[
              FadeSlideIn(index: 0, child: Text('first')),
              FadeSlideIn(index: 5, child: Text('sixth')),
            ],
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 120));
      expect(
        opacityOf(tester, find.text('first')),
        greaterThan(opacityOf(tester, find.text('sixth'))),
      );
      await tester.pumpAndSettle();
      expect(opacityOf(tester, find.text('sixth')), 1);
    });

    testWidgets('shows the child at once when animations are off', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const FadeSlideIn(child: Text('card')), disableAnimations: true),
      );
      expect(find.byType(Opacity), findsNothing);
      expect(find.text('card'), findsOneWidget);
    });
  });

  group('PressScale', () {
    testWidgets(
      'shrinks while pressed, recovers, and still lets taps through',
      (WidgetTester tester) async {
        int taps = 0;
        await tester.pumpWidget(
          host(
            Center(
              child: PressScale(
                child: ElevatedButton(
                  onPressed: () => taps++,
                  child: const Text('go'),
                ),
              ),
            ),
          ),
        );
        double scale() =>
            tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;

        expect(scale(), 1);
        final TestGesture gesture = await tester.startGesture(
          tester.getCenter(find.text('go')),
        );
        await tester.pump();
        expect(scale(), AppMotion.pressedScale);

        await gesture.up();
        await tester.pumpAndSettle();
        expect(scale(), 1);
        expect(taps, 1);
      },
    );

    testWidgets('a cancelled press also recovers', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const Center(child: PressScale(child: Text('x')))),
      );
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.text('x')),
      );
      await tester.pump();
      await gesture.cancel();
      await tester.pumpAndSettle();
      expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
    });
  });

  testWidgets('entranceDelegate wraps list items', (WidgetTester tester) async {
    await tester.pumpWidget(
      host(
        CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: entranceDelegate(
                (BuildContext context, int i) => Text('item $i'),
                childCount: 3,
              ),
            ),
          ],
        ),
      ),
    );
    expect(find.byType(FadeSlideIn), findsNWidgets(3));
    expect(find.byType(PressScale), findsNWidgets(3));
    await tester.pumpAndSettle();
    expect(find.text('item 2'), findsOneWidget);
  });

  testWidgets('tab pages fade through', (WidgetTester tester) async {
    final GoRouter router = GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              AppPageTransitions.fadeThrough(
                key: state.pageKey,
                child: const Scaffold(body: Text('one')),
              ),
        ),
        GoRoute(
          path: '/two',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              AppPageTransitions.fadeThrough(
                key: state.pageKey,
                child: const Scaffold(body: Text('two')),
              ),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(find.text('one'), findsOneWidget);

    router.go('/two');
    await tester.pump();
    await tester.pump(AppMotion.fast);
    expect(find.text('two'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('one'), findsNothing);
    expect(find.text('two'), findsOneWidget);
  });
}
