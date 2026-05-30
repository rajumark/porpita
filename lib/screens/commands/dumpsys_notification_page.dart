import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_notification_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysNotificationPage extends StatelessWidget {
  const DumpsysNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys notification',
      adbCommand: 'adb shell dumpsys notification',
      fetchData: (id) => DumpsysNotificationService.fetch(id),
    );
  }
}
