import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_activity_recents_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysActivityRecentsPage extends StatelessWidget {
  const DumpsysActivityRecentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys activity recents',
      adbCommand: 'adb shell dumpsys activity recents',
      fetchData: (id) => DumpsysActivityRecentsService.fetch(id),
    );
  }
}
