import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UiInspectorScreenshotPanel extends StatelessWidget {
  final String? screenshotPath;
  final String? error;
  final int screenshotVersion;

  const UiInspectorScreenshotPanel({
    super.key,
    required this.screenshotPath,
    this.error,
    this.screenshotVersion = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (screenshotPath == null || screenshotPath!.isEmpty) {
      return const Center(child: Text('No screenshot'));
    }

    return Stack(
      children: [
        Positioned.fill(
          child: InteractiveViewer(
            child: Center(
              child: Image.file(
                File(screenshotPath!),
                key: ValueKey('screenshot_$screenshotVersion'),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      'Failed to load screenshot: $error',
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        if (error != null)
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Material(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, size: 16, color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        error!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.copy, size: 16, color: Theme.of(context).colorScheme.onErrorContainer),
                      tooltip: 'Copy error',
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: error!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error copied'), duration: Duration(seconds: 1)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
