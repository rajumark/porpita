import 'package:flutter/material.dart';
import '../../services/commands/dmesg_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DmesgPage extends StatelessWidget {
  const DmesgPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dmesg',
      adbCommand: 'adb shell dmesg',
      fetchData: (id) => DmesgService.fetch(id),
    );
  }
}
