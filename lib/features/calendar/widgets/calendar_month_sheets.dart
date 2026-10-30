import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../projects/data/data.dart';
import '../calendar_month_strings.dart';
import '../calendar_screen.dart';
import '../data/calendar_events.dart';
import '../data/calendar_repository.dart';
import '../data/calendar_scope.dart';
import '../data/milestone.dart';
import 'calendar_event_colors.dart';

/// Shows the Project Deadline / Project Start details sheet per `docs/design/SPEC.md` (CL6).
Future<void> showCalendarDeadlineSheet({
  required BuildContext context,
  required CalendarEvent event,
  DateTime Function()? clock,
}) {
  ProjectsRepository? projectsRepo;
  try {
    projectsRepo = ProjectsScope.of(context, listen: false);
  } catch (_) {}

  final ProjectItem? project = event.projectId != null
      ? projectsRepo?.byId(event.projectId!)
      : null;

  final String clientName = project != null
      ? (projectsRepo?.clientNameOf(project) ?? '')
      : (event.subtitle.isNotEmpty ? event.subtitle : 'Sarah Benali');

  final CalendarEventColors colors = CalendarEventColors.of(event.kind);
  final bool isStart = event.kind == CalendarEventKind.start;
  final String subtitle = isStart
      ? CalendarMonthStrings.projectStart
      : CalendarMonthStrings.projectDeadline;

  return showAppSheet<void>(
    context: context,
    builder: (BuildContext sheetContext) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Icon bubble, Title, Subtitle, Status pill
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.bg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(colors.icon, size: 20, color: colors.fg),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      project?.name ?? event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.mute,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (event.pillText != null && event.pillText!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.bg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    event.pillText!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.fg,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Details Card
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.line,
                width: AppSpacing.borderWidth,
              ),
            ),
            child: Column(
              children: [
                _buildSheetRow(
                  label: CalendarMonthStrings.client,
                  value: clientName.isNotEmpty ? clientName : event.subtitle,
                ),
                const Divider(color: AppColors.line, height: 16),
                _buildSheetRow(
                  label: isStart
                      ? CalendarMonthStrings.startDate
                      : CalendarMonthStrings.dueDate,
                  value: formatShortWeekdayDate(event.date),
                ),
                const Divider(color: AppColors.line, height: 16),
                _buildSheetRow(
                  label: CalendarMonthStrings.status,
                  value: project?.status.label ?? 'Planned',
                ),
                const Divider(color: AppColors.line, height: 16),
                _buildSheetRow(
                  label: CalendarMonthStrings.budget,
                  value: project != null ? formatMoney(project.price) : '0 DZ',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // [Open project] button
          PrimaryButton(
            label: CalendarMonthStrings.openProject,
            onPressed: () {
              Navigator.of(sheetContext).pop();
              if (event.projectId != null) {
                context.push('/projects/${event.projectId}');
              }
            },
          ),
          const SizedBox(height: AppSpacing.sm),

          // [Close] button
          SecondaryButton(
            label: CalendarMonthStrings.close,
            onPressed: () => Navigator.of(sheetContext).pop(),
          ),
        ],
      );
    },
  );
}

/// Shows the Milestone details sheet per `docs/design/SPEC.md` (CL7).
Future<void> showCalendarMilestoneSheet({
  required BuildContext context,
  required String milestoneId,
  DateTime Function()? clock,
}) {
  CalendarRepository? calendarRepo;
  try {
    calendarRepo = CalendarScope.of(context, listen: false);
  } catch (_) {}

  ProjectsRepository? projectsRepo;
  try {
    projectsRepo = ProjectsScope.of(context, listen: false);
  } catch (_) {}

  final Milestone? milestone = calendarRepo?.milestoneById(milestoneId);
  if (milestone == null) {
    return Future<void>.value();
  }

  final ProjectItem? project = projectsRepo?.byId(milestone.projectId);
  final DateTime now =
      clock?.call() ?? CalendarScreen.globalClock?.call() ?? DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime mDate = DateTime(
    milestone.date.year,
    milestone.date.month,
    milestone.date.day,
  );

  final String pillText;
  final Color pillBg;
  final Color pillFg;

  if (milestone.completed) {
    pillText = CalendarMonthStrings.done;
    pillBg = AppColors.seg;
    pillFg = AppColors.mute;
  } else {
    final int diff = mDate.difference(today).inDays;
    if (diff == 0) {
      pillText = 'Due today';
      pillBg = AppColors.yellowBg;
      pillFg = AppColors.orange;
    } else if (diff > 0) {
      pillText = '${diff}d left';
      pillBg = AppColors.greenBg;
      pillFg = AppColors.green;
    } else {
      pillText = '${diff.abs()}d overdue';
      pillBg = AppColors.redBg;
      pillFg = AppColors.red;
    }
  }

  return showAppSheet<void>(
    context: context,
    builder: (BuildContext sheetContext) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Milestone icon, Title, Subtitle, Status pill
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: milestone.completed
                      ? AppColors.seg
                      : AppColors.greenBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    milestone.completed
                        ? AppIcons.circleCheck
                        : AppIcons.milestone,
                    size: 20,
                    color: milestone.completed
                        ? AppColors.mute
                        : AppColors.green,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      milestone.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      CalendarMonthStrings.milestone,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.mute,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: pillBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  pillText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: pillFg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Details Card
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.line,
                width: AppSpacing.borderWidth,
              ),
            ),
            child: Column(
              children: [
                _buildSheetRow(
                  label: CalendarMonthStrings.project,
                  value: project?.name ?? 'Project',
                ),
                const Divider(color: AppColors.line, height: 16),
                _buildSheetRow(
                  label: CalendarMonthStrings.date,
                  value: formatShortWeekdayDate(milestone.date),
                ),
                const Divider(color: AppColors.line, height: 16),
                _buildSheetRow(
                  label: CalendarMonthStrings.status,
                  value: milestone.completed
                      ? CalendarMonthStrings.done
                      : CalendarMonthStrings.pending,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // [Mark as done] / [Mark as pending] button
          PrimaryButton(
            label: milestone.completed
                ? CalendarMonthStrings.markAsPending
                : CalendarMonthStrings.markAsDone,
            onPressed: () {
              calendarRepo?.toggleMilestone(milestone.id);
              Navigator.of(sheetContext).pop();
              showAppToast(
                context,
                milestone.completed
                    ? CalendarMonthStrings.milestoneMarkedAsPending
                    : CalendarMonthStrings.milestoneMarkedAsDone,
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),

          // Red outlined [Delete milestone] button
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
            child: Material(
              color: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
                side: const BorderSide(
                  color: AppColors.red,
                  width: AppSpacing.borderWidth,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  showCalendarDeleteMilestoneConfirmSheet(
                    context: context,
                    milestone: milestone,
                    projectName: project?.name ?? 'Project',
                  );
                },
                child: Center(
                  child: Text(
                    CalendarMonthStrings.deleteMilestone,
                    style: AppText.button.copyWith(color: AppColors.red),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

/// Shows the Delete Milestone confirmation sheet per `docs/design/SPEC.md` (CL13).
Future<void> showCalendarDeleteMilestoneConfirmSheet({
  required BuildContext context,
  required Milestone milestone,
  required String projectName,
}) {
  CalendarRepository? calendarRepo;
  try {
    calendarRepo = CalendarScope.of(context, listen: false);
  } catch (_) {}

  return showAppSheet<void>(
    context: context,
    builder: (BuildContext confirmContext) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Red trash bubble + Title + Subtitle
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    AppIcons.trash2,
                    size: 22,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      CalendarMonthStrings.deleteMilestone,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.red,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      CalendarMonthStrings.thisActionCannotBeUndone,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Warning box
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.redBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.red.withValues(alpha: 0.2),
                width: AppSpacing.borderWidth,
              ),
            ),
            child: Text(
              CalendarMonthStrings.deleteMilestoneWarning(
                title: milestone.title,
                date: formatShortWeekdayDate(milestone.date),
                project: projectName,
              ),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.red,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // [Confirm delete] button (solid red)
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
            child: Material(
              color: AppColors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  calendarRepo?.deleteMilestone(milestone.id);
                  Navigator.of(confirmContext).pop();
                  showAppToast(context, CalendarMonthStrings.milestoneDeleted);
                },
                child: const Center(
                  child: Text(
                    CalendarMonthStrings.confirmDelete,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // [Cancel] button
          SecondaryButton(
            label: CalendarMonthStrings.cancel,
            onPressed: () => Navigator.of(confirmContext).pop(),
          ),
        ],
      );
    },
  );
}

/// Shows the Jump to Month modal bottom sheet per `docs/design/SPEC.md` (CL15).
Future<void> showCalendarJumpSheet({
  required BuildContext context,
  required DateTime currentShownMonth,
  required List<CalendarEvent> events,
  required DateTime now,
  required ValueChanged<DateTime> onMonthSelected,
}) {
  return showAppSheet<void>(
    context: context,
    builder: (BuildContext sheetContext) {
      return _JumpSheetContent(
        currentShownMonth: currentShownMonth,
        events: events,
        now: now,
        onMonthSelected: (DateTime dt) {
          Navigator.of(sheetContext).pop();
          onMonthSelected(dt);
        },
      );
    },
  );
}

class _JumpSheetContent extends StatefulWidget {
  const _JumpSheetContent({
    required this.currentShownMonth,
    required this.events,
    required this.now,
    required this.onMonthSelected,
  });

  final DateTime currentShownMonth;
  final List<CalendarEvent> events;
  final DateTime now;
  final ValueChanged<DateTime> onMonthSelected;

  @override
  State<_JumpSheetContent> createState() => _JumpSheetContentState();
}

class _JumpSheetContentState extends State<_JumpSheetContent> {
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.currentShownMonth.year;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        const Text(
          CalendarMonthStrings.jumpToMonth,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Year navigation: < 2026 >
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RoundIconButton(
              icon: AppIcons.chevronLeft,
              onPressed: () {
                setState(() {
                  _selectedYear--;
                });
              },
            ),
            Text(
              '$_selectedYear',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            RoundIconButton(
              icon: AppIcons.chevronRight,
              onPressed: () {
                setState(() {
                  _selectedYear++;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // 12 month tiles (4 columns x 3 rows)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.5,
          ),
          itemCount: 12,
          itemBuilder: (BuildContext context, int index) {
            final int month = index + 1;
            final bool isShown =
                _selectedYear == widget.currentShownMonth.year &&
                month == widget.currentShownMonth.month;

            final bool hasEvents = widget.events.any(
              (CalendarEvent e) =>
                  e.date.year == _selectedYear && e.date.month == month,
            );

            return Material(
              color: isShown ? AppColors.ink : AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isShown ? AppColors.ink : AppColors.line,
                  width: AppSpacing.borderWidth,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () =>
                    widget.onMonthSelected(DateTime(_selectedYear, month, 1)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      CalendarMonthStrings.shortMonths[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isShown ? AppColors.white : AppColors.ink,
                      ),
                    ),
                    if (hasEvents) ...[
                      const SizedBox(height: 3),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isShown ? AppColors.orange : AppColors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.xl),

        // [Go to today] button
        SecondaryButton(
          label: CalendarMonthStrings.goToToday,
          onPressed: () => widget.onMonthSelected(
            DateTime(widget.now.year, widget.now.month, widget.now.day),
          ),
        ),
      ],
    );
  }
}

Widget _buildSheetRow({required String label, required String value}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.mute,
          fontWeight: FontWeight.w500,
        ),
      ),
      Flexible(
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
      ),
    ],
  );
}
