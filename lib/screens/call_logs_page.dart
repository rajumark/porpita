import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/adb_content_service.dart';
import '../services/device_manager.dart';
import '../widgets/data_screen_widgets.dart';
import '../widgets/two_panel_layout.dart';

// ── model ────────────────────────────────────────────────────────────────────

class _CallLog {
  final String number;
  final String type;
  final String date;
  final String duration;
  final Map<String, String> raw;

  _CallLog({required this.raw})
      : number = raw['number'] ?? raw['name'] ?? '—',
        type = _typeLabel(raw['type']),
        date = raw['date'] ?? '',
        duration = raw['duration'] ?? '';

  static String _typeLabel(String? t) => switch (t) {
        '1' => 'Incoming',
        '2' => 'Outgoing',
        '3' => 'Missed',
        '4' => 'Voicemail',
        '5' => 'Rejected',
        _ => t ?? 'Unknown',
      };

  IconData get icon => switch (type) {
        'Incoming' => Icons.call_received,
        'Outgoing' => Icons.call_made,
        'Missed' => Icons.call_missed,
        'Voicemail' => Icons.voicemail,
        'Rejected' => Icons.call_end,
        _ => Icons.phone,
      };

  Color iconColor(ColorScheme cs) => switch (type) {
        'Missed' => cs.error,
        'Incoming' => cs.primary,
        'Outgoing' => cs.secondary,
        _ => cs.onSurfaceVariant,
      };

  String get displayDate {
    final ms = int.tryParse(date);
    if (ms == null) return date;
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${d.year}-${_p(d.month)}-${_p(d.day)} ${_p(d.hour)}:${_p(d.minute)}';
  }

  String get displayDuration {
    final s = int.tryParse(duration) ?? 0;
    final m = s ~/ 60;
    final sec = s % 60;
    return m > 0 ? '${m}m ${sec}s' : '${sec}s';
  }

  static String _p(int v) => v.toString().padLeft(2, '0');
}

// ── page ─────────────────────────────────────────────────────────────────────

class CallLogsPage extends StatefulWidget {
  const CallLogsPage({super.key});

  @override
  State<CallLogsPage> createState() => _CallLogsPageState();
}

class _CallLogsPageState extends State<CallLogsPage> {
  List<_CallLog> _items = [];
  _CallLog? _selected;
  bool _loading = false;
  String? _deviceId;

  Future<void> _fetch(String deviceId) async {
    if (_loading) return;
    setState(() => _loading = true);
    final rows = await AdbContentService.query(deviceId: deviceId, uri: 'content://call_log/calls');
    if (mounted) {
      setState(() {
        _items = rows.map((r) => _CallLog(raw: r)).toList();
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

    return TwoPanelLayout<_CallLog>(
      items: _items,
      loading: _loading,
      searchHint: 'Search calls',
      emptyMessage: 'No call logs found',
      selectedItem: _selected,
      onItemSelected: (item) => setState(() => _selected = item),
      filter: (item, query) =>
          item.number.toLowerCase().contains(query) ||
          item.type.toLowerCase().contains(query) ||
          item.displayDate.toLowerCase().contains(query),
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
            Text('${_items.length} calls', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      itemBuilder: (ctx, item, sel) => DataListTile(
        title: item.number,
        subtitle: '${item.type} · ${item.displayDate}',
        icon: item.icon,
        iconColor: item.iconColor(Theme.of(ctx).colorScheme),
        isSelected: sel,
        onTap: () => setState(() => _selected = item),
      ),
      detailBuilder: (ctx, item) => item == null
          ? const NoSelectionPanel(message: 'Select a call to view details', icon: Icons.phone_outlined)
          : DetailCard(
              title: item.number,
              icon: item.icon,
              fields: {
                'Type': item.type,
                'Date': item.displayDate,
                'Duration': item.displayDuration,
                ...item.raw,
              },
            ),
    );
  }
}
