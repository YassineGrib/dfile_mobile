import 'package:flutter/material.dart';

import '../motion.dart';
import '../theme/theme.dart';

/// Placeholder cards that pulse while a list is still loading, so the screen
/// never flashes an empty state before the data arrives.
class SkeletonList extends StatefulWidget {
  const SkeletonList({super.key, this.count = 4, this.itemHeight = 96});

  final int count;
  final double itemHeight;

  @override
  State<SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<SkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Durations.extralong1,
  );
  late final Animation<double> _pulse = Tween<double>(begin: 0.55, end: 1)
      .animate(
        CurvedAnimation(parent: _controller, curve: AppMotion.standardCurve),
      );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (!AppMotion.reduced(context)) _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _bar(double widthFactor, double height) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.seg,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading',
      child: FadeTransition(
        opacity: _pulse,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageGutter,
          ),
          child: Column(
            children: <Widget>[
              for (int i = 0; i < widget.count; i++)
                Container(
                  height: widget.itemHeight,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppRadius.cardSmall),
                    border: Border.all(
                      color: AppColors.line,
                      width: AppSpacing.borderWidth,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: AppColors.seg,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _bar(0.6, 12),
                            const SizedBox(height: AppSpacing.sm),
                            _bar(0.35, 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
