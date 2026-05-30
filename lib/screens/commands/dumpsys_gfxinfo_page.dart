import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_gfxinfo_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysGfxinfoPage extends StatelessWidget {
  const DumpsysGfxinfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys gfxinfo',
      adbCommand: 'adb shell dumpsys gfxinfo',
      fetchData: (id) => DumpsysGfxinfoService.fetch(id),
    );
  }
}
