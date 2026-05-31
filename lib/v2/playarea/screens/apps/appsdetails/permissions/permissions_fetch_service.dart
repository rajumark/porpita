import 'package:porpita/services/commands/adb_exec_service.dart';

class PermissionsFetchService {
  static Future<String> fetchDump(String deviceId, String packageName) {
    return AdbExecService.run(deviceId, ['dumpsys', 'package', packageName]);
  }
}