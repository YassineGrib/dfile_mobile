import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'auth_strings.dart';

class VerifyCodeScreen extends StatelessWidget {
  const VerifyCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(AuthStrings.verifyCode, style: AppText.sectionTitle),
      ),
    );
  }
}
