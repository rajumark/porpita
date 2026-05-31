import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/device_manager.dart';
import '../widgets/device_selector_dialog.dart';
import '../widgets/settings_dialog.dart';
import '../features/apps/screens/apps_page.dart';
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
import 'commands/service_list_page.dart';
import 'commands/dumpsys_surfaceflinger_page.dart';
import 'commands/dumpsys_appops_page.dart';
import 'commands/dumpsys_notification_page.dart';
import 'commands/dumpsys_keystore_page.dart';
import 'commands/dumpsys_media_session_page.dart';
import 'commands/dumpsys_jobscheduler_page.dart';
import 'commands/dumpsys_wallpaper_page.dart';
import 'commands/dumpsys_shortcut_page.dart';
import 'commands/dumpsys_account_page.dart';
import 'commands/dumpsys_mount_page.dart';
import 'commands/dumpsys_storagestats_page.dart';
import 'commands/dumpsys_backup_page.dart';
import 'commands/dumpsys_app_hibernation_page.dart';
import 'commands/dumpsys_fingerprint_page.dart';
import 'commands/dumpsys_uri_grants_page.dart';
import 'commands/dumpsys_netpolicy_page.dart';
import 'commands/dumpsys_overlay_page.dart';
import 'commands/dumpsys_device_policy_page.dart';
import 'commands/dumpsys_app_search_page.dart';
import 'commands/dumpsys_content_capture_page.dart';
import 'commands/dumpsys_activity_top_page.dart';
import 'commands/dumpsys_activity_broadcasts_page.dart';
import 'commands/dumpsys_activity_services_page.dart';
import 'commands/dumpsys_activity_intents_page.dart';
import 'commands/dumpsys_activity_providers_page.dart';
import 'commands/dumpsys_activity_recents_page.dart';
import 'commands/dumpsys_activity_processes_page.dart';
import 'commands/pm_dump_page.dart';
import 'commands/pm_list_users_page.dart';
import 'commands/pm_get_max_users_page.dart';
import 'commands/pm_list_instrumentation_page.dart';
import 'commands/cmd_package_compile_l_page.dart';
import 'commands/cmd_shortcut_dump_page.dart';
import 'commands/cmd_wifi_status_page.dart';
import 'commands/cmd_overlay_list_page.dart';
import 'commands/getprop_page.dart';
import 'commands/procrank_page.dart';
import 'commands/df_h_page.dart';
import 'commands/cat_proc_cpuinfo_page.dart';
import 'commands/cat_proc_meminfo_page.dart';
import 'commands/cat_proc_partitions_page.dart';
import 'commands/cat_proc_modules_page.dart';
import 'commands/cat_proc_version_page.dart';
import 'commands/cat_proc_uptime_page.dart';
import 'commands/cat_proc_net_dev_page.dart';
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
import 'commands/acpi_page.dart';
import 'commands/date_page.dart';
import 'commands/wm_page.dart';
import 'commands/uimode_page.dart';
import 'commands/deviceidle_page.dart';
import 'commands/reboot_readiness_page.dart';
import 'commands/safety_center_page.dart';
import 'commands/telecom_page.dart';
import 'commands/svc_usb_page.dart';
import 'commands/bmgr_page.dart';
import 'commands/magisk_page.dart';
import 'commands/sysfs_page.dart';
import 'command_browser_page.dart';

// ── navigation items ─────────────────────────────────────────────────────────

enum _Nav {
  commandBrowser('Commands', Icons.build_outlined),
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
  pmListPermissions('pm list permissions', Icons.code),
  serviceList('service list', Icons.code),
  dumpsysSurfaceflinger('dumpsys SurfaceFlinger', Icons.code),
  dumpsysAppops('dumpsys appops', Icons.code),
  dumpsysNotification('dumpsys notification', Icons.code),
  dumpsysKeystore('dumpsys keystore', Icons.code),
  dumpsysMediaSession('dumpsys media_session', Icons.code),
  dumpsysJobscheduler('dumpsys jobscheduler', Icons.code),
  dumpsysWallpaper('dumpsys wallpaper', Icons.code),
  dumpsysShortcut('dumpsys shortcut', Icons.code),
  dumpsysAccount('dumpsys account', Icons.code),
  dumpsysMount('dumpsys mount', Icons.code),
  dumpsysStoragestats('dumpsys storagestats', Icons.code),
  dumpsysBackup('dumpsys backup', Icons.code),
  dumpsysAppHibernation('dumpsys app_hibernation', Icons.code),
  dumpsysFingerprint('dumpsys fingerprint', Icons.code),
  dumpsysUriGrants('dumpsys uri_grants', Icons.code),
  dumpsysNetpolicy('dumpsys netpolicy', Icons.code),
  dumpsysOverlay('dumpsys overlay', Icons.code),
  dumpsysDevicePolicy('dumpsys device_policy', Icons.code),
  dumpsysAppSearch('dumpsys app_search', Icons.code),
  dumpsysContentCapture('dumpsys content_capture', Icons.code),
  dumpsysActivityTop('dumpsys activity top', Icons.code),
  dumpsysActivityBroadcasts('dumpsys activity broadcasts', Icons.code),
  dumpsysActivityServices('dumpsys activity services', Icons.code),
  dumpsysActivityIntents('dumpsys activity intents', Icons.code),
  dumpsysActivityProviders('dumpsys activity providers', Icons.code),
  dumpsysActivityRecents('dumpsys activity recents', Icons.code),
  dumpsysActivityProcesses('dumpsys activity processes', Icons.code),
  pmDump('pm dump', Icons.code),
  pmListUsers('pm list users', Icons.code),
  pmGetMaxUsers('pm get-max-users', Icons.code),
  pmListInstrumentation('pm list instrumentation', Icons.code),
  cmdPackageCompileL('cmd package compile -l', Icons.code),
  cmdShortcutDump('cmd shortcut dump', Icons.code),
  cmdWifiStatus('cmd wifi status', Icons.code),
  cmdOverlayList('cmd overlay list', Icons.code),
  getprop('getprop', Icons.code),
  procrank('procrank', Icons.code),
  dfH('df -h', Icons.code),
  catProcCpuinfo('cat /proc/cpuinfo', Icons.code),
  catProcMeminfo('cat /proc/meminfo', Icons.code),
  catProcPartitions('cat /proc/partitions', Icons.code),
  catProcModules('cat /proc/modules', Icons.code),
  catProcVersion('cat /proc/version', Icons.code),
  catProcUptime('cat /proc/uptime', Icons.code),
  catProcNetDev('cat /proc/net/dev', Icons.code),
  acpi('acpi', Icons.code),
  date('date', Icons.code),
  wm('wm', Icons.code),
  uimode('cmd uimode', Icons.code),
  deviceidle('cmd deviceidle', Icons.code),
  rebootReadiness('cmd reboot_readiness', Icons.code),
  safetyCenter('cmd safety_center', Icons.code),
  telecom('telecom', Icons.code),
  svcUsb('svc usb', Icons.code),
  bmgr('bmgr', Icons.code),
  magisk('magisk', Icons.code),
  sysfs('sysfs', Icons.code),;

  final String label;
  final IconData icon;
  const _Nav(this.label, this.icon);
}

Widget _buildPage(_Nav nav) => switch (nav) {
      _Nav.commandBrowser => const CommandBrowserPage(),
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
      _Nav.serviceList => const ServiceListPage(),
      _Nav.dumpsysSurfaceflinger => const DumpsysSurfaceflingerPage(),
      _Nav.dumpsysAppops => const DumpsysAppopsPage(),
      _Nav.dumpsysNotification => const DumpsysNotificationPage(),
      _Nav.dumpsysKeystore => const DumpsysKeystorePage(),
      _Nav.dumpsysMediaSession => const DumpsysMediaSessionPage(),
      _Nav.dumpsysJobscheduler => const DumpsysJobschedulerPage(),
      _Nav.dumpsysWallpaper => const DumpsysWallpaperPage(),
      _Nav.dumpsysShortcut => const DumpsysShortcutPage(),
      _Nav.dumpsysAccount => const DumpsysAccountPage(),
      _Nav.dumpsysMount => const DumpsysMountPage(),
      _Nav.dumpsysStoragestats => const DumpsysStoragestatsPage(),
      _Nav.dumpsysBackup => const DumpsysBackupPage(),
      _Nav.dumpsysAppHibernation => const DumpsysAppHibernationPage(),
      _Nav.dumpsysFingerprint => const DumpsysFingerprintPage(),
      _Nav.dumpsysUriGrants => const DumpsysUriGrantsPage(),
      _Nav.dumpsysNetpolicy => const DumpsysNetpolicyPage(),
      _Nav.dumpsysOverlay => const DumpsysOverlayPage(),
      _Nav.dumpsysDevicePolicy => const DumpsysDevicePolicyPage(),
      _Nav.dumpsysAppSearch => const DumpsysAppSearchPage(),
      _Nav.dumpsysContentCapture => const DumpsysContentCapturePage(),
      _Nav.dumpsysActivityTop => const DumpsysActivityTopPage(),
      _Nav.dumpsysActivityBroadcasts => const DumpsysActivityBroadcastsPage(),
      _Nav.dumpsysActivityServices => const DumpsysActivityServicesPage(),
      _Nav.dumpsysActivityIntents => const DumpsysActivityIntentsPage(),
      _Nav.dumpsysActivityProviders => const DumpsysActivityProvidersPage(),
      _Nav.dumpsysActivityRecents => const DumpsysActivityRecentsPage(),
      _Nav.dumpsysActivityProcesses => const DumpsysActivityProcessesPage(),
      _Nav.pmDump => const PmDumpPage(),
      _Nav.pmListUsers => const PmListUsersPage(),
      _Nav.pmGetMaxUsers => const PmGetMaxUsersPage(),
      _Nav.pmListInstrumentation => const PmListInstrumentationPage(),
      _Nav.cmdPackageCompileL => const CmdPackageCompileLPage(),
      _Nav.cmdShortcutDump => const CmdShortcutDumpPage(),
      _Nav.cmdWifiStatus => const CmdWifiStatusPage(),
      _Nav.cmdOverlayList => const CmdOverlayListPage(),
      _Nav.getprop => const GetpropPage(),
      _Nav.procrank => const ProcrankPage(),
      _Nav.dfH => const DfHPage(),
      _Nav.catProcCpuinfo => const CatProcCpuinfoPage(),
      _Nav.catProcMeminfo => const CatProcMeminfoPage(),
      _Nav.catProcPartitions => const CatProcPartitionsPage(),
      _Nav.catProcModules => const CatProcModulesPage(),
      _Nav.catProcVersion => const CatProcVersionPage(),
      _Nav.catProcUptime => const CatProcUptimePage(),
      _Nav.catProcNetDev => const CatProcNetDevPage(),
      _Nav.acpi => const AcpiPage(),
      _Nav.date => const DatePage(),
      _Nav.wm => const WmPage(),
      _Nav.uimode => const UimodePage(),
      _Nav.deviceidle => const DeviceidlePage(),
      _Nav.rebootReadiness => const RebootReadinessPage(),
      _Nav.safetyCenter => const SafetyCenterPage(),
      _Nav.telecom => const TelecomPage(),
      _Nav.svcUsb => const SvcUsbPage(),
      _Nav.bmgr => const BmgrPage(),
      _Nav.magisk => const MagiskPage(),
      _Nav.sysfs => const SysfsPage(),

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

class _NavDrawer extends StatefulWidget {
  final _Nav current;
  final ValueChanged<_Nav> onSelected;

  const _NavDrawer({required this.current, required this.onSelected});

  @override
  State<_NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<_NavDrawer> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Group nav items
    final allGroups = <String, List<_Nav>>{
      'Device': [_Nav.commandBrowser, _Nav.debug, _Nav.properties, _Nav.terminal],
      'Data': [_Nav.callLogs, _Nav.messages, _Nav.contacts, _Nav.calendar, _Nav.media],
      'Apps': [_Nav.apps, _Nav.services, _Nav.lifecycle],
      'System Core & OS State': [_Nav.dumpsys, _Nav.dumpsysL, _Nav.dumpsysActivity, _Nav.dumpsysWindow, _Nav.dumpsysStatusbar, _Nav.dumpsysPower, _Nav.dumpsysAlarm, _Nav.dumpsysUsagestats, _Nav.dumpsysSettings, _Nav.wm, _Nav.uimode, _Nav.date],
      'Hardware, Power & Battery': [_Nav.dumpsysBattery, _Nav.dumpsysBatterystats, _Nav.dumpsysDisplay, _Nav.dumpsysInput, _Nav.dumpsysSensor, _Nav.dumpsysAudio, _Nav.dumpsysVibrator, _Nav.dumpsysUsb, _Nav.dumpsysThermal, _Nav.dumpsysLights, _Nav.deviceidle, _Nav.svcUsb],
      'Connectivity & Networking': [_Nav.dumpsysNetstats, _Nav.dumpsysConnectivity, _Nav.dumpsysWifi, _Nav.dumpsysBluetooth, _Nav.dumpsysTelephonyRegistry, _Nav.dumpsysNetworkManagement, _Nav.dumpsysLocation, _Nav.telecom],
      'Diagnostics & Logs': [_Nav.bugreport, _Nav.logcatD, _Nav.dmesg, _Nav.dumpsysBugreport, _Nav.dumpsysDropbox, _Nav.rebootReadiness, _Nav.safetyCenter],
      'Memory & Process Performance': [_Nav.dumpsysMeminfo, _Nav.dumpsysProcstats, _Nav.dumpsysCpuinfo, _Nav.dumpsysGfxinfo, _Nav.amDumpheap],
      'App & Package Management': [_Nav.pmListFeatures, _Nav.pmListLibraries, _Nav.pmListPermissions, _Nav.bmgr],
      'Core Service Discovery & Composition': [_Nav.serviceList, _Nav.dumpsysSurfaceflinger, _Nav.dumpsysAppops, _Nav.dumpsysNotification, _Nav.dumpsysKeystore, _Nav.dumpsysMediaSession, _Nav.dumpsysJobscheduler, _Nav.dumpsysWallpaper, _Nav.dumpsysShortcut, _Nav.dumpsysAccount, _Nav.dumpsysMount, _Nav.dumpsysStoragestats, _Nav.dumpsysBackup, _Nav.dumpsysAppHibernation, _Nav.dumpsysFingerprint, _Nav.dumpsysUriGrants, _Nav.dumpsysNetpolicy, _Nav.dumpsysOverlay, _Nav.dumpsysDevicePolicy, _Nav.dumpsysAppSearch, _Nav.dumpsysContentCapture],
      'Activity Manager State Diagnostics': [_Nav.dumpsysActivityTop, _Nav.dumpsysActivityBroadcasts, _Nav.dumpsysActivityServices, _Nav.dumpsysActivityIntents, _Nav.dumpsysActivityProviders, _Nav.dumpsysActivityRecents, _Nav.dumpsysActivityProcesses],
      'Package Manager State Diagnostics': [_Nav.pmDump, _Nav.pmListUsers, _Nav.pmGetMaxUsers, _Nav.pmListInstrumentation],
      'High-Fidelity Service Routing': [_Nav.cmdPackageCompileL, _Nav.cmdShortcutDump, _Nav.cmdWifiStatus, _Nav.cmdOverlayList],
      'Linux Kernel & Virtual File System': [_Nav.getprop, _Nav.procrank, _Nav.dfH, _Nav.catProcCpuinfo, _Nav.catProcMeminfo, _Nav.catProcPartitions, _Nav.catProcModules, _Nav.catProcVersion, _Nav.catProcUptime, _Nav.catProcNetDev, _Nav.sysfs, _Nav.acpi, _Nav.magisk],
      'System': [_Nav.settings],
    };

    // Filter groups by search query
    final q = _searchQuery.toLowerCase().trim();
    final groups = q.isEmpty
        ? allGroups
        : allGroups.map((key, value) {
            final filtered = value.where((nav) =>
              nav.label.toLowerCase().contains(q)
            ).toList();
            return MapEntry(key, filtered);
          })..removeWhere((key, value) => value.isEmpty);

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
            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search menus…',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchQuery.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: groups.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off, size: 32, color: cs.outlineVariant),
                          const SizedBox(height: 8),
                          Text('No menus match "$_searchQuery"', style: TextStyle(color: cs.onSurfaceVariant)),
                        ],
                      ),
                    )
                  : ListView(
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
                              selected: nav == widget.current,
                              selectedColor: cs.primary,
                              selectedTileColor: cs.primaryContainer,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                              onTap: () => widget.onSelected(nav),
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
