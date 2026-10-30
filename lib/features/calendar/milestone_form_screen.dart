import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme.dart';
import '../../core/widgets/app_icons.dart';

/// Milestone creation form per `docs/design/SPEC.md` (CL8-CL10).
///
/// Handed off to Agent C for full implementation.
class MilestoneFormScreen extends StatelessWidget {
  const MilestoneFormScreen({
    super.key,
    this.projectId,
    this.date,
    this.clock,
  });

  final String? projectId;
  final String? date;
  final DateTime Function()? clock;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(AppIcons.arrowLeft, color: AppColors.ink),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/more'),
        ),
        title: const Text(
          'MilestoneFormScreen',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'MilestoneFormScreen',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}
