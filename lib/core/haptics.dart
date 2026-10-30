import 'dart:async';

import 'package:flutter/services.dart';

/// Light physical feedback for taps that matter. It never throws, so it is
/// safe on devices (and in tests) with no vibration motor.
abstract final class AppHaptics {
  /// Moving between tabs, toggling a switch, picking an option.
  static void selection() => _run(HapticFeedback.selectionClick);

  /// Pressing a primary button or card.
  static void light() => _run(HapticFeedback.lightImpact);

  /// A change that was saved.
  static void success() => _run(HapticFeedback.mediumImpact);

  static void _run(Future<void> Function() feedback) {
    unawaited(feedback().catchError((Object _) {}));
  }
}
