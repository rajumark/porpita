import 'package:flutter/material.dart';
import '../../services/commands/pm_list_libraries_service.dart';
import '../../widgets/data_screen_widgets.dart';

class PmListLibrariesPage extends StatelessWidget {
  const PmListLibrariesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'pm list libraries',
      adbCommand: 'adb shell pm list libraries',
      fetchData: (id) => PmListLibrariesService.fetch(id),
    );
  }
}
