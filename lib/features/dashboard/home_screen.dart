import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';

/// Dashboard home screen placeholder (agent A).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
      bottomNavigationBar: const AppTabBar(
        currentIndex: AppTabBar.homeTabIndex,
      ),
      body: Center(
        child: Text(
          'HomeScreen',
          style: AppText.sectionTitle,
        ),
      ),
    );
  }
}
