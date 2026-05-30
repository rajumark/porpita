import 'package:flutter/material.dart';
import '../../services/commands/telecom_service.dart';
import '../../widgets/data_screen_widgets.dart';

class TelecomPage extends StatelessWidget {
  const TelecomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'telecom',
      adbCommand: 'adb shell telecom get-system-dialer',
      fetchData: (id) => TelecomService.fetch(id),
    );
  }
}
