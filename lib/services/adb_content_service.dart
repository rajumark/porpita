import 'dart:async';
import 'dart:io';

import 'adb_manager.dart';

/// Central ADB data-fetching service for all content-provider based screens.
/// Each method returns a list of row-maps parsed from `adb shell content query` output.
class AdbContentService {
  AdbContentService._();

  static Future<List<Map<String, String>>> query({
    required String deviceId,
    required String uri,
  }) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) return [];

    final result = await Process.run(adb, ['-s', deviceId, 'shell', 'content', 'query', '--uri', uri]);
    if (result.exitCode != 0) return [];
    return _parse(result.stdout.toString());
  }

  static Future<List<Map<String, String>>> shell({
    required String deviceId,
    required List<String> args,
  }) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) return [];
    final result = await Process.run(adb, ['-s', deviceId, 'shell', ...args]);
    if (result.exitCode != 0) return [];
    return _parse(result.stdout.toString());
  }

  static Future<String> shellRaw({
    required String deviceId,
    required List<String> args,
  }) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) return '';
    final result = await Process.run(adb, ['-s', deviceId, 'shell', ...args]);
    return result.stdout.toString();
  }

  /// Parse `adb content query` output — each line is `Row: N key1=val1, key2=val2, …`
  static List<Map<String, String>> _parse(String output) {
    final rows = <Map<String, String>>[];
    for (final line in output.split('\n')) {
      final clean = line.contains('Row: ') ? line.substring(line.indexOf('Row: ') + 5).trim() : line.trim();
      if (clean.isEmpty) continue;
      // strip leading "N " row index
      final noIndex = RegExp(r'^\d+ ').hasMatch(clean) ? clean.replaceFirst(RegExp(r'^\d+ '), '') : clean;
      final map = <String, String>{};
      // split on ", KEY=" boundaries
      final parts = noIndex.split(RegExp(r',\s*(?=\w+=)'));
      for (final part in parts) {
        final eq = part.indexOf('=');
        if (eq < 1) continue;
        final k = part.substring(0, eq).trim();
        final v = part.substring(eq + 1).trim();
        if (k.isNotEmpty) map[k] = v == 'NULL' ? '' : v;
      }
      if (map.isNotEmpty) rows.add(map);
    }
    return rows;
  }
}
