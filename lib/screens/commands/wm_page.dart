import 'package:flutter/material.dart';
import '../../services/commands/wm_service.dart';
import '../../widgets/data_screen_widgets.dart';

class WmPage extends StatelessWidget {
  const WmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'wm',
      adbCommand: 'adb shell wm size && wm density && wm rotation',
      fetchData: (id) => WmService.fetch(id),
    );
  }
}
