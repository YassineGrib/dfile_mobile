import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_icons.dart';
import '../data/dashboard_stats.dart';
import '../dashboard_home_strings.dart';
import 'dash_icon_bubble.dart';
import 'home_pill.dart';

/// Upcoming deadlines section per HM1 & SPEC.md:
/// - Section header "Upcoming deadlines" with action "See all" -> /projects
/// - Up to 3 projects that are not Completed / Delivered / Cancelled and have an end date, ascending
/// - Pill states:
///   * Overdue: triangleAlert on red, "Overdue Nd"
///   * Due soon (<=7d): calendarClock on orange, "Nd left" (or "Today" if 0)
///   * Later: clock or calendarClock on grey/seg, "Nd left"
/// - Tap card -> /projects/:id
/// - Friendly line when none
class HomeUpcomingDeadlines extends StatelessWidget {
  const HomeUpcomingDeadlines({
    super.key,
    required this.deadlines,
    this.clientNameLookup,
  });

  final List<DeadlineItem> deadlines;
  final String Function(String clientId)? clientNameLookup;

  Widget _buildDeadlineCard(BuildContext context, DeadlineItem item) {
    final Color iconBg;
    final Color iconColor;
    final IconData icon;

    final Color pillBg;
    final Color pillTextColor;
    final Color pillIconColor;

    if (item.state == DeadlineState.overdue) {
      iconBg = AppColors.redBg;
      iconColor = AppColors.red;
      icon = AppIcons.triangleAlert;
      pillBg = AppColors.redBg;
      pillTextColor = AppColors.red;
      pillIconColor = AppColors.red;
    } else if (item.state == DeadlineState.soon) {
      iconBg = AppColors.yellowBg;
      iconColor = AppColors.orange;
      icon = AppIcons.calendarClock;
      pillBg = AppColors.yellowBg;
      pillTextColor = AppColors.orange;
      pillIconColor = AppColors.orange;
    } else {
      iconBg = AppColors.seg;
      iconColor = AppColors.mute;
      icon = AppIcons.clock;
      pillBg = AppColors.seg;
      pillTextColor = AppColors.mute;
      pillIconColor = AppColors.mute;
    }

    final String clientName =
        clientNameLookup?.call(item.project.clientId) ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
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
          onTap: () => context.push('/projects/${item.project.id}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                DashIconBubble(
                  icon: icon,
                  background: iconBg,
                  foreground: iconColor,
                  size: 40,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.project.name,
                        style: AppText.bodyBold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (clientName.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          clientName,
                          style: AppText.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                HomePill(
                  label: item.pillText,
                  backgroundColor: pillBg,
                  textColor: pillTextColor,
                  iconColor: pillIconColor,
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                DashboardHomeStrings.upcomingDeadlines,
                style: AppText.cardTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: () => context.push('/calendar?tab=agenda'),
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DashboardHomeStrings.seeAll,
                    style: AppText.captionSm.copyWith(
                      color: AppColors.purple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    AppIcons.chevronRight,
                    size: 16,
                    color: AppColors.purple,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (deadlines.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                color: AppColors.line,
                width: AppSpacing.borderWidth,
              ),
            ),
            child: Text(
              DashboardHomeStrings.noDeadlines,
              style: AppText.caption.copyWith(color: AppColors.mute),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...deadlines.map((item) => _buildDeadlineCard(context, item)),
      ],
    );
  }
}
