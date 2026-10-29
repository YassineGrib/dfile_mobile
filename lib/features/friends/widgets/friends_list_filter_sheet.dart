import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../data/friend_tx_type.dart';
import '../friends_list_strings.dart';

/// Modal bottom sheet for filtering transactions per screen FD9.
class FriendsListFilterSheet extends StatefulWidget {
  const FriendsListFilterSheet({
    super.key,
    required this.initialDirection,
    required this.initialStatus,
    required this.initialType,
    required this.onApply,
  });

  final FriendDirectionFilter initialDirection;
  final FriendStatusFilter initialStatus;
  final FriendTypeFilter initialType;
  final void Function(
    FriendDirectionFilter direction,
    FriendStatusFilter status,
    FriendTypeFilter type,
  ) onApply;

  @override
  State<FriendsListFilterSheet> createState() => _FriendsListFilterSheetState();
}

class _FriendsListFilterSheetState extends State<FriendsListFilterSheet> {
  late FriendDirectionFilter _draftDirection = widget.initialDirection;
  late FriendStatusFilter _draftStatus = widget.initialStatus;
  late FriendTypeFilter _draftType = widget.initialType;

  void _handleReset() {
    setState(() {
      _draftDirection = FriendDirectionFilter.all;
      _draftStatus = FriendStatusFilter.all;
      _draftType = FriendTypeFilter.all;
    });
  }

  void _handleApply() {
    widget.onApply(_draftDirection, _draftStatus, _draftType);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    const List<(String, FriendDirectionFilter)> directionOptions =
        <(String, FriendDirectionFilter)>[
      (FriendsListStrings.directionAll, FriendDirectionFilter.all),
      (FriendsListStrings.directionOwedToMe, FriendDirectionFilter.owedToMe),
      (FriendsListStrings.directionIOwe, FriendDirectionFilter.iOwe),
    ];

    const List<(String, FriendStatusFilter)> statusOptions =
        <(String, FriendStatusFilter)>[
      (FriendsListStrings.statusAll, FriendStatusFilter.all),
      (FriendsListStrings.statusPending, FriendStatusFilter.pending),
      (FriendsListStrings.statusPartial, FriendStatusFilter.partial),
      (FriendsListStrings.statusSettled, FriendStatusFilter.settled),
    ];

    const List<(String, FriendTypeFilter)> natureOptions =
        <(String, FriendTypeFilter)>[
      (FriendsListStrings.natureAll, FriendTypeFilter.all),
      (FriendsListStrings.natureMoney, FriendTypeFilter.money),
      (FriendsListStrings.natureService, FriendTypeFilter.service),
      (FriendsListStrings.natureExpense, FriendTypeFilter.expense),
    ];

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title & Reset
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  FriendsListStrings.filterSheetTitle,
                  style: AppText.sectionTitle,
                ),
              ),
              InkWell(
                onTap: _handleReset,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  child: Text(
                    FriendsListStrings.reset,
                    style: AppText.bodyMedium.copyWith(
                      color: AppColors.purple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Direction Section
          Text(
            FriendsListStrings.filterSectionDirection,
            style: AppText.label.copyWith(fontSize: 14),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final (String label, FriendDirectionFilter dir)
                  in directionOptions)
                AppPill(
                  label: label,
                  selected: _draftDirection == dir,
                  onTap: () => setState(() => _draftDirection = dir),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Status Section
          Text(
            FriendsListStrings.filterSectionStatus,
            style: AppText.label.copyWith(fontSize: 14),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final (String label, FriendStatusFilter stat) in statusOptions)
                AppPill(
                  label: label,
                  selected: _draftStatus == stat,
                  onTap: () => setState(() => _draftStatus = stat),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Nature Section
          Text(
            FriendsListStrings.filterSectionNature,
            style: AppText.label.copyWith(fontSize: 14),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final (String label, FriendTypeFilter nat) in natureOptions)
                AppPill(
                  label: label,
                  selected: _draftType == nat,
                  onTap: () => setState(() => _draftType = nat),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Action Buttons
          PrimaryButton(
            label: FriendsListStrings.applyFilters,
            onPressed: _handleApply,
          ),
          const SizedBox(height: AppSpacing.md),
          SecondaryButton(
            label: FriendsListStrings.cancel,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
