import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/adb_manager.dart';
import '../services/device_manager.dart';
import '../widgets/data_screen_widgets.dart';
import '../widgets/two_panel_layout.dart';

class _LifecycleEntry {
  final String time;
  final String type;
  final String packageName;
  final String className;
  final Map<String, String> raw;

  _LifecycleEntry({required this.raw})
      : time = raw['time'] ?? '',
        type = raw['type'] ?? '',
        packageName = raw['package'] ?? '',
        className = raw['class'] ?? '';

  IconData get icon => switch (type.toLowerCase()) {
        'move_to_foreground' => Icons.open_in_full,
        'move_to_background' => Icons.minimize,
        _ => Icons.swap_horiz,
      };

  String get shortClass => className.contains('.') ? className.split('.').last : className;
}

Map<String, String> _parseLifecycleLine(String line) {
  final map = <String, String>{};
  // time="..."
  final timeMatch = RegExp(r'time="([^"]*)"').firstMatch(line);
  if (timeMatch != null) map['time'] = timeMatch.group(1)!;

  for (final kv in line.split(' ')) {
    final eq = kv.indexOf('=');
    if (eq < 1) continue;
    final k = kv.substring(0, eq);
    var v = kv.substring(eq + 1);
    if (v.startsWith('"') && v.endsWith('"')) v = v.substring(1, v.length - 1);
    if (k != 'time') map[k] = v;
  }
  return map;
}

class LifecyclePage extends StatefulWidget {
  const LifecyclePage({super.key});

  @override
  State<LifecyclePage> createState() => _LifecyclePageState();
}

class _LifecyclePageState extends State<LifecyclePage> {
  List<_LifecycleEntry> _items = [];
  _LifecycleEntry? _selected;
  bool _loading = false;
  String? _deviceId;

  Future<void> _fetch(String deviceId) async {
    if (_loading) return;
    setState(() => _loading = true);
    final adb = AdbManager.instance.adbPath;
    if (adb == null) { setState(() => _loading = false); return; }

    final result = await Process.run(adb, ['-s', deviceId, 'shell', 'dumpsys', 'usagestats']);
    final entries = <_LifecycleEntry>[];
    if (result.exitCode == 0) {
      for (final line in result.stdout.toString().split('\n')) {
        final map = _parseLifecycleLine(line.trim());
        if (map.containsKey('time') && map.containsKey('type')) {
          entries.add(_LifecycleEntry(raw: map));
        }
      }
    }
    if (mounted) {
      setState(() {
        _items = entries.reversed.toList();
        _loading = false;
        _deviceId = deviceId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dm = context.watch<DeviceManager>();
    final device = dm.selected;
    if (device == null || !device.isConnected) return const NoDevicePanel();

    if (_deviceId != device.id) WidgetsBinding.instance.addPostFrameCallback((_) => _fetch(device.id));

    return TwoPanelLayout<_LifecycleEntry>(
      items: _items,
      loading: _loading,
      searchHint: 'Search lifecycle',
      emptyMessage: 'No lifecycle events found',
      selectedItem: _selected,
      onItemSelected: (item) => setState(() => _selected = item),
      filter: (item, query) =>
          item.packageName.toLowerCase().contains(query) ||
          item.className.toLowerCase().contains(query) ||
          item.type.toLowerCase().contains(query),
      listHeader: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(icon: const Icon(Icons.refresh, size: 18), onPressed: () => _fetch(device.id)),
            Text('${_items.length} events', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      itemBuilder: (ctx, item, sel) => DataListTile(
        title: item.packageName.isEmpty ? item.type : item.packageName,
        subtitle: '${item.type} · ${item.time}',
        icon: item.icon,
        isSelected: sel,
        onTap: () => setState(() => _selected = item),
      ),
      detailBuilder: (ctx, item) => item == null
          ? const NoSelectionPanel(message: 'Select an event to view details', icon: Icons.timeline_outlined)
          : DetailCard(
              title: item.packageName.isEmpty ? item.type : item.packageName,
              icon: item.icon,
              fields: {
                'Time': item.time,
                'Type': item.type,
                'Package': item.packageName,
                'Class': item.className,
                ...item.raw,
              },
            ),
    );
  }
}
