import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_wifi_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysWifiPage extends StatelessWidget {
  const DumpsysWifiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys wifi',
      adbCommand: 'adb shell dumpsys wifi',
      fetchData: (id) => DumpsysWifiService.fetch(id),
    );
  }
}
