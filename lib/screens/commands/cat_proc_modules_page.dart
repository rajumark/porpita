import 'package:flutter/material.dart';
import '../../services/commands/cat_proc_modules_service.dart';
import '../../widgets/data_screen_widgets.dart';

class CatProcModulesPage extends StatelessWidget {
  const CatProcModulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'cat /proc/modules',
      adbCommand: 'adb shell cat /proc/modules',
      fetchData: (id) => CatProcModulesService.fetch(id),
    );
  }
}
