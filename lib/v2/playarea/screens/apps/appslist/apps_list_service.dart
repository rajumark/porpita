import 'dart:io';

import 'package:porpita/services/adb_manager.dart';

enum AppFilter {
  all('All Apps'),
  user('User Apps'),
  system('System Apps'),
  enabled('Enabled Apps'),
  disabled('Disabled Apps');

  final String label;
  const AppFilter(this.label);
}

class AppsListService {
  static Future<List<String>> fetchApps(String deviceId, AppFilter filter) async {
    final adbPath = AdbManager.instance.adbPath;
    if (adbPath == null) return [];

    final args = ['-s', deviceId, 'shell', 'pm', 'list', 'packages'];
    if (filter == AppFilter.user) args.add('-3');
    if (filter == AppFilter.system) args.add('-s');
    if (filter == AppFilter.enabled) args.add('-e');
    if (filter == AppFilter.disabled) args.add('-d');

    final result = await Process.run(adbPath, args);
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

  static Future<({List<String> system, List<String> user})> fetchCategorizedApps(
    String deviceId,
  ) async {
    final results = await Future.wait([
      fetchApps(deviceId, AppFilter.system),
      fetchApps(deviceId, AppFilter.user),
    ]);
    return (system: results[0], user: results[1]);
  }
}
