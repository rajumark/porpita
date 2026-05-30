import 'dart:io';

import 'adb_manager.dart';

/// Service that sends Android settings intents via ADB.
class SettingsService {
  const SettingsService._();

  /// Launches a settings screen on the connected device [deviceId] using the
  /// given [intent] action string (e.g. `android.settings.WIFI_SETTINGS`).
  static Future<bool> openSetting({
    required String deviceId,
    required String intent,
  }) async {
    final adbPath = AdbManager.instance.adbPath;
    if (adbPath == null) return false;

    try {
      final result = await Process.run(adbPath, [
        '-s', deviceId,
        'shell', 'am', 'start', '-a', intent,
      ]);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }
}
