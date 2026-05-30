import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_shortcut_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysShortcutPage extends StatelessWidget {
  const DumpsysShortcutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys shortcut',
      adbCommand: 'adb shell dumpsys shortcut',
      fetchData: (id) => DumpsysShortcutService.fetch(id),
    );
  }
}
