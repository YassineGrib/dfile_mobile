import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_icons.dart';
import '../../clients/data/data.dart';
import '../../projects/data/data.dart';
import '../calendar_views_strings.dart';
import '../data/calendar_events.dart';
import '../data/calendar_scope.dart';
import '../data/milestone.dart';

/// Milestone dot indicator rendered on project Gantt rows.
class CalendarMilestoneDot extends StatelessWidget {
  const CalendarMilestoneDot({super.key, this.milestoneId});

  final String? milestoneId;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: milestoneId != null ? ValueKey('milestone_dot_$milestoneId') : null,
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white,
        border: Border.all(color: AppColors.green, width: 3),
      ),
    );
  }
}

/// Project Gantt bar rendered on project rows.
class CalendarProjectBar extends StatelessWidget {
  const CalendarProjectBar({
    super.key,
    required this.project,
    required this.startsBeforeWindow,
  });

  final ProjectItem project;
  final bool startsBeforeWindow;

  static Color barColorForStatus(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.inProgress:
        return AppColors.orange;
      case ProjectStatus.waitingClient:
        return AppColors.purple;
      case ProjectStatus.planned:
        return AppColors.statusPlanned;
      case ProjectStatus.completed:
      case ProjectStatus.delivered:
        return AppColors.green;
      case ProjectStatus.cancelled:
        return AppColors.mute;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('project_bar_${project.id}'),
      height: 26,
      decoration: BoxDecoration(
        color: barColorForStatus(project.status),
        borderRadius: BorderRadius.circular(13),
      ),
      alignment: Alignment.centerLeft,
      child: startsBeforeWindow
          ? const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(
                AppIcons.chevronLeft,
                size: 14,
                color: AppColors.white,
              ),
            )
          : null,
    );
  }
}

/// Red 2px vertical Today line spanning timeline rows.
class CalendarTodayLine extends StatelessWidget {
  const CalendarTodayLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('timeline_today_line'),
      width: 2,
      color: AppColors.red,
    );
  }
}

/// Timeline (Gantt) view component per `docs/design/SPEC.md` (CL5).
class CalendarTimelineView extends StatefulWidget {
  const CalendarTimelineView({
    super.key,
    required this.now,
    this.projects,
    this.milestones,
    this.onProjectTap,
    this.clock,
  });

  final DateTime now;
  final List<ProjectItem>? projects;
  final List<Milestone>? milestones;
  final void Function(ProjectItem project)? onProjectTap;
  final DateTime Function()? clock;

  @override
  State<CalendarTimelineView> createState() => _CalendarTimelineViewState();
}

class _CalendarTimelineViewState extends State<CalendarTimelineView> {
  bool _showOngoingOnly = true;

  static bool _isOngoing(ProjectItem p) {
    return p.status != ProjectStatus.completed &&
        p.status != ProjectStatus.delivered &&
        p.status != ProjectStatus.cancelled;
  }

  static String _shortMonth(DateTime date) {
    const List<String> months = <String>[
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
    return months[date.month - 1];
  }

  static String _formatClientName(String name) {
    if (name.isEmpty) return '';
    final List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[1].isNotEmpty) {
      return '${parts[0]} ${parts[1][0]}.';
    }
    return name;
  }

  void _handleProjectTap(ProjectItem project) {
    if (widget.onProjectTap != null) {
      widget.onProjectTap!(project);
    } else {
      context.push('/projects/${project.id}');
    }
  }

  Widget _buildFilterPills(int allCount) {
    return Row(
      children: [
        _buildPill(
          label: CalendarViewsStrings.ongoingPill,
          isSelected: _showOngoingOnly,
          onTap: () {
            if (!_showOngoingOnly) {
              setState(() {
                _showOngoingOnly = true;
              });
            }
          },
        ),
        const SizedBox(width: AppSpacing.sm),
        _buildPill(
          label: CalendarViewsStrings.allPill(allCount),
          isSelected: !_showOngoingOnly,
          onTap: () {
            if (_showOngoingOnly) {
              setState(() {
                _showOngoingOnly = false;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? AppColors.ink : AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        side: BorderSide(
          color: isSelected ? AppColors.ink : AppColors.line,
          width: AppSpacing.borderWidth,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGanttCard({
    required List<ProjectItem> displayedProjects,
    required Map<String, String> clientNames,
    required List<Milestone> allMilestones,
    required TimelineWindow window,
    required DateTime effectiveNow,
  }) {
    const double labelColumnWidth = 100.0;
    const double headerHeight = 36.0;
    const double rowHeight = 62.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.line,
          width: AppSpacing.borderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double cardWidth = constraints.maxWidth;
          final double barAreaWidth = math.max(
            80.0,
            cardWidth - labelColumnWidth - 1.0,
          );
          final double todayFrac = dayOffsetFraction(window, effectiveNow);
          final double todayX = todayFrac * barAreaWidth;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Month Header Row
              SizedBox(
                height: headerHeight,
                child: Row(
                  children: [
                    const SizedBox(width: labelColumnWidth),
                    Container(width: 1, color: AppColors.line),
                    Expanded(
                      child: SizedBox(
                        height: headerHeight,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Thin vertical month dividers
                            for (int i = 1; i < window.months.length; i++) ...[
                              Positioned(
                                left:
                                    dayOffsetFraction(
                                      window,
                                      window.months[i],
                                    ) *
                                    barAreaWidth,
                                top: 0,
                                bottom: 0,
                                width: 1,
                                child: Container(color: AppColors.line),
                              ),
                            ],
                            // Month Labels
                            for (int i = 0; i < window.months.length; i++) ...[
                              Builder(
                                builder: (BuildContext context) {
                                  final double mStart =
                                      dayOffsetFraction(
                                        window,
                                        window.months[i],
                                      ) *
                                      barAreaWidth;
                                  final double mEnd =
                                      i < window.months.length - 1
                                      ? dayOffsetFraction(
                                              window,
                                              window.months[i + 1],
                                            ) *
                                            barAreaWidth
                                      : barAreaWidth;
                                  final double mWidth = mEnd - mStart;
                                  return Positioned(
                                    left: mStart,
                                    width: mWidth,
                                    top: 0,
                                    bottom: 0,
                                    child: Center(
                                      child: Text(
                                        _shortMonth(window.months[i]),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.mute,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                            // Today line in header
                            Positioned(
                              left: todayX - 1,
                              top: 20,
                              bottom: 0,
                              width: 2,
                              child: const CalendarTodayLine(),
                            ),
                            // Small red Today flag
                            Positioned(
                              left: (todayX - 19).clamp(0.0, barAreaWidth - 38),
                              top: 4,
                              child: Container(
                                key: const ValueKey('timeline_today_flag'),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  CalendarViewsStrings.todayFlag,
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Container(height: 1, color: AppColors.line),

              // 2. Project Rows
              for (int pIdx = 0; pIdx < displayedProjects.length; pIdx++) ...[
                Builder(
                  builder: (BuildContext context) {
                    final ProjectItem project = displayedProjects[pIdx];
                    final String clientName =
                        clientNames[project.clientId] ?? '';

                    // Bar bounds
                    final DateTime startDay = DateTime(
                      project.startDate.year,
                      project.startDate.month,
                      project.startDate.day,
                    );
                    final DateTime endDay = project.endDate != null
                        ? DateTime(
                            project.endDate!.year,
                            project.endDate!.month,
                            project.endDate!.day,
                          )
                        : startDay;
                    final DateTime normalizedEnd = endDay.isBefore(startDay)
                        ? startDay
                        : endDay;

                    final bool liesOutside =
                        normalizedEnd.isBefore(window.startDate) ||
                        startDay.isAfter(window.endDate);
                    final bool startsBefore = startDay.isBefore(
                      window.startDate,
                    );

                    final DateTime clipStart = startsBefore
                        ? window.startDate
                        : startDay;
                    final DateTime clipEnd =
                        normalizedEnd.isAfter(window.endDate)
                        ? window.endDate
                        : normalizedEnd;

                    final double startFrac = dayOffsetFraction(
                      window,
                      clipStart,
                    );
                    final double endFrac = dayOffsetFraction(window, clipEnd);
                    final double barLeft = startFrac * barAreaWidth;
                    final double barRight = endFrac * barAreaWidth;
                    final double barWidth = math.max(16.0, barRight - barLeft);

                    // Milestones for this project inside the window
                    final List<Milestone> pMilestones = allMilestones
                        .where((Milestone m) => m.projectId == project.id)
                        .toList();

                    return Material(
                      color: AppColors.transparent,
                      child: InkWell(
                        onTap: () => _handleProjectTap(project),
                        child: SizedBox(
                          height: rowHeight,
                          child: Row(
                            children: [
                              // Left label column
                              SizedBox(
                                width: labelColumnWidth,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        project.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.ink,
                                          height: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _formatClientName(clientName),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.mute,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(width: 1, color: AppColors.line),
                              // Right bar area
                              Expanded(
                                child: SizedBox(
                                  height: rowHeight,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      // Vertical month dividers
                                      for (
                                        int i = 1;
                                        i < window.months.length;
                                        i++
                                      ) ...[
                                        Positioned(
                                          left:
                                              dayOffsetFraction(
                                                window,
                                                window.months[i],
                                              ) *
                                              barAreaWidth,
                                          top: 0,
                                          bottom: 0,
                                          width: 1,
                                          child: Container(
                                            color: AppColors.line,
                                          ),
                                        ),
                                      ],
                                      // Project bar
                                      if (!liesOutside) ...[
                                        Positioned(
                                          left: barLeft,
                                          width: barWidth,
                                          top: (rowHeight - 26) / 2,
                                          height: 26,
                                          child: CalendarProjectBar(
                                            project: project,
                                            startsBeforeWindow: startsBefore,
                                          ),
                                        ),
                                      ],
                                      // Milestone dots
                                      for (final Milestone m
                                          in pMilestones) ...[
                                        Builder(
                                          builder: (BuildContext context) {
                                            final DateTime mDay = DateTime(
                                              m.date.year,
                                              m.date.month,
                                              m.date.day,
                                            );
                                            if (mDay.isBefore(
                                                  window.startDate,
                                                ) ||
                                                mDay.isAfter(window.endDate)) {
                                              return const SizedBox.shrink();
                                            }
                                            final double mX =
                                                dayOffsetFraction(
                                                  window,
                                                  mDay,
                                                ) *
                                                barAreaWidth;
                                            return Positioned(
                                              left: mX - 6,
                                              top: (rowHeight - 12) / 2,
                                              child: CalendarMilestoneDot(
                                                milestoneId: m.id,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                      // Red Today line
                                      Positioned(
                                        left: todayX - 1,
                                        top: 0,
                                        bottom: 0,
                                        width: 2,
                                        child: const CalendarTodayLine(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (pIdx < displayedProjects.length - 1)
                  Container(height: 1, color: AppColors.line),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegendDot(
                color: AppColors.orange,
                label: CalendarViewsStrings.legendOngoing,
              ),
              _buildLegendDot(
                color: AppColors.purple,
                label: CalendarViewsStrings.legendWaitingClient,
              ),
              _buildLegendDot(
                color: AppColors.statusPlanned,
                label: CalendarViewsStrings.legendPlanned,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white,
                  border: Border.all(color: AppColors.green, width: 2.5),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                CalendarViewsStrings.legendMilestone,
                style: TextStyle(fontSize: 12, color: AppColors.mute),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.mute),
        ),
      ],
    );
  }

  Widget _buildCapacityCard(BuildContext context, CapacityInfo info) {
    return Material(
      key: const ValueKey('timeline_capacity_card'),
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: AppColors.line,
          width: AppSpacing.borderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/calendar/capacity'),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.orangeBg,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    AppIcons.gauge,
                    size: 20,
                    color: AppColors.orange,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      CalendarViewsStrings.capacityTitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CalendarViewsStrings.workloadSubtitle(info.level.label),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.mute,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                AppIcons.chevronRight,
                size: 18,
                color: AppColors.placeholder,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime effectiveNow = widget.clock?.call() ?? widget.now;

    // Resolve repositories/scopes
    final ProjectsScope? projectsScope = context
        .dependOnInheritedWidgetOfExactType<ProjectsScope>();
    final List<ProjectItem> allProjects =
        widget.projects ??
        projectsScope?.notifier?.projects ??
        const <ProjectItem>[];

    final CalendarScope? calendarScope = context
        .dependOnInheritedWidgetOfExactType<CalendarScope>();
    final List<Milestone> allMilestones =
        widget.milestones ??
        calendarScope?.notifier?.milestones ??
        const <Milestone>[];

    final ClientsScope? clientsScope = context
        .dependOnInheritedWidgetOfExactType<ClientsScope>();
    final List<Client> clientsList =
        clientsScope?.notifier?.clients ?? const <Client>[];
    final Map<String, String> clientNames = <String, String>{
      for (final Client c in clientsList) c.id: c.name,
    };

    final TimelineWindow window = timelineWindow(effectiveNow);
    final CapacityInfo info = capacityInfo(allProjects, effectiveNow);

    final List<ProjectItem> displayedProjects = _showOngoingOnly
        ? allProjects.where(_isOngoing).toList()
        : allProjects
              .where((p) => p.status != ProjectStatus.cancelled)
              .toList();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageGutter,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pills
          _buildFilterPills(allProjects.length),
          const SizedBox(height: AppSpacing.md),

          // White card with Gantt or friendly line
          if (displayedProjects.isEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.line,
                  width: AppSpacing.borderWidth,
                ),
              ),
              child: const Center(
                child: Text(
                  CalendarViewsStrings.emptyTimeline,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mute,
                  ),
                ),
              ),
            ),
          ] else ...[
            _buildGanttCard(
              displayedProjects: displayedProjects,
              clientNames: clientNames,
              allMilestones: allMilestones,
              window: window,
              effectiveNow: effectiveNow,
            ),
          ],

          // Legend
          _buildLegend(),

          // Capacity Card
          _buildCapacityCard(context, info),
        ],
      ),
    );
  }
}
