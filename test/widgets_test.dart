import 'package:dfile_mobile/core/theme/theme.dart';
import 'package:dfile_mobile/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pageGutter),
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Shared core widgets', () {
    testWidgets('PrimaryButton renders label, leading, and fires onPressed', (
      WidgetTester tester,
    ) async {
      int tapCount = 0;
      await tester.pumpWidget(
        _wrap(
          PrimaryButton(
            label: 'Get started',
            leading: const Icon(Icons.add, key: Key('primary-leading')),
            onPressed: () => tapCount++,
          ),
        ),
      );

      expect(find.text('Get started'), findsOneWidget);
      expect(find.byKey(const Key('primary-leading')), findsOneWidget);

      await tester.tap(find.text('Get started'));
      await tester.pump();
      expect(tapCount, 1);
    });

    testWidgets(
      'SecondaryButton renders Google SVG leading and fires onPressed',
      (WidgetTester tester) async {
        int tapCount = 0;
        await tester.pumpWidget(
          _wrap(
            SecondaryButton(
              label: 'Continue with Google',
              leading: SvgPicture.asset(
                'assets/images/google_g.svg',
                width: 22,
                height: 22,
              ),
              onPressed: () => tapCount++,
            ),
          ),
        );

        expect(find.text('Continue with Google'), findsOneWidget);
        expect(find.byType(SvgPicture), findsOneWidget);

        await tester.tap(find.text('Continue with Google'));
        await tester.pump();
        expect(tapCount, 1);
      },
    );

    testWidgets(
      'AppTextField renders label, placeholder, obscure toggle, and multiline',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _wrap(
            const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  label: 'Password',
                  placeholder: 'Enter password',
                  obscureText: true,
                ),
                SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Notes',
                  placeholder: 'Payment terms...',
                  multiline: true,
                ),
              ],
            ),
          ),
        );

        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Enter password'), findsOneWidget);
        expect(find.text('Notes'), findsOneWidget);
        expect(find.text('Payment terms...'), findsOneWidget);

        EditableText passwordEditable = tester.widget<EditableText>(
          find.byType(EditableText).first,
        );
        expect(passwordEditable.obscureText, isTrue);

        await tester.tap(find.byIcon(Icons.visibility_off_outlined));
        await tester.pump();

        passwordEditable = tester.widget<EditableText>(
          find.byType(EditableText).first,
        );
        expect(passwordEditable.obscureText, isFalse);

        final EditableText notesEditable = tester.widget<EditableText>(
          find.byType(EditableText).last,
        );
        expect(notesEditable.maxLines, 4);
      },
    );

    testWidgets('AppPill renders filled/outline states and fires onTap', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrap(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppPill(label: 'All', selected: true),
              const SizedBox(width: AppSpacing.sm),
              AppPill(
                label: 'Active',
                selected: false,
                onTap: () => tapped = true,
              ),
            ],
          ),
        ),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);

      await tester.tap(find.text('Active'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('RoundIconButton renders 44px circle and fires onPressed', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        _wrap(RoundIconButton(icon: Icons.arrow_back, onPressed: () => taps++)),
      );

      final Size buttonSize = tester.getSize(find.byType(RoundIconButton));
      expect(buttonSize, const Size(44, 44));

      await tester.tap(find.byType(RoundIconButton));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('InitialAvatar renders uppercase initial', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const InitialAvatar(
            initial: 'Mohamed Bachir',
            color: AppColors.orange,
          ),
        ),
      );

      expect(find.text('M'), findsOneWidget);
    });

    testWidgets('StatusPill renders Active and Archived variants', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatusPill.active(),
              SizedBox(width: AppSpacing.sm),
              StatusPill.archived(),
            ],
          ),
        ),
      );

      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Archived'), findsOneWidget);
    });

    testWidgets('SegmentedToggle renders two options and fires onChanged', (
      WidgetTester tester,
    ) async {
      int selected = 0;
      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SegmentedToggle(
                options: const <String>['Quick mode', 'Advanced mode'],
                selectedIndex: selected,
                onChanged: (int value) => setState(() => selected = value),
              );
            },
          ),
        ),
      );

      expect(find.text('Quick mode'), findsOneWidget);
      expect(find.text('Advanced mode'), findsOneWidget);

      await tester.tap(find.text('Advanced mode'));
      await tester.pump();
      expect(selected, 1);
    });

    testWidgets('MascotPanel renders coloured container with mascot image', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const MascotPanel(color: AppColors.yellow, height: 220)),
      );

      expect(find.byType(MascotPanel), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(tester.getSize(find.byType(MascotPanel)).height, 220);
    });

    testWidgets('showAppSheet opens AppBottomSheet with grabber and content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return Center(
                  child: PrimaryButton(
                    label: 'Open sheet',
                    onPressed: () {
                      showAppSheet<void>(
                        context: context,
                        builder: (BuildContext _) => const Text('Sort by'),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open sheet'));
      await tester.pumpAndSettle();

      expect(find.byType(AppBottomSheet), findsOneWidget);
      expect(find.text('Sort by'), findsOneWidget);
    });

    testWidgets('showAppToast renders AppToast and auto-dismisses', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return Center(
                  child: PrimaryButton(
                    label: 'Show toast',
                    onPressed: () {
                      showAppToast(
                        context,
                        'Client deleted successfully',
                        duration: const Duration(milliseconds: 500),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show toast'));
      await tester.pump();

      expect(find.byType(AppToast), findsOneWidget);
      expect(find.text('Client deleted successfully'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(AppToast), findsNothing);
    });

    testWidgets(
      'AppTabBar renders 5 tabs with Clients active and fires onTap',
      (WidgetTester tester) async {
        int? tappedTab;
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              bottomNavigationBar: AppTabBar(
                onTap: (int index) => tappedTab = index,
              ),
            ),
          ),
        );

        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Projects'), findsOneWidget);
        expect(find.text('Clients'), findsOneWidget);
        expect(find.text('Payments'), findsOneWidget);
        expect(find.text('Expenses'), findsOneWidget);

        final Text clientsLabel = tester.widget<Text>(find.text('Clients'));
        expect(clientsLabel.style?.fontWeight, FontWeight.w700);

        await tester.tap(find.text('Projects'));
        await tester.pump();
        expect(tappedTab, 1);
      },
    );
  });
}
