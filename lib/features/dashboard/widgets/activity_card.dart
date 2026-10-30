import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_icons.dart';
import '../../clients/data/clients_repository.dart';
import '../../clients/data/clients_scope.dart';
import '../../expenses/data/expenses_repository.dart';
import '../../expenses/data/expenses_scope.dart';
import '../../friends/data/friends_repository.dart';
import '../../friends/data/friends_scope.dart';
import '../../projects/data/projects_repository.dart';
import '../../projects/data/projects_scope.dart';
import '../dashboard_activity_strings.dart';
import '../data/dashboard_stats.dart';
import 'dash_card.dart';
import 'dash_icon_bubble.dart';

/// Recent activity section card per `docs/design/SPEC.md` (HM3).
///
/// Displays a section head "Recent activity" with "See all" navigating to `/home/notifications`,
/// followed by a white card with up to 4 rows from [recentActivity] (payments, expenses,
/// friend settlements, project started events).
/// If there is no activity, displays a friendly empty state line.
class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    this.clock,
  });

  /// Optional clock provider for deterministic testing.
  final DateTime Function()? clock;

  @override
  Widget build(BuildContext context) {
    final ProjectsRepository projectsRepo = ProjectsScope.of(context);
    final ExpensesRepository expensesRepo = ExpensesScope.of(context);
    final FriendsRepository friendsRepo = FriendsScope.of(context);
    final ClientsRepository clientsRepo = ClientsScope.of(context);

    final List<ActivityItem> items = recentActivity(
      payments: projectsRepo.payments,
      expenses: expensesRepo.expenses,
      settlements: friendsRepo.settlements,
      friendTransactions: friendsRepo.transactions,
      projects: projectsRepo.projects,
      clientNameLookup: (String clientId) =>
          clientsRepo.byId(clientId)?.name ?? '',
      projectNameLookup: (String projectId) =>
          projectsRepo.byId(projectId)?.name ?? '',
      friendNameLookup: (String friendId) =>
          friendsRepo.friendById(friendId)?.name ?? '',
      limit: 4,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                DashboardActivityStrings.recentActivity,
                style: AppText.cardTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => context.push(AppRoutes.notificationsPath),
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DashboardActivityStrings.seeAll,
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
        const SizedBox(height: 12),
        DashCard(
          padding: items.isEmpty
              ? const EdgeInsets.symmetric(horizontal: 20, vertical: 24)
              : const EdgeInsets.symmetric(vertical: 8),
          child: items.isEmpty
              ? Center(
                  child: Text(
                    DashboardActivityStrings.noRecentActivity,
                    style: AppText.caption.copyWith(
                      color: AppColors.mute,
                      fontSize: 14,
                    ),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < items.length; i++) ...[
                      _ActivityRow(item: items[i]),
                      if (i < items.length - 1)
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColors.line,
                          indent: 68,
                          endIndent: 20,
                        ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item});

  final ActivityItem item;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color fg, Color bg) = switch (item.kind) {
      ActivityKind.payment => (
          AppIcons.circleCheck,
          AppColors.green,
          AppColors.greenBg,
        ),
      ActivityKind.expense => (
          AppIcons.receipt,
          AppColors.coral,
          AppColors.coralBg,
        ),
      ActivityKind.settlement => (
          AppIcons.arrowRightLeft,
          AppColors.purple,
          AppColors.purpleBg,
        ),
      ActivityKind.projectStarted => (
          AppIcons.folderKanban,
          AppColors.orange,
          AppColors.orangeBg,
        ),
    };

    return InkWell(
      onTap: () => context.push(item.route),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            DashIconBubble(
              icon: icon,
              foreground: fg,
              background: bg,
              size: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    style: AppText.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: AppText.caption.copyWith(
                      color: AppColors.mute,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              flex: 0,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 50, maxWidth: 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.amount != null) ...[
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          item.amount! >= 0
                              ? '+${formatAmount(item.amount!)}'
                              : '-${formatAmount(item.amount!.abs())}',
                          style: AppText.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: item.amount! >= 0 ? AppColors.green : AppColors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        formatShortDate(item.date),
                        style: AppText.captionSm.copyWith(
                          color: AppColors.placeholder,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
