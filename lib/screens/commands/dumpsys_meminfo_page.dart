import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_meminfo_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysMeminfoPage extends StatelessWidget {
  const DumpsysMeminfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys meminfo',
      adbCommand: 'adb shell dumpsys meminfo',
      fetchData: (id) => DumpsysMeminfoService.fetch(id),
    );
  }
}
