import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_jobscheduler_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysJobschedulerPage extends StatelessWidget {
  const DumpsysJobschedulerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys jobscheduler',
      adbCommand: 'adb shell dumpsys jobscheduler',
      fetchData: (id) => DumpsysJobschedulerService.fetch(id),
    );
  }
}
