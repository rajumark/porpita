import 'package:flutter/material.dart';
import '../../services/commands/getprop_service.dart';
import '../../widgets/data_screen_widgets.dart';

class GetpropPage extends StatelessWidget {
  const GetpropPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'getprop',
      adbCommand: 'adb shell getprop',
      fetchData: (id) => GetpropService.fetch(id),
    );
  }
}
