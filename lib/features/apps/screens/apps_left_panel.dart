import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/device_manager.dart';
import '../services/apps_service.dart';

class AppsLeftPanel extends StatefulWidget {
  final String? selectedPackage;
  final ValueChanged<String> onPackageSelected;

  const AppsLeftPanel({
    super.key,
    required this.onPackageSelected,
    this.selectedPackage,
  });

  @override
  State<AppsLeftPanel> createState() => _AppsLeftPanelState();
}

class _AppsLeftPanelState extends State<AppsLeftPanel> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  AppType _appType = AppType.user;
  List<String> _allPackages = [];
  bool _loading = false;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<String> get _filteredPackages {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _allPackages;
    return _allPackages.where((p) => p.toLowerCase().contains(query)).toList();
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

  @override
  Widget build(BuildContext context) {
    final dm = context.watch<DeviceManager>();
    final deviceId = dm.selected?.id;

    if (deviceId == null || !(dm.selected?.isConnected ?? false)) {
      return const Center(
        child: Text('Connect a device to view apps'),
      );
    }

    if (_allPackages.isEmpty && !_loading) {
      _fetchPackages(deviceId);
    }

    final filtered = _filteredPackages;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search ${_allPackages.length} items',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 4),
              PopupMenuButton<AppType>(
                icon: Icon(
                  Icons.filter_alt,
                  color: _appType != AppType.user
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  size: 22,
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
          child: _loading && _allPackages.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : filtered.isEmpty
                  ? const Center(child: Text('No packages found'))
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final pkg = filtered[i];
                        final isSelected = pkg == widget.selectedPackage;
                        return _AppListItem(
                          packageName: pkg,
                          isSelected: isSelected,
                          onTap: () => widget.onPackageSelected(pkg),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

class _AppListItem extends StatelessWidget {
  final String packageName;
  final bool isSelected;
  final VoidCallback onTap;

  const _AppListItem({
    required this.packageName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.android,
                size: 18,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  packageName,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
