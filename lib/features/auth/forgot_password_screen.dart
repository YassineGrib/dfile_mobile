import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'auth_strings.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(AuthStrings.forgotPassword, style: AppText.sectionTitle),
      ),
    );
  }
}
