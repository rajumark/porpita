import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DebugCopyButton extends StatelessWidget {
  final String text;
  const DebugCopyButton(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.copy, size: 16),
      onPressed: () {
        Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Copied'), duration: Duration(seconds: 1)),
        );
      },
    );
  }
}

class DebugTile extends StatelessWidget {
  final String label;
  final String code;

  const DebugTile({super.key, required this.label, required this.code});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: DebugCopyButton(code),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      subtitle: Text(code, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class DebugColorTile extends StatelessWidget {
  final String label;
  final String code;
  final Color color;

  const DebugColorTile({super.key, required this.label, required this.code, required this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DebugCopyButton(code),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      subtitle: Text(code, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class DebugTextTile extends StatelessWidget {
  final String label;
  final String code;
  final TextStyle style;

  const DebugTextTile({super.key, required this.label, required this.code, required this.style});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: DebugCopyButton(code),
      title: Text(label, style: style),
      subtitle: Text(code, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}