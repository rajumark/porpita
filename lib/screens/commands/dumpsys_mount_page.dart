import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_mount_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysMountPage extends StatelessWidget {
  const DumpsysMountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys mount',
      adbCommand: 'adb shell dumpsys mount',
      fetchData: (id) => DumpsysMountService.fetch(id),
    );
  }
}
