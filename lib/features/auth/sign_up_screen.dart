import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'auth_strings.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(AuthStrings.signUp, style: AppText.sectionTitle),
      ),
    );
  }
}
