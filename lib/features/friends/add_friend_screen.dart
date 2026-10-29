import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';

/// Screen to create and save a new friend record per `docs/design/SPEC.md` (FD7).
class AddFriendScreen extends StatelessWidget {
  const AddFriendScreen({super.key});

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
        child: Text('AddFriendScreen'),
      ),
    );
  }
}
