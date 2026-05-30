import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysPage extends StatelessWidget {
  const DumpsysPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys',
      adbCommand: 'adb shell dumpsys',
      fetchData: (id) => DumpsysService.fetch(id),
    );
  }
}
