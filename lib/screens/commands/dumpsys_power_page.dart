import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_power_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysPowerPage extends StatelessWidget {
  const DumpsysPowerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys power',
      adbCommand: 'adb shell dumpsys power',
      fetchData: (id) => DumpsysPowerService.fetch(id),
    );
  }
}
