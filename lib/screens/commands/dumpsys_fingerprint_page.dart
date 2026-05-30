import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_fingerprint_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysFingerprintPage extends StatelessWidget {
  const DumpsysFingerprintPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys fingerprint',
      adbCommand: 'adb shell dumpsys fingerprint',
      fetchData: (id) => DumpsysFingerprintService.fetch(id),
    );
  }
}
