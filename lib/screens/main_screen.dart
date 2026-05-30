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
  settings('Settings', Icons.settings_suggest_outlined);

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
