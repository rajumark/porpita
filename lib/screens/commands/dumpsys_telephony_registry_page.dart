import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_telephony_registry_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysTelephonyRegistryPage extends StatelessWidget {
  const DumpsysTelephonyRegistryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys telephony.registry',
      adbCommand: 'adb shell dumpsys telephony.registry',
      fetchData: (id) => DumpsysTelephonyRegistryService.fetch(id),
    );
  }
}
