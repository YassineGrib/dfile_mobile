import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';

/// Dashboard notifications screen placeholder (agent C).
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(AppIcons.arrowLeft, color: AppColors.ink),
          onPressed: () => _handleBack(context),
        ),
      ),
      body: Center(
        child: Text(
          'NotificationsScreen',
          style: AppText.sectionTitle,
        ),
      ),
    );
  }
}
