import 'package:flutter/material.dart';
import '../../services/commands/am_dumpheap_service.dart';
import '../../widgets/data_screen_widgets.dart';

class AmDumpheapPage extends StatelessWidget {
  const AmDumpheapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'am dumpheap',
      adbCommand: 'adb shell am dumpheap',
      fetchData: (id) => AmDumpheapService.fetch(id),
    );
  }
}
