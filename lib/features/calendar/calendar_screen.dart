import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme.dart';
import '../../core/widgets/app_icons.dart';

/// Main calendar screen per `docs/design/SPEC.md` (CL1-CL3).
///
/// Handed off to Agent A for full implementation.
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({
    super.key,
    this.tab,
    this.date,
    this.clock,
  });

  final String? tab;
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
          'CalendarScreen',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'CalendarScreen',
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
