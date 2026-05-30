import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_batterystats_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysBatterystatsPage extends StatelessWidget {
  const DumpsysBatterystatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys batterystats',
      adbCommand: 'adb shell dumpsys batterystats',
      fetchData: (id) => DumpsysBatterystatsService.fetch(id),
    );
  }
}
