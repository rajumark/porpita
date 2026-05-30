import 'package:flutter/material.dart';
import '../../services/commands/cmd_overlay_list_service.dart';
import '../../widgets/data_screen_widgets.dart';

class CmdOverlayListPage extends StatelessWidget {
  const CmdOverlayListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'cmd overlay list',
      adbCommand: 'adb shell cmd overlay list',
      fetchData: (id) => CmdOverlayListService.fetch(id),
    );
  }
}
