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

  static Future<StatusbarInfo?> getStatusBarInfo(String deviceId) async {
    // 1. Try dumpsys window (modern Android way to get statusBars frame/insets/visibility)
    final windowOutput = await AdbExecService.run(deviceId, ['dumpsys', 'window']);
    
    // Pattern A: type=statusBars frame=[left,top][right,bottom] visible=true|false
    final frameMatch = RegExp(r'type=statusBars.*?frame=\[(\d+),(\d+)\]\[(\d+),(\d+)\](?:\s+visible=(true|false))?', caseSensitive: false)
        .firstMatch(windowOutput);
    if (frameMatch != null) {
      final top = int.tryParse(frameMatch.group(2)!);
      final bottom = int.tryParse(frameMatch.group(4)!);
      final visibleStr = frameMatch.group(5);
      final visible = visibleStr == null || visibleStr.toLowerCase() == 'true';
      if (top != null && bottom != null && bottom > top) {
        return StatusbarInfo(height: bottom - top, visible: visible);
      }
    }

    // Pattern B: type=statusBars ... insetsSize=Insets{left=0, top=142, right=0, bottom=0}
    final insetsMatch = RegExp(r'type=statusBars.*?insetsSize=Insets\{[^}]*?top=(\d+)', caseSensitive: false)
        .firstMatch(windowOutput);
    if (insetsMatch != null) {
      final top = int.tryParse(insetsMatch.group(1)!);
      if (top != null && top > 0) {
        return StatusbarInfo(height: top, visible: true);
      }
    }

    final output = await AdbExecService.run(deviceId, ['dumpsys', 'window', 'policy']);
    final match = RegExp(r'mStatusBarHeight[=:](\d+)').firstMatch(output);
    if (match != null) {
      final val = int.tryParse(match.group(1)!);
      if (val != null) return StatusbarInfo(height: val, visible: true);
    }

    final stableMatch = RegExp(r'stableInsets.*?top[=:](\d+)', caseSensitive: false).firstMatch(output);
    if (stableMatch != null) {
      final val = int.tryParse(stableMatch.group(1)!);
      if (val != null) return StatusbarInfo(height: val, visible: true);
    }

    final displayOutput = await AdbExecService.run(deviceId, ['dumpsys', 'window', 'displays']);
    final appMatch = RegExp(r'app:\s*(\d+)x(\d+)').firstMatch(displayOutput);
    final realMatch = RegExp(r'real:\s*(\d+)x(\d+)').firstMatch(displayOutput);
    if (appMatch != null && realMatch != null) {
      final appH = int.tryParse(appMatch.group(2)!);
      final realH = int.tryParse(realMatch.group(2)!);
      if (appH != null && realH != null && realH > appH) {
        return StatusbarInfo(height: realH - appH, visible: true);
      }
    }

    return null;
  }

  static String? get cachedPath => _cachedPath;
}

class StatusbarInfo {
  final int height;
  final bool visible;

  const StatusbarInfo({required this.height, required this.visible});
}
