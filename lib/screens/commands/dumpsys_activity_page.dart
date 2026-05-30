import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_activity_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysActivityPage extends StatelessWidget {
  const DumpsysActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys activity',
      adbCommand: 'adb shell dumpsys activity',
      fetchData: (id) => DumpsysActivityService.fetch(id),
    );
  }
}
