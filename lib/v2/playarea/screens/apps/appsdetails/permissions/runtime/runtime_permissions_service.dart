import '../permissions_fetch_service.dart';
import 'runtime_permissions_model.dart';

class RuntimePermissionsService {
  static Future<List<RuntimePermission>> fetch(String deviceId, String packageName) async {
    final raw = await PermissionsFetchService.fetchDump(deviceId, packageName);
    return _parse(raw);
  }

  static List<RuntimePermission> _parse(String raw) {
    final lines = raw.split('\n');

    final results = <List<RuntimePermission>>[];
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].trim() != 'runtime permissions:') continue;
      if (i > 0 && lines[i - 1].trim().startsWith('gids=')) continue;
      if (i > 0 && !lines[i - 1].trim().startsWith('User') && !lines[i - 1].trim().contains('User')) {
        final section = <RuntimePermission>[];
        for (int j = i + 1; j < lines.length; j++) {
          final line = lines[j].trim();
          if (line.isEmpty) break;
          if (!line.contains(':')) break;
          final colonIdx = line.indexOf(':');
          final name = line.substring(0, colonIdx).trim();
          final rest = line.substring(colonIdx + 1).trim();
          bool? granted;
          final grantedMatch = RegExp(r'granted=(true|false)').firstMatch(rest);
          if (grantedMatch != null) {
            granted = grantedMatch.group(1) == 'true';
          }
          String flags = '';
          final flagsMatch = RegExp(r'flags=\[([^\]]*)\]').firstMatch(rest);
          if (flagsMatch != null) flags = flagsMatch.group(1) ?? '';
          section.add(RuntimePermission(name: name, granted: granted, flags: flags));
        }
        results.add(section);
      }
    }

    if (results.isEmpty) {
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].trim() != 'runtime permissions:') continue;
        final section = <RuntimePermission>[];
        for (int j = i + 1; j < lines.length; j++) {
          final line = lines[j].trim();
          if (line.isEmpty) break;
          if (!line.contains(':')) break;
          final colonIdx = line.indexOf(':');
          final name = line.substring(0, colonIdx).trim();
          final rest = line.substring(colonIdx + 1).trim();
          bool? granted;
          final grantedMatch = RegExp(r'granted=(true|false)').firstMatch(rest);
          if (grantedMatch != null) {
            granted = grantedMatch.group(1) == 'true';
          }
          String flags = '';
          final flagsMatch = RegExp(r'flags=\[([^\]]*)\]').firstMatch(rest);
          if (flagsMatch != null) flags = flagsMatch.group(1) ?? '';
          section.add(RuntimePermission(name: name, granted: granted, flags: flags));
        }
        results.add(section);
      }
    }

    if (results.isEmpty) return [];
    return results.first;
  }
}