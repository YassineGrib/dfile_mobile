import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';

/// Screen for recording or editing an expense per `docs/design/SPEC.md` (EX9..EX13).
class ExpenseFormScreen extends StatelessWidget {
  const ExpenseFormScreen({
    super.key,
    this.expenseId,
    this.projectId,
  });

  final String? expenseId;
  final String? projectId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
        child: Text('ExpenseFormScreen'),
      ),
    );
  }
}
