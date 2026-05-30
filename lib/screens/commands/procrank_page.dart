import 'package:flutter/material.dart';
import '../../services/commands/procrank_service.dart';
import '../../widgets/data_screen_widgets.dart';

class ProcrankPage extends StatelessWidget {
  const ProcrankPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'procrank',
      adbCommand: 'adb shell procrank',
      fetchData: (id) => ProcrankService.fetch(id),
    );
  }
}
