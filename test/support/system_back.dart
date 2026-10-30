import 'package:flutter_test/flutter_test.dart';

/// Presses the Android system back button (or does the back gesture).
///
/// The screens have no on-screen back button, so tests that used to tap one go
/// back this way instead.
Future<void> systemBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}
