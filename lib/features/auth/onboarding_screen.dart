import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'auth_strings.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(AuthStrings.onboarding, style: AppText.sectionTitle),
      ),
    );
  }
}
