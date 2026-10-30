import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Dark pill toast with a green check circle, matching screen C6.
class AppToast extends StatelessWidget {
  const AppToast({super.key, required this.message});

  final String message;

  /// Displays [AppToast] above the current screen via [Overlay] and auto-dismisses after [duration].
  static VoidCallback show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    double bottomOffset = 100,
  }) {
    return showAppToast(
      context,
      message,
      duration: duration,
      bottomOffset: bottomOffset,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 16,
                color: AppColors.white,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Flexible(
              child: Text(
                message,
                style: AppText.bodyBold.copyWith(
                  fontSize: 16,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Overlay helper that displays an [AppToast] and auto-dismisses after [duration].
///
/// Returns a callback that dismisses the toast early if still mounted.
VoidCallback showAppToast(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
  double bottomOffset = 100,
}) {
  final OverlayState overlay = Overlay.of(context, rootOverlay: true);
  late final OverlayEntry entry;
  bool removed = false;

  void removeEntry() {
    if (removed) {
      return;
    }
    removed = true;
    if (entry.mounted) {
      entry.remove();
    }
  }

  entry = OverlayEntry(
    builder: (BuildContext overlayContext) => _AutoDismissToastHost(
      duration: duration,
      bottomOffset: bottomOffset,
      onDismiss: removeEntry,
      child: AppToast(message: message),
    ),
  );

  overlay.insert(entry);
  return removeEntry;
}

class _AutoDismissToastHost extends StatefulWidget {
  const _AutoDismissToastHost({
    required this.duration,
    required this.bottomOffset,
    required this.onDismiss,
    required this.child,
  });

  final Duration duration;
  final double bottomOffset;
  final VoidCallback onDismiss;
  final Widget child;

  @override
  State<_AutoDismissToastHost> createState() => _AutoDismissToastHostState();
}

class _AutoDismissToastHostState extends State<_AutoDismissToastHost> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, widget.onDismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: AppSpacing.pageGutter,
      right: AppSpacing.pageGutter,
      bottom: widget.bottomOffset,
      child: IgnorePointer(child: Center(child: widget.child)),
    );
  }
}
