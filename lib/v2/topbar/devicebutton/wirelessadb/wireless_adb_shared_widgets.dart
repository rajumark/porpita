import 'package:flutter/material.dart';

class AdbInfoCard extends StatelessWidget {
  final IconData icon;
  final String text;

  const AdbInfoCard({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}

class AdbOutputBox extends StatelessWidget {
  final String text;
  final bool isError;

  const AdbOutputBox({super.key, required this.text, required this.isError});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isError ? Theme.of(context).colorScheme.errorContainer : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontFamily: 'monospace',
          color: isError ? Theme.of(context).colorScheme.onErrorContainer : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class AdbTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool enabled;
  final bool obscure;

  const AdbTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.enabled = true,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}