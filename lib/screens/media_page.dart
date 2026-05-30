import 'package:flutter/material.dart';
import '../services/commands/media_service.dart';
import '../widgets/data_screen_widgets.dart';

class MediaPage extends StatelessWidget {
  const MediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'Media',
      adbCommand: 'adb shell content query --uri content://media/external/images/media',
      fetchData: (id) => MediaService.fetch(id),
    );
  }
}
