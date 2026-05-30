import 'package:flutter/material.dart';
import '../../services/commands/date_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DatePage extends StatelessWidget {
  const DatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'date',
      adbCommand: 'adb shell date',
      fetchData: (id) => DateService.fetch(id),
    );
  }
}
