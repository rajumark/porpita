import '../permissions_fetch_service.dart';
import 'install_permissions_model.dart';

class InstallPermissionsService {
  static Future<List<InstallPermission>> fetch(String deviceId, String packageName) async {
    final raw = await PermissionsFetchService.fetchDump(deviceId, packageName);
    return _parse(raw);
  }

  static List<InstallPermission> _parse(String raw) {
    final lines = raw.split('\n');

    final results = <List<InstallPermission>>[];
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].trim() != 'install permissions:') continue;
      final section = <InstallPermission>[];
      for (int j = i + 1; j < lines.length; j++) {
        final line = lines[j].trim();
        if (line.isEmpty || (!line.startsWith('android.') && !line.startsWith('com.'))) break;
        if (!line.contains(':')) break;
        final colonIdx = line.indexOf(':');
        final name = line.substring(0, colonIdx).trim();
        final rest = line.substring(colonIdx + 1).trim();
        bool? granted;
        final grantedMatch = RegExp(r'granted=(true|false)').firstMatch(rest);
        if (grantedMatch != null) {
          granted = grantedMatch.group(1) == 'true';
        }
        section.add(InstallPermission(name: name, granted: granted));
      }
      results.add(section);
    }

    if (results.isEmpty) return [];
    return results.first;
  }
}