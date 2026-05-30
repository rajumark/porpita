import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/device_manager.dart';
import '../widgets/device_selector_dialog.dart';
import '../widgets/settings_dialog.dart';
import 'apps_page.dart';
import 'call_logs_page.dart';
import 'calendar_page.dart';
import 'contacts_page.dart';
import 'debug_page.dart';
import 'lifecycle_page.dart';
import 'media_page.dart';
import 'messages_page.dart';
import 'properties_page.dart';
import 'services_page.dart';
import 'settings_page.dart';
import 'terminal_page.dart';
import 'commands/dumpsys_page.dart';
import 'commands/dumpsys_l_page.dart';
import 'commands/dumpsys_activity_page.dart';
import 'commands/dumpsys_window_page.dart';
import 'commands/dumpsys_statusbar_page.dart';
import 'commands/dumpsys_power_page.dart';
import 'commands/dumpsys_alarm_page.dart';
import 'commands/dumpsys_usagestats_page.dart';
import 'commands/dumpsys_settings_page.dart';
import 'commands/dumpsys_battery_page.dart';
import 'commands/dumpsys_batterystats_page.dart';
import 'commands/dumpsys_display_page.dart';
import 'commands/dumpsys_input_page.dart';
import 'commands/dumpsys_sensor_page.dart';
import 'commands/dumpsys_audio_page.dart';
import 'commands/dumpsys_vibrator_page.dart';
import 'commands/dumpsys_usb_page.dart';
import 'commands/dumpsys_thermal_page.dart';
import 'commands/dumpsys_lights_page.dart';
import 'commands/dumpsys_netstats_page.dart';
import 'commands/dumpsys_connectivity_page.dart';
import 'commands/dumpsys_wifi_page.dart';
import 'commands/dumpsys_bluetooth_page.dart';
import 'commands/dumpsys_telephony_registry_page.dart';
import 'commands/dumpsys_network_management_page.dart';
import 'commands/dumpsys_location_page.dart';
import 'commands/bugreport_page.dart';
import 'commands/logcat_d_page.dart';
import 'commands/dmesg_page.dart';
import 'commands/dumpsys_bugreport_page.dart';
import 'commands/dumpsys_dropbox_page.dart';
import 'commands/dumpsys_meminfo_page.dart';
import 'commands/dumpsys_procstats_page.dart';
import 'commands/dumpsys_cpuinfo_page.dart';
import 'commands/dumpsys_gfxinfo_page.dart';
import 'commands/am_dumpheap_page.dart';
import 'commands/pm_list_features_page.dart';
import 'commands/pm_list_libraries_page.dart';
import 'commands/pm_list_permissions_page.dart';

// ── navigation items ─────────────────────────────────────────────────────────

enum _Nav {
  debug('Debug', Icons.bug_report_outlined),
  apps('Apps', Icons.apps_outlined),
  callLogs('Call Logs', Icons.phone_outlined),
  messages('Messages', Icons.sms_outlined),
  media('Media', Icons.perm_media_outlined),
  services('Services', Icons.settings_applications_outlined),
  lifecycle('Lifecycle', Icons.timeline_outlined),
  contacts('Contacts', Icons.contacts_outlined),
  calendar('Calendar', Icons.calendar_today_outlined),
  properties('Properties', Icons.tune_outlined),
  terminal('Terminal', Icons.terminal_outlined),
  settings('Settings', Icons.settings_suggest_outlined),

  dumpsys('dumpsys', Icons.code),
  dumpsysL('dumpsys -l', Icons.code),
  dumpsysActivity('dumpsys activity', Icons.code),
  dumpsysWindow('dumpsys window', Icons.code),
  dumpsysStatusbar('dumpsys statusbar', Icons.code),
  dumpsysPower('dumpsys power', Icons.code),
  dumpsysAlarm('dumpsys alarm', Icons.code),
  dumpsysUsagestats('dumpsys usagestats', Icons.code),
  dumpsysSettings('dumpsys settings', Icons.code),
  dumpsysBattery('dumpsys battery', Icons.code),
  dumpsysBatterystats('dumpsys batterystats', Icons.code),
  dumpsysDisplay('dumpsys display', Icons.code),
  dumpsysInput('dumpsys input', Icons.code),
  dumpsysSensor('dumpsys sensor', Icons.code),
  dumpsysAudio('dumpsys audio', Icons.code),
  dumpsysVibrator('dumpsys vibrator', Icons.code),
  dumpsysUsb('dumpsys usb', Icons.code),
  dumpsysThermal('dumpsys thermal', Icons.code),
  dumpsysLights('dumpsys lights', Icons.code),
  dumpsysNetstats('dumpsys netstats', Icons.code),
  dumpsysConnectivity('dumpsys connectivity', Icons.code),
  dumpsysWifi('dumpsys wifi', Icons.code),
  dumpsysBluetooth('dumpsys bluetooth', Icons.code),
  dumpsysTelephonyRegistry('dumpsys telephony.registry', Icons.code),
  dumpsysNetworkManagement('dumpsys network_management', Icons.code),
  dumpsysLocation('dumpsys location', Icons.code),
  bugreport('bugreport', Icons.code),
  logcatD('logcat -d', Icons.code),
  dmesg('dmesg', Icons.code),
  dumpsysBugreport('dumpsys bugreport', Icons.code),
  dumpsysDropbox('dumpsys dropbox', Icons.code),
  dumpsysMeminfo('dumpsys meminfo', Icons.code),
  dumpsysProcstats('dumpsys procstats', Icons.code),
  dumpsysCpuinfo('dumpsys cpuinfo', Icons.code),
  dumpsysGfxinfo('dumpsys gfxinfo', Icons.code),
  amDumpheap('am dumpheap', Icons.code),
  pmListFeatures('pm list features', Icons.code),
  pmListLibraries('pm list libraries', Icons.code),
  pmListPermissions('pm list permissions', Icons.code),;

  final String label;
  final IconData icon;
  const _Nav(this.label, this.icon);
}

Widget _buildPage(_Nav nav) => switch (nav) {
      _Nav.debug => const DebugPage(),
      _Nav.apps => const AppsPage(),
      _Nav.callLogs => const CallLogsPage(),
      _Nav.messages => const MessagesPage(),
      _Nav.media => const MediaPage(),
      _Nav.services => const ServicesPage(),
      _Nav.lifecycle => const LifecyclePage(),
      _Nav.contacts => const ContactsPage(),
      _Nav.calendar => const CalendarPage(),
      _Nav.properties => const PropertiesPage(),
      _Nav.terminal => const TerminalPage(),
      _Nav.settings => const SettingsPage(),
      _Nav.dumpsys => const DumpsysPage(),
      _Nav.dumpsysL => const DumpsysLPage(),
      _Nav.dumpsysActivity => const DumpsysActivityPage(),
      _Nav.dumpsysWindow => const DumpsysWindowPage(),
      _Nav.dumpsysStatusbar => const DumpsysStatusbarPage(),
      _Nav.dumpsysPower => const DumpsysPowerPage(),
      _Nav.dumpsysAlarm => const DumpsysAlarmPage(),
      _Nav.dumpsysUsagestats => const DumpsysUsagestatsPage(),
      _Nav.dumpsysSettings => const DumpsysSettingsPage(),
      _Nav.dumpsysBattery => const DumpsysBatteryPage(),
      _Nav.dumpsysBatterystats => const DumpsysBatterystatsPage(),
      _Nav.dumpsysDisplay => const DumpsysDisplayPage(),
      _Nav.dumpsysInput => const DumpsysInputPage(),
      _Nav.dumpsysSensor => const DumpsysSensorPage(),
      _Nav.dumpsysAudio => const DumpsysAudioPage(),
      _Nav.dumpsysVibrator => const DumpsysVibratorPage(),
      _Nav.dumpsysUsb => const DumpsysUsbPage(),
      _Nav.dumpsysThermal => const DumpsysThermalPage(),
      _Nav.dumpsysLights => const DumpsysLightsPage(),
      _Nav.dumpsysNetstats => const DumpsysNetstatsPage(),
      _Nav.dumpsysConnectivity => const DumpsysConnectivityPage(),
      _Nav.dumpsysWifi => const DumpsysWifiPage(),
      _Nav.dumpsysBluetooth => const DumpsysBluetoothPage(),
      _Nav.dumpsysTelephonyRegistry => const DumpsysTelephonyRegistryPage(),
      _Nav.dumpsysNetworkManagement => const DumpsysNetworkManagementPage(),
      _Nav.dumpsysLocation => const DumpsysLocationPage(),
      _Nav.bugreport => const BugreportPage(),
      _Nav.logcatD => const LogcatDPage(),
      _Nav.dmesg => const DmesgPage(),
      _Nav.dumpsysBugreport => const DumpsysBugreportPage(),
      _Nav.dumpsysDropbox => const DumpsysDropboxPage(),
      _Nav.dumpsysMeminfo => const DumpsysMeminfoPage(),
      _Nav.dumpsysProcstats => const DumpsysProcstatsPage(),
      _Nav.dumpsysCpuinfo => const DumpsysCpuinfoPage(),
      _Nav.dumpsysGfxinfo => const DumpsysGfxinfoPage(),
      _Nav.amDumpheap => const AmDumpheapPage(),
      _Nav.pmListFeatures => const PmListFeaturesPage(),
      _Nav.pmListLibraries => const PmListLibrariesPage(),
      _Nav.pmListPermissions => const PmListPermissionsPage(),

    };

// ── main screen ──────────────────────────────────────────────────────────────

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late _Nav _current;

  @override
  void initState() {
    super.initState();
    _current = _Nav.values[widget.initialIndex.clamp(0, _Nav.values.length - 1)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_current.label),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'App Settings',
            onPressed: () => showDialog(context: context, builder: (_) => const SettingsDialog()),
          ),
        ],
      ),
      drawer: _NavDrawer(current: _current, onSelected: (nav) {
        setState(() => _current = nav);
        Navigator.of(context).pop();
      }),
      body: _buildPage(_current),
    );
  }
}

// ── navigation drawer ────────────────────────────────────────────────────────

class _NavDrawer extends StatelessWidget {
  final _Nav current;
  final ValueChanged<_Nav> onSelected;

  const _NavDrawer({required this.current, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Group nav items
    final groups = <String, List<_Nav>>{
      'Device': [_Nav.debug, _Nav.properties, _Nav.terminal],
      'Data': [_Nav.callLogs, _Nav.messages, _Nav.contacts, _Nav.calendar, _Nav.media],
      'Apps': [_Nav.apps, _Nav.services, _Nav.lifecycle],
      'System Core & OS State': [_Nav.dumpsys, _Nav.dumpsysL, _Nav.dumpsysActivity, _Nav.dumpsysWindow, _Nav.dumpsysStatusbar, _Nav.dumpsysPower, _Nav.dumpsysAlarm, _Nav.dumpsysUsagestats, _Nav.dumpsysSettings],
      'Hardware, Power & Battery': [_Nav.dumpsysBattery, _Nav.dumpsysBatterystats, _Nav.dumpsysDisplay, _Nav.dumpsysInput, _Nav.dumpsysSensor, _Nav.dumpsysAudio, _Nav.dumpsysVibrator, _Nav.dumpsysUsb, _Nav.dumpsysThermal, _Nav.dumpsysLights],
      'Connectivity & Networking': [_Nav.dumpsysNetstats, _Nav.dumpsysConnectivity, _Nav.dumpsysWifi, _Nav.dumpsysBluetooth, _Nav.dumpsysTelephonyRegistry, _Nav.dumpsysNetworkManagement, _Nav.dumpsysLocation],
      'Diagnostics & Logs': [_Nav.bugreport, _Nav.logcatD, _Nav.dmesg, _Nav.dumpsysBugreport, _Nav.dumpsysDropbox],
      'Memory & Process Performance': [_Nav.dumpsysMeminfo, _Nav.dumpsysProcstats, _Nav.dumpsysCpuinfo, _Nav.dumpsysGfxinfo, _Nav.amDumpheap],
      'App & Package Management': [_Nav.pmListFeatures, _Nav.pmListLibraries, _Nav.pmListPermissions],
      'System': [_Nav.settings],
    };

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Icon(Icons.adb, size: 28, color: cs.primary),
                  const SizedBox(width: 8),
                  Text('Porpita', style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            // Device chip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Consumer<DeviceManager>(
                builder: (context, dm, _) {
                  final label = dm.selected?.id ?? 'No device';
                  final ok = dm.selected?.isConnected ?? false;
                  return OutlinedButton.icon(
                    onPressed: dm.devices.isNotEmpty
                        ? () => showDialog(context: context, builder: (_) => const DeviceSelectorDialog())
                        : null,
                    icon: Icon(ok ? Icons.phone_android : Icons.warning, size: 16),
                    label: Text(label, overflow: TextOverflow.ellipsis),
                  );
                },
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: groups.entries.expand((entry) => [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(
                      entry.key.toUpperCase(),
                      style: tt.labelSmall?.copyWith(color: cs.primary, letterSpacing: 1.2, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...entry.value.map((nav) => ListTile(
                        leading: Icon(nav.icon, size: 20),
                        title: Text(nav.label),
                        selected: nav == current,
                        selectedColor: cs.primary,
                        selectedTileColor: cs.primaryContainer,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        onTap: () => onSelected(nav),
                      )),
                ]).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
