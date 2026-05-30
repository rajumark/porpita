import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_network_management_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysNetworkManagementPage extends StatelessWidget {
  const DumpsysNetworkManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys network_management',
      adbCommand: 'adb shell dumpsys network_management',
      fetchData: (id) => DumpsysNetworkManagementService.fetch(id),
    );
  }
}
