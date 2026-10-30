import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Motion constants for the whole app, taken from the Material 3 tokens so
/// every screen moves with the same rhythm.
abstract final class AppMotion {
  /// Press feedback, small state changes.
  static const Duration fast = Durations.short3;

  /// Colour, size and selection changes.
  static const Duration standard = Durations.medium2;

  /// Content arriving on screen.
  static const Duration entrance = Durations.medium3;

  /// Moving between pages.
  static const Duration page = Durations.medium4;

  /// Extra delay per item of a list that arrives in sequence.
  static const Duration stagger = Duration(milliseconds: 45);

  /// Items past this index arrive together so long lists never feel slow.
  static const int maxStaggerIndex = 8;

  static const Curve standardCurve = Easing.standard;
  static const Curve enterCurve = Easing.emphasizedDecelerate;
  static const Curve exitCurve = Easing.emphasizedAccelerate;

  /// How far content travels while fading in, in logical pixels.
  static const double entranceOffset = 14;

  /// How much a pressed card shrinks.
  static const double pressedScale = 0.97;

  /// True when the system asks for less motion (or tests turn animation off).
  static bool reduced(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);
}

/// Page transitions for routes that need something other than the theme
/// default. Tab destinations fade through, so switching tabs feels like a
/// change of view rather than a forward step.
abstract final class AppPageTransitions {
  static CustomTransitionPage<void> fadeThrough({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: AppMotion.standard,
      reverseTransitionDuration: AppMotion.fast,
      transitionsBuilder:
          (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            final Animation<double> enter = CurvedAnimation(
              parent: animation,
              curve: AppMotion.enterCurve,
            );
            final Animation<double> leave = CurvedAnimation(
              parent: secondaryAnimation,
              curve: AppMotion.exitCurve,
            );
            return FadeTransition(
              opacity: ReverseAnimation(leave),
              child: FadeTransition(
                opacity: enter,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.98, end: 1).animate(enter),
                  child: child,
                ),
              ),
            );
          },
    );
  }
}
