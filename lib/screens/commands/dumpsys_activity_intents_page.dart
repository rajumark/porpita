import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_activity_intents_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysActivityIntentsPage extends StatelessWidget {
  const DumpsysActivityIntentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys activity intents',
      adbCommand: 'adb shell dumpsys activity intents',
      fetchData: (id) => DumpsysActivityIntentsService.fetch(id),
    );
  }
}
