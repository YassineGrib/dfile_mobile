import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../projects/data/project.dart';
import '../../projects/data/projects_repository.dart';
import '../../projects/data/projects_scope.dart';
import '../dashboard_charts_strings.dart';
import '../data/dashboard_stats.dart';
import 'dash_card.dart';

class StatusSlice {
  const StatusSlice({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;
}

/// Dashboard projects by status card with donut chart per HM2 in SPEC.md.
class StatusDonutCard extends StatelessWidget {
  const StatusDonutCard({super.key, this.clock});

  final DateTime Function()? clock;

  @override
  Widget build(BuildContext context) {
    final ProjectsRepository? projectsRepo = context
        .dependOnInheritedWidgetOfExactType<ProjectsScope>()
        ?.notifier;
    final List<ProjectItem> projects =
        projectsRepo?.projects ?? const <ProjectItem>[];

    final Map<ProjectStatus, int> counts = statusCounts(projects);

    final List<StatusSlice> slices = <StatusSlice>[
      StatusSlice(
        label: DashboardChartsStrings.delivered,
        count: counts[ProjectStatus.delivered] ?? 0,
        color: AppColors.green,
      ),
      StatusSlice(
        label: DashboardChartsStrings.completed,
        count: counts[ProjectStatus.completed] ?? 0,
        color: AppColors.statusCompleted,
      ),
      StatusSlice(
        label: DashboardChartsStrings.inProgress,
        count: counts[ProjectStatus.inProgress] ?? 0,
        color: AppColors.purple,
      ),
      StatusSlice(
        label: DashboardChartsStrings.waitingClient,
        count: counts[ProjectStatus.waitingClient] ?? 0,
        color: AppColors.orange,
      ),
      StatusSlice(
        label: DashboardChartsStrings.planned,
        count: counts[ProjectStatus.planned] ?? 0,
        color: AppColors.statusPlanned,
      ),
    ];

    final int total = slices.fold<int>(
      0,
      (int sum, StatusSlice s) => sum + s.count,
    );

    return DashCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            DashboardChartsStrings.projectsByStatus,
            style: AppText.cardTitle,
          ),
          const SizedBox(height: 20),
          if (total == 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  DashboardChartsStrings.noProjectsYet,
                  style: AppText.bodyMedium.copyWith(color: AppColors.mute),
                ),
              ),
            )
          else
            Row(
              children: <Widget>[
                // Donut chart
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      CustomPaint(
                        size: const Size(120, 120),
                        painter: StatusDonutPainter(
                          slices: slices,
                          total: total,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            '$total',
                            style: AppText.sectionTitleLg.copyWith(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            total == 1
                                ? DashboardChartsStrings.project
                                : DashboardChartsStrings.projects,
                            style: AppText.captionSm.copyWith(
                              color: AppColors.mute,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),

                // Legend
                Expanded(
                  child: Column(
                    children: slices.map((StatusSlice slice) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: slice.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                slice.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.bodyMedium.copyWith(
                                  fontSize: 13,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${slice.count}',
                              style: AppText.bodyBold.copyWith(
                                fontSize: 13,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// CustomPainter rendering donut arcs with small gaps and inner radius ~62%.
class StatusDonutPainter extends CustomPainter {
  const StatusDonutPainter({required this.slices, required this.total});

  final List<StatusSlice> slices;
  final int total;

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0) return;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double outerR = size.width / 2;
    // Inner radius about 62% of outer radius
    final double innerR = outerR * 0.62;
    final double strokeW = outerR - innerR;
    final double midR = (outerR + innerR) / 2;

    final List<StatusSlice> activeSlices = slices
        .where((StatusSlice s) => s.count > 0)
        .toList();

    if (activeSlices.length == 1) {
      final Paint paint = Paint()
        ..color = activeSlices.first.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW;
      canvas.drawCircle(center, midR, paint);
      return;
    }

    const double gapAngle = 0.08; // small gap in radians (~4.5 degrees)
    double startAngle = -math.pi / 2; // start from 12 o'clock

    for (final StatusSlice slice in slices) {
      if (slice.count <= 0) continue;

      final double fraction = slice.count / total;
      final double totalSliceAngle = fraction * 2 * math.pi;
      final double sweepAngle = math.max(0.01, totalSliceAngle - gapAngle);

      final Paint paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: midR),
        startAngle + gapAngle / 2,
        sweepAngle,
        false,
        paint,
      );

      startAngle += totalSliceAngle;
    }
  }

  @override
  bool shouldRepaint(covariant StatusDonutPainter oldDelegate) {
    return oldDelegate.total != total || oldDelegate.slices != slices;
  }
}
