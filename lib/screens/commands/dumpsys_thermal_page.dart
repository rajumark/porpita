import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_thermal_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysThermalPage extends StatelessWidget {
  const DumpsysThermalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys thermal',
      adbCommand: 'adb shell dumpsys thermal',
      fetchData: (id) => DumpsysThermalService.fetch(id),
    );
  }
}
