import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_procstats_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysProcstatsPage extends StatelessWidget {
  const DumpsysProcstatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys procstats',
      adbCommand: 'adb shell dumpsys procstats',
      fetchData: (id) => DumpsysProcstatsService.fetch(id),
    );
  }
}
