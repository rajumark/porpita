import 'package:flutter/material.dart';
import '../../services/commands/reboot_readiness_service.dart';
import '../../widgets/data_screen_widgets.dart';

class RebootReadinessPage extends StatelessWidget {
  const RebootReadinessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'cmd reboot_readiness',
      adbCommand: 'adb shell cmd reboot_readiness check-interactivity-state',
      fetchData: (id) => RebootReadinessService.fetch(id),
    );
  }
}
