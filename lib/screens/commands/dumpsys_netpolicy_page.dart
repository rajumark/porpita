import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_netpolicy_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysNetpolicyPage extends StatelessWidget {
  const DumpsysNetpolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys netpolicy',
      adbCommand: 'adb shell dumpsys netpolicy',
      fetchData: (id) => DumpsysNetpolicyService.fetch(id),
    );
  }
}
