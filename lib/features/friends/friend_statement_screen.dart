import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';

/// Screen displaying an individual friend's debt statement per `docs/design/SPEC.md` (FD3).
class FriendStatementScreen extends StatelessWidget {
  const FriendStatementScreen({
    super.key,
    required this.friendId,
  });

  final String friendId;

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
        child: Text('FriendStatementScreen'),
      ),
    );
  }
}
