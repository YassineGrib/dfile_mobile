import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';

/// Placeholder screen for the payment receipt (PY5..PY8).
class PaymentReceiptScreen extends StatelessWidget {
  const PaymentReceiptScreen({
    super.key,
    required this.paymentId,
  });

  final String paymentId;

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
          'PaymentReceiptScreen',
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
