import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_alarm_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysAlarmPage extends StatelessWidget {
  const DumpsysAlarmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys alarm',
      adbCommand: 'adb shell dumpsys alarm',
      fetchData: (id) => DumpsysAlarmService.fetch(id),
    );
  }
}
