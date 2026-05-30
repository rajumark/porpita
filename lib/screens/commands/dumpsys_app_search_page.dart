import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_app_search_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysAppSearchPage extends StatelessWidget {
  const DumpsysAppSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys app_search',
      adbCommand: 'adb shell dumpsys app_search',
      fetchData: (id) => DumpsysAppSearchService.fetch(id),
    );
  }
}
