import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/adb_content_service.dart';
import '../services/device_manager.dart';
import '../widgets/data_screen_widgets.dart';
import '../widgets/two_panel_layout.dart';

class _CalEvent {
  final String id;
  final String title;
  final String dtStart;
  final String dtEnd;
  final String calendar;
  final Map<String, String> raw;

  _CalEvent({required this.raw})
      : id = raw['_id'] ?? '',
        title = raw['title'] ?? raw['name'] ?? '(Untitled)',
        dtStart = _fmtTs(raw['dtstart']),
        dtEnd = _fmtTs(raw['dtend']),
        calendar = raw['calendar_displayName'] ?? raw['calendar_id'] ?? '';

  static String _fmtTs(String? ms) {
    if (ms == null || ms.isEmpty) return '';
    final n = int.tryParse(ms);
    if (n == null) return ms;
    final d = DateTime.fromMillisecondsSinceEpoch(n);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  List<_CalEvent> _items = [];
  _CalEvent? _selected;
  bool _loading = false;
  String? _deviceId;

  Future<void> _fetch(String deviceId) async {
    if (_loading) return;
    setState(() => _loading = true);
    final rows = await AdbContentService.query(deviceId: deviceId, uri: 'content://com.android.calendar/events');
    if (mounted) {
      setState(() {
        _items = rows.map((r) => _CalEvent(raw: r)).toList();
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

    return TwoPanelLayout<_CalEvent>(
      items: _items,
      loading: _loading,
      searchHint: 'Search events',
      emptyMessage: 'No calendar events found',
      selectedItem: _selected,
      onItemSelected: (item) => setState(() => _selected = item),
      filter: (item, query) =>
          item.title.toLowerCase().contains(query) ||
          item.calendar.toLowerCase().contains(query),
      listHeader: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(icon: const Icon(Icons.refresh, size: 18), onPressed: () => _fetch(device.id)),
            Text('${_items.length} events', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      itemBuilder: (ctx, ev, sel) => DataListTile(
        title: ev.title,
        subtitle: ev.dtStart.isEmpty ? ev.calendar : ev.dtStart,
        icon: Icons.event_outlined,
        isSelected: sel,
        onTap: () => setState(() => _selected = ev),
      ),
      detailBuilder: (ctx, ev) => ev == null
          ? const NoSelectionPanel(message: 'Select an event to view details', icon: Icons.calendar_today_outlined)
          : DetailCard(
              title: ev.title,
              icon: Icons.event,
              fields: {
                'Start': ev.dtStart,
                'End': ev.dtEnd,
                'Calendar': ev.calendar,
                ...ev.raw,
              },
            ),
    );
  }
}
