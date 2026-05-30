import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_window_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysWindowPage extends StatelessWidget {
  const DumpsysWindowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys window',
      adbCommand: 'adb shell dumpsys window',
      fetchData: (id) => DumpsysWindowService.fetch(id),
    );
  }
}
