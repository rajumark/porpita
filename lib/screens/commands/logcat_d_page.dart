import 'package:flutter/material.dart';
import '../../services/commands/logcat_d_service.dart';
import '../../widgets/data_screen_widgets.dart';

class LogcatDPage extends StatelessWidget {
  const LogcatDPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'logcat -d',
      adbCommand: 'adb shell logcat -d',
      fetchData: (id) => LogcatDService.fetch(id),
    );
  }
}
