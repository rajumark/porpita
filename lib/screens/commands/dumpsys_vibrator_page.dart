import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_vibrator_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysVibratorPage extends StatelessWidget {
  const DumpsysVibratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys vibrator',
      adbCommand: 'adb shell dumpsys vibrator',
      fetchData: (id) => DumpsysVibratorService.fetch(id),
    );
  }
}
