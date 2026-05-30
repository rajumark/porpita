import 'package:flutter/material.dart';
import '../../services/commands/pm_get_max_users_service.dart';
import '../../widgets/data_screen_widgets.dart';

class PmGetMaxUsersPage extends StatelessWidget {
  const PmGetMaxUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'pm get-max-users',
      adbCommand: 'adb shell pm get-max-users',
      fetchData: (id) => PmGetMaxUsersService.fetch(id),
    );
  }
}
