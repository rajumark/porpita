import 'dart:io';

import 'package:porpita/services/commands/adb_exec_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class QuickPanelService {
  static Future<String> pressBack(String deviceId) {
    return AdbExecService.run(deviceId, ['input', 'keyevent', '4']);
  }

  static Future<String> pressHome(String deviceId) {
    return AdbExecService.run(deviceId, ['input', 'keyevent', '3']);
  }

  static Future<String> pressRecent(String deviceId) {
    return AdbExecService.run(deviceId, ['input', 'keyevent', '187']);
  }

  static Future<String> pressVolumeUp(String deviceId) {
    return AdbExecService.run(deviceId, ['input', 'keyevent', '24']);
  }

  static Future<String> pressVolumeDown(String deviceId) {
    return AdbExecService.run(deviceId, ['input', 'keyevent', '25']);
  }

  static Future<String> mediaPlay(String deviceId) {
    return AdbExecService.run(deviceId, ['input', 'keyevent', '126']);
  }

  static Future<String> mediaPause(String deviceId) {
    return AdbExecService.run(deviceId, ['input', 'keyevent', '127']);
  }

  static Future<String> volumeMute(String deviceId) {
    return AdbExecService.run(deviceId, ['input', 'keyevent', '164']);
  }

  static Future<String> openSettings(String deviceId) {
    return AdbExecService.run(deviceId, [
      'am', 'start', '-a', 'android.settings.SETTINGS',
    ]);
  }

  static Future<String> pressPower(String deviceId) {
    return AdbExecService.run(deviceId, ['input', 'keyevent', '26']);
  }

  static Future<String> longPressPower(String deviceId) {
    return AdbExecService.run(deviceId, ['input', 'keyevent', '--longpress', '26']);
  }

  static Future<void> captureScreenshot(String deviceId) async {
    await AdbExecService.run(deviceId, ['screencap', '-p', '/sdcard/screenshot.png']);
    final dir = await getDownloadsDirectory();
    if (dir != null) {
      final filePath = '${dir.path}/screenshot_${DateTime.now().millisecondsSinceEpoch}.png';
      await AdbExecService.runAdb(deviceId, ['pull', '/sdcard/screenshot.png', filePath]);
      final file = File(filePath);
      if (await file.exists()) {
        launchUrl(Uri.file(dir.path), mode: LaunchMode.externalApplication);
      }
    }
  }

  static Future<String> expandQuickSettings(String deviceId) {
    return AdbExecService.run(deviceId, ['cmd', 'statusbar', 'expand-settings']);
  }

  static Future<String> expandNotifications(String deviceId) {
    return AdbExecService.run(deviceId, ['cmd', 'statusbar', 'expand-notifications']);
  }

  static Future<String> collapseAll(String deviceId) {
    return AdbExecService.run(deviceId, ['cmd', 'statusbar', 'collapse']);
  }

  static Future<String> openDeveloperSettings(String deviceId) {
    return AdbExecService.run(deviceId, [
      'am', 'start', '-a', 'android.settings.APPLICATION_DEVELOPMENT_SETTINGS',
    ]);
  }

  static Future<String> showTaps(String deviceId) {
    return AdbExecService.run(deviceId, ['settings', 'put', 'system', 'show_touches', '1']);
  }

  static Future<String> hideTaps(String deviceId) {
    return AdbExecService.run(deviceId, ['settings', 'put', 'system', 'show_touches', '0']);
  }
}
