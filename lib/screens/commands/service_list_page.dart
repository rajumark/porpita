import 'package:flutter/material.dart';
import '../../services/commands/service_list_service.dart';
import '../../widgets/data_screen_widgets.dart';

class ServiceListPage extends StatelessWidget {
  const ServiceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'service list',
      adbCommand: 'adb shell service list',
      fetchData: (id) => ServiceListService.fetch(id),
    );
  }
}
