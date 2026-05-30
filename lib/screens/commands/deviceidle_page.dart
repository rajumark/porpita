import 'package:flutter/material.dart';
import '../../services/commands/deviceidle_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DeviceidlePage extends StatelessWidget {
  const DeviceidlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'cmd deviceidle',
      adbCommand: 'adb shell cmd deviceidle get deep',
      fetchData: (id) => DeviceidleService.fetch(id),
    );
  }
}
