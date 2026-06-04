import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:porpita/services/device_manager.dart';
import 'package:porpita/v2/widgets/search_view.dart';
import 'package:porpita/v2/widgets/overflow_menu.dart';
import 'call_log_model.dart';
import 'calllogs_service.dart';
import 'calllogs_list_content.dart';
import 'system_settings_service.dart';

class CallLogsListScreen extends StatefulWidget {
  final void Function(CallLogEntry entry) onEntrySelected;
  final void Function(CallLogEntry entry)? onViewContact;
  const CallLogsListScreen({
    super.key,
    required this.onEntrySelected,
    this.onViewContact,
  });

  @override
  State<CallLogsListScreen> createState() => _CallLogsListScreenState();
}

class _CallLogsListScreenState extends State<CallLogsListScreen> {
  List<CallLogEntry> _entries = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;
  String _searchQuery = '';
  String? _lastDeviceId;
  final _searchController = TextEditingController();
  Timer? _refreshTimer;
  static const _refreshInterval = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _cancelTimer();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
  }

  void _cancelTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  void _startTimer(String deviceId) {
    _cancelTimer();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) => _silentRefresh(deviceId));
  }

  void _handleDeviceSwitch(String deviceId) {
    _lastDeviceId = deviceId;
    _cancelTimer();
    _initialFetch(deviceId);
  }

  Future<void> _initialFetch(String deviceId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final entries = await CallLogsService.fetchCallLogs(deviceId);
      if (!mounted) return;
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
      _startTimer(deviceId);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _manualRefresh(String deviceId) async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      final entries = await CallLogsService.fetchCallLogs(deviceId);
      if (!mounted) return;
      if (!_listsEqual(_entries, entries)) {
        setState(() => _entries = entries);
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  Future<void> _silentRefresh(String deviceId) async {
    try {
      final entries = await CallLogsService.fetchCallLogs(deviceId);
      if (!mounted) return;
      if (!_listsEqual(_entries, entries)) {
        setState(() => _entries = entries);
      }
    } catch (_) {
    }
  }

  bool _listsEqual(List<CallLogEntry> a, List<CallLogEntry> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id ||
          a[i].type != b[i].type ||
          a[i].duration != b[i].duration ||
          a[i].date != b[i].date) {
        return false;
      }
    }
    return true;
  }

  Future<void> _onMenuSelected(String value) async {
    final device = context.read<DeviceManager>().selected;
    final messenger = ScaffoldMessenger.of(context);
    if (device == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No device connected')),
      );
      return;
    }
    try {
      switch (value) {
        case 'open_dialer':
          await SystemSettingsService.openDialerApp(device.id);
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Opening Dialer…'),
              duration: Duration(seconds: 1),
            ),
          );
        case 'open_contacts':
          await SystemSettingsService.openContactsApp(device.id);
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Opening Contacts…'),
              duration: Duration(seconds: 1),
            ),
          );
        case 'default_apps':
          await SystemSettingsService.openDefaultAppsSettings(device.id);
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Opening Default Apps settings…'),
              duration: Duration(seconds: 1),
            ),
          );
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  Future<void> _onCall(CallLogEntry entry) async {
    final device = context.read<DeviceManager>().selected;
    if (device == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No device connected')),
      );
      return;
    }
    final number = entry.displayNumber;
    if (number.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No number available')),
      );
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    try {
      await CallLogsService.callNumber(device.id, number);
      messenger.showSnackBar(
        SnackBar(content: Text('Calling $number…'), duration: const Duration(seconds: 1)),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to call: $e')),
      );
    }
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
                  hintText: 'Search call logs…',
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: _isRefreshing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                iconSize: 20,
                tooltip: 'Refresh',
                onPressed: device == null || _isRefreshing
                    ? null
                    : () => _manualRefresh(device.id),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints.tight(const Size(36, 36)),
              ),
              OverflowMenu(
                items: const [
                  OverflowMenuItem(
                    value: 'open_dialer',
                    label: 'Open call app',
                    icon: Icons.phone,
                  ),
                  OverflowMenuItem(
                    value: 'open_contacts',
                    label: 'Open contacts app',
                    icon: Icons.contacts,
                  ),
                  OverflowMenuItem(
                    value: 'default_apps',
                    label: 'Default apps',
                    icon: Icons.apps,
                  ),
                ],
                onSelected: _onMenuSelected,
                tooltip: 'More',
              ),
            ],
          ),
        ),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
    }
    return CallLogsListContent(
      entries: _entries,
      searchQuery: _searchQuery,
      onEntrySelected: widget.onEntrySelected,
      onCall: _onCall,
      onViewContact: widget.onViewContact,
    );
  }
}
