import 'package:flutter/material.dart';
import '../services/commands/messages_service.dart';
import '../widgets/data_screen_widgets.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'Messages',
      adbCommand: 'adb shell content query --uri content://sms',
      fetchData: (id) => MessagesService.fetch(id),
    );
  }
}
