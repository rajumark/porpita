import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_bugreport_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysBugreportPage extends StatelessWidget {
  const DumpsysBugreportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys bugreport',
      adbCommand: 'adb shell dumpsys bugreport',
      fetchData: (id) => DumpsysBugreportService.fetch(id),
    );
  }
}
