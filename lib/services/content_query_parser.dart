import 'dart:io';

import 'package:porpita/services/adb_manager.dart';

/// A robust parser for `adb shell content query --uri <uri>` output.
///
/// Lines look like:
///   `Row: 0 _id=8, thread_id=6, body=Hello, how are you? x=1, type=1`
///
/// The naive comma-split breaks when a value contains a comma, an `=`, or
/// even a substring that looks like another key. To handle these cases we
/// accept a known list of valid column names per URI. The parser walks the
/// line, finds each `<known_key>=` boundary, and treats the gap between
/// two boundaries as the value of the previous key — regardless of what
/// characters the value contains.
class ContentQueryParser {
  static Future<List<Map<String, String>>> query({
    required String deviceId,
    required String uri,
    required List<String> knownColumns,
  }) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) return [];

    final result = await Process.run(adb, [
      '-s', deviceId, 'shell', 'content', 'query', '--uri', uri,
    ]);
    if (result.exitCode != 0) return [];
    return parse(result.stdout.toString(), knownColumns: knownColumns);
  }

  static Future<String> runRaw({
    required String deviceId,
    required String uri,
  }) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) return '';
    final result = await Process.run(adb, [
      '-s', deviceId, 'shell', 'content', 'query', '--uri', uri,
    ]);
    return result.stdout.toString();
  }

  static List<Map<String, String>> parse(
    String output, {
    required List<String> knownColumns,
  }) {
    final sortedKeys = List<String>.from(knownColumns)
      ..sort((a, b) => b.length.compareTo(a.length));

    final rows = <Map<String, String>>[];
    for (final rawLine in output.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;
      if (!line.contains('=')) continue;

      final payload = _stripRowPrefix(line);
      if (payload.isEmpty) continue;

      final map = _parseRow(payload, sortedKeys);
      if (map.isNotEmpty) rows.add(map);
    }
    return rows;
  }

  static String _stripRowPrefix(String line) {
    final idx = line.indexOf('Row:');
    if (idx < 0) return line;
    final after = line.substring(idx + 4).trimLeft();
    final spaceIdx = after.indexOf(' ');
    if (spaceIdx < 0) return after;
    final tail = after.substring(spaceIdx + 1).trimLeft();
    return tail;
  }

  static Map<String, String> _parseRow(String payload, List<String> sortedKeys) {
    final boundaries = <({int offset, String key, int valueStart})>[];
    final used = List<bool>.filled(payload.length, false);

    for (final key in sortedKeys) {
      final pattern = '$key=';
      int from = 0;
      while (true) {
        final idx = payload.indexOf(pattern, from);
        if (idx < 0) break;

        final isValidStart = idx == 0 || !_isAlnum(payload.codeUnitAt(idx - 1));
        if (isValidStart) {
          var alreadyUsed = false;
          for (int i = idx; i < idx + pattern.length; i++) {
            if (i < used.length && used[i]) {
              alreadyUsed = true;
              break;
            }
          }
          if (!alreadyUsed) {
            for (int i = idx; i < idx + pattern.length; i++) {
              if (i < used.length) used[i] = true;
            }
            boundaries.add((offset: idx, key: key, valueStart: idx + pattern.length));
          }
        }
        from = idx + pattern.length;
      }
    }

    if (boundaries.isEmpty) return const {};

    boundaries.sort((a, b) => a.offset.compareTo(b.offset));

    final map = <String, String>{};
    for (int i = 0; i < boundaries.length; i++) {
      final start = boundaries[i].valueStart;
      final end = i + 1 < boundaries.length ? boundaries[i + 1].offset : payload.length;
      var raw = payload.substring(start, end);
      raw = raw.replaceAll(RegExp(r',\s*$'), '');
      raw = raw.trim();
      map[boundaries[i].key] = raw == 'NULL' ? '' : raw;
    }
    return map;
  }

  static bool _isAlnum(int code) {
    return (code >= 0x30 && code <= 0x39) ||
        (code >= 0x41 && code <= 0x5A) ||
        (code >= 0x61 && code <= 0x7A) ||
        code == 0x5F;
  }
}
