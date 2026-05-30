import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_statusbar_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysStatusbarPage extends StatelessWidget {
  const DumpsysStatusbarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys statusbar',
      adbCommand: 'adb shell dumpsys statusbar',
      fetchData: (id) => DumpsysStatusbarService.fetch(id),
    );
  }
}
