import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_activity_processes_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysActivityProcessesPage extends StatelessWidget {
  const DumpsysActivityProcessesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys activity processes',
      adbCommand: 'adb shell dumpsys activity processes',
      fetchData: (id) => DumpsysActivityProcessesService.fetch(id),
    );
  }
}
