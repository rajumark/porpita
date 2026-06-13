import 'dart:io';
import 'package:porpita/services/adb_manager.dart';

class ControlCenterService {
  static Future<bool> _runCommand(String deviceId, List<String> args) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) return false;
    try {
      final result = await Process.run(adb, ['-s', deviceId, 'shell', ...args]);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  static Future<String> _getSetting(String deviceId, String namespace, String key) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) return '';
    try {
      final result = await Process.run(adb, [
        '-s', deviceId, 'shell', 'settings', 'get', namespace, key,
      ]);
      return result.stdout.toString().trim();
    } catch (_) {
      return '';
    }
  }

  static Future<bool> setWifi(String deviceId, bool enable) async {
    return _runCommand(deviceId, ['cmd', 'wifi', 'set-wifi-enabled', enable ? 'enabled' : 'disabled']);
  }

  static Future<bool> setMobileData(String deviceId, bool enable) async {
    return _runCommand(deviceId, ['svc', 'data', enable ? 'enable' : 'disable']);
  }

  static Future<bool> setBluetooth(String deviceId, bool enable) async {
    return _runCommand(deviceId, ['cmd', 'bluetooth_manager', enable ? 'enable' : 'disable']);
  }

  static Future<bool> setAirplaneMode(String deviceId, bool enable) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) return false;
    try {
      await Process.run(adb, [
        '-s', deviceId, 'shell', 'settings', 'put', 'global', 'airplane_mode_on',
        enable ? '1' : '0',
      ]);
      await Process.run(adb, [
        '-s', deviceId, 'shell', 'am', 'broadcast', '-a',
        'android.intent.action.AIRPLANE_MODE',
        '--ez', 'state', enable.toString(),
      ]);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> setDarkMode(String deviceId, bool enable) async {
    return _runCommand(deviceId, ['cmd', 'uimode', 'night', enable ? 'yes' : 'no']);
  }

  static Future<bool> setFlashlight(String deviceId, bool enable) async {
    return _runCommand(deviceId, ['cmd', 'flash', 'torch', enable ? 'on' : 'off']);
  }

  static Future<bool> setDnd(String deviceId, bool enable) async {
    return _runCommand(deviceId, [
      'settings', 'put', 'global', 'zen_mode', enable ? '1' : '0',
    ]);
  }

  static Future<bool> setBatterySaver(String deviceId, bool enable) async {
    return _runCommand(deviceId, [
      'settings', 'put', 'global', 'low_power_mode', enable ? '1' : '0',
    ]);
  }

  static Future<bool> setLocation(String deviceId, bool enable) async {
    return _runCommand(deviceId, ['settings', 'put', 'secure', 'location_mode', enable ? '3' : '0']);
  }

  static Future<bool> setHotspot(String deviceId, bool enable) async {
    return _runCommand(deviceId, ['svc', 'wifi', 'tether', enable ? 'enable' : 'disable']);
  }

  static Future<Map<String, int>> fetchTileStates(String deviceId) async {
    final results = await Future.wait([
      _getSetting(deviceId, 'global', 'wifi_on'),
      _getSetting(deviceId, 'global', 'bluetooth_on'),
      _getSetting(deviceId, 'global', 'airplane_mode_on'),
      _getSetting(deviceId, 'secure', 'ui_night_mode'),
      _getSetting(deviceId, 'global', 'zen_mode'),
      _getSetting(deviceId, 'global', 'low_power_mode'),
    ]);

    return {
      'wifi': int.tryParse(results[0]) ?? 0,
      'bluetooth': int.tryParse(results[1]) ?? 0,
      'airplane': int.tryParse(results[2]) ?? 0,
      'darkmode': int.tryParse(results[3]) ?? 0,
      'dnd': int.tryParse(results[4]) ?? 0,
      'batterySaver': int.tryParse(results[5]) ?? 0,
    };
  }
}