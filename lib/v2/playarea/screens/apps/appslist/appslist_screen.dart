import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:porpita/services/device_manager.dart';
import 'package:porpita/v2/widgets/search_view.dart';
import 'apps_list_service.dart';
import 'apps_item_tile.dart';
import 'app_actions_service.dart';
import 'appinstall/app_install_service.dart';
import 'appinstall/app_install_dialog.dart';
import 'current_app/current_app_service.dart';

class AppsListScreen extends StatefulWidget {
  final ValueChanged<String> onAppSelected;
  const AppsListScreen({super.key, required this.onAppSelected});

  @override
  State<AppsListScreen> createState() => _AppsListScreenState();
}

class _AppsListScreenState extends State<AppsListScreen> {
  List<String> _systemApps = [];
  List<String> _userApps = [];
  ForegroundApp? _foregroundApp;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _lastDeviceId;
  AppFilter _selectedFilter = AppFilter.all;
  final _searchController = TextEditingController();
  static const _filterKey = 'apps_filter_index';

  Timer? _appsTimer;
  Timer? _currentAppTimer;
  static const _appsRefreshInterval = Duration(seconds: 5);
  static const _currentAppRefreshInterval = Duration(seconds: 3);

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
    _cancelTimers();
    super.dispose();
  }

  void _cancelTimers() {
    _appsTimer?.cancel();
    _appsTimer = null;
    _currentAppTimer?.cancel();
    _currentAppTimer = null;
  }

  void _startTimers(String deviceId) {
    _cancelTimers();
    _appsTimer = Timer.periodic(_appsRefreshInterval, (_) => _fetchApps(deviceId));
    _currentAppTimer = Timer.periodic(_currentAppRefreshInterval, (_) => _fetchCurrentApp(deviceId));
  }

  void _handleDeviceSwitch(String deviceId) {
    _lastDeviceId = deviceId;
    _cancelTimers();
    _fetchData(deviceId);
  }

  Future<void> _loadFilter() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_filterKey) ?? 0;
    if (mounted) {
      setState(() => _selectedFilter = AppFilter.values[index]);
    }
  }

  Future<void> _saveFilter(AppFilter filter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_filterKey, filter.index);
  }

  void _onSearchChanged() {
    setState(() => _searchQuery = _searchController.text.toLowerCase());
  }

  bool _matchesSearch(String package) {
    if (_searchQuery.isEmpty) return true;
    return package.toLowerCase().contains(_searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    final dm = context.watch<DeviceManager>();
    final device = dm.selected;

    if (device != null && device.id != _lastDeviceId) {
      _handleDeviceSwitch(device.id);
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
                  if (value == 'filter') {
                    _showFilterDialog();
                  } else if (value == 'install') {
                    _installApk();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'filter', child: Text('Filter by')),
                  const PopupMenuItem(value: 'sort', child: Text('Sort by')),
                  const PopupMenuItem(value: 'install', child: Text('Install app')),
                ],
                icon: const Icon(Icons.more_vert),
                iconSize: 24,
                padding: EdgeInsets.zero,
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
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _installApk() async {
    final device = context.read<DeviceManager>().selected;
    if (device == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No device connected')),
      );
      return;
    }

    final result = await AppInstallService.pickAndInstall(device.id);

    if (!mounted) return;
    showInstallResultDialog(
      context,
      success: result.success,
      message: result.message,
      filePath: result.filePath,
    );

    if (result.success) {
      final dev = context.read<DeviceManager>().selected;
      if (dev != null) _fetchData(dev.id);
    }
  }

  void _handleAppAction(AppAction action, String packageName) {
    final device = context.read<DeviceManager>().selected;
    if (device == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No device connected')),
      );
      return;
    }
    AppActionsService.run(device.id, action, packageName).then((_) {
      if (!mounted) return;
      final msg = '${action.label}: $packageName';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
      );
      if (action == AppAction.uninstall ||
          action == AppAction.enable ||
          action == AppAction.disable ||
          action == AppAction.clearData) {
        final dev = context.read<DeviceManager>().selected;
        if (dev != null) _fetchData(dev.id);
      }
    });
  }

  Future<void> _fetchData(String deviceId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        CurrentAppService.fetch(deviceId),
        AppsListService.fetchCategorizedApps(deviceId),
      ]);

      if (!mounted) return;

      final newForegroundApp = results[0] as ForegroundApp?;
      final categorized = results[1] as ({List<String> system, List<String> user});

      setState(() {
        _foregroundApp = newForegroundApp;
        _systemApps = categorized.system;
        _userApps = categorized.user;
        _isLoading = false;
      });

      _startTimers(deviceId);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchApps(String deviceId) async {
    try {
      final categorized = await AppsListService.fetchCategorizedApps(deviceId);
      if (!mounted) return;

      final systemChanged = !_listEquals(_systemApps, categorized.system);
      final userChanged = !_listEquals(_userApps, categorized.user);

      if (systemChanged || userChanged) {
        setState(() {
          _systemApps = categorized.system;
          _userApps = categorized.user;
        });
      }
    } catch (_) {
      // Silently ignore background refresh errors
    }
  }

  Future<void> _fetchCurrentApp(String deviceId) async {
    try {
      final newApp = await CurrentAppService.fetch(deviceId);
      if (!mounted) return;

      final changed = newApp?.packageName != _foregroundApp?.packageName ||
          newApp?.activityName != _foregroundApp?.activityName;

      if (changed) {
        setState(() => _foregroundApp = newApp);
      }
    } catch (_) {
      // Silently ignore background refresh errors
    }
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
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

    final showCurrentApp = _foregroundApp != null;
    final showSystemSection = _selectedFilter == AppFilter.all || _selectedFilter == AppFilter.system;
    final showUserSection = _selectedFilter == AppFilter.all || _selectedFilter == AppFilter.user;

    final filteredSystem = _systemApps.where(_matchesSearch).toList();
    final filteredUser = _userApps.where(_matchesSearch).toList();
    final currentAppMatches = _foregroundApp != null && _matchesSearch(_foregroundApp!.packageName);

    if (!showCurrentApp && !showSystemSection && !showUserSection) {
      return Center(
        child: Text('No apps found', style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    final hasAnyContent = (showCurrentApp && currentAppMatches) ||
        (showSystemSection && filteredSystem.isNotEmpty) ||
        (showUserSection && filteredUser.isNotEmpty);

    if (!hasAnyContent) {
      return Center(
        child: Text('No apps found', style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        if (showCurrentApp && currentAppMatches) ...[
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4, left: 4),
            child: Text(
              'Current Foreground App',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
           AppItemTile(
            title: '${_foregroundApp!.packageName} (${_foregroundApp!.activityName.split('.').last})',
            borderRadius: BorderRadius.circular(12),
            onTap: () => widget.onAppSelected(_foregroundApp!.packageName),
            packageName: _foregroundApp!.packageName,
            onMenuItemSelected: (action) => _handleAppAction(action, _foregroundApp!.packageName),
          ),
          const SizedBox(height: 8),
        ],
        if (showSystemSection && filteredSystem.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4, left: 4),
            child: Text(
              'System Apps (${filteredSystem.length})',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ...filteredSystem.asMap().entries.map((e) => AppItemTile(
            title: e.value,
            borderRadius: _borderRadius(e.key, filteredSystem.length),
            onTap: () => widget.onAppSelected(e.value),
            packageName: e.value,
            onMenuItemSelected: (action) => _handleAppAction(action, e.value),
          )),
          const SizedBox(height: 8),
        ],
        if (showUserSection && filteredUser.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4, left: 4),
            child: Text(
              'User Apps (${filteredUser.length})',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ...filteredUser.asMap().entries.map((e) => AppItemTile(
            title: e.value,
            borderRadius: _borderRadius(e.key, filteredUser.length),
            onTap: () => widget.onAppSelected(e.value),
            packageName: e.value,
            onMenuItemSelected: (action) => _handleAppAction(action, e.value),
          )),
        ],
      ],
    );
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
}
