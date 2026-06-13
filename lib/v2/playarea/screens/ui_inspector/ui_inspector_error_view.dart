import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UiInspectorErrorView extends StatelessWidget {
  final String error;

  const UiInspectorErrorView({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            SelectableText(
              error,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontFamily: 'monospace',
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: error));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error copied'), duration: Duration(seconds: 1)),
                );
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy Error'),
            ),
          ],
        ),
      ),
    );
  }
}
