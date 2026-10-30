import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../motion.dart';

/// Fades its child in while it rises a few pixels, once, when it first
/// appears. Give list items their [index] and they arrive one after another.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, required this.child, this.index = 0});

  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduced(context)) return child;
    final Duration delay =
        AppMotion.stagger * math.min(index, AppMotion.maxStaggerIndex);
    final Duration total = AppMotion.entrance + delay;
    final double start = delay.inMilliseconds / total.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: total,
      curve: Interval(start, 1, curve: AppMotion.enterCurve),
      child: child,
      builder: (BuildContext context, double t, Widget? child) {
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - t) * AppMotion.entranceOffset),
            child: child,
          ),
        );
      },
    );
  }
}

/// Shrinks its child slightly while a finger is down on it. It only listens,
/// so taps still reach the button or card inside.
class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.scale = AppMotion.pressedScale,
  });

  final Widget child;
  final double scale;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  void _set(bool value) {
    if (_pressed != value && mounted) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: AppMotion.fast,
        curve: AppMotion.standardCurve,
        child: widget.child,
      ),
    );
  }
}

/// A [SliverChildBuilderDelegate] whose items arrive with [FadeSlideIn].
SliverChildBuilderDelegate entranceDelegate(
  NullableIndexedWidgetBuilder builder, {
  int? childCount,
}) {
  return SliverChildBuilderDelegate((BuildContext context, int index) {
    final Widget? item = builder(context, index);
    return item == null
        ? null
        : FadeSlideIn(
            index: index,
            child: PressScale(child: item),
          );
  }, childCount: childCount);
}

/// A bar that fills from the left to [value] (0..1) with a short animation.
/// It scales instead of resizing, so no layout runs while it moves.
class AnimatedFill extends StatelessWidget {
  const AnimatedFill({
    super.key,
    required this.value,
    required this.color,
    this.radius = 4,
  });

  final double value;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final double target = value.clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: target),
      duration: AppMotion.reduced(context) ? Duration.zero : AppMotion.page,
      curve: AppMotion.enterCurve,
      builder: (BuildContext context, double v, Widget? child) {
        return Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: v,
            heightFactor: 1,
            child: child,
          ),
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
