import 'package:flutter/material.dart';
import '../../services/commands/sysfs_service.dart';
import '../../widgets/data_screen_widgets.dart';

class SysfsPage extends StatelessWidget {
  const SysfsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'sysfs',
      adbCommand: 'adb shell cat /sys/...',
      fetchData: (id) => SysfsService.fetch(id),
    );
  }
}
