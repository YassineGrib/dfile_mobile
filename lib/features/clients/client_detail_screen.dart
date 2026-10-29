import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'client_strings.dart';

class ClientDetailScreen extends StatelessWidget {
  const ClientDetailScreen({
    super.key,
    required this.clientId,
  });

  final String clientId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '${ClientStrings.clientDetail} ($clientId)',
          style: AppText.sectionTitle,
        ),
      ),
    );
  }
}
