import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_account_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysAccountPage extends StatelessWidget {
  const DumpsysAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys account',
      adbCommand: 'adb shell dumpsys account',
      fetchData: (id) => DumpsysAccountService.fetch(id),
    );
  }
}
