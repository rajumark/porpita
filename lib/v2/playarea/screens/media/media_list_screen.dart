import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:porpita/services/device_manager.dart';
import 'package:porpita/v2/widgets/search_view.dart';
import 'package:porpita/v2/widgets/overflow_menu.dart';
import 'media_model.dart';
import 'media_uri.dart';
import 'media_service.dart';
import 'media_list_content.dart';
import '../calllogs/system_settings_service.dart';

class MediaListScreen extends StatefulWidget {
  final void Function(MediaEntry entry) onEntrySelected;
  const MediaListScreen({super.key, required this.onEntrySelected});

  @override
  State<MediaListScreen> createState() => _MediaListScreenState();
}

class _MediaListScreenState extends State<MediaListScreen> {
  MediaVolume _volume = MediaVolume.external;
  MediaUri _externalUri = kExternalMediaUris.first;
  MediaUri _internalUri = kInternalMediaUris.first;
  MediaViewMode _viewMode = MediaViewMode.list;
  List<MediaEntry> _entries = [];
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
    _refreshTimer = Timer.periodic(
      _refreshInterval,
      (_) => _silentRefresh(deviceId),
    );
  }

  void _handleDeviceSwitch(String deviceId) {
    _lastDeviceId = deviceId;
    _cancelTimer();
    _initialFetch(deviceId);
  }

  void _handleVolumeOrUriChange() {
    final device = context.read<DeviceManager>().selected;
    if (device != null) {
      _lastDeviceId = null;
      _handleDeviceSwitch(device.id);
    } else {
      setState(() => _entries = []);
    }
  }

  MediaUri get _currentUri =>
      _volume == MediaVolume.external ? _externalUri : _internalUri;

  Future<void> _initialFetch(String deviceId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final entries = await MediaService.fetch(deviceId, _currentUri);
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
      final entries = await MediaService.fetch(deviceId, _currentUri);
      if (!mounted) return;
      if (!_entriesEqual(_entries, entries)) {
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
      final entries = await MediaService.fetch(deviceId, _currentUri);
      if (!mounted) return;
      if (!_entriesEqual(_entries, entries)) {
        setState(() => _entries = entries);
      }
    } catch (_) {}
  }

  bool _entriesEqual(List<MediaEntry> a, List<MediaEntry> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id ||
          a[i].size != b[i].size ||
          a[i].dateAdded != b[i].dateAdded ||
          a[i].dateModified != b[i].dateModified) {
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
        case 'open_files':
          await SystemSettingsService.openFilesApp(device.id);
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Opening Files app…'),
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

  @override
  Widget build(BuildContext context) {
    final dm = context.watch<DeviceManager>();
    final device = dm.selected;
    final uris = mediaUrisFor(_volume);

    if (device != null && device.id != _lastDeviceId) {
      _handleDeviceSwitch(device.id);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          child: Row(
            children: [
              Expanded(
                child: SearchView(
                  controller: _searchController,
                  hintText: 'Search files…',
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: _viewMode == MediaViewMode.list
                    ? const Icon(Icons.grid_view_outlined)
                    : const Icon(Icons.view_list_outlined),
                iconSize: 20,
                tooltip: _viewMode == MediaViewMode.list
                    ? 'Switch to grid'
                    : 'Switch to list',
                onPressed: () => setState(() {
                  _viewMode = _viewMode == MediaViewMode.list
                      ? MediaViewMode.grid
                      : MediaViewMode.list;
                }),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints.tight(const Size(36, 36)),
              ),
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
                    value: 'open_files',
                    label: 'Open files app',
                    icon: Icons.folder_open,
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
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
          child: Row(
            children: [
              SegmentedButton<MediaVolume>(
                segments: const [
                  ButtonSegment(
                    value: MediaVolume.external,
                    label: Text('External'),
                    icon: Icon(Icons.sd_storage_outlined, size: 14),
                  ),
                  ButtonSegment(
                    value: MediaVolume.internal,
                    label: Text('Internal'),
                    icon: Icon(Icons.smartphone, size: 14),
                  ),
                ],
                selected: {_volume},
                onSelectionChanged: (s) {
                  setState(() => _volume = s.first);
                  _handleVolumeOrUriChange();
                },
                showSelectedIcon: false,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SegmentedButton<MediaUri>(
                  segments: [
                    for (final u in uris)
                      ButtonSegment(value: u, label: Text(u.label)),
                  ],
                  selected: {_currentUri},
                  onSelectionChanged: (s) {
                    setState(() {
                      if (_volume == MediaVolume.external) {
                        _externalUri = s.first;
                      } else {
                        _internalUri = s.first;
                      }
                    });
                    _handleVolumeOrUriChange();
                  },
                  showSelectedIcon: false,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 8, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${_currentUri.uri}  ·  ${_entries.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
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
    return MediaListContent(
      entries: _entries,
      searchQuery: _searchQuery,
      viewMode: _viewMode,
      onEntrySelected: widget.onEntrySelected,
    );
  }
}


