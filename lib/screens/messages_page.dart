import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/adb_content_service.dart';
import '../services/device_manager.dart';
import '../widgets/data_screen_widgets.dart';
import '../widgets/two_panel_layout.dart';

// ── model ────────────────────────────────────────────────────────────────────

class _Sms {
  final String address;
  final String body;
  final String type;
  final String date;
  final Map<String, String> raw;

  _Sms({required this.raw})
      : address = raw['address'] ?? '—',
        body = raw['body'] ?? '',
        date = raw['date'] ?? '',
        type = _typeLabel(raw['type']);

  static String _typeLabel(String? t) => switch (t) {
        '1' => 'Received',
        '2' => 'Sent',
        '3' => 'Draft',
        '4' => 'Failed',
        _ => t ?? 'Unknown',
      };

  IconData get icon =>
      type == 'Sent' ? Icons.outbox : type == 'Draft' ? Icons.drafts : Icons.inbox;

  String get displayDate {
    final ms = int.tryParse(date);
    if (ms == null) return date;
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  String get preview => body.length > 60 ? '${body.substring(0, 60)}…' : body;
}

// ── page ─────────────────────────────────────────────────────────────────────

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  List<_Sms> _items = [];
  _Sms? _selected;
  bool _loading = false;
  String? _deviceId;

  Future<void> _fetch(String deviceId) async {
    if (_loading) return;
    setState(() => _loading = true);
    final rows = await AdbContentService.query(deviceId: deviceId, uri: 'content://sms');
    if (mounted) {
      setState(() {
        _items = rows.map((r) => _Sms(raw: r)).toList();
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

    return TwoPanelLayout<_Sms>(
      items: _items,
      loading: _loading,
      searchHint: 'Search messages',
      emptyMessage: 'No messages found',
      selectedItem: _selected,
      onItemSelected: (item) => setState(() => _selected = item),
      filter: (item, query) =>
          item.address.toLowerCase().contains(query) ||
          item.body.toLowerCase().contains(query),
      listHeader: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              tooltip: 'Refresh',
              onPressed: () => _fetch(device.id),
            ),
            Text('${_items.length} messages', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      itemBuilder: (ctx, item, sel) => DataListTile(
        title: item.address,
        subtitle: item.preview,
        icon: item.icon,
        isSelected: sel,
        onTap: () => setState(() => _selected = item),
      ),
      detailBuilder: (ctx, item) => item == null
          ? const NoSelectionPanel(message: 'Select a message to read it', icon: Icons.sms_outlined)
          : _MessageDetail(sms: item),
    );
  }
}

class _MessageDetail extends StatelessWidget {
  final _Sms sms;
  const _MessageDetail({required this.sms});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: cs.primaryContainer,
              child: Icon(sms.icon, color: cs.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sms.address, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Text('${sms.type} · ${sms.displayDate}', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Message body bubble
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: sms.type == 'Sent' ? cs.primaryContainer : cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SelectableText(
            sms.body.isEmpty ? '(empty)' : sms.body,
            style: tt.bodyMedium,
          ),
        ),
        const SizedBox(height: 16),
        // Raw fields
        DetailCard(
          title: 'Message Details',
          icon: Icons.info_outline,
          fields: Map.fromEntries(sms.raw.entries.where((e) => e.key != 'body')),
        ),
      ],
    );
  }
}
