import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';

/// Screen to record a new friend debt transaction per `docs/design/SPEC.md` (FD11, FD12).
class TransactionFormScreen extends StatelessWidget {
  const TransactionFormScreen({
    super.key,
    this.friendId,
  });

  final String? friendId;

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
        child: Text('TransactionFormScreen'),
      ),
    );
  }
}
