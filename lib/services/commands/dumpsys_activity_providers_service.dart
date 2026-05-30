import 'dart:io';
import '../adb_manager.dart';

class DumpsysActivityProvidersService {
  static Future<String> fetch(String deviceId) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) return '';
    final result = await Process.run(adb, ['-s', deviceId, 'shell', 'dumpsys', 'activity', 'providers']);
    return result.stdout.toString();
  }
}
