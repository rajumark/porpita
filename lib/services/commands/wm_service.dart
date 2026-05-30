import 'dart:io';
import '../adb_manager.dart';

class WmService {
  static Future<String> fetch(String deviceId) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) return '';
    final sb = StringBuffer();
    final r1 = await Process.run(adb, ['-s', deviceId, 'shell', 'wm', 'size']);
    sb.writeln('=== wm size ===');
    sb.writeln(r1.stdout.toString().trim());
    final r2 = await Process.run(adb, ['-s', deviceId, 'shell', 'wm', 'density']);
    sb.writeln('\n=== wm density ===');
    sb.writeln(r2.stdout.toString().trim());
    final r3 = await Process.run(adb, ['-s', deviceId, 'shell', 'wm', 'rotation']);
    sb.writeln('\n=== wm rotation ===');
    sb.writeln(r3.stdout.toString().trim());
    final r4 = await Process.run(adb, ['-s', deviceId, 'shell', 'wm', 'get-ignore-orientation-request']);
    sb.writeln('\n=== wm get-ignore-orientation-request ===');
    sb.writeln(r4.stdout.toString().trim());
    return sb.toString();
  }
}
