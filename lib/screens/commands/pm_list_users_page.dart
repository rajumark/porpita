import 'package:flutter/material.dart';
import '../../services/commands/pm_list_users_service.dart';
import '../../widgets/data_screen_widgets.dart';

class PmListUsersPage extends StatelessWidget {
  const PmListUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'pm list users',
      adbCommand: 'adb shell pm list users',
      fetchData: (id) => PmListUsersService.fetch(id),
    );
  }
}
