import 'package:porpita/services/commands/adb_exec_service.dart';

class RawDataService {
  static Future<String> fetch(String deviceId, String packageName) {
    return AdbExecService.run(deviceId, ['dumpsys', 'package', packageName]);
  }
}