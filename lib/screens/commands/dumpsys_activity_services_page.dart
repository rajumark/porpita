import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_activity_services_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysActivityServicesPage extends StatelessWidget {
  const DumpsysActivityServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys activity services',
      adbCommand: 'adb shell dumpsys activity services',
      fetchData: (id) => DumpsysActivityServicesService.fetch(id),
    );
  }
}
