import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../data/calendar_events.dart';

/// 3-segment workload gauge with an indicator knob matching CL11.
class CalendarFormsGauge extends StatelessWidget {
  const CalendarFormsGauge({
    super.key,
    required this.level,
    this.height = 20.0,
  });

  final CapacityLevel level;
  final double height;

  @override
  Widget build(BuildContext context) {
    const double barHeight = 8.0;
    const double knobSize = 18.0;
    const double gap = 6.0;

    final Color seg1Color = AppColors.green;
    final Color seg2Color =
        (level == CapacityLevel.moderate || level == CapacityLevel.heavy)
        ? AppColors.orange
        : AppColors.seg;
    final Color seg3Color = level == CapacityLevel.heavy
        ? AppColors.red
        : AppColors.seg;

    final int activeIndex = switch (level) {
      CapacityLevel.light => 0,
      CapacityLevel.moderate => 1,
      CapacityLevel.heavy => 2,
    };

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double totalWidth = constraints.maxWidth;
          final double segmentWidth = (totalWidth - (gap * 2)) / 3;

          final double knobCenterX = switch (activeIndex) {
            0 => segmentWidth / 2,
            1 => segmentWidth + gap + (segmentWidth / 2),
            _ => (segmentWidth * 2) + (gap * 2) + (segmentWidth / 2),
          };

          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              // 3-segment track
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: seg1Color,
                        borderRadius: BorderRadius.circular(barHeight / 2),
                      ),
                    ),
                  ),
                  const SizedBox(width: gap),
                  Expanded(
                    child: Container(
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: seg2Color,
                        borderRadius: BorderRadius.circular(barHeight / 2),
                      ),
                    ),
                  ),
                  const SizedBox(width: gap),
                  Expanded(
                    child: Container(
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: seg3Color,
                        borderRadius: BorderRadius.circular(barHeight / 2),
                      ),
                    ),
                  ),
                ],
              ),

              // Knob
              Positioned(
                left: knobCenterX - (knobSize / 2),
                top: (height - knobSize) / 2,
                child: Container(
                  width: knobSize,
                  height: knobSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white,
                    border: Border.all(color: AppColors.ink, width: 3.0),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
