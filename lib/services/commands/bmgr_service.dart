import 'dart:io';
import '../adb_manager.dart';

class BmgrService {
  static Future<String> fetch(String deviceId) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) return '';
    final sb = StringBuffer();
    final r1 = await Process.run(adb, ['-s', deviceId, 'shell', 'bmgr', 'enabled']);
    sb.writeln('=== enabled ===');
    sb.writeln(r1.stdout.toString().trim());
    final r2 = await Process.run(adb, ['-s', deviceId, 'shell', 'bmgr', 'list', 'transports']);
    sb.writeln('\n=== transports ===');
    sb.writeln(r2.stdout.toString().trim());
    final r3 = await Process.run(adb, ['-s', deviceId, 'shell', 'bmgr', 'list', 'sets']);
    sb.writeln('\n=== restore sets ===');
    sb.writeln(r3.stdout.toString().trim());
    return sb.toString();
  }
}
