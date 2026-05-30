import 'package:flutter/material.dart';
import '../../services/commands/safety_center_service.dart';
import '../../widgets/data_screen_widgets.dart';

class SafetyCenterPage extends StatelessWidget {
  const SafetyCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'cmd safety_center',
      adbCommand: 'adb shell cmd safety_center package-name',
      fetchData: (id) => SafetyCenterService.fetch(id),
    );
  }
}
