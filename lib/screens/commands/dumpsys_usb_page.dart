import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_usb_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysUsbPage extends StatelessWidget {
  const DumpsysUsbPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys usb',
      adbCommand: 'adb shell dumpsys usb',
      fetchData: (id) => DumpsysUsbService.fetch(id),
    );
  }
}
