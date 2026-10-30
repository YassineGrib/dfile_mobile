import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../data/calendar_tab.dart';

/// 3-way segmented control for switching between Month, Agenda, and Timeline views
/// matching SPEC.md (CL1) stadium pill design (`seg` track, white active pill).
class CalendarSegmented extends StatelessWidget {
  const CalendarSegmented({
    super.key,
    required this.selectedTab,
    required this.onChanged,
    this.height = 48,
  });

  /// The active [CalendarTab].
  final CalendarTab selectedTab;

  /// Callback when a segment is selected.
  final ValueChanged<CalendarTab> onChanged;

  /// Overall control height (default 48).
  final double height;

  int get selectedIndex => selectedTab.index;

  @override
  Widget build(BuildContext context) {
    const List<CalendarTab> tabs = CalendarTab.values;

    return Container(
      height: height,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.seg,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Row(
        children: tabs.map((CalendarTab tab) {
          final bool isSelected = tab == selectedTab;
          return Expanded(
            child: Material(
              color: isSelected ? AppColors.card : AppColors.transparent,
              borderRadius: BorderRadius.circular((height - AppSpacing.sm) / 2),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  if (!isSelected) {
                    onChanged(tab);
                  }
                },
                child: Center(
                  child: Text(
                    tab.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodyMedium.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected ? AppColors.ink : AppColors.mute,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
