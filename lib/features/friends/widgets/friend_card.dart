import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/user_avatar.dart';
import '../data/friend.dart';
import 'friend_net_chip.dart';

/// Helper resolving an avatar background color based on [index].
Color friendAvatarColor(int index) {
  const List<Color> colors = <Color>[
    AppColors.orange,
    AppColors.purple,
    AppColors.yellow,
    AppColors.coral,
  ];
  return colors[index.abs() % colors.length];
}

/// Friend card matching `docs/design/screens/FD1 Friends list.png`.
class FriendCard extends StatelessWidget {
  const FriendCard({
    super.key,
    required this.friend,
    required this.balance,
    this.onTap,
  });

  final Friend friend;
  final FriendBalance balance;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final String lastActivityText = balance.lastActivity != null
        ? 'Last: ${formatDate(balance.lastActivity!)}'
        : 'No activity';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: AppColors.line,
          width: AppSpacing.borderWidth,
        ),
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row: Avatar, Name & Phone, Net chip
                Row(
                  children: [
                    UserAvatar(name: friend.name, size: 48),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            friend.name,
                            style: AppText.cardTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            friend.phone.isNotEmpty ? friend.phone : 'No phone',
                            style: AppText.caption.copyWith(
                              color: AppColors.mute,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    FriendNetChip(net: balance.net),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Hairline divider
                Container(height: 1, color: AppColors.line),
                const SizedBox(height: AppSpacing.sm),

                // Bottom metadata row: Active & Settled counts, Last activity
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${balance.active} active • ${balance.settled} settled',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.captionSm.copyWith(
                          color: AppColors.mute,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      lastActivityText,
                      maxLines: 1,
                      style: AppText.captionSm.copyWith(color: AppColors.mute),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
