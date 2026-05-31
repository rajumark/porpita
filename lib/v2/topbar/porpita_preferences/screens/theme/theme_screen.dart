import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:porpita/services/theme_manager.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = context.watch<ThemeManager>();
    final current = themeManager.themeMode;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Theme', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          RadioListTile<ThemeMode>(
            title: const Text('System'),
            value: ThemeMode.system,
            groupValue: current,
            onChanged: (mode) {
              if (mode != null) themeManager.setThemeMode(mode);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark'),
            value: ThemeMode.dark,
            groupValue: current,
            onChanged: (mode) {
              if (mode != null) themeManager.setThemeMode(mode);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Light'),
            value: ThemeMode.light,
            groupValue: current,
            onChanged: (mode) {
              if (mode != null) themeManager.setThemeMode(mode);
            },
          ),
        ],
      ),
    );
  }
}
