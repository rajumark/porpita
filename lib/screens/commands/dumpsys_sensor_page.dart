import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_sensor_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysSensorPage extends StatelessWidget {
  const DumpsysSensorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys sensor',
      adbCommand: 'adb shell dumpsys sensor',
      fetchData: (id) => DumpsysSensorService.fetch(id),
    );
  }
}
