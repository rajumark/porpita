import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/adb_manager.dart';
import '../services/device_manager.dart';
import '../widgets/data_screen_widgets.dart';
import '../widgets/two_panel_layout.dart';

class _Service {
  final String pid;
  final String name;

  _Service({required this.pid, required this.name});
}

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  List<_Service> _items = [];
  _Service? _selected;
  bool _loading = false;
  String? _deviceId;
  // Details — raw dumpsys output for selected service
  String _details = '';

  Future<void> _fetch(String deviceId) async {
    if (_loading) return;
    setState(() => _loading = true);
    final adb = AdbManager.instance.adbPath;
    if (adb == null) { setState(() => _loading = false); return; }

    final result = await Process.run(adb, ['-s', deviceId, 'shell', 'dumpsys', 'activity', 'services']);
    final services = <_Service>[];
    if (result.exitCode == 0) {
      for (final line in result.stdout.toString().split('\n')) {
        final t = line.trim();
        if (t.startsWith('app=ProcessRecord')) {
          final aa = t.split(' ').last.replaceAll('}', '');
          final parts = aa.split(':');
          if (parts.length == 2) {
            final pid = parts[0];
            final name = parts[1].contains('/') ? parts[1].split('/').first : parts[1];
            services.add(_Service(pid: pid, name: name));
          }
        }
      }
    }
    if (mounted) {
      setState(() {
        _items = services;
        _loading = false;
        _deviceId = deviceId;
        _selected = null;
        _details = '';
      });
    }
  }

  Future<void> _fetchDetails(String deviceId, _Service svc) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) return;
    setState(() => _details = 'Loading…');
    final result = await Process.run(adb, ['-s', deviceId, 'shell', 'dumpsys', svc.name]);
    if (mounted) setState(() => _details = result.stdout.toString());
  }

  @override
  Widget build(BuildContext context) {
    final dm = context.watch<DeviceManager>();
    final device = dm.selected;
    if (device == null || !device.isConnected) return const NoDevicePanel();

    if (_deviceId != device.id) WidgetsBinding.instance.addPostFrameCallback((_) => _fetch(device.id));

    return TwoPanelLayout<_Service>(
      items: _items,
      loading: _loading,
      searchHint: 'Search services',
      emptyMessage: 'No services found',
      selectedItem: _selected,
      onItemSelected: (item) {
        setState(() => _selected = item);
        _fetchDetails(device.id, item);
      },
      filter: (item, query) =>
          item.name.toLowerCase().contains(query) ||
          item.pid.toLowerCase().contains(query),
      listHeader: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(icon: const Icon(Icons.refresh, size: 18), onPressed: () => _fetch(device.id)),
            Text('${_items.length} services', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      itemBuilder: (ctx, svc, sel) => DataListTile(
        title: svc.name,
        subtitle: 'PID: ${svc.pid}',
        icon: Icons.settings_applications_outlined,
        isSelected: sel,
        onTap: () {
          setState(() => _selected = svc);
          _fetchDetails(device.id, svc);
        },
      ),
      detailBuilder: (ctx, svc) {
        if (svc == null) return const NoSelectionPanel(message: 'Select a service to view dumpsys output', icon: Icons.layers_outlined);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.settings_applications_outlined),
                  const SizedBox(width: 8),
                  Expanded(child: Text(svc.name, style: Theme.of(ctx).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
                  Text('PID ${svc.pid}', style: Theme.of(ctx).textTheme.bodySmall),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  _details.isEmpty ? '(loading)' : _details,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
