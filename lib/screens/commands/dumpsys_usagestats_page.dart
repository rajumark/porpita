import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_usagestats_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysUsagestatsPage extends StatelessWidget {
  const DumpsysUsagestatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys usagestats',
      adbCommand: 'adb shell dumpsys usagestats',
      fetchData: (id) => DumpsysUsagestatsService.fetch(id),
    );
  }
}
