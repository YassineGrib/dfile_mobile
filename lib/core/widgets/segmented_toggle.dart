import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Two-option stadium segmented control matching SPEC.md (`seg` track, white active pill).
class SegmentedToggle extends StatelessWidget {
  const SegmentedToggle({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
    this.height = 48,
  }) : assert(options.length == 2, 'SegmentedToggle requires exactly 2 options.');

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.seg,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Row(
        children: List<Widget>.generate(options.length, (int index) {
          final bool isSelected = index == selectedIndex;
          return Expanded(
            child: Material(
              color: isSelected ? AppColors.card : AppColors.transparent,
              borderRadius: BorderRadius.circular((height - AppSpacing.sm) / 2),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  if (index != selectedIndex) {
                    onChanged(index);
                  }
                },
                child: Center(
                  child: Text(
                    options[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodyMedium.copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.ink : AppColors.mute,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
