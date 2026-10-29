import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';

/// Placeholder screen for recording a payment (PY9..PY12).
class RecordPaymentScreen extends StatelessWidget {
  const RecordPaymentScreen({
    super.key,
    this.projectId,
  });

  final String? projectId;

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
              context.go(AppRoutes.paymentsPath);
            }
          },
        ),
      ),
      body: const Center(
        child: Text(
          'RecordPaymentScreen',
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
