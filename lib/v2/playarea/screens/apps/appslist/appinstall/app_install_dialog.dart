import 'package:flutter/material.dart';

void showInstallResultDialog(
  BuildContext context, {
  required bool success,
  required String message,
  String? filePath,
}) {
  final fileName = filePath?.split(RegExp(r'[/\\]')).last ?? '';

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      icon: Icon(
        success ? Icons.check_circle_outline : Icons.error_outline,
        color: success ? Colors.green : Colors.red,
        size: 48,
      ),
      title: Text(success ? 'Install Success' : 'Install Failed'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          if (filePath != null) ...[
            const SizedBox(height: 12),
            Text(
              'File: $fileName',
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
