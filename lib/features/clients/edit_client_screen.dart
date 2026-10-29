import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'client_strings.dart';

class EditClientScreen extends StatelessWidget {
  const EditClientScreen({
    super.key,
    required this.clientId,
  });

  final String clientId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '${ClientStrings.editClient} ($clientId)',
          style: AppText.sectionTitle,
        ),
      ),
    );
  }
}
