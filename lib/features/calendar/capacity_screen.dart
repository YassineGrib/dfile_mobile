import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import '../projects/data/data.dart';
import '../settings/data/data.dart';
import 'calendar_forms_strings.dart';
import 'data/data.dart';
import 'widgets/calendar_forms_gauge.dart';

/// Workload capacity and availability screen per `docs/design/SPEC.md` (CL11).
class CapacityScreen extends StatelessWidget {
  const CapacityScreen({
    super.key,
    this.clock,
  });

  final DateTime Function()? clock;

  static DateTime Function() defaultClock = DateTime.now;

  Color _statusProgressColor(ProjectStatus status) {
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
        return AppColors.red;
    }
  }

  Widget _buildWorkloadCard(CapacityInfo info) {
    final (String pillLabel, Color pillBg, Color pillFg) = switch (info.level) {
      CapacityLevel.light => (
          CalendarFormsStrings.lightLevel,
          AppColors.greenBg,
          AppColors.green,
        ),
      CapacityLevel.moderate => (
          CalendarFormsStrings.moderateLevel,
          AppColors.orangeBg,
          AppColors.orange,
        ),
      CapacityLevel.heavy => (
          CalendarFormsStrings.heavyLevel,
          AppColors.redBg,
          AppColors.red,
        ),
    };

    final String countText = info.activeCount == 0
        ? CalendarFormsStrings.noActiveProjects
        : CalendarFormsStrings.activeProjectsCount(info.activeCount);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: AppColors.line,
          width: AppSpacing.borderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                CalendarFormsStrings.workloadLabel,
                style: AppText.caption.copyWith(
                  color: AppColors.mute,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: pillBg,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  pillLabel,
                  style: AppText.captionSm.copyWith(
                    color: pillFg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            countText,
            style: AppText.cardTitle.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          CalendarFormsGauge(level: info.level),
          const SizedBox(height: 14),
          Text(
            info.level.sentence,
            style: AppText.caption.copyWith(
              color: AppColors.mute,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextSlotCard(CapacityInfo info) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: AppColors.line,
          width: AppSpacing.borderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.greenBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  AppIcons.calendarDays,
                  color: AppColors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CalendarFormsStrings.nextAvailableSlot,
                      style: AppText.caption.copyWith(
                        color: AppColors.mute,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      info.nextSlotLabel,
                      style: AppText.cardTitle.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (info.nextProject != null) ...[
            const SizedBox(height: 14),
            Text(
              CalendarFormsStrings.earliestContractToFreeUp(
                info.nextProject!.name,
              ),
              style: AppText.caption.copyWith(
                color: AppColors.mute,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveProjectsProgressCard(CapacityInfo info) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: AppColors.line,
          width: AppSpacing.borderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  CalendarFormsStrings.activeProjectsProgressTitle,
                  style: AppText.cardTitle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                CalendarFormsStrings.averageProgress(info.averageProgress),
                style: AppText.caption.copyWith(
                  color: AppColors.mute,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (info.activeProjects.isEmpty) ...[
            const SizedBox(height: 16),
            Text(
              CalendarFormsStrings.noActiveProjects,
              style: AppText.caption.copyWith(color: AppColors.mute),
            ),
          ] else ...[
            for (final ProjectItem project in info.activeProjects) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: AppText.bodyBold.copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${project.progress}%',
                    style: AppText.bodyBold.copyWith(fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (project.progress / 100.0).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: AppColors.seg,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _statusProgressColor(project.status),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildCalendarSyncRow(
    BuildContext context,
    SettingsRepository settingsRepo,
  ) {
    final bool isConnected = settingsRepo.googleConnected;

    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(
          color: AppColors.line,
          width: AppSpacing.borderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/calendar/sync'),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 16,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.purpleBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  AppIcons.calendarDays,
                  color: AppColors.purple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CalendarFormsStrings.calendarSyncRowTitle,
                      style: AppText.bodyBold.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isConnected
                          ? CalendarFormsStrings.calendarSyncConnected
                          : CalendarFormsStrings.calendarSyncNotConnected,
                      style: AppText.caption.copyWith(
                        color: AppColors.mute,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                AppIcons.chevronRight,
                color: AppColors.mute,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = (clock ?? defaultClock)();
    final ProjectsRepository projectsRepo = ProjectsScope.of(context);
    final SettingsRepository settingsRepo = SettingsScope.of(context);
    final CapacityInfo info = capacityInfo(projectsRepo.projects, now);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leadingWidth: 44 + AppSpacing.pageGutter,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.pageGutter),
          child: Center(
            child: RoundIconButton(
              icon: AppIcons.arrowLeft,
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/calendar'),
            ),
          ),
        ),
        title: Text(
          CalendarFormsStrings.capacityTitle,
          style: AppText.cardTitle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageGutter,
            AppSpacing.md,
            AppSpacing.pageGutter,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildWorkloadCard(info),
              const SizedBox(height: AppSpacing.lg),
              _buildNextSlotCard(info),
              const SizedBox(height: AppSpacing.lg),
              _buildActiveProjectsProgressCard(info),
              const SizedBox(height: AppSpacing.lg),
              _buildCalendarSyncRow(context, settingsRepo),
            ],
          ),
        ),
      ),
    );
  }
}
