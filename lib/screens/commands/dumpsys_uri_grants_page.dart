import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_uri_grants_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysUriGrantsPage extends StatelessWidget {
  const DumpsysUriGrantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys uri_grants',
      adbCommand: 'adb shell dumpsys uri_grants',
      fetchData: (id) => DumpsysUriGrantsService.fetch(id),
    );
  }
}
