import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/theme_manager.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  @override
  Widget build(BuildContext context) {
    final themeManager = context.watch<ThemeManager>();

    return AlertDialog(
      title: const Text('Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Theme',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          RadioGroup<ThemeMode>(
            groupValue: themeManager.themeMode,
            onChanged: (m) {
              if (m != null) themeManager.setThemeMode(m);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ThemeOption(
                  value: ThemeMode.system,
                  label: 'System',
                  icon: Icons.settings_suggest,
                ),
                _ThemeOption(
                  value: ThemeMode.light,
                  label: 'Light',
                  icon: Icons.light_mode,
                ),
                _ThemeOption(
                  value: ThemeMode.dark,
                  label: 'Dark',
                  icon: Icons.dark_mode,
                ),
              ],
            ),
          ),
        ],
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

class _ThemeOption extends StatelessWidget {
  final ThemeMode value;
  final String label;
  final IconData icon;

  const _ThemeOption({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<ThemeMode>(
      value: value,
      title: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}
