import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:porpita/services/device_manager.dart';
import 'package:porpita/v2/widgets/search_view.dart';
import 'notification_model.dart';
import 'notifications_service.dart';
import 'notifications_list_content.dart';

class NotificationsListScreen extends StatefulWidget {
  final void Function(NotificationEntry entry) onEntrySelected;
  const NotificationsListScreen({
    super.key,
    required this.onEntrySelected,
  });

  @override
  State<NotificationsListScreen> createState() => _NotificationsListScreenState();
}

class _NotificationsListScreenState extends State<NotificationsListScreen> {
  List<NotificationEntry> _entries = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;
  String _searchQuery = '';
  String? _lastDeviceId;
  final _searchController = TextEditingController();
  Timer? _refreshTimer;
  static const _refreshInterval = Duration(seconds: 60);

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
      final entries = await NotificationsService.fetchNotifications(deviceId);
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
      final entries = await NotificationsService.fetchNotifications(deviceId);
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
      final entries = await NotificationsService.fetchNotifications(deviceId);
      if (!mounted) return;
      if (!_listsEqual(_entries, entries)) {
        setState(() => _entries = entries);
      }
    } catch (_) {
    }
  }

  bool _listsEqual(List<NotificationEntry> a, List<NotificationEntry> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].key != b[i].key) return false;
    }
    return true;
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
                  hintText: 'Search notifications…',
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
    return NotificationsListContent(
      entries: _entries,
      searchQuery: _searchQuery,
      onEntrySelected: widget.onEntrySelected,
    );
  }
}