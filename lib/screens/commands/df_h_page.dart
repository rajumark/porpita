import 'package:flutter/material.dart';
import '../../services/commands/df_h_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DfHPage extends StatelessWidget {
  const DfHPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'df -h',
      adbCommand: 'adb shell df -h',
      fetchData: (id) => DfHService.fetch(id),
    );
  }
}
