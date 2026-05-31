import 'dart:io';
import '../adb_manager.dart';

class AdbExecService {
  static Future<String> run(String deviceId, List<String> shellArgs) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) return '';
    final result = await Process.run(adb, ['-s', deviceId, 'shell', ...shellArgs]);
    final out = result.stdout.toString().trim();
    final err = result.stderr.toString().trim();
    if (out.isNotEmpty && err.isNotEmpty) return '$out\n$err';
    if (err.isNotEmpty) return err;
    return out;
  }

  static Future<String> runAdb(String deviceId, List<String> args) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) return '';
    final result = await Process.run(adb, ['-s', deviceId, ...args]);
    final out = result.stdout.toString().trim();
    final err = result.stderr.toString().trim();
    if (out.isNotEmpty && err.isNotEmpty) return '$out\n$err';
    if (err.isNotEmpty) return err;
    return out;
  }

  static Future<String> runRaw(List<String> args) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) return '';
    final result = await Process.run(adb, args);
    final out = result.stdout.toString().trim();
    final err = result.stderr.toString().trim();
    if (out.isNotEmpty && err.isNotEmpty) return '$out\n$err';
    if (err.isNotEmpty) return err;
    return out;
  }
}
