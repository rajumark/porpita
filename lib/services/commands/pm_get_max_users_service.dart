import 'dart:io';
import '../adb_manager.dart';

class PmGetMaxUsersService {
  static Future<String> fetch(String deviceId) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) return '';
    final result = await Process.run(adb, ['-s', deviceId, 'shell', 'pm', 'get-max-users']);
    return result.stdout.toString();
  }
}
