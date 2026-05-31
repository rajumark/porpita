import 'package:flutter/material.dart';

class PorpitaPreferencesDialog extends StatelessWidget {
  const PorpitaPreferencesDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const PorpitaPreferencesDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Preferences'),
      content: const Center(
        child: Text('Coming soon preferences'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
