import 'package:porpita/services/commands/adb_exec_service.dart';
import 'battery_model.dart';

class BatteryService {
  static Future<BatteryInfo> fetchBattery(String deviceId) async {
    final output = await AdbExecService.run(deviceId, ['dumpsys', 'battery']);
    return BatteryInfo.fromRawOutput(output);
  }

  static Future<String> fetchRaw(String deviceId) async {
    return AdbExecService.run(deviceId, ['dumpsys', 'battery']);
  }

  static Future<String> setLevel(String deviceId, int level) async {
    return AdbExecService.run(deviceId, ['dumpsys', 'battery', 'set', 'level', level.toString()]);
  }

  static Future<String> setAcCharging(String deviceId, bool charging) async {
    return AdbExecService.run(deviceId, ['dumpsys', 'battery', 'set', 'ac', charging ? '1' : '0']);
  }

  static Future<String> setUsbCharging(String deviceId, bool charging) async {
    return AdbExecService.run(deviceId, ['dumpsys', 'battery', 'set', 'usb', charging ? '1' : '0']);
  }

  static Future<String> reset(String deviceId) async {
    return AdbExecService.run(deviceId, ['dumpsys', 'battery', 'reset']);
  }
}