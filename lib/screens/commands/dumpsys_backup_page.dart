import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_backup_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysBackupPage extends StatelessWidget {
  const DumpsysBackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys backup',
      adbCommand: 'adb shell dumpsys backup',
      fetchData: (id) => DumpsysBackupService.fetch(id),
    );
  }
}
