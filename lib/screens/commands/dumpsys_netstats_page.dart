import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_netstats_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysNetstatsPage extends StatelessWidget {
  const DumpsysNetstatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys netstats',
      adbCommand: 'adb shell dumpsys netstats',
      fetchData: (id) => DumpsysNetstatsService.fetch(id),
    );
  }
}
