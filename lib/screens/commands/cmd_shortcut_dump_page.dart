import 'package:flutter/material.dart';
import '../../services/commands/cmd_shortcut_dump_service.dart';
import '../../widgets/data_screen_widgets.dart';

class CmdShortcutDumpPage extends StatelessWidget {
  const CmdShortcutDumpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'cmd shortcut dump',
      adbCommand: 'adb shell cmd shortcut dump',
      fetchData: (id) => CmdShortcutDumpService.fetch(id),
    );
  }
}
