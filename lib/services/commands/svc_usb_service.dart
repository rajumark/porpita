import 'dart:io';
import '../adb_manager.dart';

class SvcUsbService {
  static Future<String> fetch(String deviceId) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) return '';
    final sb = StringBuffer();
    final r1 = await Process.run(adb, ['-s', deviceId, 'shell', 'svc', 'usb', 'getFunctions']);
    sb.writeln('=== USB functions ===');
    sb.writeln(r1.stdout.toString().trim());
    final r2 = await Process.run(adb, ['-s', deviceId, 'shell', 'svc', 'usb', 'getUsbSpeed']);
    sb.writeln('\n=== USB speed ===');
    sb.writeln(r2.stdout.toString().trim());
    final r3 = await Process.run(adb, ['-s', deviceId, 'shell', 'svc', 'usb', 'getGadgetHalVersion']);
    sb.writeln('\n=== gadget HAL version ===');
    sb.writeln(r3.stdout.toString().trim());
    final r4 = await Process.run(adb, ['-s', deviceId, 'shell', 'svc', 'usb', 'getUsbHalVersion']);
    sb.writeln('\n=== USB HAL version ===');
    sb.writeln(r4.stdout.toString().trim());
    return sb.toString();
  }
}
