import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import '../settings/data/data.dart';
import '../settings/widgets/settings_group_card.dart';
import '../settings/widgets/settings_toggle_row.dart';
import 'calendar_forms_strings.dart';
import 'data/data.dart';

/// Calendar synchronization preferences and action screen per `docs/design/SPEC.md` (CL12).
class CalendarSyncScreen extends StatelessWidget {
  const CalendarSyncScreen({super.key, this.clock});

  final DateTime Function()? clock;

  static DateTime Function() defaultClock = DateTime.now;

  String _formatLastSynced(DateTime dt, DateTime now) {
    final String hour = dt.hour.toString().padLeft(2, '0');
    final String minute = dt.minute.toString().padLeft(2, '0');
    final String time = '$hour:$minute';

    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return CalendarFormsStrings.lastSyncedToday(time);
    }
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
    final String date = '${months[dt.month - 1]} ${dt.day}';
    return CalendarFormsStrings.lastSyncedAt(date, time);
  }

  Widget _buildGoogleCalendarCard(
    BuildContext context,
    CalendarRepository calendarRepo,
    SettingsRepository settingsRepo,
    DateTime now,
  ) {
    final bool isConnected = settingsRepo.googleConnected;

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.purpleBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  AppIcons.calendarDays,
                  color: AppColors.purple,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CalendarFormsStrings.googleCalendarTitle,
                      style: AppText.cardTitle.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      settingsRepo.profile.email,
                      style: AppText.caption.copyWith(
                        color: AppColors.mute,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isConnected ? AppColors.greenBg : AppColors.seg,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  isConnected
                      ? CalendarFormsStrings.connected
                      : CalendarFormsStrings.notConnected,
                  style: AppText.captionSm.copyWith(
                    color: isConnected ? AppColors.green : AppColors.mute,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (isConnected) ...[
            SizedBox(
              height: AppSpacing.buttonHeight,
              child: Material(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    calendarRepo.markSynced(now);
                    AppToast.show(
                      context,
                      CalendarFormsStrings.calendarSyncedToast,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        AppIcons.refreshCw,
                        size: 18,
                        color: AppColors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(CalendarFormsStrings.syncNow, style: AppText.button),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              calendarRepo.lastSynced == null
                  ? CalendarFormsStrings.neverSynced
                  : _formatLastSynced(calendarRepo.lastSynced!, now),
              textAlign: TextAlign.center,
              style: AppText.caption.copyWith(
                color: AppColors.mute,
                fontSize: 13,
              ),
            ),
          ] else ...[
            PrimaryButton(
              label: CalendarFormsStrings.connectInSettings,
              onPressed: () => context.push('/settings/integrations'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(CalendarRepository calendarRepo) {
    return SettingsGroupCard(
      children: [
        SettingsToggleRow(
          title: CalendarFormsStrings.projectDeadlinesTitle,
          subtitle: CalendarFormsStrings.projectDeadlinesSubtitle,
          value: calendarRepo.syncDeadlines,
          onChanged: (bool val) => calendarRepo.syncDeadlines = val,
        ),
        SettingsToggleRow(
          title: CalendarFormsStrings.milestonesTitle,
          subtitle: CalendarFormsStrings.milestonesSubtitle,
          value: calendarRepo.syncMilestones,
          onChanged: (bool val) => calendarRepo.syncMilestones = val,
        ),
        SettingsToggleRow(
          title: CalendarFormsStrings.debtsTitle,
          subtitle: CalendarFormsStrings.debtsSubtitle,
          value: calendarRepo.syncDebts,
          onChanged: (bool val) => calendarRepo.syncDebts = val,
          last: true,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = (clock ?? defaultClock)();
    final CalendarRepository calendarRepo = CalendarScope.of(context);
    final SettingsRepository settingsRepo = SettingsScope.of(context);

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
          CalendarFormsStrings.calendarSyncTitle,
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
              _buildGoogleCalendarCard(
                context,
                calendarRepo,
                settingsRepo,
                now,
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildPreferencesCard(calendarRepo),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: 8,
                ),
                child: Text(
                  CalendarFormsStrings.syncNote,
                  textAlign: TextAlign.center,
                  style: AppText.caption.copyWith(
                    color: AppColors.mute,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
