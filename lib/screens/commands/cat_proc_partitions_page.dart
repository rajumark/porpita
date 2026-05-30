import 'package:flutter/material.dart';
import '../../services/commands/cat_proc_partitions_service.dart';
import '../../widgets/data_screen_widgets.dart';

class CatProcPartitionsPage extends StatelessWidget {
  const CatProcPartitionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'cat /proc/partitions',
      adbCommand: 'adb shell cat /proc/partitions',
      fetchData: (id) => CatProcPartitionsService.fetch(id),
    );
  }
}
