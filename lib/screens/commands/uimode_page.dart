import 'package:flutter/material.dart';
import '../../services/commands/uimode_service.dart';
import '../../widgets/data_screen_widgets.dart';

class UimodePage extends StatelessWidget {
  const UimodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'cmd uimode',
      adbCommand: 'adb shell cmd uimode',
      fetchData: (id) => UimodeService.fetch(id),
    );
  }
}
