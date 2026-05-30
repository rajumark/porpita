/// Script to convert all command screen files to use the reusable CommandScreen widget.
///
/// Run: dart run tool/convert_screens.dart
import 'dart:io';

/// ADB command mapping: screen file name -> (title, adb_command)
final Map<String, List<String>> knownCommands = {
  // dumpsys
  'dumpsys': ['dumpsys', 'adb shell dumpsys'],
  'dumpsys_l': ['dumpsys -l', 'adb shell dumpsys -l'],
  'dumpsys_activity': ['dumpsys activity', 'adb shell dumpsys activity'],
  'dumpsys_window': ['dumpsys window', 'adb shell dumpsys window'],
  'dumpsys_statusbar': ['dumpsys statusbar', 'adb shell dumpsys statusbar'],
  'dumpsys_power': ['dumpsys power', 'adb shell dumpsys power'],
  'dumpsys_alarm': ['dumpsys alarm', 'adb shell dumpsys alarm'],
  'dumpsys_usagestats': ['dumpsys usagestats', 'adb shell dumpsys usagestats'],
  'dumpsys_settings': ['dumpsys settings', 'adb shell dumpsys settings'],
  'dumpsys_battery': ['dumpsys battery', 'adb shell dumpsys battery'],
  'dumpsys_batterystats': ['dumpsys batterystats', 'adb shell dumpsys batterystats'],
  'dumpsys_display': ['dumpsys display', 'adb shell dumpsys display'],
  'dumpsys_input': ['dumpsys input', 'adb shell dumpsys input'],
  'dumpsys_sensor': ['dumpsys sensor', 'adb shell dumpsys sensor'],
  'dumpsys_audio': ['dumpsys audio', 'adb shell dumpsys audio'],
  'dumpsys_vibrator': ['dumpsys vibrator', 'adb shell dumpsys vibrator'],
  'dumpsys_usb': ['dumpsys usb', 'adb shell dumpsys usb'],
  'dumpsys_thermal': ['dumpsys thermal', 'adb shell dumpsys thermal'],
  'dumpsys_lights': ['dumpsys lights', 'adb shell dumpsys lights'],
  'dumpsys_netstats': ['dumpsys netstats', 'adb shell dumpsys netstats'],
  'dumpsys_connectivity': ['dumpsys connectivity', 'adb shell dumpsys connectivity'],
  'dumpsys_wifi': ['dumpsys wifi', 'adb shell dumpsys wifi'],
  'dumpsys_bluetooth': ['dumpsys bluetooth', 'adb shell dumpsys bluetooth'],
  'dumpsys_telephony_registry': ['dumpsys telephony.registry', 'adb shell dumpsys telephony.registry'],
  'dumpsys_network_management': ['dumpsys network_management', 'adb shell dumpsys network_management'],
  'dumpsys_location': ['dumpsys location', 'adb shell dumpsys location'],
  'dumpsys_bugreport': ['dumpsys bugreport', 'adb shell dumpsys bugreport'],
  'dumpsys_dropbox': ['dumpsys dropbox', 'adb shell dumpsys dropbox'],
  'dumpsys_meminfo': ['dumpsys meminfo', 'adb shell dumpsys meminfo'],
  'dumpsys_procstats': ['dumpsys procstats', 'adb shell dumpsys procstats'],
  'dumpsys_cpuinfo': ['dumpsys cpuinfo', 'adb shell dumpsys cpuinfo'],
  'dumpsys_gfxinfo': ['dumpsys gfxinfo', 'adb shell dumpsys gfxinfo'],
  'dumpsys_surfaceflinger': ['dumpsys SurfaceFlinger', 'adb shell dumpsys SurfaceFlinger'],
  'dumpsys_appops': ['dumpsys appops', 'adb shell dumpsys appops'],
  'dumpsys_notification': ['dumpsys notification', 'adb shell dumpsys notification'],
  'dumpsys_keystore': ['dumpsys keystore', 'adb shell dumpsys keystore'],
  'dumpsys_media_session': ['dumpsys media_session', 'adb shell dumpsys media_session'],
  'dumpsys_jobscheduler': ['dumpsys jobscheduler', 'adb shell dumpsys jobscheduler'],
  'dumpsys_wallpaper': ['dumpsys wallpaper', 'adb shell dumpsys wallpaper'],
  'dumpsys_shortcut': ['dumpsys shortcut', 'adb shell dumpsys shortcut'],
  'dumpsys_account': ['dumpsys account', 'adb shell dumpsys account'],
  'dumpsys_mount': ['dumpsys mount', 'adb shell dumpsys mount'],
  'dumpsys_storagestats': ['dumpsys storagestats', 'adb shell dumpsys storagestats'],
  'dumpsys_backup': ['dumpsys backup', 'adb shell dumpsys backup'],
  'dumpsys_app_hibernation': ['dumpsys app_hibernation', 'adb shell dumpsys app_hibernation'],
  'dumpsys_fingerprint': ['dumpsys fingerprint', 'adb shell dumpsys fingerprint'],
  'dumpsys_uri_grants': ['dumpsys uri_grants', 'adb shell dumpsys uri_grants'],
  'dumpsys_netpolicy': ['dumpsys netpolicy', 'adb shell dumpsys netpolicy'],
  'dumpsys_overlay': ['dumpsys overlay', 'adb shell dumpsys overlay'],
  'dumpsys_device_policy': ['dumpsys device_policy', 'adb shell dumpsys device_policy'],
  'dumpsys_app_search': ['dumpsys app_search', 'adb shell dumpsys app_search'],
  'dumpsys_content_capture': ['dumpsys content_capture', 'adb shell dumpsys content_capture'],
  'dumpsys_activity_top': ['dumpsys activity top', 'adb shell dumpsys activity top'],
  'dumpsys_activity_broadcasts': ['dumpsys activity broadcasts', 'adb shell dumpsys activity broadcasts'],
  'dumpsys_activity_services': ['dumpsys activity services', 'adb shell dumpsys activity services'],
  'dumpsys_activity_intents': ['dumpsys activity intents', 'adb shell dumpsys activity intents'],
  'dumpsys_activity_providers': ['dumpsys activity providers', 'adb shell dumpsys activity providers'],
  'dumpsys_activity_recents': ['dumpsys activity recents', 'adb shell dumpsys activity recents'],
  'dumpsys_activity_processes': ['dumpsys activity processes', 'adb shell dumpsys activity processes'],
  // pm
  'pm_dump': ['pm dump', 'adb shell pm dump'],
  'pm_list_features': ['pm list features', 'adb shell pm list features'],
  'pm_list_libraries': ['pm list libraries', 'adb shell pm list libraries'],
  'pm_list_permissions': ['pm list permissions', 'adb shell pm list permissions'],
  'pm_list_users': ['pm list users', 'adb shell pm list users'],
  'pm_get_max_users': ['pm get-max-users', 'adb shell pm get-max-users'],
  'pm_list_instrumentation': ['pm list instrumentation', 'adb shell pm list instrumentation'],
  // cmd
  'cmd_package_compile_l': ['cmd package compile -l', 'adb shell cmd package compile -l'],
  'cmd_shortcut_dump': ['cmd shortcut dump', 'adb shell cmd shortcut dump'],
  'cmd_wifi_status': ['cmd wifi status', 'adb shell cmd wifi status'],
  'cmd_overlay_list': ['cmd overlay list', 'adb shell cmd overlay list'],
  // other
  'getprop': ['getprop', 'adb shell getprop'],
  'procrank': ['procrank', 'adb shell procrank'],
  'df_h': ['df -h', 'adb shell df -h'],
  'cat_proc_cpuinfo': ['cat /proc/cpuinfo', 'adb shell cat /proc/cpuinfo'],
  'cat_proc_meminfo': ['cat /proc/meminfo', 'adb shell cat /proc/meminfo'],
  'cat_proc_partitions': ['cat /proc/partitions', 'adb shell cat /proc/partitions'],
  'cat_proc_modules': ['cat /proc/modules', 'adb shell cat /proc/modules'],
  'cat_proc_version': ['cat /proc/version', 'adb shell cat /proc/version'],
  'cat_proc_uptime': ['cat /proc/uptime', 'adb shell cat /proc/uptime'],
  'cat_proc_net_dev': ['cat /proc/net/dev', 'adb shell cat /proc/net/dev'],
  'bugreport': ['bugreport', 'adb shell bugreport'],
  'logcat_d': ['logcat -d', 'adb shell logcat -d'],
  'dmesg': ['dmesg', 'adb shell dmesg'],
  'am_dumpheap': ['am dumpheap', 'adb shell am dumpheap'],
  'service_list': ['service list', 'adb shell service list'],
  // new commands
  'acpi': ['acpi', 'adb shell acpi -V'],
  'date': ['date', 'adb shell date'],
  'wm': ['wm', 'adb shell wm size && wm density && wm rotation'],
  'uimode': ['cmd uimode', 'adb shell cmd uimode'],
  'deviceidle': ['cmd deviceidle', 'adb shell cmd deviceidle get deep'],
  'reboot_readiness': ['cmd reboot_readiness', 'adb shell cmd reboot_readiness check-interactivity-state'],
  'safety_center': ['cmd safety_center', 'adb shell cmd safety_center package-name'],
  'telecom': ['telecom', 'adb shell telecom get-system-dialer'],
  'svc_usb': ['svc usb', 'adb shell svc usb getFunctions'],
  'bmgr': ['bmgr', 'adb shell bmgr enabled'],
  'magisk': ['magisk', 'adb shell magisk -c'],
  'sysfs': ['sysfs', 'adb shell cat /sys/...'],
};

void main() {
  final screensDir = Directory('lib/screens/commands');
  final files = screensDir.listSync().whereType<File>().toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  int updated = 0;
  int skipped = 0;

  for (final file in files) {
    if (!file.path.endsWith('_page.dart')) continue;
    final content = file.readAsStringSync();

    // Skip if already using CommandScreen
    if (content.contains('CommandScreen(')) {
      skipped++;
      continue;
    }

    // Extract base name from path
    final baseName = file.path.split('/').last.replaceAll('_page.dart', '');

    // Look up command info
    final info = knownCommands[baseName];
    if (info == null) {
      print('WARNING: Unknown command for $baseName');
      skipped++;
      continue;
    }

    final title = info[0];
    final adbCommand = info[1];

    // Extract service class name
    final serviceMatch = RegExp(r'await\s+(\w+)\.fetch\(deviceId\)').firstMatch(content);
    final serviceClass = serviceMatch?.group(1) ?? '${_toPascal(baseName)}Service';

    // Generate new content
    final newContent = _generateScreen(baseName, serviceClass, title, adbCommand);
    file.writeAsStringSync(newContent);
    print('Updated: ${file.path} ($title)');
    updated++;
  }

  print('\nDone! $updated files updated, $skipped skipped.');
}

String _generateScreen(String baseName, String serviceClass, String title, String adbCommand) {
  final importName = '${baseName}_service';

  return '''import 'package:flutter/material.dart';
import '../../services/commands/$importName.dart';
import '../../widgets/data_screen_widgets.dart';

class ${_toPascal(baseName)}Page extends StatelessWidget {
  const ${_toPascal(baseName)}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return CommandScreen(
      title: '$title',
      adbCommand: '$adbCommand',
      fetchData: (id) => $serviceClass.fetch(id),
    );
  }
}
''';
}

String _toPascal(String snake) {
  return snake.split('_').map((part) {
    if (part.isEmpty) return '';
    return '${part[0].toUpperCase()}${part.substring(1)}';
  }).join('');
}
