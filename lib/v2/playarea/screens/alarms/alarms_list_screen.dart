import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:porpita/services/device_manager.dart';
import 'package:porpita/v2/widgets/search_view.dart';
import 'alarm_model.dart';
import 'alarms_service.dart';
import 'alarms_list_content.dart';

class AlarmsListScreen extends StatefulWidget {
  final void Function(AlarmEntry entry) onEntrySelected;

  const AlarmsListScreen({
    super.key,
    required this.onEntrySelected,
  });

  @override
  State<AlarmsListScreen> createState() => _AlarmsListScreenState();
}

class _AlarmsListScreenState extends State<AlarmsListScreen> {
  List<AlarmEntry> _entries = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;
  String _searchQuery = '';
  String? _lastDeviceId;
  final _searchController = TextEditingController();
  Timer? _refreshTimer;
  static const _refreshInterval = Duration(seconds: 10);

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
    setState(() { _isLoading = true; _error = null; });
    try {
      final result = await AlarmsService.fetchAlarms(deviceId);
      if (!mounted) return;
      setState(() {
        _entries = result.$2;
        _isLoading = false;
      });
      _startTimer(deviceId);
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _manualRefresh(String deviceId) async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      final result = await AlarmsService.fetchAlarms(deviceId);
      if (!mounted) return;
      setState(() {
        _entries = result.$2;
      });
    } catch (_) {}
    finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  Future<void> _silentRefresh(String deviceId) async {
    try {
      final result = await AlarmsService.fetchAlarms(deviceId);
      if (!mounted) return;
      if (result.$2.length != _entries.length) {
        setState(() {
          _entries = result.$2;
        });
      }
    } catch (_) {}
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
                  hintText: 'Search alarms…',
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: _isRefreshing
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh),
                iconSize: 20,
                tooltip: 'Refresh',
                onPressed: device == null || _isRefreshing ? null : () => _manualRefresh(device.id),
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
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Text(_error!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.error,
        )),
      );
    }
    return AlarmsListContent(
      entries: _entries,
      searchQuery: _searchQuery,
      onEntrySelected: widget.onEntrySelected,
    );
  }
}