import 'package:porpita/services/commands/adb_exec_service.dart';

class AppDetailsInfo {
  final List<MapEntry<String, String>> properties;

  const AppDetailsInfo({this.properties = const []});
}

class AppDetailsService {
  static Future<AppDetailsInfo> fetch(String deviceId, String packageName) async {
    final raw = await AdbExecService.run(deviceId, ['dumpsys', 'package', packageName]);
    return _parse(raw, packageName);
  }

  static int _indentLevel(String line) {
    var count = 0;
    for (final ch in line.runes) {
      if (ch == 0x20) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  static bool _isExclude(String trimmed, List<String> excludeStubs) {
    for (final stub in excludeStubs) {
      if (trimmed == stub || trimmed.startsWith('$stub ')) return true;
    }
    return false;
  }

  static AppDetailsInfo _parse(String raw, String packageName) {
    final lines = raw.split('\n');

    int start = -1;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('Package [$packageName]') ||
          (lines[i].contains('Package [') && start == -1)) {
        start = i;
        break;
      }
    }
    if (start == -1) return const AppDetailsInfo();

    final excludeStubs = <String>[
      'declared permissions:',
      'requested permissions:',
      'install permissions:',
      'runtime permissions:',
      'User 0:',
    ];

    final properties = <MapEntry<String, String>>[];
    int skipUntilIndent = -1;
    int i = start + 1;

    while (i < lines.length) {
      final line = lines[i];

      if (line.contains('Package [') && i != start) break;

      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        i++;
        continue;
      }

      final currentIndent = _indentLevel(line);

      if (skipUntilIndent >= 0) {
        if (currentIndent <= skipUntilIndent) {
          if (_isExclude(trimmed, excludeStubs)) {
            skipUntilIndent = currentIndent;
            i++;
            continue;
          }
          skipUntilIndent = -1;
        } else {
          i++;
          continue;
        }
      }

      if (_isExclude(trimmed, excludeStubs)) {
        skipUntilIndent = currentIndent;
        i++;
        continue;
      }

      final eq = trimmed.indexOf('=');
      if (eq > 0) {
        final key = trimmed.substring(0, eq).trim();
        final val = trimmed.substring(eq + 1).trim();
        properties.add(MapEntry(key, val));
      }

      i++;
    }

    return AppDetailsInfo(properties: properties);
  }
}