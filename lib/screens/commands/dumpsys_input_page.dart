import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_input_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysInputPage extends StatelessWidget {
  const DumpsysInputPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys input',
      adbCommand: 'adb shell dumpsys input',
      fetchData: (id) => DumpsysInputService.fetch(id),
    );
  }
}
