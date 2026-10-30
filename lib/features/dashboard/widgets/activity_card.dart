import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

/// Recent activity card placeholder (agent C).
class ActivityCard extends StatelessWidget {
  const ActivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: AppColors.line, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'ActivityCard',
            style: AppText.cardTitle,
          ),
        ),
      ),
    );
  }
}
