import 'package:flutter/material.dart';
import '../../services/commands/bugreport_service.dart';
import '../../widgets/data_screen_widgets.dart';

class BugreportPage extends StatelessWidget {
  const BugreportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'bugreport',
      adbCommand: 'adb shell bugreport',
      fetchData: (id) => BugreportService.fetch(id),
    );
  }
}
