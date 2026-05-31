import '../permissions_fetch_service.dart';
import 'requested_permissions_model.dart';

class RequestedPermissionsService {
  static Future<List<RequestedPermission>> fetch(String deviceId, String packageName) async {
    final raw = await PermissionsFetchService.fetchDump(deviceId, packageName);
    return _parse(raw);
  }

  static List<RequestedPermission> _parse(String raw) {
    final lines = raw.split('\n');
    int start = -1;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].trim() == 'requested permissions:') {
        start = i + 1;
        break;
      }
    }
    if (start == -1) return [];

    final result = <RequestedPermission>[];
    for (int i = start; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) break;
      if (!line.contains('.')) break;
      result.add(RequestedPermission(name: line));
    }
    return result;
  }
}