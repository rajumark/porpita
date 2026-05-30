import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_storagestats_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysStoragestatsPage extends StatelessWidget {
  const DumpsysStoragestatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys storagestats',
      adbCommand: 'adb shell dumpsys storagestats',
      fetchData: (id) => DumpsysStoragestatsService.fetch(id),
    );
  }
}
