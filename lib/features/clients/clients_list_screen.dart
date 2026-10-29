import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'client_strings.dart';

class ClientsListScreen extends StatelessWidget {
  const ClientsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(ClientStrings.clientsList, style: AppText.sectionTitle),
      ),
    );
  }
}
