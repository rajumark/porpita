import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/adb_content_service.dart';
import '../services/device_manager.dart';
import '../widgets/data_screen_widgets.dart';
import '../widgets/two_panel_layout.dart';

class _Contact {
  final String contactId;
  final String displayName;
  final List<String> numbers;
  final List<Map<String, String>> rows;

  _Contact({
    required this.contactId,
    required this.displayName,
    required this.numbers,
    required this.rows,
  });

  String get initials {
    final parts = displayName.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }
}

List<_Contact> _groupContacts(List<Map<String, String>> rows) {
  final byId = <String, List<Map<String, String>>>{};
  for (final row in rows) {
    final id = row['contact_id'] ?? row['_id'] ?? '';
    if (id.isEmpty) continue;
    byId.putIfAbsent(id, () => []).add(row);
  }
  final contacts = byId.entries.map((e) {
    final rowList = e.value;
    String name = '';
    final numbers = <String>[];
    for (final r in rowList) {
      final mt = r['mimetype'] ?? '';
      if (mt.contains('name') && r['data1'] != null && r['data1']!.isNotEmpty) name = r['data1']!;
      if (mt.contains('phone') && r['data1'] != null && r['data1']!.isNotEmpty) numbers.add(r['data1']!);
    }
    if (name.isEmpty) name = rowList.first['display_name'] ?? 'Contact ${e.key}';
    return _Contact(contactId: e.key, displayName: name, numbers: numbers, rows: rowList);
  }).toList()
    ..sort((a, b) => a.displayName.compareTo(b.displayName));
  return contacts;
}

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<_Contact> _items = [];
  _Contact? _selected;
  bool _loading = false;
  String? _deviceId;

  Future<void> _fetch(String deviceId) async {
    if (_loading) return;
    setState(() => _loading = true);
    final rows = await AdbContentService.query(deviceId: deviceId, uri: 'content://com.android.contacts/data');
    if (mounted) {
      setState(() {
        _items = _groupContacts(rows);
        _loading = false;
        _deviceId = deviceId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dm = context.watch<DeviceManager>();
    final device = dm.selected;
    if (device == null || !device.isConnected) return const NoDevicePanel();

    if (_deviceId != device.id) WidgetsBinding.instance.addPostFrameCallback((_) => _fetch(device.id));

    return TwoPanelLayout<_Contact>(
      items: _items,
      loading: _loading,
      searchHint: 'Search contacts',
      emptyMessage: 'No contacts found',
      selectedItem: _selected,
      onItemSelected: (item) => setState(() => _selected = item),
      filter: (item, query) =>
          item.displayName.toLowerCase().contains(query) ||
          item.numbers.any((n) => n.toLowerCase().contains(query)),
      listHeader: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(icon: const Icon(Icons.refresh, size: 18), onPressed: () => _fetch(device.id)),
            Text('${_items.length} contacts', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      itemBuilder: (ctx, contact, sel) {
        final cs = Theme.of(ctx).colorScheme;
        return Material(
          color: sel ? cs.primaryContainer : Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _selected = contact),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: sel ? cs.primary : cs.secondaryContainer,
                    child: Text(
                      contact.initials,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: sel ? cs.onPrimary : cs.onSecondaryContainer),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(contact.displayName,
                            style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(fontWeight: sel ? FontWeight.bold : FontWeight.normal),
                            overflow: TextOverflow.ellipsis),
                        if (contact.numbers.isNotEmpty)
                          Text(contact.numbers.first,
                              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                              overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      detailBuilder: (ctx, contact) {
        if (contact == null) return const NoSelectionPanel(message: 'Select a contact to view details', icon: Icons.person_outline);
        final cs = Theme.of(ctx).colorScheme;
        final tt = Theme.of(ctx).textTheme;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: CircleAvatar(
                radius: 36,
                backgroundColor: cs.primaryContainer,
                child: Text(contact.initials, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: cs.primary)),
              ),
            ),
            const SizedBox(height: 12),
            Center(child: Text(contact.displayName, style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
            if (contact.numbers.isNotEmpty) ...[
              const SizedBox(height: 4),
              Center(child: Text(contact.numbers.join(' · '), style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant))),
            ],
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              color: cs.surfaceContainerLow,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Phone Numbers', style: tt.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...contact.numbers.map((n) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: SelectableText(n, style: tt.bodyMedium),
                        )),
                    if (contact.numbers.isEmpty) Text('None', style: tt.bodySmall?.copyWith(color: cs.outlineVariant)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Raw data entries
            ...contact.rows.map((row) {
              final mt = row['mimetype'] ?? '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  elevation: 0,
                  color: cs.surfaceContainerLow,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mt, style: tt.labelSmall?.copyWith(color: cs.primary)),
                        const SizedBox(height: 4),
                        ...row.entries.where((e) => e.key != 'mimetype').map((e) => Row(
                              children: [
                                SizedBox(width: 120, child: Text(e.key, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant))),
                                Expanded(child: SelectableText(e.value, style: tt.bodySmall)),
                              ],
                            )),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
