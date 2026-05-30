import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_location_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysLocationPage extends StatelessWidget {
  const DumpsysLocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys location',
      adbCommand: 'adb shell dumpsys location',
      fetchData: (id) => DumpsysLocationService.fetch(id),
    );
  }
}
