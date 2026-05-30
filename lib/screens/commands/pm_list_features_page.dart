import 'package:flutter/material.dart';
import '../../services/commands/pm_list_features_service.dart';
import '../../widgets/data_screen_widgets.dart';

class PmListFeaturesPage extends StatelessWidget {
  const PmListFeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'pm list features',
      adbCommand: 'adb shell pm list features',
      fetchData: (id) => PmListFeaturesService.fetch(id),
    );
  }
}
