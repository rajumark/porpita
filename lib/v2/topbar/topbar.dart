import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:porpita/services/screen_capture_service.dart';
import 'devicebutton/device_button.dart';
import 'porpita_preferences/porpita_preferences_dialog.dart';

class TopBar extends StatelessWidget {
  final VoidCallback onMenuTap;

  const TopBar({
    super.key,
    required this.onMenuTap,
  });

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
          if (Platform.isMacOS || Platform.isWindows || Platform.isLinux)
            IconButton(
              icon: const Icon(Icons.camera_alt_outlined, size: 20),
              onPressed: () => ScreenCaptureService.captureAndSave(context),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tight(const Size(36, 36)),
              tooltip: 'Screenshot',
            ),
          IconButton(
            icon: const Icon(Icons.settings, size: 20),
            onPressed: () => PorpitaPreferencesDialog.show(context),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tight(const Size(36, 36)),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}