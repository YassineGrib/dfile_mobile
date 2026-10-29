import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import 'data/friends_tab.dart';

/// Screen displaying the Friends and Transactions tabs per `docs/design/SPEC.md` (FD1, FD8).
class FriendsScreen extends StatelessWidget {
  const FriendsScreen({
    super.key,
    this.initialTab = FriendsTab.friends,
    this.initialQuery,
  });

  final FriendsTab initialTab;
  final String? initialQuery;

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
        child: Text('FriendsScreen'),
      ),
    );
  }
}
