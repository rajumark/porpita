import 'package:porpita/services/commands/adb_exec_service.dart';

class QueriesSection {
  final String key;
  final String rawLine;
  final List<String> children;

  const QueriesSection({required this.key, required this.rawLine, required this.children});
}

class QueriesInfo {
  final String systemAppsQueryable;
  final List<QueriesSection> sections;

  const QueriesInfo({this.systemAppsQueryable = '', this.sections = const []});
}

class QueriesService {
  static Future<QueriesInfo> fetch(String deviceId, String packageName) async {
    final raw = await AdbExecService.run(deviceId, ['dumpsys', 'package', packageName]);
    return _parse(raw);
  }

  static QueriesInfo _parse(String raw) {
    final lines = raw.split('\n');
    int start = -1;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].trim() == 'Queries:') {
        start = i;
        break;
      }
    }
    if (start == -1) return const QueriesInfo();

    final endMarkers = ['Dexopt state:', 'Packages:', 'Activity Resolver Table:'];
    final sectionLines = <String>[];
    for (int i = start; i < lines.length; i++) {
      final trimmed = lines[i].trim();
      for (final marker in endMarkers) {
        if (trimmed.startsWith(marker)) {
          return _parseSections(sectionLines);
        }
      }
      sectionLines.add(lines[i]);
    }

    return _parseSections(sectionLines);
  }

  static QueriesInfo _parseSections(List<String> lines) {
    if (lines.isEmpty) return const QueriesInfo();

    String systemAppsQueryable = '';
    final sections = <QueriesSection>[];

    final sectionKeys = [
      'queries via forceQueryable:',
      'queries via package name:',
      'queries via component:',
      'queryable via interaction:',
      'queryable via uses-library:',
    ];

    int i = 0;

    // skip "Queries:" header line
    if (lines[i].trim() == 'Queries:') i++;

    for (; i < lines.length; i++) {
      final trimmed = lines[i].trim();

      if (trimmed.startsWith('system apps queryable:')) {
        systemAppsQueryable = trimmed;
        continue;
      }

      String? matchedKey;
      for (final key in sectionKeys) {
        if (trimmed == key || trimmed.startsWith(key)) {
          matchedKey = key;
          break;
        }
      }

      if (matchedKey != null) {
        final children = <String>[];
        final indent = lines[i].indexOf(trimmed);
        i++;
        while (i < lines.length) {
          final nextTrimmed = lines[i].trim();
          if (nextTrimmed.isEmpty) {
            i++;
            continue;
          }
          final nextIndent = lines[i].length - lines[i].trimLeft().length;
          if (nextIndent <= indent && nextTrimmed.isNotEmpty) {
            // check if this is another section key
            bool isNextKey = false;
            for (final key in sectionKeys) {
              if (nextTrimmed == key || nextTrimmed.startsWith(key)) {
                isNextKey = true;
                break;
              }
            }
            if (nextTrimmed.startsWith('system apps queryable:')) isNextKey = true;
            if (isNextKey) {
              i--;
              break;
            }
          }
          children.add(lines[i]);
          i++;
        }
        sections.add(QueriesSection(key: matchedKey, rawLine: trimmed, children: children));
      }
    }

    return QueriesInfo(systemAppsQueryable: systemAppsQueryable, sections: sections);
  }
}