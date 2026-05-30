import 'dart:io';
import '../adb_manager.dart';

class DeviceidleService {
  static Future<String> fetch(String deviceId) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) return '';
    final sb = StringBuffer();
    final r1 = await Process.run(adb, ['-s', deviceId, 'shell', 'cmd', 'deviceidle', 'get', 'deep']);
    sb.writeln('=== deep state ===');
    sb.writeln(r1.stdout.toString().trim());
    final r2 = await Process.run(adb, ['-s', deviceId, 'shell', 'cmd', 'deviceidle', 'enabled']);
    sb.writeln('\n=== enabled ===');
    sb.writeln(r2.stdout.toString().trim());
    final r3 = await Process.run(adb, ['-s', deviceId, 'shell', 'cmd', 'deviceidle', 'whitelist']);
    sb.writeln('\n=== whitelist ===');
    sb.writeln(r3.stdout.toString().trim());
    final r4 = await Process.run(adb, ['-s', deviceId, 'shell', 'cmd', 'deviceidle', 'tempwhitelist']);
    sb.writeln('\n=== tempwhitelist ===');
    sb.writeln(r4.stdout.toString().trim());
    return sb.toString();
  }
}
