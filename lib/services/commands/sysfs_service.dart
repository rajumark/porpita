import 'dart:io';
import '../adb_manager.dart';

class SysfsService {
  static Future<String> fetch(String deviceId) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) return '';
    final sb = StringBuffer();

    final cmds = <String, List<String>>{
      '/sys/class/leds/leds-sec1/trigger': ['cat', '/sys/class/leds/leds-sec1/trigger'],
      '/sys/power/state': ['cat', '/sys/power/state'],
      '/sys/devices/soc0/hw_platform': ['cat', '/sys/devices/soc0/hw_platform'],
      'USB drivers': ['ls', '/sys/bus/usb/drivers/'],
      '/sys/devices/platform/panel_0/modalias': ['cat', '/sys/devices/platform/panel_0/modalias'],
      'WiFi firmware version': ['cat', '/sys/wifi/wifiver'],
      'WiFi MAC address': ['cat', '/sys/wifi/mac_addr'],
      'WiFi roaming': ['cat', '/sys/wifi/roamoff'],
    };

    for (final entry in cmds.entries) {
      final args = ['-s', deviceId, 'shell', ...entry.value];
      final r = await Process.run(adb, args);
      sb.writeln('=== ${entry.key} ===');
      final out = r.stdout.toString().trim();
      sb.writeln(out.isEmpty ? '(empty/no such file)' : out);
      sb.writeln();
    }

    return sb.toString();
  }
}
