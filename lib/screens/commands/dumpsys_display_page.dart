import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_display_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysDisplayPage extends StatelessWidget {
  const DumpsysDisplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys display',
      adbCommand: 'adb shell dumpsys display',
      fetchData: (id) => DumpsysDisplayService.fetch(id),
    );
  }
}
