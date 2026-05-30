import 'package:flutter/material.dart';
import '../../services/commands/magisk_service.dart';
import '../../widgets/data_screen_widgets.dart';

class MagiskPage extends StatelessWidget {
  const MagiskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'magisk',
      adbCommand: 'adb shell magisk -c',
      fetchData: (id) => MagiskService.fetch(id),
    );
  }
}
