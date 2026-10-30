import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:dfile_mobile/core/theme/theme.dart';
import 'package:dfile_mobile/core/widgets/app_tab_bar.dart';
import 'package:dfile_mobile/features/dashboard/dashboard_home_strings.dart';
import 'package:dfile_mobile/features/dashboard/widgets/home_quick_actions.dart';

const List<(String, String)> actions = <(String, String)>[
  (DashboardHomeStrings.recordPayment, '/payments/new'),
  (DashboardHomeStrings.addExpense, '/expenses/new'),
  (DashboardHomeStrings.newProject, '/projects/new'),
  (DashboardHomeStrings.addClient, '/clients/new'),
  (DashboardHomeStrings.newMilestone, '/calendar/new'),
  (DashboardHomeStrings.calendar, '/calendar'),
  (DashboardHomeStrings.friendsDebts, '/friends'),
  (DashboardHomeStrings.settings, '/settings'),
];

GoRouter buildRouter() {
  return GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(AppSpacing.pageGutter),
            child: HomeQuickActions(),
          ),
          bottomNavigationBar: AppTabBar(currentIndex: AppTabBar.homeTabIndex),
        ),
      ),
      for (final String path in <String>[
        ...actions.map(((String, String) a) => a.$2),
        '/payments',
        '/expenses',
        '/home',
        '/projects',
        '/clients',
      ])
        GoRoute(
          path: path,
          builder: (BuildContext context, GoRouterState state) =>
              Scaffold(body: Text('page $path')),
        ),
    ],
  );
}

Future<void> pumpApp(WidgetTester tester, GoRouter router) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    MaterialApp.router(theme: AppTheme.light, routerConfig: router),
  );
  await tester.pump();
}

void main() {
  testWidgets(
    'every quick action is reachable by swiping and opens its route',
    (WidgetTester tester) async {
      for (final (String label, String route) in actions) {
        final GoRouter router = buildRouter();
        await pumpApp(tester, router);

        final Finder card = find.text(label);
        await tester.scrollUntilVisible(
          card,
          120,
          scrollable: find.byType(Scrollable).first,
        );
        expect(card, findsOneWidget, reason: label);
        await tester.ensureVisible(card);
        await tester.pumpAndSettle();
        await tester.tap(card);
        await tester.pumpAndSettle();
        expect(router.state.uri.toString(), route, reason: 'tapping $label');
      }
    },
  );

  testWidgets('cards share one size and the row scrolls horizontally', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, buildRouter());

    final Size first = tester.getSize(
      find
          .ancestor(
            of: find.text(DashboardHomeStrings.recordPayment),
            matching: find.byType(SizedBox),
          )
          .first,
    );
    expect(first.width, HomeQuickActions.cardWidth);
    expect(first.height, HomeQuickActions.cardHeight);

    final Finder list = find.byType(ListView);
    expect(tester.widget<ListView>(list).scrollDirection, Axis.horizontal);
    // The last card is not on screen until the row is swiped.
    final Finder last = find.text(DashboardHomeStrings.settings);
    expect(last, findsNothing);
    await tester.scrollUntilVisible(
      last,
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.getTopLeft(last).dx, lessThan(390));
    expect(tester.takeException(), isNull);
  });

  testWidgets('bottom bar shows the five main sections and navigates', (
    WidgetTester tester,
  ) async {
    final GoRouter router = buildRouter();
    await pumpApp(tester, router);

    for (final String label in AppTabBar.labels) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(AppTabBar.labels, <String>[
      'Home',
      'Projects',
      'Clients',
      'Payments',
      'Expenses',
    ]);
    expect(find.text('More'), findsNothing);

    await tester.tap(find.text('Payments'));
    await tester.pumpAndSettle();
    expect(router.state.uri.toString(), '/payments');

    router.go('/');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Expenses'));
    await tester.pumpAndSettle();
    expect(router.state.uri.toString(), '/expenses');
  });
}
