import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format.dart';
import '../../../core/haptics.dart';
import '../../../core/privacy.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../clients/data/data.dart';
import '../../projects/data/data.dart';
import '../dashboard_home_strings.dart';
import '../data/follow_up.dart';
import 'dash_card.dart';
import 'dash_section_head.dart';

/// "Follow up": the clients who still owe money, each with a one-tap WhatsApp
/// reminder that is already written. Shows nothing when everyone has paid.
class HomeFollowUp extends StatelessWidget {
  const HomeFollowUp({super.key});

  Future<void> _remind(BuildContext context, FollowUp item) async {
    final Uri? uri = whatsappUri(item);
    if (uri == null) {
      showAppToast(context, DashboardHomeStrings.followUpNoPhone);
      return;
    }
    AppHaptics.light();
    final bool opened = await openExternalLink(uri);
    if (!opened && context.mounted) {
      showAppToast(context, DashboardHomeStrings.followUpCouldNotOpen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<FollowUp> items = followUps(
      projects: ProjectsScope.of(context),
      clients: ClientsScope.of(context).clients,
    );
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashSectionHead(title: DashboardHomeStrings.followUp, action: null),
        const SizedBox(height: AppSpacing.md),
        DashCard(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                if (i > 0)
                  const Divider(height: 1, thickness: 1, color: AppColors.line),
                _FollowUpRow(
                  item: items[i],
                  onOpen: () => context.push('/clients/${items[i].client.id}'),
                  onRemind: () => _remind(context, items[i]),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

class _FollowUpRow extends StatelessWidget {
  const _FollowUpRow({
    required this.item,
    required this.onOpen,
    required this.onRemind,
  });

  final FollowUp item;
  final VoidCallback onOpen;
  final VoidCallback onRemind;

  @override
  Widget build(BuildContext context) {
    final String amount = PrivacyScope.shown(
      context,
      formatMoney(item.outstanding),
    );
    return InkWell(
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            UserAvatar(name: item.client.name, size: 40),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.client.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodyBold,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$amount ${DashboardHomeStrings.followUpOutstanding}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption.copyWith(color: AppColors.mute),
                  ),
                ],
              ),
            ),
            Semantics(
              button: true,
              label:
                  '${DashboardHomeStrings.followUpRemind} ${item.client.name}',
              child: InkResponse(
                radius: 26,
                onTap: onRemind,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.greenBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    AppIcons.messageCircle,
                    size: 20,
                    color: AppColors.green,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
