import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../../../../services/commands/adb_exec_service.dart';

class StatusbarScreenshotService {
  static String? _cachedPath;

  static Future<String?> capture(String deviceId) async {
    await AdbExecService.run(deviceId, ['screencap', '-p', '/sdcard/statusbar_screenshot.png']);

    final appDir = await getApplicationSupportDirectory();
    final dir = Directory('${appDir.path}/statusbar_screenshots');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final localPath = '${dir.path}/screenshot.png';
    await AdbExecService.runAdb(deviceId, ['pull', '/sdcard/statusbar_screenshot.png', localPath]);

    final file = File(localPath);
    if (await file.exists()) {
      _cachedPath = localPath;
      return localPath;
    }
    return null;
  }

  static Future<int?> getStatusBarHeight(String deviceId) async {
    final output = await AdbExecService.run(deviceId, ['dumpsys', 'window', 'policy']);
    final match = RegExp(r'mStatusBarHeight[=:](\d+)').firstMatch(output);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }

    final stableMatch = RegExp(r'stableInsets.*?top[=:](\d+)', caseSensitive: false).firstMatch(output);
    if (stableMatch != null) {
      return int.tryParse(stableMatch.group(1)!);
    }

    final displayOutput = await AdbExecService.run(deviceId, ['dumpsys', 'window', 'displays']);
    final appMatch = RegExp(r'app:\s*(\d+)x(\d+)').firstMatch(displayOutput);
    final realMatch = RegExp(r'real:\s*(\d+)x(\d+)').firstMatch(displayOutput);
    if (appMatch != null && realMatch != null) {
      final appH = int.tryParse(appMatch.group(2)!);
      final realH = int.tryParse(realMatch.group(2)!);
      if (appH != null && realH != null && realH > appH) {
        return realH - appH;
      }
    }

    return null;
  }

  static String? get cachedPath => _cachedPath;
}
