import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_lights_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysLightsPage extends StatelessWidget {
  const DumpsysLightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys lights',
      adbCommand: 'adb shell dumpsys lights',
      fetchData: (id) => DumpsysLightsService.fetch(id),
    );
  }
}
