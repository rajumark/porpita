import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/adb_manager.dart';
import '../services/device_manager.dart';
import '../widgets/data_screen_widgets.dart';
import '../widgets/two_panel_layout.dart';

enum _PropNs { system, secure, global }

class _PropItem {
  final _PropNs ns;
  final String key;
  final String value;
  _PropItem({required this.ns, required this.key, required this.value});

  String get nsLabel => switch (ns) {
        _PropNs.system => 'System',
        _PropNs.secure => 'Secure',
        _PropNs.global => 'Global',
      };
}

class PropertiesPage extends StatefulWidget {
  const PropertiesPage({super.key});

  @override
  State<PropertiesPage> createState() => _PropertiesPageState();
}

class _PropertiesPageState extends State<PropertiesPage> {
  List<_PropItem> _all = [];
  _PropItem? _selected;
  bool _loading = false;
  String? _deviceId;
  _PropNs? _nsFilter;

  List<_PropItem> get _items {
    var list = _nsFilter == null ? _all : _all.where((p) => p.ns == _nsFilter).toList();
    return list;
  }

  Future<void> _fetch(String deviceId) async {
    if (_loading) return;
    setState(() => _loading = true);
    final adb = AdbManager.instance.adbPath;
    if (adb == null) { setState(() => _loading = false); return; }

    Future<List<_PropItem>> fetchNs(_PropNs ns, String name) async {
      final r = await Process.run(adb, ['-s', deviceId, 'shell', 'settings', 'list', name]);
      if (r.exitCode != 0) return [];
      return r.stdout.toString().split('\n').where((l) => l.contains('=')).map((l) {
        final eq = l.indexOf('=');
        if (eq < 1) return null;
        return _PropItem(ns: ns, key: l.substring(0, eq).trim(), value: l.substring(eq + 1).trim());
      }).whereType<_PropItem>().toList();
    }

    final results = await Future.wait([
      fetchNs(_PropNs.system, 'system'),
      fetchNs(_PropNs.secure, 'secure'),
      fetchNs(_PropNs.global, 'global'),
    ]);

    if (mounted) {
      setState(() {
        _all = results.expand((e) => e).toList();
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

    final items = _items;

    final nsChips = [
      (null, 'All'),
      (_PropNs.system, 'System'),
      (_PropNs.secure, 'Secure'),
      (_PropNs.global, 'Global'),
    ];

    return TwoPanelLayout<_PropItem>(
      items: items,
      loading: _loading,
      searchHint: 'Search properties',
      emptyMessage: 'No properties found',
      selectedItem: _selected,
      onItemSelected: (item) => setState(() => _selected = item),
      filter: (item, query) =>
          item.key.toLowerCase().contains(query) ||
          item.value.toLowerCase().contains(query),
      listHeader: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: nsChips.map((t) => Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: ChoiceChip(
                    label: Text(t.$2, style: const TextStyle(fontSize: 11)),
                    selected: _nsFilter == t.$1,
                    onSelected: (_) => setState(() => _nsFilter = t.$1),
                    visualDensity: VisualDensity.compact,
                  ),
                )).toList(),
          ),
        ),
      ),
      itemBuilder: (ctx, prop, sel) => DataListTile(
        title: prop.key,
        subtitle: prop.value.isEmpty ? '(empty)' : prop.value,
        icon: switch (prop.ns) {
          _PropNs.system => Icons.tune,
          _PropNs.secure => Icons.security,
          _PropNs.global => Icons.public,
        },
        isSelected: sel,
        onTap: () => setState(() => _selected = prop),
      ),
      detailBuilder: (ctx, prop) => prop == null
          ? const NoSelectionPanel(message: 'Select a property to view it', icon: Icons.tune_outlined)
          : DetailCard(
              title: prop.key,
              icon: Icons.tune,
              fields: {
                'Namespace': prop.nsLabel,
                'Key': prop.key,
                'Value': prop.value.isEmpty ? '(empty)' : prop.value,
              },
            ),
    );
  }
}
