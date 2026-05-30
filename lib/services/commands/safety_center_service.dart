import 'dart:io';
import '../adb_manager.dart';

class SafetyCenterService {
  static Future<String> fetch(String deviceId) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) return '';
    final sb = StringBuffer();
    final r1 = await Process.run(adb, ['-s', deviceId, 'shell', 'cmd', 'safety_center', 'package-name']);
    sb.writeln('=== package name ===');
    sb.writeln(r1.stdout.toString().trim());
    final r2 = await Process.run(adb, ['-s', deviceId, 'shell', 'cmd', 'safety_center', 'supported']);
    sb.writeln('\n=== supported ===');
    sb.writeln(r2.stdout.toString().trim());
    final r3 = await Process.run(adb, ['-s', deviceId, 'shell', 'cmd', 'safety_center', 'enabled']);
    sb.writeln('\n=== enabled ===');
    sb.writeln(r3.stdout.toString().trim());
    return sb.toString();
  }
}
