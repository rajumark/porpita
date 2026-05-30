import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_device_policy_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysDevicePolicyPage extends StatelessWidget {
  const DumpsysDevicePolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys device_policy',
      adbCommand: 'adb shell dumpsys device_policy',
      fetchData: (id) => DumpsysDevicePolicyService.fetch(id),
    );
  }
}
