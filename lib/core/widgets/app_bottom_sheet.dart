import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Modal bottom sheet container with 36px top corner radius, cream fill, and 60x5 grabber.
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.pageGutter,
      AppSpacing.xl,
      AppSpacing.pageGutter,
      AppSpacing.xxl,
    ),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.panel),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.md),
              Container(
                width: AppSpacing.grabberWidth,
                height: AppSpacing.grabberHeight,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              Flexible(
                child: Padding(padding: padding, child: child),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows a modal bottom sheet styled per `docs/design/SPEC.md` (36px top radius, grabber, 50% ink scrim).
Future<T?> showAppSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    elevation: 0,
    backgroundColor: AppColors.transparent,
    barrierColor: AppColors.scrim,
    builder: (BuildContext sheetContext) =>
        AppBottomSheet(child: builder(sheetContext)),
  );
}
