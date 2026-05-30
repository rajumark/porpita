import 'dart:io';
import '../adb_manager.dart';

class DumpsysDropboxService {
  static Future<String> fetch(String deviceId) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) return '';
    final result = await Process.run(adb, ['-s', deviceId, 'shell', 'dumpsys', 'dropbox']);
    return result.stdout.toString();
  }
}
