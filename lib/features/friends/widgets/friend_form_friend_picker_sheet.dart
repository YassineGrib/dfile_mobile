import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/initial_avatar.dart';
import '../data/friend.dart';
import '../data/friends_repository.dart';
import '../friend_forms_strings.dart';
import 'friend_card.dart';

/// Opens the friend picker modal bottom sheet returning the chosen [Friend] or null if cancelled.
Future<Friend?> showFriendPickerSheet({
  required BuildContext context,
  required FriendsRepository friendsRepo,
  String? selectedFriendId,
}) {
  return showAppSheet<Friend>(
    context: context,
    builder: (BuildContext sheetContext) {
      return _FriendPickerSheetContent(
        friendsRepo: friendsRepo,
        selectedFriendId: selectedFriendId,
      );
    },
  );
}

class _FriendPickerSheetContent extends StatelessWidget {
  const _FriendPickerSheetContent({
    required this.friendsRepo,
    this.selectedFriendId,
  });

  final FriendsRepository friendsRepo;
  final String? selectedFriendId;

  @override
  Widget build(BuildContext context) {
    final List<Friend> friends = friendsRepo.friends;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                FriendFormsStrings.selectFriendSheetTitle,
                style: AppText.cardTitle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton.icon(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                context.push(AppRoutes.addFriendPath);
              },
              icon: const Icon(
                Icons.add_rounded,
                size: 18,
                color: AppColors.purple,
              ),
              label: Text(
                FriendFormsStrings.newFriendLink,
                style: AppText.captionSm.copyWith(
                  color: AppColors.purple,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (friends.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
            child: Center(
              child: Text(
                FriendFormsStrings.noFriendsFound,
                style: AppText.body.copyWith(color: AppColors.mute),
              ),
            ),
          )
        else
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.45,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: friends.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(height: 1, color: AppColors.line),
              itemBuilder: (BuildContext context, int index) {
                final Friend friend = friends[index];
                final bool isSelected = friend.id == selectedFriendId;

                return Material(
                  color: AppColors.transparent,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    leading: InitialAvatar(
                      initial: friend.name,
                      color: friendAvatarColor(friend.avatarColorIndex),
                      size: 38,
                    ),
                    title: Text(
                      friend.name,
                      style: AppText.body.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    subtitle: friend.phone.isNotEmpty
                        ? Text(
                            friend.phone,
                            style: AppText.captionSm.copyWith(
                              color: AppColors.mute,
                            ),
                          )
                        : null,
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: AppColors.green,
                            size: 22,
                          )
                        : null,
                    onTap: () => Navigator.of(context).pop(friend),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
