import 'package:flutter/material.dart';
import '../../services/commands/cat_proc_net_dev_service.dart';
import '../../widgets/data_screen_widgets.dart';

class CatProcNetDevPage extends StatelessWidget {
  const CatProcNetDevPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'cat /proc/net/dev',
      adbCommand: 'adb shell cat /proc/net/dev',
      fetchData: (id) => CatProcNetDevService.fetch(id),
    );
  }
}
