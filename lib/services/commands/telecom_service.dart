import 'dart:io';
import '../adb_manager.dart';

class TelecomService {
  static Future<String> fetch(String deviceId) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) return '';
    final sb = StringBuffer();
    final r1 = await Process.run(adb, ['-s', deviceId, 'shell', 'telecom', 'get-system-dialer']);
    sb.writeln('=== system dialer ===');
    sb.writeln(r1.stdout.toString().trim());
    final r2 = await Process.run(adb, ['-s', deviceId, 'shell', 'telecom', 'get-default-dialer']);
    sb.writeln('\n=== default dialer ===');
    sb.writeln(r2.stdout.toString().trim());
    final r3 = await Process.run(adb, ['-s', deviceId, 'shell', 'telecom', 'get-max-phones']);
    sb.writeln('\n=== max phones (SIM slots) ===');
    sb.writeln(r3.stdout.toString().trim());
    final r4 = await Process.run(adb, ['-s', deviceId, 'shell', 'telecom', 'get-sim-config']);
    sb.writeln('\n=== SIM config ===');
    sb.writeln(r4.stdout.toString().trim());
    return sb.toString();
  }
}
