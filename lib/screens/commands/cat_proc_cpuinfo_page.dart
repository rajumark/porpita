import 'package:flutter/material.dart';
import '../../services/commands/cat_proc_cpuinfo_service.dart';
import '../../widgets/data_screen_widgets.dart';

class CatProcCpuinfoPage extends StatelessWidget {
  const CatProcCpuinfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'cat /proc/cpuinfo',
      adbCommand: 'adb shell cat /proc/cpuinfo',
      fetchData: (id) => CatProcCpuinfoService.fetch(id),
    );
  }
}
