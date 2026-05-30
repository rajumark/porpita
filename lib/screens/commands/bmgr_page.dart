import 'package:flutter/material.dart';
import '../../services/commands/bmgr_service.dart';
import '../../widgets/data_screen_widgets.dart';

class BmgrPage extends StatelessWidget {
  const BmgrPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'bmgr',
      adbCommand: 'adb shell bmgr enabled',
      fetchData: (id) => BmgrService.fetch(id),
    );
  }
}
