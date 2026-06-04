import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../services/device_manager.dart';
import 'wireless_adb_service.dart';
import 'wireless_adb_shared_widgets.dart';

class Android10Tab extends StatefulWidget {
  const Android10Tab({super.key});

  @override
  State<Android10Tab> createState() => _Android10TabState();
}

class _Android10TabState extends State<Android10Tab> {
  int _step = 0;
  final _tcpIpController = TextEditingController();

  @override
  void dispose() {
    _tcpIpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<WirelessAdbService>();
    final hasUsbDevice = context.select<DeviceManager, bool>(
      (dm) => dm.physicalDevices.any((d) => d.isConnected && !d.isEmulator),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdbInfoCard(icon: Icons.info_outline, text: 'Android 10 and below require a USB cable to initialize wireless ADB. Connect your device via USB first.'),
        const SizedBox(height: 12),
        if (!hasUsbDevice) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, size: 16, color: Theme.of(context).colorScheme.onErrorContainer),
                const SizedBox(width: 8),
                Expanded(child: Text('No USB device detected. Connect your device via USB first.', style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer, fontSize: 12))),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        Text('Step 1: Switch to TCP Mode', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        if (hasUsbDevice) ...[
          Text('Device: ${context.read<DeviceManager>().physicalDevices.firstWhere((d) => d.isConnected && !d.isEmulator).id}', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: service.busy ? null : () async {
                final device = context.read<DeviceManager>().physicalDevices.firstWhere((d) => d.isConnected && !d.isEmulator);
                final result = await service.switchToTcpMode(device.id);
                if (result.success) {
                  setState(() => _step = 1);
                }
              },
              child: const Text('Enable TCP Mode (Port 5555)'),
            ),
          ),
        ],
        if (_step >= 1) ...[
          const Divider(height: 24),
          const AdbInfoCard(icon: Icons.cable, text: 'You can now unplug the USB cable.'),
          const SizedBox(height: 12),
          Text('Step 2: Connect Wirelessly', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          AdbTextField(controller: _tcpIpController, label: 'Device IP Address', hint: '192.168.1.50', enabled: !service.busy),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: service.busy ? null : () async {
                final result = await service.connectDevice(
                  _tcpIpController.text.trim(),
                  '5555',
                );
                if (result.success) {
                  setState(() => _step = 2);
                }
              },
              child: const Text('Connect'),
            ),
          ),
        ],
        if (_step >= 2) ...[
          const Divider(height: 24),
          const AdbInfoCard(icon: Icons.check_circle, text: 'Device connected wirelessly! It should now appear in the device list.'),
        ],
      ],
    );
  }
}