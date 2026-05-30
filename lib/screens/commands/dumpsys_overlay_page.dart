import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_overlay_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysOverlayPage extends StatelessWidget {
  const DumpsysOverlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys overlay',
      adbCommand: 'adb shell dumpsys overlay',
      fetchData: (id) => DumpsysOverlayService.fetch(id),
    );
  }
}
