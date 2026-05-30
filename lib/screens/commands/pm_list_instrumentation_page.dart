import 'package:flutter/material.dart';
import '../../services/commands/pm_list_instrumentation_service.dart';
import '../../widgets/data_screen_widgets.dart';

class PmListInstrumentationPage extends StatelessWidget {
  const PmListInstrumentationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'pm list instrumentation',
      adbCommand: 'adb shell pm list instrumentation',
      fetchData: (id) => PmListInstrumentationService.fetch(id),
    );
  }
}
