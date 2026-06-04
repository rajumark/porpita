import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:porpita/services/device_manager.dart';
import 'package:porpita/v2/widgets/search_view.dart';
import 'package:porpita/v2/widgets/overflow_menu.dart';
import 'sms_model.dart';
import 'mms_model.dart';
import 'raw_message_entry.dart';
import 'message_uri.dart';
import 'messages_service.dart';
import 'messages_list_content.dart';
import '../calllogs/system_settings_service.dart';

enum MessageTab { sms, mms }

class MessagesListScreen extends StatefulWidget {
  final void Function(SmsEntry entry) onSmsSelected;
  final void Function(MmsEntry entry) onMmsSelected;
  final void Function(RawMessageEntry entry) onRawSelected;
  final void Function(SmsEntry entry)? onSmsViewContact;
  final void Function(MmsEntry entry)? onMmsViewContact;
  const MessagesListScreen({
    super.key,
    required this.onSmsSelected,
    required this.onMmsSelected,
    required this.onRawSelected,
    this.onSmsViewContact,
    this.onMmsViewContact,
  });

  @override
  State<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends State<MessagesListScreen> {
  MessageTab _tab = MessageTab.sms;
  MessageUri _smsUri = kSmsUris.first;
  MessageUri _mmsUri = kMmsUris.first;

  List<SmsEntry> _smsEntries = [];
  List<MmsEntry> _mmsEntries = [];
  List<RawMessageEntry> _rawEntries = [];

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

  void _handleUriChange() {
    final device = context.read<DeviceManager>().selected;
    if (device != null) {
      _lastDeviceId = null;
      _handleDeviceSwitch(device.id);
    } else {
      setState(() {
        _smsEntries = [];
        _mmsEntries = [];
        _rawEntries = [];
      });
    }
  }

  Future<void> _initialFetch(String deviceId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _fetchAll(deviceId, _onFetchSettled);
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
      await _fetchAll(deviceId, _onFetchSettled);
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  Future<void> _silentRefresh(String deviceId) async {
    try {
      await _fetchAll(deviceId, _onFetchSettled);
    } catch (_) {
    }
  }

  void _onFetchSettled() {
    if (!mounted) return;
    _startTimer(_lastDeviceId!);
  }

  Future<void> _fetchAll(String deviceId, VoidCallback onSettled) async {
    final currentUri = _currentUri();
    if (currentUri.isStandard) {
      if (_tab == MessageTab.sms) {
        final sms = await MessagesService.fetchSmsByUri(deviceId, currentUri);
        if (!mounted) return;
        if (!_smsEquals(_smsEntries, sms)) {
          setState(() {
            _smsEntries = sms;
            _mmsEntries = [];
            _rawEntries = [];
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      } else {
        final mms = await MessagesService.fetchMmsByUri(deviceId, currentUri);
        if (!mounted) return;
        if (!_mmsEquals(_mmsEntries, mms)) {
          setState(() {
            _mmsEntries = mms;
            _smsEntries = [];
            _rawEntries = [];
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      }
    } else {
      final raw = await MessagesService.fetchRawByUri(deviceId, currentUri);
      if (!mounted) return;
      if (!_rawEquals(_rawEntries, raw)) {
        setState(() {
          _rawEntries = raw;
          _smsEntries = [];
          _mmsEntries = [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    }
    onSettled();
  }

  MessageUri _currentUri() {
    return _tab == MessageTab.sms ? _smsUri : _mmsUri;
  }

  bool _smsEquals(List<SmsEntry> a, List<SmsEntry> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id ||
          a[i].body != b[i].body ||
          a[i].read != b[i].read ||
          a[i].date != b[i].date) {
        return false;
      }
    }
    return true;
  }

  bool _mmsEquals(List<MmsEntry> a, List<MmsEntry> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id ||
          a[i].read != b[i].read ||
          a[i].sub != b[i].sub ||
          a[i].date != b[i].date) {
        return false;
      }
    }
    return true;
  }

  bool _rawEquals(List<RawMessageEntry> a, List<RawMessageEntry> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].raw.length != b[i].raw.length) return false;
      for (final key in a[i].raw.keys) {
        if (a[i].raw[key] != b[i].raw[key]) return false;
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
        case 'open_messaging':
          await SystemSettingsService.openMessagingApp(device.id);
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Opening Messages…'),
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

  @override
  Widget build(BuildContext context) {
    final dm = context.watch<DeviceManager>();
    final device = dm.selected;
    final uris = _tab == MessageTab.sms ? kSmsUris : kMmsUris;
    final currentUri = _currentUri();
    final isStandard = currentUri.isStandard;
    final entryCount = isStandard
        ? (_tab == MessageTab.sms ? _smsEntries.length : _mmsEntries.length)
        : _rawEntries.length;

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
                  hintText: isStandard
                      ? (_tab == MessageTab.sms ? 'Search SMS…' : 'Search MMS…')
                      : 'Search ${currentUri.label}…',
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
                    value: 'open_messaging',
                    label: 'Open message app',
                    icon: Icons.message,
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
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
          child: Row(
            children: [
              SegmentedButton<MessageTab>(
                segments: [
                  ButtonSegment(
                    value: MessageTab.sms,
                    label: const Text('SMS'),
                    icon: const Icon(Icons.sms_outlined, size: 14),
                  ),
                  ButtonSegment(
                    value: MessageTab.mms,
                    label: const Text('MMS'),
                    icon: const Icon(Icons.mms_outlined, size: 14),
                  ),
                ],
                selected: {_tab},
                onSelectionChanged: (s) => setState(() => _tab = s.first),
                showSelectedIcon: false,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _UriDropdown(
                  uris: uris,
                  currentUri: currentUri,
                  onChanged: (uri) {
                    setState(() {
                      if (_tab == MessageTab.sms) {
                        _smsUri = uri;
                      } else {
                        _mmsUri = uri;
                      }
                    });
                    _handleUriChange();
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 8, 4),
          child: Row(
            children: [
              Text(
                '${currentUri.uri}  ·  $entryCount',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
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
    final currentUri = _currentUri();
    if (currentUri.isStandard) {
      if (_tab == MessageTab.sms) {
        return SmsListContent(
          entries: _smsEntries,
          searchQuery: _searchQuery,
          onEntrySelected: widget.onSmsSelected,
          onViewContact: widget.onSmsViewContact,
        );
      }
      return MmsListContent(
        entries: _mmsEntries,
        searchQuery: _searchQuery,
        onEntrySelected: widget.onMmsSelected,
        onViewContact: widget.onMmsViewContact,
      );
    }
    return RawMessageListContent(
      entries: _rawEntries,
      searchQuery: _searchQuery,
      onEntrySelected: widget.onRawSelected,
    );
  }
}

class _UriDropdown extends StatelessWidget {
  final List<MessageUri> uris;
  final MessageUri currentUri;
  final ValueChanged<MessageUri> onChanged;

  const _UriDropdown({
    required this.uris,
    required this.currentUri,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 36,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        children: [
          Icon(Icons.folder_outlined, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<MessageUri>(
                value: currentUri,
                isExpanded: true,
                isDense: true,
                icon: const Icon(Icons.arrow_drop_down, size: 20),
                style: Theme.of(context).textTheme.bodySmall,
                items: [
                  for (final u in uris)
                    DropdownMenuItem(
                      value: u,
                      child: Text(
                        u.label,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
