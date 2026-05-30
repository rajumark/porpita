import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_activity_top_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysActivityTopPage extends StatelessWidget {
  const DumpsysActivityTopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys activity top',
      adbCommand: 'adb shell dumpsys activity top',
      fetchData: (id) => DumpsysActivityTopService.fetch(id),
    );
  }
}
