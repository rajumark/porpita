import 'package:flutter/material.dart';
import '../../services/commands/cat_proc_version_service.dart';
import '../../widgets/data_screen_widgets.dart';

class CatProcVersionPage extends StatelessWidget {
  const CatProcVersionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'cat /proc/version',
      adbCommand: 'adb shell cat /proc/version',
      fetchData: (id) => CatProcVersionService.fetch(id),
    );
  }
}
