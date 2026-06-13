import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../services/adb_manager.dart';
import '../../../../services/device_manager.dart';
import 'debuginfo_widgets.dart';

class DebugAdbTab extends StatelessWidget {
  const DebugAdbTab({super.key});

  @override
  Widget build(BuildContext context) {
    final adb = AdbManager.instance;
    final dm = context.watch<DeviceManager>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.adb, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'ADB Path',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    DebugCopyButton(adb.adbPath ?? ''),
                  ],
                ),
                const SizedBox(height: 8),
                SelectableText(
                  adb.adbPath ?? 'Not available',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.phone_android, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Selected Device',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    DebugCopyButton(dm.selected?.id ?? ''),
                  ],
                ),
                const SizedBox(height: 8),
                SelectableText(
                  dm.selected?.id ?? 'No device connected',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}