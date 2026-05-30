import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_connectivity_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysConnectivityPage extends StatelessWidget {
  const DumpsysConnectivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys connectivity',
      adbCommand: 'adb shell dumpsys connectivity',
      fetchData: (id) => DumpsysConnectivityService.fetch(id),
    );
  }
}
