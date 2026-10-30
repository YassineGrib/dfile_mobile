import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

/// 4-step wizard progress indicator matching screens P12..P16.
///
/// Completed steps render a green circle with a white check mark, the active
/// step renders an ink circle with the 1-based step number and bold ink label,
/// and upcoming steps render a neutral `seg` circle with muted label.
class ProjectStepIndicator extends StatelessWidget {
  const ProjectStepIndicator({
    super.key,
    required this.currentStep,
    required this.labels,
  });

  final int currentStep;
  final List<String> labels;

  static const double _circleSize = 30;

  @override
  Widget build(BuildContext context) {
    final int count = labels.length;
    if (count == 0) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double stepWidth = constraints.maxWidth / count;

        return Stack(
          children: [
            if (count > 1)
              Positioned(
                top: (_circleSize - 1.5) / 2,
                left: stepWidth / 2,
                right: stepWidth / 2,
                child: Container(height: 1.5, color: AppColors.line),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List<Widget>.generate(count, (int index) {
                final bool isDone = index < currentStep;
                final bool isCurrent = index == currentStep;

                final Color circleColor = isDone
                    ? AppColors.green
                    : (isCurrent ? AppColors.ink : AppColors.seg);

                final Widget circleChild = isDone
                    ? const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: AppColors.white,
                      )
                    : Text(
                        '${index + 1}',
                        style: AppText.captionSm.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isCurrent ? AppColors.white : AppColors.mute,
                          height: 1,
                        ),
                      );

                return Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: _circleSize,
                        height: _circleSize,
                        decoration: BoxDecoration(
                          color: circleColor,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: circleChild,
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          labels[index],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppText.captionSm.copyWith(
                            color: isCurrent ? AppColors.ink : AppColors.mute,
                            fontWeight: isCurrent
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}
