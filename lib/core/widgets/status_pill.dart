import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Client/entity status badge: Active (green with dot) or Archived (grey).
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.isActive,
    this.activeLabel = 'Active',
    this.archivedLabel = 'Archived',
  });

  const StatusPill.active({super.key, String label = 'Active'})
    : isActive = true,
      activeLabel = label,
      archivedLabel = 'Archived';

  const StatusPill.archived({super.key, String label = 'Archived'})
    : isActive = false,
      activeLabel = 'Active',
      archivedLabel = label;

  final bool isActive;
  final String activeLabel;
  final String archivedLabel;

  @override
  Widget build(BuildContext context) {
    final Color bg = isActive ? AppColors.greenBg : AppColors.seg;
    final Color fg = isActive ? AppColors.green : AppColors.mute;
    final String text = isActive ? activeLabel : archivedLabel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive) ...[
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: AppText.caption.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
