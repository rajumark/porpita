import 'dart:io';

import 'package:porpita/services/adb_manager.dart';

enum AppFilter {
  all('All Apps', []),
  user('User Apps', ['-3']),
  system('System Apps', ['-s']),
  enabled('Enabled Apps', ['-e']),
  disabled('Disabled Apps', ['-d']);

  final String label;
  final List<String> args;
  const AppFilter(this.label, this.args);
}

class AppsListService {
  static Future<List<String>> fetchApps(String deviceId, AppFilter filter) async {
    final adbPath = AdbManager.instance.adbPath;
    if (adbPath == null) return [];

    final result = await Process.run(adbPath, [
      '-s', deviceId,
      'shell', 'pm', 'list', 'packages', ...filter.args,
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
