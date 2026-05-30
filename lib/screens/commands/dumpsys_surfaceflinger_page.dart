import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_surfaceflinger_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysSurfaceflingerPage extends StatelessWidget {
  const DumpsysSurfaceflingerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys SurfaceFlinger',
      adbCommand: 'adb shell dumpsys SurfaceFlinger',
      fetchData: (id) => DumpsysSurfaceflingerService.fetch(id),
    );
  }
}
