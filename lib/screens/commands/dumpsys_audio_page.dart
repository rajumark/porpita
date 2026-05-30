import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_audio_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysAudioPage extends StatelessWidget {
  const DumpsysAudioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys audio',
      adbCommand: 'adb shell dumpsys audio',
      fetchData: (id) => DumpsysAudioService.fetch(id),
    );
  }
}
