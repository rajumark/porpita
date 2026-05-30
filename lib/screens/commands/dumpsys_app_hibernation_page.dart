import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_app_hibernation_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysAppHibernationPage extends StatelessWidget {
  const DumpsysAppHibernationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys app_hibernation',
      adbCommand: 'adb shell dumpsys app_hibernation',
      fetchData: (id) => DumpsysAppHibernationService.fetch(id),
    );
  }
}
