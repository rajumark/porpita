import 'dart:io';
import '../adb_manager.dart';

class RebootReadinessService {
  static Future<String> fetch(String deviceId) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) return '';
    final sb = StringBuffer();
    final r1 = await Process.run(adb, ['-s', deviceId, 'shell', 'cmd', 'reboot_readiness', 'check-interactivity-state']);
    sb.writeln('=== interactivity state ===');
    sb.writeln(r1.stdout.toString().trim());
    final r2 = await Process.run(adb, ['-s', deviceId, 'shell', 'cmd', 'reboot_readiness', 'check-app-activity-state', '--list-blocking']);
    sb.writeln('\n=== app activity state ===');
    sb.writeln(r2.stdout.toString().trim());
    final r3 = await Process.run(adb, ['-s', deviceId, 'shell', 'cmd', 'reboot_readiness', 'check-subsystems-state', '--list-blocking']);
    sb.writeln('\n=== subsystems state ===');
    sb.writeln(r3.stdout.toString().trim());
    return sb.toString();
  }
}
