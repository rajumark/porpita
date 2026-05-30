import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_battery_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysBatteryPage extends StatelessWidget {
  const DumpsysBatteryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys battery',
      adbCommand: 'adb shell dumpsys battery',
      fetchData: (id) => DumpsysBatteryService.fetch(id),
    );
  }
}
