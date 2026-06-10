import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:porpita/services/device_manager.dart';
import 'package:porpita/v2/widgets/search_view.dart';
import 'lifecycle_model.dart';
import 'lifecycle_service.dart';

class LifecycleEventsScreen extends StatefulWidget {
  const LifecycleEventsScreen({super.key});

  @override
  State<LifecycleEventsScreen> createState() => _LifecycleEventsScreenState();
}

class _LifecycleEventsScreenState extends State<LifecycleEventsScreen> {
  List<UsageEvent> _events = [];
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
      final events = await LifecycleService.fetchEvents(deviceId);
      if (!mounted) return;
      setState(() { _events = events; _isLoading = false; });
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
      final events = await LifecycleService.fetchEvents(deviceId);
      if (!mounted) return;
      setState(() => _events = events);
    } catch (_) {}
    finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  Future<void> _silentRefresh(String deviceId) async {
    try {
      final events = await LifecycleService.fetchEvents(deviceId);
      if (!mounted) return;
      if (events.length != _events.length) {
        setState(() => _events = events);
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

    final filtered = _searchQuery.isEmpty
        ? _events
        : _events.where((e) {
            final q = _searchQuery;
            return e.packageName.toLowerCase().contains(q) ||
                e.type.value.toLowerCase().contains(q) ||
                (e.className?.toLowerCase().contains(q) ?? false) ||
                (e.channelId?.toLowerCase().contains(q) ?? false);
          }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: SearchView(
                  controller: _searchController,
                  hintText: 'Search events…',
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
        Expanded(child: _buildContent(filtered)),
      ],
    );
  }

  Widget _buildContent(List<UsageEvent> events) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Text(_error!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.error,
        )),
      );
    }
    if (events.isEmpty) {
      return Center(child: Text(
        _searchQuery.isEmpty ? 'No events' : 'No matching events',
        style: Theme.of(context).textTheme.bodyMedium,
      ));
    }

    final scheme = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final e = events[index];
        final br = index == 0
            ? const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))
            : index == events.length - 1
                ? const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))
                : BorderRadius.circular(2);
        return Material(
          color: scheme.surfaceContainer,
          borderRadius: br,
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8, top: 6, bottom: 6),
            child: Row(
              children: [
                Icon(e.type.icon, size: 18, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(children: [
                        Expanded(child: Text(e.packageName,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                        )),
                        const SizedBox(width: 8),
                        Text(e.type.value,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ]),
                      if (e.className != null)
                        Text(e.className!,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}