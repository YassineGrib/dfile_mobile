import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../data/friend_tx_type.dart';
import '../friend_forms_strings.dart';

/// Direction selector with two stateful tiles ("Owed to me" / "I owe") matching FD11.
class FriendFormDirectionTiles extends StatelessWidget {
  const FriendFormDirectionTiles({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final FriendTxDirection selected;
  final ValueChanged<FriendTxDirection> onChanged;

  Widget _buildTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool isSelected,
    required Color activeBorderColor,
    required Color activeBgColor,
    required Color activeTextColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? activeBgColor : AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        side: BorderSide(
          color: isSelected ? activeBorderColor : AppColors.line,
          width: isSelected ? 2.0 : AppSpacing.borderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.input),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 14,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppText.cardTitle.copyWith(
                  color: isSelected ? activeTextColor : AppColors.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppText.captionSm.copyWith(
                  color: AppColors.mute,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          FriendFormsStrings.directionLabel,
          style: AppText.label,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildTile(
                context: context,
                title: FriendFormsStrings.owedToMeLabel,
                subtitle: FriendFormsStrings.owedToMeSubtitle,
                isSelected: selected == FriendTxDirection.lent,
                activeBorderColor: AppColors.green,
                activeBgColor: AppColors.greenBg,
                activeTextColor: AppColors.green,
                onTap: () => onChanged(FriendTxDirection.lent),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildTile(
                context: context,
                title: FriendFormsStrings.iOweLabel,
                subtitle: FriendFormsStrings.iOweSubtitle,
                isSelected: selected == FriendTxDirection.borrowed,
                activeBorderColor: AppColors.red,
                activeBgColor: AppColors.redBg,
                activeTextColor: AppColors.red,
                onTap: () => onChanged(FriendTxDirection.borrowed),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
