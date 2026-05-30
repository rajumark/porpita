import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_activity_providers_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysActivityProvidersPage extends StatelessWidget {
  const DumpsysActivityProvidersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys activity providers',
      adbCommand: 'adb shell dumpsys activity providers',
      fetchData: (id) => DumpsysActivityProvidersService.fetch(id),
    );
  }
}
