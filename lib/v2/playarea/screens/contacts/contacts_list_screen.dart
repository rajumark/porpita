import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:porpita/services/device_manager.dart';
import 'package:porpita/v2/widgets/search_view.dart';
import 'package:porpita/v2/widgets/overflow_menu.dart';
import 'contact_model.dart';
import 'contacts_service.dart';
import 'contacts_uri.dart';
import 'contacts_list_content.dart';
import '../calllogs/system_settings_service.dart';

class ContactsListScreen extends StatefulWidget {
  final void Function(ContactEntry entry) onContactSelected;
  final void Function(ContactDataEntry entry) onDataRowSelected;
  const ContactsListScreen({
    super.key,
    required this.onContactSelected,
    required this.onDataRowSelected,
  });

  @override
  State<ContactsListScreen> createState() => _ContactsListScreenState();
}

class _ContactsListScreenState extends State<ContactsListScreen> {
  ContactsUri _uri = kContactsUris.first;

  List<ContactEntry> _contacts = [];
  List<ContactDataEntry> _dataRows = [];
  List<Map<String, String>> _rawRows = [];

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

  void _handleUriChange() {
    final device = context.read<DeviceManager>().selected;
    if (device != null) {
      _lastDeviceId = null;
      _handleDeviceSwitch(device.id);
    } else {
      setState(() {
        _contacts = [];
        _dataRows = [];
        _rawRows = [];
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
    } catch (_) {}
  }

  void _onFetchSettled() {
    if (!mounted) return;
    _startTimer(_lastDeviceId!);
  }

  Future<void> _fetchAll(String deviceId, VoidCallback onSettled) async {
    if (_uri.isStandard && _uri.uri == kContactsUris.first.uri) {
      final contacts = await ContactsService.fetchContacts(deviceId);
      if (!mounted) return;
      if (!_contactsEqual(_contacts, contacts)) {
        setState(() {
          _contacts = contacts;
          _dataRows = [];
          _rawRows = [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } else if (_uri.uri.endsWith('/data')) {
      final rows = await ContactsService.fetchRawRows(
        deviceId,
        uri: _uri.uri,
        columns: _uri.columns,
      );
      if (!mounted) return;
      final data = rows.map(ContactDataEntry.fromMap).toList();
      if (!_dataEqual(_dataRows, data)) {
        setState(() {
          _dataRows = data;
          _contacts = [];
          _rawRows = [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } else {
      final rows = await ContactsService.fetchRawRows(
        deviceId,
        uri: _uri.uri,
        columns: _uri.columns,
      );
      if (!mounted) return;
      if (!_rawEqual(_rawRows, rows)) {
        setState(() {
          _rawRows = rows;
          _contacts = [];
          _dataRows = [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    }
    onSettled();
  }

  bool _contactsEqual(List<ContactEntry> a, List<ContactEntry> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id ||
          a[i].displayName != b[i].displayName ||
          a[i].hasPhoneNumber != b[i].hasPhoneNumber) {
        return false;
      }
    }
    return true;
  }

  bool _dataEqual(List<ContactDataEntry> a, List<ContactDataEntry> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].primaryValue != b[i].primaryValue) {
        return false;
      }
    }
    return true;
  }

  bool _rawEqual(List<Map<String, String>> a, List<Map<String, String>> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].length != b[i].length) return false;
      for (final k in a[i].keys) {
        if (a[i][k] != b[i][k]) return false;
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
        case 'open_contacts':
          await SystemSettingsService.openContactsApp(device.id);
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Opening Contacts…'),
              duration: Duration(seconds: 1),
            ),
          );
        case 'open_dialer':
          await SystemSettingsService.openDialerApp(device.id);
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Opening Dialer…'),
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

  int get _count {
    if (_uri.isStandard && _uri.uri == kContactsUris.first.uri) {
      return _contacts.length;
    } else if (_uri.uri.endsWith('/data')) {
      return _dataRows.length;
    }
    return _rawRows.length;
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
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          child: Row(
            children: [
              Expanded(
                child: SearchView(
                  controller: _searchController,
                  hintText: 'Search ${_uri.label}…',
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
                    value: 'open_contacts',
                    label: 'Open contacts app',
                    icon: Icons.contacts,
                  ),
                  OverflowMenuItem(
                    value: 'open_dialer',
                    label: 'Open call app',
                    icon: Icons.phone,
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
              Expanded(
                child: _UriDropdown(
                  uris: kContactsUris,
                  currentUri: _uri,
                  onChanged: (uri) {
                    setState(() => _uri = uri);
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
                '${_uri.uri}  ·  $_count',
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
    if (_uri.isStandard && _uri.uri == kContactsUris.first.uri) {
      return ContactsListContent(
        entries: _contacts,
        searchQuery: _searchQuery,
        onEntrySelected: widget.onContactSelected,
      );
    } else if (_uri.uri.endsWith('/data')) {
      return ContactDataListContent(
        entries: _dataRows,
        searchQuery: _searchQuery,
        onEntrySelected: widget.onDataRowSelected,
      );
    } else {
      return Center(
        child: Text(
          '${_rawRows.length} rows — use a contacts tool to inspect raw content',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
  }
}

class _UriDropdown extends StatelessWidget {
  final List<ContactsUri> uris;
  final ContactsUri currentUri;
  final ValueChanged<ContactsUri> onChanged;

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
              child: DropdownButton<ContactsUri>(
                value: currentUri,
                isExpanded: true,
                isDense: true,
                icon: const Icon(Icons.arrow_drop_down, size: 20),
                style: Theme.of(context).textTheme.bodySmall,
                items: [
                  for (final u in uris)
                    DropdownMenuItem(
                      value: u,
                      child: Text(u.label, overflow: TextOverflow.ellipsis),
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
