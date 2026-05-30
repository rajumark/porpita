import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_appops_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysAppopsPage extends StatelessWidget {
  const DumpsysAppopsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys appops',
      adbCommand: 'adb shell dumpsys appops',
      fetchData: (id) => DumpsysAppopsService.fetch(id),
    );
  }
}
