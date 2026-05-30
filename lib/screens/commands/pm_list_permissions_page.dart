import 'package:flutter/material.dart';
import '../../services/commands/pm_list_permissions_service.dart';
import '../../widgets/data_screen_widgets.dart';

class PmListPermissionsPage extends StatelessWidget {
  const PmListPermissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'pm list permissions',
      adbCommand: 'adb shell pm list permissions',
      fetchData: (id) => PmListPermissionsService.fetch(id),
    );
  }
}
