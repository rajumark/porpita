import 'dart:io';
import '../adb_manager.dart';

class DateService {
  static Future<String> fetch(String deviceId) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) return '';
    final sb = StringBuffer();
    final r1 = await Process.run(adb, ['-s', deviceId, 'shell', 'date']);
    sb.writeln('=== date ===');
    sb.writeln(r1.stdout.toString().trim());
    final r2 = await Process.run(adb, ['-s', deviceId, 'shell', 'date', '+%s']);
    sb.writeln('\n=== epoch seconds ===');
    sb.writeln(r2.stdout.toString().trim());
    final r3 = await Process.run(adb, ['-s', deviceId, 'shell', 'date', '+%s%3N']);
    sb.writeln('\n=== epoch millis ===');
    sb.writeln(r3.stdout.toString().trim());
    return sb.toString();
  }
}
