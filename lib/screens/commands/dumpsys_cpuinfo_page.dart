import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_cpuinfo_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysCpuinfoPage extends StatelessWidget {
  const DumpsysCpuinfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys cpuinfo',
      adbCommand: 'adb shell dumpsys cpuinfo',
      fetchData: (id) => DumpsysCpuinfoService.fetch(id),
    );
  }
}
