import 'dart:io';
import '../adb_manager.dart';

class MagiskService {
  static Future<String> fetch(String deviceId) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) return '';
    final sb = StringBuffer();
    final r1 = await Process.run(adb, ['-s', deviceId, 'shell', 'magisk', '-c']);
    sb.writeln('=== binary version ===');
    sb.writeln(r1.stdout.toString().trim());
    final r2 = await Process.run(adb, ['-s', deviceId, 'shell', 'magisk', '-v']);
    sb.writeln('\n=== daemon version ===');
    sb.writeln(r2.stdout.toString().trim());
    final r3 = await Process.run(adb, ['-s', deviceId, 'shell', 'magisk', '-V']);
    sb.writeln('\n=== daemon version code ===');
    sb.writeln(r3.stdout.toString().trim());
    final r4 = await Process.run(adb, ['-s', deviceId, 'shell', 'magisk', '--list']);
    sb.writeln('\n=== available applets ===');
    sb.writeln(r4.stdout.toString().trim());
    final r5 = await Process.run(adb, ['-s', deviceId, 'shell', 'magisk', '--path']);
    sb.writeln('\n=== tmpfs path ===');
    sb.writeln(r5.stdout.toString().trim());
    return sb.toString();
  }
}
