import 'package:flutter/material.dart';
import '../../services/commands/dumpsys_wallpaper_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysWallpaperPage extends StatelessWidget {
  const DumpsysWallpaperPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: 'dumpsys wallpaper',
      adbCommand: 'adb shell dumpsys wallpaper',
      fetchData: (id) => DumpsysWallpaperService.fetch(id),
    );
  }
}
