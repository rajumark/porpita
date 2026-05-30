import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_content_capture_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysContentCapturePage extends StatelessWidget {
  const DumpsysContentCapturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys content_capture',
      adbCommand: 'adb shell dumpsys content_capture',
      fetchData: (id) => DumpsysContentCaptureService.fetch(id),
    );
  }
}
