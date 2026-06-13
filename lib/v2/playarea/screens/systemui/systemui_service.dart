import 'package:porpita/services/commands/adb_exec_service.dart';

class SystemUiService {
  static const _action = 'com.android.systemui.demo';
  static const _settingKey = 'sysui_demo_allowed';

  static Future<bool> isDemoAllowed(String deviceId) async {
    final output =
        await AdbExecService.run(deviceId, ['settings', 'get', 'global', _settingKey]);
    return output.trim() == '1';
  }

  static Future<void> setDemoAllowed(String deviceId, bool allowed) async {
    await AdbExecService.run(deviceId, [
      'settings',
      'put',
      'global',
      _settingKey,
      allowed ? '1' : '0',
    ]);
  }

  static Future<String> enterDemoMode(String deviceId) async {
    return _broadcast(deviceId, 'enter');
  }

  static Future<String> exitDemoMode(String deviceId) async {
    return _broadcast(deviceId, 'exit');
  }

  static Future<String> setBatteryLevel(String deviceId, int level) async {
    return _broadcast(deviceId, 'battery', {'level': level.toString()});
  }

  static Future<String> setBatteryPlugged(String deviceId, bool plugged) async {
    return _broadcast(deviceId, 'battery', {'plugged': plugged.toString()});
  }

  static Future<String> setBatteryPowersave(String deviceId, bool powersave) async {
    return _broadcast(deviceId, 'battery', {'powersave': powersave.toString()});
  }

  static Future<String> setWifi(String deviceId, {required bool show, int level = 4, String? hotspot}) async {
    final extras = <String, String>{
      'wifi': show ? 'show' : 'hide',
      'level': level.toString(),
    };
    if (hotspot != null) extras['hotspot'] = hotspot;
    return _broadcast(deviceId, 'network', extras);
  }

  static Future<String> setMobile(
    String deviceId, {
    required bool show,
    String datatype = 'lte',
    int level = 4,
  }) async {
    return _broadcast(deviceId, 'network', {
      'mobile': show ? 'show' : 'hide',
      'datatype': datatype,
      'level': level.toString(),
    });
  }

  static Future<String> setFully(String deviceId, bool fully) async {
    return _broadcast(deviceId, 'network', {'fully': fully.toString()});
  }

  static Future<String> setAirplane(String deviceId, bool show) async {
    return _broadcast(deviceId, 'network', {'airplane': show ? 'show' : 'hide'});
  }

  static Future<String> setSims(String deviceId, int count) async {
    return _broadcast(deviceId, 'network', {'sims': count.toString()});
  }

  static Future<String> setNoSim(String deviceId, bool show) async {
    return _broadcast(deviceId, 'network', {'nosim': show ? 'show' : 'hide'});
  }

  static Future<String> setCarrierNetworkChange(String deviceId, bool show) async {
    return _broadcast(deviceId, 'network', {'carriernetworkchange': show ? 'show' : 'hide'});
  }

  static Future<String> setSatellite(
    String deviceId, {
    required bool show,
    String connection = 'unknown',
    int level = 0,
  }) async {
    return _broadcast(deviceId, 'network', {
      'satellite': show ? 'show' : 'hide',
      'connection': connection,
      'level': level.toString(),
    });
  }

  static Future<String> setClock(String deviceId, int hour, int minute) async {
    final hhmm = '${hour.toString().padLeft(2, '0')}${minute.toString().padLeft(2, '0')}';
    return _broadcast(deviceId, 'clock', {'hhmm': hhmm});
  }

  static Future<String> setBarsMode(String deviceId, String mode) async {
    return _broadcast(deviceId, 'bars', {'mode': mode});
  }

  static Future<String> setStatusIcon(String deviceId, String slot, String value) async {
    return _broadcast(deviceId, 'status', {slot: value});
  }

  static Future<String> setNotificationsVisible(String deviceId, bool visible) async {
    return _broadcast(deviceId, 'notifications', {'visible': visible.toString()});
  }

  static Future<String> _broadcast(
    String deviceId,
    String command, [
    Map<String, String>? extras,
  ]) async {
    final args = <String>[
      'am',
      'broadcast',
      '-a',
      _action,
      '-e',
      'command',
      command,
    ];
    if (extras != null) {
      for (final entry in extras.entries) {
        args.addAll(['-e', entry.key, entry.value]);
      }
    }
    return AdbExecService.run(deviceId, args);
  }
}
