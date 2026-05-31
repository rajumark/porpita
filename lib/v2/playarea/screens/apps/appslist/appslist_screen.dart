import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:porpita/services/device_manager.dart';
import 'package:porpita/v2/widgets/search_view.dart';
import 'apps_list_service.dart';

class AppsListScreen extends StatefulWidget {
  final ValueChanged<String> onAppSelected;
  const AppsListScreen({super.key, required this.onAppSelected});

  @override
  State<AppsListScreen> createState() => _AppsListScreenState();
}

class _AppsListScreenState extends State<AppsListScreen> {
  List<String> _apps = [];
  List<String> _filteredApps = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _lastDeviceId;
  AppFilter _selectedFilter = AppFilter.user;
  final _searchController = TextEditingController();
  static const _filterKey = 'apps_filter_index';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadFilter();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFilter() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_filterKey) ?? 1;
    if (mounted) {
      setState(() => _selectedFilter = AppFilter.values[index]);
    }
  }

  Future<void> _saveFilter(AppFilter filter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_filterKey, filter.index);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filteredApps = _apps.where((app) => app.toLowerCase().contains(_searchQuery)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dm = context.watch<DeviceManager>();
    final device = dm.selected;

    if (device != null && device.id != _lastDeviceId) {
      _lastDeviceId = device.id;
      _fetchApps(device.id);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: SearchView(
                  controller: _searchController,
                  hintText: 'Search apps...',
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  if (value == 'filter') _showFilterDialog();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'filter', child: Text('Filter by')),
                  const PopupMenuItem(value: 'sort', child: Text('Sort by')),
                  const PopupMenuItem(value: 'install', child: Text('Install app')),
                ],
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: IconButton(
                    icon: const Icon(Icons.more_vert),
                    iconSize: 24,
                    onPressed: null,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints.tight(const Size(36, 36)),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter by'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppFilter.values.map((filter) {
              return RadioListTile<AppFilter>(
                title: Text(filter.label),
                value: filter,
                groupValue: _selectedFilter,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedFilter = value);
                    _saveFilter(value);
                    Navigator.of(context).pop();
                    final device = context.read<DeviceManager>().selected;
                    if (device != null) _fetchApps(device.id);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _fetchApps(String deviceId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apps = await AppsListService.fetchApps(deviceId, _selectedFilter);
      if (mounted) {
        setState(() {
          _apps = apps;
          _filteredApps = _searchQuery.isEmpty
              ? apps
              : apps.where((app) => app.toLowerCase().contains(_searchQuery)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  BorderRadius _borderRadius(int index, int total) {
    if (total == 1) return BorderRadius.circular(12);
    if (index == 0) {
      return const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      );
    }
    if (index == total - 1) {
      return const BorderRadius.only(
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      );
    }
    return BorderRadius.circular(2);
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(_error!, style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    if (_filteredApps.isEmpty) {
      return Center(
        child: Text('No apps found', style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    final total = _filteredApps.length;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: total,
      separatorBuilder: (_, __) => const SizedBox(height: 2),
      itemBuilder: (context, index) {
        final app = _filteredApps[index];
        final borderRadius = _borderRadius(index, total);
        return Material(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: borderRadius,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: () => widget.onAppSelected(app),
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 6, bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(app, style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  PopupMenuButton<String>(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (value) {},
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'start', child: Text('Start')),
                      const PopupMenuItem(value: 'stop', child: Text('Stop')),
                      const PopupMenuItem(value: 'restart', child: Text('Restart')),
                    ],
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: IconButton(
                        icon: const Icon(Icons.more_vert),
                        iconSize: 20,
                        onPressed: null,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints.tight(const Size(32, 32)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
