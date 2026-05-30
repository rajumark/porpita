import 'package:flutter/material.dart';
import '../../services/commands/cat_proc_uptime_service.dart';
import '../../widgets/data_screen_widgets.dart';

class CatProcUptimePage extends StatelessWidget {
  const CatProcUptimePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'cat /proc/uptime',
      adbCommand: 'adb shell cat /proc/uptime',
      fetchData: (id) => CatProcUptimeService.fetch(id),
    );
  }
}
