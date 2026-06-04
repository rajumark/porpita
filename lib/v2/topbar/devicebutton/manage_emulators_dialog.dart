import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/device_manager.dart';
import '../../../services/emulator_manager.dart';

class ManageEmulatorsDialog extends StatefulWidget {
  const ManageEmulatorsDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const ManageEmulatorsDialog(),
    );
  }

  @override
  State<ManageEmulatorsDialog> createState() => _ManageEmulatorsDialogState();
}

class _ManageEmulatorsDialogState extends State<ManageEmulatorsDialog> {
  String? _launchingAvd;

  void _onLaunch(String avdName) {
    if (_launchingAvd != null) return;
    setState(() => _launchingAvd = avdName);
    context.read<EmulatorManager>().launchAvd(avdName);
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _launchingAvd = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final em = context.watch<EmulatorManager>();
    final dm = context.watch<DeviceManager>();
    final runningEmulators = dm.emulatorDevices;

    return AlertDialog(
      title: const Text('Manage Emulators'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (runningEmulators.isNotEmpty) ...[
              Text(
                'Running',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              ...runningEmulators.map((device) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.computer, size: 20),
                    title: Text(device.id),
                    subtitle: Text(device.status),
                    contentPadding: EdgeInsets.zero,
                  )),
              const Divider(),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available AVDs',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  onPressed: em.loading ? null : () => context.read<EmulatorManager>().refreshAvds(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (em.loading)
              const Center(child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              ))
            else if (em.error != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(em.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              )
            else if (em.avds.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('No AVDs found.'),
              )
            else
              ...em.avds.map((avd) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.phone_android_outlined, size: 20),
                    title: Text(avd.name),
                    trailing: FilledButton.tonal(
                      onPressed: _launchingAvd == avd.name ? null : () => _onLaunch(avd.name),
                      child: const Text('Start'),
                    ),
                    contentPadding: EdgeInsets.zero,
                  )),
          ],
        ),
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