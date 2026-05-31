import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:porpita/services/device_manager.dart';
import 'package:porpita/services/adb_manager.dart';

class AppsListScreen extends StatelessWidget {
  const AppsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dm = context.watch<DeviceManager>();
    final adb = context.watch<AdbManager>();
    final device = dm.selected;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            device?.id ?? 'No device',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            adb.adbPath ?? 'No adb path',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
