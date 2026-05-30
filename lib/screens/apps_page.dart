import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/apps_service.dart';
import '../services/device_manager.dart';

class AppsPage extends StatefulWidget {
  const AppsPage({super.key});

  @override
  State<AppsPage> createState() => _AppsPageState();
}

class _AppsPageState extends State<AppsPage> {
  final _searchController = TextEditingController();
  AppType _appType = AppType.user;
  List<String> _allPackages = [];
  Timer? _refreshTimer;
  bool _loading = false;

  @override
  void dispose() {
    _searchController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dm = context.watch<DeviceManager>();
    final deviceId = dm.selected?.id;

    if (deviceId == null || !(dm.selected?.isConnected ?? false)) {
      return const Center(
        child: Text('Connect a device to view apps'),
      );
    }

    if (_refreshTimer == null) {
      _startAutoRefresh(deviceId);
    }

    final query = _searchController.text.toLowerCase();
    final filtered = query.isEmpty
        ? _allPackages
        : _allPackages.where((p) => p.toLowerCase().contains(query)).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search apps',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<AppType>(
                icon: Icon(
                  Icons.filter_alt,
                  color: _appType != AppType.user
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                tooltip: 'Filter',
                initialValue: _appType,
                onSelected: (type) {
                  setState(() => _appType = type);
                  _fetchPackages(deviceId);
                },
                itemBuilder: (_) => AppType.values.map((type) {
                  return PopupMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        if (type == _appType)
                          Icon(
                            Icons.check,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        else
                          const SizedBox(width: 18),
                        const SizedBox(width: 8),
                        Text(type.label),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : filtered.isEmpty
                  ? const Center(child: Text('No packages found'))
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, i) => _PackageTile(
                        packageName: filtered[i],
                        deviceId: deviceId,
                      ),
                    ),
        ),
      ],
    );
  }

  void _startAutoRefresh(String deviceId) {
    _fetchPackages(deviceId);
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      final dm = context.read<DeviceManager>();
      final id = dm.selected?.id;
      if (id != null && dm.selected?.isConnected == true) {
        _fetchPackages(id);
      }
    });
  }

  Future<void> _fetchPackages(String deviceId) async {
    if (_loading) return;
    setState(() => _loading = true);

    final packages = await AppsService.fetchPackages(
      deviceId: deviceId,
      type: _appType,
    );

    if (mounted) {
      setState(() {
        _allPackages = packages;
        _loading = false;
      });
    }
  }
}

class _PackageTile extends StatelessWidget {
  final String packageName;
  final String deviceId;

  const _PackageTile({
    required this.packageName,
    required this.deviceId,
  });

  static const _actionData = {
    AppAction.start:       ('Start',        Icons.play_arrow),
    AppAction.stop:        ('Stop',         Icons.stop),
    AppAction.restart:     ('Restart',      Icons.restart_alt),
    AppAction.clearData:   ('Clear Data',   Icons.cleaning_services),
    AppAction.uninstall:   ('Uninstall',    Icons.delete_outline),
    AppAction.enable:      ('Enable',       Icons.check_circle_outline),
    AppAction.disable:     ('Disable',      Icons.block),
    AppAction.home:        ('Home',         Icons.home),
    AppAction.copy:        ('Copy',         Icons.copy),
    AppAction.appInfo:     ('App Info',     Icons.info_outline),
    AppAction.playStore:   ('Play Store',   Icons.shop),
    AppAction.openInBrowser: ('Open in Browser', Icons.open_in_browser),
    AppAction.findOnline:  ('Find Online',  Icons.search),
  };

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(
        packageName,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
      ),
      trailing: PopupMenuButton<AppAction>(
        icon: const Icon(Icons.more_vert, size: 20),
        onSelected: (action) => _handleAction(context, action),
        itemBuilder: (_) {
          final items = <PopupMenuEntry<AppAction>>[];
          for (final action in AppAction.values) {
            items.add(PopupMenuItem(
              value: action,
              child: Row(
                children: [
                  Icon(_actionData[action]!.$2, size: 18),
                  const SizedBox(width: 12),
                  Text(_actionData[action]!.$1),
                ],
              ),
            ));
            if (action == AppAction.copy) {
              items.add(
                const PopupMenuItem<AppAction>(
                  enabled: false,
                  child: Divider(height: 1),
                ),
              );
            }
          }
          return items;
        },
      ),
      onTap: () {},
    );
  }

  Future<void> _handleAction(BuildContext context, AppAction action) async {
    if (action == AppAction.openInBrowser) {
      final url = AppsService.playStoreUrl(packageName);
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      return;
    }

    if (action == AppAction.findOnline) {
      final url = AppsService.findOnlineUrl(packageName);
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      return;
    }

    await AppsService.runAction(
      deviceId: deviceId,
      packageName: packageName,
      action: action,
    );

    if (action == AppAction.copy && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Package name copied'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
