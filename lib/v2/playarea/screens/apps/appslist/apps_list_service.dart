import 'dart:io';

import 'package:porpita/services/adb_manager.dart';

class AppsListService {
  static Future<List<String>> fetchUserApps(String deviceId) async {
    final adbPath = AdbManager.instance.adbPath;
    if (adbPath == null) return [];

    final result = await Process.run(adbPath, [
      '-s', deviceId,
      'shell', 'pm', 'list', 'packages', '-3',
    ]);

    if (result.exitCode != 0) return [];

    final packages = <String>[];
    for (final line in result.stdout.toString().split('\n')) {
      final trimmed = line.trim();
      if (trimmed.startsWith('package:')) {
        packages.add(trimmed.substring(8));
      }
    }
    return packages;
  }

  static Future<List<String>> fetchSystemApps(String deviceId) async {
    final adbPath = AdbManager.instance.adbPath;
    if (adbPath == null) return [];

    final result = await Process.run(adbPath, [
      '-s', deviceId,
      'shell', 'pm', 'list', 'packages', '-s',
    ]);

    if (result.exitCode != 0) return [];

    final packages = <String>[];
    for (final line in result.stdout.toString().split('\n')) {
      final trimmed = line.trim();
      if (trimmed.startsWith('package:')) {
        packages.add(trimmed.substring(8));
      }
    }
    return packages;
  }

  static Future<List<String>> fetchAllApps(String deviceId) async {
    final adbPath = AdbManager.instance.adbPath;
    if (adbPath == null) return [];

    final result = await Process.run(adbPath, [
      '-s', deviceId,
      'shell', 'pm', 'list', 'packages',
    ]);

    if (result.exitCode != 0) return [];

    final packages = <String>[];
    for (final line in result.stdout.toString().split('\n')) {
      final trimmed = line.trim();
      if (trimmed.startsWith('package:')) {
        packages.add(trimmed.substring(8));
      }
    }
    return packages;
  }
}
