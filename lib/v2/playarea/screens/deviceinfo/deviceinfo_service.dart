import 'package:porpita/services/commands/adb_exec_service.dart';
import 'deviceinfo_model.dart';

class DeviceInfoService {
  static Future<String> _getprop(String deviceId, String prop) async {
    return AdbExecService.run(deviceId, ['getprop', prop]);
  }

  static Future<String> _shell(String deviceId, List<String> args) async {
    return AdbExecService.run(deviceId, args);
  }

  static Future<String> _adb(String deviceId, List<String> args) async {
    return AdbExecService.runAdb(deviceId, args);
  }

  static Future<BasicDeviceInfo> fetchBasic(String deviceId) async {
    final results = await Future.wait([
      _getprop(deviceId, 'ro.product.model'),
      _getprop(deviceId, 'ro.product.manufacturer'),
      _getprop(deviceId, 'ro.product.device'),
      _getprop(deviceId, 'ro.build.version.release'),
      _getprop(deviceId, 'ro.build.version.sdk'),
      _getprop(deviceId, 'ro.build.fingerprint'),
      _getprop(deviceId, 'ro.build.version.security_patch'),
      _adb(deviceId, ['get-serialno']),
      _shell(deviceId, ['dumpsys', 'battery']),
      _shell(deviceId, ['uptime']),
      _shell(deviceId, ['su', '-c', 'id']),
      _shell(deviceId, ['wm', 'size']),
      _shell(deviceId, ['wm', 'density']),
      _getprop(deviceId, 'ro.product.cpu.abi'),
      _shell(deviceId, ['cat', '/proc/meminfo']),
      _shell(deviceId, ['df', '/data']),
      _shell(deviceId, ['ip', 'addr', 'show', 'wlan0']),
      _shell(deviceId, ['dumpsys', 'wifi']),
      _shell(deviceId, ['settings', 'get', 'global', 'adb_enabled']),
    ]);

    final batteryMap = _parseKeyValue(results[8]);
    final uptimeRaw = results[9];
    final suResult = results[10];
    final wmSizeRaw = results[11];
    final wmDensityRaw = results[12];
    final memInfoRaw = results[13];
    final dfRaw = results[14];
    final ipRaw = results[15];
    final wifiRaw = results[16];
    final adbEnabled = results[17];

    return BasicDeviceInfo(
      deviceName: results[0],
      manufacturer: results[1],
      codename: results[2],
      androidVersion: results[3],
      sdkVersion: results[4],
      buildFingerprint: results[5],
      securityPatch: results[6],
      serialNumber: results[7],
      batteryLevel: batteryMap['level'] ?? '—',
      batteryStatus: _batteryStatusLabel(batteryMap['status']),
      batteryHealth: _batteryHealthLabel(batteryMap['health']),
      batteryTemp: _formatTemp(batteryMap['temperature']),
      batteryTech: batteryMap['technology'] ?? '—',
      deviceUptime: _formatUptime(uptimeRaw),
      rootStatus: suResult.contains('uid=0') ? 'Rooted' : 'Not Rooted',
      screenResolution: _parseWmSize(wmSizeRaw),
      screenDensity: _parseWmDensity(wmDensityRaw),
      cpuAbi: results[13].isNotEmpty ? results[13] : '—',
      ramTotal: _parseMemTotal(memInfoRaw),
      ramFree: _parseMemFree(memInfoRaw),
      internalStorageTotal: _parseStorageTotal(dfRaw),
      internalStorageFree: _parseStorageFree(dfRaw),
      ipAddress: _parseIpAddress(ipRaw),
      wifiState: _parseWifiState(wifiRaw),
      usbDebugging: adbEnabled.trim() == '1' ? 'Enabled' : 'Disabled',
    );
  }

  static Future<AdvancedDeviceInfo> fetchAdvanced(String deviceId) async {
    final results = await Future.wait([
      _shell(deviceId, ['uname', '-a']),
      _getprop(deviceId, 'ro.bootloader'),
      _getprop(deviceId, 'gsm.version.baseband'),
      _shell(deviceId, ['getenforce']),
      _getprop(deviceId, 'ro.crypto.state'),
      _getprop(deviceId, 'ro.treble.enabled'),
      _getprop(deviceId, 'ro.boot.verifiedbootstate'),
      _shell(deviceId, ['cat', '/proc/cpuinfo']),
      _shell(deviceId, ['cat', '/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq']),
      _shell(deviceId, ['dumpsys', 'meminfo']),
      _shell(deviceId, ['dumpsys', 'display']),
      _shell(deviceId, ['dumpsys', 'power']),
      _shell(deviceId, ['dumpsys', 'wifi']),
      _shell(deviceId, ['dumpsys', 'telephony.registry']),
      _shell(deviceId, ['settings', 'get', 'global', 'airplane_mode_on']),
      _getprop(deviceId, 'net.dns1'),
      _shell(deviceId, ['dumpsys', 'sensorservice']),
      _shell(deviceId, ['dumpsys', 'SurfaceFlinger']),
      _shell(deviceId, ['pm', 'list', 'packages']),
      _shell(deviceId, ['ps', '-A']),
      _shell(deviceId, ['dumpsys', 'activity', 'activities']),
      _adb(deviceId, ['logcat', '-g']),
    ]);

    final cpuInfo = results[7];
    final displayRaw = results[10];
    final powerRaw = results[11];
    final wifiRaw = results[12];
    final telephonyRaw = results[13];
    final sensorRaw = results[16];
    final surfaceFlingerRaw = results[17];
    final packagesRaw = results[18];
    final psRaw = results[19];
    final activityRaw = results[20];
    final logcatRaw = results[21];

    return AdvancedDeviceInfo(
      kernelVersion: results[0],
      bootloaderVersion: results[1],
      basebandVersion: results[2],
      selinuxStatus: _capitalize(results[3]),
      encryptionState: _capitalize(results[4]),
      trebleSupport: results[5] == 'true' ? 'Supported' : 'Not Supported',
      verifiedBoot: _capitalize(results[6]),
      cpuModel: _parseCpuModel(cpuInfo),
      cpuCores: _parseCpuCores(cpuInfo),
      cpuFrequency: _parseCpuFreq(results[8]),
      ramUsed: _parseRamUsed(results[9]),
      lowMemoryState: _parseLowMemory(results[9]),
      refreshRate: _parseRefreshRate(displayRaw),
      displayState: _parseDisplayState(powerRaw),
      orientation: _parseOrientation(displayRaw),
      wifiSsid: _parseWifiSsid(wifiRaw),
      mobileNetwork: _parseMobileNetwork(telephonyRaw),
      airplaneMode: results[14].trim() == '1' ? 'On' : 'Off',
      dnsServers: results[15].isNotEmpty ? results[15] : '—',
      sensorCount: _parseSensorCount(sensorRaw),
      gpuModel: _parseGpuModel(surfaceFlingerRaw),
      openGlVersion: _parseOpenGlVersion(surfaceFlingerRaw),
      vulkanSupport: '—',
      runningProcesses: _parseProcessCount(psRaw),
      foregroundApp: _parseForegroundApp(activityRaw),
      installedAppsCount: _parsePackageCount(packagesRaw),
      logcatBufferSize: _parseLogcatSize(logcatRaw),
    );
  }

  static Map<String, String> _parseKeyValue(String output) {
    final map = <String, String>{};
    for (final line in output.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final colonIndex = trimmed.indexOf(':');
      if (colonIndex < 0) continue;
      final key = trimmed.substring(0, colonIndex).trim();
      final value = trimmed.substring(colonIndex + 1).trim();
      if (key.isEmpty) continue;
      map[key] = value;
    }
    return map;
  }

  static String _batteryStatusLabel(String? status) {
    final val = int.tryParse(status ?? '') ?? 0;
    return switch (val) {
      2 => 'Charging',
      3 => 'Discharging',
      4 => 'Not Charging',
      5 => 'Full',
      _ => 'Unknown',
    };
  }

  static String _batteryHealthLabel(String? health) {
    final val = int.tryParse(health ?? '') ?? 0;
    return switch (val) {
      2 => 'Good',
      3 => 'Overheat',
      4 => 'Dead',
      5 => 'Over Voltage',
      6 => 'Unspecified Failure',
      7 => 'Cold',
      _ => 'Unknown',
    };
  }

  static String _formatTemp(String? temp) {
    final val = int.tryParse(temp ?? '') ?? 0;
    return '${(val / 10).toStringAsFixed(1)}°C';
  }

  static String _formatUptime(String raw) {
    if (raw.isEmpty) return '—';
    final match = RegExp(r'up time: (.*)').firstMatch(raw);
    if (match != null) return match.group(1)?.trim() ?? raw;
    return raw.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String _parseWmSize(String raw) {
    final match = RegExp(r'(\d+)x(\d+)').firstMatch(raw);
    return match != null ? '${match.group(1)}x${match.group(2)}' : raw;
  }

  static String _parseWmDensity(String raw) {
    final match = RegExp(r'(\d+)').firstMatch(raw);
    return match != null ? '${match.group(1)} dpi' : raw;
  }

  static String _parseMemTotal(String raw) {
    final match = RegExp(r'MemTotal:\s+(\d+)', multiLine: true).firstMatch(raw);
    if (match != null) {
      final kb = int.tryParse(match.group(1) ?? '') ?? 0;
      return _formatBytes(kb * 1024);
    }
    return '—';
  }

  static String _parseMemFree(String raw) {
    final match = RegExp(r'MemFree:\s+(\d+)', multiLine: true).firstMatch(raw);
    if (match != null) {
      final kb = int.tryParse(match.group(1) ?? '') ?? 0;
      return _formatBytes(kb * 1024);
    }
    return '—';
  }

  static String _parseStorageTotal(String raw) {
    final lines = raw.split('\n');
    if (lines.length >= 2) {
      final parts = lines[1].split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        final kb = int.tryParse(parts[1]) ?? 0;
        return _formatBytes(kb * 1024);
      }
    }
    return '—';
  }

  static String _parseStorageFree(String raw) {
    final lines = raw.split('\n');
    if (lines.length >= 2) {
      final parts = lines[1].split(RegExp(r'\s+'));
      if (parts.length >= 4) {
        final kb = int.tryParse(parts[3]) ?? 0;
        return _formatBytes(kb * 1024);
      }
    }
    return '—';
  }

  static String _formatBytes(int bytes) {
    if (bytes <= 0) return '—';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    int unitIndex = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  static String _parseIpAddress(String raw) {
    final match = RegExp(r'inet (\d+\.\d+\.\d+\.\d+)').firstMatch(raw);
    return match != null ? match.group(1)! : '—';
  }

  static String _parseWifiState(String raw) {
    if (raw.contains('Wifi is enabled') || raw.contains('mWifiInfo')) {
      return 'Connected';
    }
    if (raw.contains('Wifi is disabled')) return 'Disabled';
    return 'Unknown';
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return '—';
    return s[0].toUpperCase() + s.substring(1);
  }

  static String _parseCpuModel(String raw) {
    final match = RegExp(r'Hardware\s*:\s*(.+)', multiLine: true).firstMatch(raw);
    if (match != null) return match.group(1)?.trim() ?? '—';
    final match2 = RegExp(r'model name\s*:\s*(.+)', multiLine: true).firstMatch(raw);
    if (match2 != null) return match2.group(1)?.trim() ?? '—';
    return '—';
  }

  static String _parseCpuCores(String raw) {
    final count = RegExp(r'^processor\s*:', multiLine: true).allMatches(raw).length;
    return count > 0 ? count.toString() : '—';
  }

  static String _parseCpuFreq(String raw) {
    final khz = int.tryParse(raw.trim()) ?? 0;
    if (khz <= 0) return '—';
    if (khz >= 1000000) return '${(khz / 1000000).toStringAsFixed(2)} GHz';
    return '${(khz / 1000).round()} MHz';
  }

  static String _parseRamUsed(String raw) {
    final match = RegExp(r'Total RAM:\s+(\d+)', multiLine: true).firstMatch(raw);
    if (match == null) return '—';
    return '—';
  }

  static String _parseLowMemory(String raw) {
    if (raw.contains('low memory')) return 'Yes';
    return 'No';
  }

  static String _parseRefreshRate(String raw) {
    final match = RegExp(r'refreshRate\s*=\s*([\d.]+)', multiLine: true).firstMatch(raw);
    if (match != null) {
      final hz = double.tryParse(match.group(1) ?? '') ?? 0;
      return '${hz.round()} Hz';
    }
    return '—';
  }

  static String _parseDisplayState(String raw) {
    if (raw.contains('mWakefulness=Awake') || raw.contains('Display Power: state=ON')) {
      return 'ON';
    }
    if (raw.contains('mWakefulness=Asleep')) return 'OFF';
    return '—';
  }

  static String _parseOrientation(String raw) {
    final match = RegExp(r'rotation=(\d+)', multiLine: true).firstMatch(raw);
    if (match != null) {
      return switch (match.group(1)) {
        '0' => 'Portrait',
        '1' => 'Landscape',
        '2' => 'Reverse Portrait',
        '3' => 'Reverse Landscape',
        _ => '—',
      };
    }
    return '—';
  }

  static String _parseWifiSsid(String raw) {
    final match = RegExp(r'SSID:\s*(.+)', multiLine: true).firstMatch(raw);
    return match?.group(1)?.trim() ?? '—';
  }

  static String _parseMobileNetwork(String raw) {
    final match = RegExp(r'mOperatorAlphaLong=(.+)', multiLine: true).firstMatch(raw);
    return match?.group(1)?.trim() ?? '—';
  }

  static String _parseSensorCount(String raw) {
    final count = RegExp(r'0x[0-9a-f]+').allMatches(raw).length;
    return count > 0 ? count.toString() : '—';
  }

  static String _parseGpuModel(String raw) {
    final match = RegExp(r'GLES:\s*(.+)', multiLine: true).firstMatch(raw);
    if (match != null) return match.group(1)?.trim() ?? '—';
    return '—';
  }

  static String _parseOpenGlVersion(String raw) {
    final match = RegExp(r'OpenGL ES (\S+)', multiLine: true).firstMatch(raw);
    return match?.group(1) ?? '—';
  }

  static String _parseProcessCount(String raw) {
    final lines = raw.split('\n').where((l) => l.trim().isNotEmpty).length;
    return lines > 1 ? (lines - 1).toString() : '—';
  }

  static String _parseForegroundApp(String raw) {
    final match = RegExp(r'ResumedActivity:\s*.+/(.+)', multiLine: true).firstMatch(raw);
    return match?.group(1)?.trim() ?? '—';
  }

  static String _parsePackageCount(String raw) {
    final count = RegExp(r'package:').allMatches(raw).length;
    return count > 0 ? count.toString() : '—';
  }

  static String _parseLogcatSize(String raw) {
    final match = RegExp(r'(\S+)\s+total', multiLine: true).firstMatch(raw);
    return match?.group(1) ?? '—';
  }
}
