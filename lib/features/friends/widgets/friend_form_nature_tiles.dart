import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../data/friend_tx_type.dart';
import '../friend_forms_strings.dart';

/// Nature selector with 3 tiles ("Money loan", "Service", "Shared cost") matching FD11.
class FriendFormNatureTiles extends StatelessWidget {
  const FriendFormNatureTiles({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final FriendTxType selected;
  final ValueChanged<FriendTxType> onChanged;

  Widget _buildTile({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? AppColors.purpleBg : AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        side: BorderSide(
          color: isSelected ? AppColors.purple : AppColors.line,
          width: AppSpacing.borderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.input),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppText.captionSm.copyWith(
              color: isSelected ? AppColors.purple : AppColors.ink,
              fontWeight: FontWeight.w600,
              fontSize: 13,
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          FriendFormsStrings.natureLabel,
          style: AppText.label,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildTile(
                context: context,
                label: FriendFormsStrings.natureMoney,
                isSelected: selected == FriendTxType.money,
                onTap: () => onChanged(FriendTxType.money),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildTile(
                context: context,
                label: FriendFormsStrings.natureService,
                isSelected: selected == FriendTxType.service,
                onTap: () => onChanged(FriendTxType.service),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildTile(
                context: context,
                label: FriendFormsStrings.natureSharedCost,
                isSelected: selected == FriendTxType.expense,
                onTap: () => onChanged(FriendTxType.expense),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
