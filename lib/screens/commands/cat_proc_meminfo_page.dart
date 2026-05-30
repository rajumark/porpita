import 'package:flutter/material.dart';
import '../../services/commands/cat_proc_meminfo_service.dart';
import '../../widgets/data_screen_widgets.dart';

class CatProcMeminfoPage extends StatelessWidget {
  const CatProcMeminfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'cat /proc/meminfo',
      adbCommand: 'adb shell cat /proc/meminfo',
      fetchData: (id) => CatProcMeminfoService.fetch(id),
    );
  }
}
