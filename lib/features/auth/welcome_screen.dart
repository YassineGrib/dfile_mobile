import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'auth_strings.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(AuthStrings.welcome, style: AppText.sectionTitle),
      ),
    );
  }
}
