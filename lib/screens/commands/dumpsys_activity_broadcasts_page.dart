import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_activity_broadcasts_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysActivityBroadcastsPage extends StatelessWidget {
  const DumpsysActivityBroadcastsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys activity broadcasts',
      adbCommand: 'adb shell dumpsys activity broadcasts',
      fetchData: (id) => DumpsysActivityBroadcastsService.fetch(id),
    );
  }
}
