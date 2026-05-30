import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_dropbox_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysDropboxPage extends StatelessWidget {
  const DumpsysDropboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys dropbox',
      adbCommand: 'adb shell dumpsys dropbox',
      fetchData: (id) => DumpsysDropboxService.fetch(id),
    );
  }
}
