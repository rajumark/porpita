import 'package:flutter/material.dart';
import '../../services/commands/cmd_package_compile_l_service.dart';
import '../../widgets/data_screen_widgets.dart';

class CmdPackageCompileLPage extends StatelessWidget {
  const CmdPackageCompileLPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'cmd package compile -l',
      adbCommand: 'adb shell cmd package compile -l',
      fetchData: (id) => CmdPackageCompileLService.fetch(id),
    );
  }
}
