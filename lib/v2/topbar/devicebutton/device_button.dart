import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/device_manager.dart';
import 'manage_emulators_dialog.dart';
import 'wirelessadb/wireless_adb_dialog.dart';

class DeviceButton extends StatelessWidget {
  const DeviceButton({super.key});

  @override
  Widget build(BuildContext context) {
    final dm = context.watch<DeviceManager>();
    final selected = dm.selected;
    final label = selected?.id ?? 'No device';

    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (id) {
        if (id == '__manage_emulators__') {
          ManageEmulatorsDialog.show(context);
          return;
        }
        if (id == '__wireless_adb__') {
          WirelessAdbDialog.show(context);
          return;
        }
        final device = dm.devices.firstWhere(
          (d) => d.id == id,
          orElse: () => dm.devices.first,
        );
        dm.select(device);
      },
      offset: const Offset(0, 36),
      itemBuilder: (context) {
        final physicalDevices = dm.physicalDevices;
        final emulatorDevices = dm.emulatorDevices;
        final hasPhysical = physicalDevices.isNotEmpty;
        final hasEmulators = emulatorDevices.isNotEmpty;
        final noDevices = !hasPhysical && !hasEmulators;

        final items = <PopupMenuEntry<String>>[];

        if (noDevices) {
          items.add(const PopupMenuItem<String>(
            enabled: false,
            height: 32,
            child: Text('No devices connected'),
          ));
        } else {
          for (final device in physicalDevices) {
            final isSelected = dm.selected?.id == device.id;
            items.add(PopupMenuItem<String>(
              value: device.id,
              height: 32,
              child: Row(
                children: [
                  Icon(Icons.phone_android, size: 16, color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      device.id,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check, size: 16, color: Theme.of(context).colorScheme.primary),
                ],
              ),
            ));
          }
        }

        if (hasEmulators) {
          if (hasPhysical) {
            items.add(const PopupMenuDivider());
          }
          for (final device in emulatorDevices) {
            final isSelected = dm.selected?.id == device.id;
            items.add(PopupMenuItem<String>(
              value: device.id,
              height: 32,
              child: Row(
                children: [
                  Icon(Icons.computer, size: 16, color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      device.id,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check, size: 16, color: Theme.of(context).colorScheme.primary),
                ],
              ),
            ));
          }
        }

        items.add(const PopupMenuDivider());
        items.add(const PopupMenuItem<String>(
          value: '__manage_emulators__',
          height: 32,
          child: Row(
            children: [
              Icon(Icons.list_alt, size: 16),
              SizedBox(width: 8),
              Text('Manage Emulators'),
            ],
          ),
        ));
        items.add(const PopupMenuItem<String>(
          value: '__wireless_adb__',
          height: 32,
          child: Row(
            children: [
              Icon(Icons.wifi, size: 16),
              SizedBox(width: 8),
              Text('Wireless ADB'),
            ],
          ),
        ));

        return items;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down, size: 16, color: Theme.of(context).colorScheme.onSurface),
          ],
        ),
      ),
    );
  }
}