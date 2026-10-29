import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';

/// Placeholder screen for the payments list (PY2..PY4).
class PaymentsListScreen extends StatelessWidget {
  const PaymentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: BackButton(
          color: AppColors.ink,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.morePath);
            }
          },
        ),
      ),
      body: const Center(
        child: Text(
          'PaymentsListScreen',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}
