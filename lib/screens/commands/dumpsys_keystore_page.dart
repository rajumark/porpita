import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_keystore_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysKeystorePage extends StatelessWidget {
  const DumpsysKeystorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys keystore',
      adbCommand: 'adb shell dumpsys keystore',
      fetchData: (id) => DumpsysKeystoreService.fetch(id),
    );
  }
}
