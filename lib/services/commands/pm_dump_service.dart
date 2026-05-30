import 'dart:io';
import '../adb_manager.dart';

class PmDumpService {
  static Future<String> fetch(String deviceId) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) return '';
    final result = await Process.run(adb, ['-s', deviceId, 'shell', 'pm', 'dump']);
    return result.stdout.toString();
  }
}
