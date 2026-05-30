import 'package:flutter/material.dart';
import '../../services/commands/svc_usb_service.dart';
import '../../widgets/data_screen_widgets.dart';

class SvcUsbPage extends StatelessWidget {
  const SvcUsbPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'svc usb',
      adbCommand: 'adb shell svc usb getFunctions',
      fetchData: (id) => SvcUsbService.fetch(id),
    );
  }
}
