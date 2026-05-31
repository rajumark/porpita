import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/device_manager.dart';

class DeviceButton extends StatelessWidget {
  const DeviceButton({super.key});

  @override
  Widget build(BuildContext context) {
    final dm = context.watch<DeviceManager>();
    final selected = dm.selected;
    final label = selected?.id ?? 'No device';

    return PopupMenuButton<String>(
      onSelected: (id) {
        final device = dm.devices.firstWhere(
          (d) => d.id == id,
          orElse: () => dm.devices.first,
        );
        dm.select(device);
      },
      offset: const Offset(0, 36),
      itemBuilder: (context) {
        if (dm.devices.isEmpty) {
          return [
            const PopupMenuItem<String>(
              enabled: false,
              child: Text('No devices connected'),
            ),
          ];
        }
        return dm.devices.map((device) {
          final isSelected = dm.selected?.id == device.id;
          return PopupMenuItem<String>(
            value: device.id,
            child: Row(
              children: [
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
          );
        }).toList();
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
