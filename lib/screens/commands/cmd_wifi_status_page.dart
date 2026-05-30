import 'package:flutter/material.dart';
import '../../services/commands/cmd_wifi_status_service.dart';
import '../../widgets/data_screen_widgets.dart';

class CmdWifiStatusPage extends StatelessWidget {
  const CmdWifiStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'cmd wifi status',
      adbCommand: 'adb shell cmd wifi status',
      fetchData: (id) => CmdWifiStatusService.fetch(id),
    );
  }
}
