import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/device_manager.dart';

class DeviceSelectorDialog extends StatelessWidget {
  const DeviceSelectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final dm = context.watch<DeviceManager>();

    return AlertDialog(
      title: const Text('Select Device'),
      content: SizedBox(
        width: double.maxFinite,
        child: dm.devices.isEmpty
            ? const Text('No devices connected.')
            : ListView.builder(
                shrinkWrap: true,
                itemCount: dm.devices.length,
                itemBuilder: (context, i) {
                  final device = dm.devices[i];
                  final selected = dm.selected?.id == device.id;
                  return ListTile(
                    leading: Icon(
                      device.isConnected ? Icons.phone_android : Icons.warning,
                    ),
                    title: Text(device.id),
                    subtitle: Text(device.status),
                    trailing: selected ? const Icon(Icons.check) : null,
                    selected: selected,
                    onTap: () {
                      dm.select(device);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
