import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_l_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysLPage extends StatelessWidget {
  const DumpsysLPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys -l',
      adbCommand: 'adb shell dumpsys -l',
      fetchData: (id) => DumpsysLService.fetch(id),
    );
  }
}
