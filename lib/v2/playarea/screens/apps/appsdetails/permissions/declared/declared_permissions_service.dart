import '../permissions_fetch_service.dart';
import 'declared_permissions_model.dart';

class DeclaredPermissionsService {
  static Future<List<DeclaredPermission>> fetch(String deviceId, String packageName) async {
    final raw = await PermissionsFetchService.fetchDump(deviceId, packageName);
    return _parse(raw);
  }

  static List<DeclaredPermission> _parse(String raw) {
    final lines = raw.split('\n');
    int start = -1;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].trim() == 'declared permissions:') {
        start = i + 1;
        break;
      }
    }
    if (start == -1) return [];

    final result = <DeclaredPermission>[];
    for (int i = start; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty || (!line.startsWith('android.') && !line.startsWith('com.') && !line.contains(':'))) break;
      if (!line.contains(':')) break;
      final colonIdx = line.indexOf(':');
      final name = line.substring(0, colonIdx).trim();
      final rest = line.substring(colonIdx + 1).trim();
      String prot = '';
      final protMatch = RegExp(r'prot=([^\s,]+)').firstMatch(rest);
      if (protMatch != null) prot = protMatch.group(1)!;
      result.add(DeclaredPermission(name: name, protectionLevel: prot));
    }
    return result;
  }
}