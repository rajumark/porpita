import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_bluetooth_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysBluetoothPage extends StatelessWidget {
  const DumpsysBluetoothPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys bluetooth',
      adbCommand: 'adb shell dumpsys bluetooth',
      fetchData: (id) => DumpsysBluetoothService.fetch(id),
    );
  }
}
