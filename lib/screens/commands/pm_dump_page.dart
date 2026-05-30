import 'package:flutter/material.dart';
import '../../services/commands/pm_dump_service.dart';
import '../../widgets/data_screen_widgets.dart';

class PmDumpPage extends StatelessWidget {
  const PmDumpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'pm dump',
      adbCommand: 'adb shell pm dump',
      fetchData: (id) => PmDumpService.fetch(id),
    );
  }
}
