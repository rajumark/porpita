import 'package:flutter/material.dart';
import '../services/commands/call_logs_service.dart';
import '../widgets/data_screen_widgets.dart';

class CallLogsPage extends StatelessWidget {
  const CallLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'Call Logs',
      adbCommand: 'adb shell content query --uri content://call_log/calls',
      fetchData: (id) => CallLogsService.fetch(id),
    );
  }
}
