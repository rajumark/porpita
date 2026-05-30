import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_media_session_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysMediaSessionPage extends StatelessWidget {
  const DumpsysMediaSessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys media_session',
      adbCommand: 'adb shell dumpsys media_session',
      fetchData: (id) => DumpsysMediaSessionService.fetch(id),
    );
  }
}
