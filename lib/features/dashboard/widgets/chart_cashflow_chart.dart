import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/theme/theme.dart';
import '../dashboard_charts_strings.dart';
import '../data/dashboard_stats.dart';

const List<String> _shortMonths = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Reusable grouped-bar cashflow chart widget.
///
/// Supports 6 and 12 month groups. Renders rounded-top bars for inflow (green)
/// and outflow (coral), baseline, month labels, and highlights the best-inflow month
/// with strong colours and a dark bubble pill above its bar.
class CashflowChart extends StatelessWidget {
  const CashflowChart({super.key, required this.flows, this.height = 180.0});

  final List<MonthFlow> flows;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (flows.isEmpty) {
      return SizedBox(
        height: height,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: Text(
                  DashboardChartsStrings.noCashMovement,
                  style: AppText.caption.copyWith(color: AppColors.mute),
                ),
              ),
            ),
            Container(height: 1.0, color: AppColors.line),
            const SizedBox(height: 20.0),
          ],
        ),
      );
    }

    final double maxInflow = flows.fold<double>(
      0.0,
      (double m, MonthFlow f) => math.max(m, f.inflow),
    );
    final double maxOutflow = flows.fold<double>(
      0.0,
      (double m, MonthFlow f) => math.max(m, f.outflow),
    );
    final double maxVal = math.max(maxInflow, maxOutflow);
    final bool hasData = maxVal > 0.0;

    int bestIndex = -1;
    if (maxInflow > 0.0) {
      bestIndex = flows.indexWhere((MonthFlow f) => f.inflow == maxInflow);
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final int count = flows.length;
        final double slotWidth = width / count;

        final double barWidth = count > 6
            ? (width >= 300 ? 7.0 : 6.0)
            : (width >= 300 ? 14.0 : 12.0);
        final double barGap = count > 6 ? 2.0 : (width >= 300 ? 4.0 : 3.0);

        const double labelHeight = 20.0;
        const double baselineThickness = 1.0;
        const double topPadding = 28.0;
        final double barAreaHeight = math.max(
          10.0,
          height - labelHeight - baselineThickness - topPadding,
        );
        final double baselineY = topPadding + barAreaHeight;

        Widget? bubbleWidget;
        if (hasData && bestIndex >= 0) {
          final MonthFlow bestFlow = flows[bestIndex];
          final double inflowHeight = math.max(
            3.0,
            (bestFlow.inflow / maxVal) * barAreaHeight,
          );
          final double barTop = baselineY - inflowHeight;
          final double bestCenterX = (bestIndex + 0.5) * slotWidth;
          final double inflowCenterX = bestCenterX - barGap / 2 - barWidth / 2;

          const double bubbleEstimatedWidth = 72.0;
          const double bubbleHeight = 24.0;
          final double bubbleLeft = (inflowCenterX - bubbleEstimatedWidth / 2)
              .clamp(0.0, math.max(0.0, width - bubbleEstimatedWidth));
          final double bubbleTop = math.max(0.0, barTop - bubbleHeight - 6.0);

          bubbleWidget = Positioned(
            left: bubbleLeft,
            top: bubbleTop,
            child: Container(
              height: bubbleHeight,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+${formatAmount(bestFlow.inflow)}',
                style: AppText.captionSm.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  height: 1.0,
                ),
              ),
            ),
          );
        }

        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              // Chart bars and baseline
              CustomPaint(
                size: Size(width, baselineY + baselineThickness),
                painter: CashflowChartPainter(
                  flows: flows,
                  maxVal: maxVal,
                  hasData: hasData,
                  bestIndex: bestIndex,
                  slotWidth: slotWidth,
                  barWidth: barWidth,
                  barGap: barGap,
                  baselineY: baselineY,
                  barAreaHeight: barAreaHeight,
                ),
              ),

              // Empty data message
              if (!hasData)
                Positioned(
                  top: topPadding,
                  left: 0,
                  right: 0,
                  bottom: labelHeight + baselineThickness,
                  child: Center(
                    child: Text(
                      DashboardChartsStrings.noCashMovement,
                      style: AppText.caption.copyWith(color: AppColors.mute),
                    ),
                  ),
                ),

              // Highlight bubble
              ?bubbleWidget,

              // Month labels below the baseline
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: labelHeight,
                child: Row(
                  children: List<Widget>.generate(count, (int i) {
                    final MonthFlow f = flows[i];
                    final String monthName = _shortMonths[f.month.month - 1];
                    final bool isBest = i == bestIndex;

                    return Expanded(
                      child: Center(
                        child: Text(
                          monthName,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: AppText.captionSm.copyWith(
                            fontSize: count > 6 ? 9.5 : 12.0,
                            fontWeight: isBest
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isBest ? AppColors.ink : AppColors.mute,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// CustomPainter rendering grouped bars and baseline for [CashflowChart].
class CashflowChartPainter extends CustomPainter {
  const CashflowChartPainter({
    required this.flows,
    required this.maxVal,
    required this.hasData,
    required this.bestIndex,
    required this.slotWidth,
    required this.barWidth,
    required this.barGap,
    required this.baselineY,
    required this.barAreaHeight,
  });

  final List<MonthFlow> flows;
  final double maxVal;
  final bool hasData;
  final int bestIndex;
  final double slotWidth;
  final double barWidth;
  final double barGap;
  final double baselineY;
  final double barAreaHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = AppColors.line
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw baseline
    canvas.drawLine(
      Offset(0, baselineY),
      Offset(size.width, baselineY),
      linePaint,
    );

    if (!hasData) return;

    final double radiusVal = math.min(barWidth / 2, 4.0);
    final Radius cornerRadius = Radius.circular(radiusVal);

    for (int i = 0; i < flows.length; i++) {
      final MonthFlow flow = flows[i];
      final bool isBest = i == bestIndex;

      final double centerX = (i + 0.5) * slotWidth;
      final double inflowLeft = centerX - barGap / 2 - barWidth;
      final double outflowLeft = centerX + barGap / 2;

      // Inflow bar
      if (flow.inflow > 0.0) {
        final double barH = math.max(
          3.0,
          (flow.inflow / maxVal) * barAreaHeight,
        );
        final double barTop = baselineY - barH;
        final Paint inflowPaint = Paint()
          ..color = isBest ? AppColors.green : AppColors.chartGreenMuted
          ..style = PaintingStyle.fill;

        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(inflowLeft, barTop, barWidth, barH),
            topLeft: cornerRadius,
            topRight: cornerRadius,
          ),
          inflowPaint,
        );
      }

      // Outflow bar
      if (flow.outflow > 0.0) {
        final double barH = math.max(
          3.0,
          (flow.outflow / maxVal) * barAreaHeight,
        );
        final double barTop = baselineY - barH;
        final Paint outflowPaint = Paint()
          ..color = isBest ? AppColors.coral : AppColors.chartCoralMuted
          ..style = PaintingStyle.fill;

        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(outflowLeft, barTop, barWidth, barH),
            topLeft: cornerRadius,
            topRight: cornerRadius,
          ),
          outflowPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CashflowChartPainter oldDelegate) {
    return oldDelegate.flows != flows ||
        oldDelegate.maxVal != maxVal ||
        oldDelegate.bestIndex != bestIndex ||
        oldDelegate.slotWidth != slotWidth ||
        oldDelegate.barWidth != barWidth ||
        oldDelegate.baselineY != baselineY;
  }
}
