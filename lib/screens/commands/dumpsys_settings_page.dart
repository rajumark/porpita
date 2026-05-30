import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_settings_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysSettingsPage extends StatelessWidget {
  const DumpsysSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys settings',
      adbCommand: 'adb shell dumpsys settings',
      fetchData: (id) => DumpsysSettingsService.fetch(id),
    );
  }
}
