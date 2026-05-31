import 'package:flutter/material.dart';
import 'devicebutton/device_button.dart';
import 'porpita_preferences/porpita_preferences_dialog.dart';

class TopBar extends StatelessWidget {
  final VoidCallback onMenuTap;
  const TopBar({super.key, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Row(
        children: [
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.menu),
            iconSize: 24,
            onPressed: onMenuTap,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tight(const Size(36, 36)),
          ),
          const Text('Porpita'),
          const SizedBox(width: 16),
          const DeviceButton(),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings),
            iconSize: 24,
            onPressed: () => PorpitaPreferencesDialog.show(context),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tight(const Size(36, 36)),
          ),
        ],
      ),
    );
  }
}
