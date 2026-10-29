import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'client_strings.dart';

class AddClientScreen extends StatelessWidget {
  const AddClientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(ClientStrings.addClient, style: AppText.sectionTitle),
      ),
    );
  }
}
