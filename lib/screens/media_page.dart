import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/adb_content_service.dart';
import '../services/device_manager.dart';
import '../widgets/data_screen_widgets.dart';
import '../widgets/two_panel_layout.dart';

enum _MediaType { images, videos, audio }

class _MediaItem {
  final String name;
  final String path;
  final String size;
  final String date;
  final _MediaType kind;
  final Map<String, String> raw;

  _MediaItem({required this.raw, required this.kind})
      : name = raw['_display_name'] ?? raw['title'] ?? raw['_id'] ?? '—',
        path = raw['_data'] ?? raw['data1'] ?? '',
        size = raw['_size'] ?? '',
        date = raw['date_added'] ?? '';

  String get displaySize {
    final b = int.tryParse(size) ?? 0;
    if (b == 0) return '—';
    if (b < 1024) return '${b}B';
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(1)}KB';
    return '${(b / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  IconData get icon => switch (kind) {
        _MediaType.images => Icons.image_outlined,
        _MediaType.videos => Icons.videocam_outlined,
        _MediaType.audio => Icons.audiotrack_outlined,
      };
}

class MediaPage extends StatefulWidget {
  const MediaPage({super.key});

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  _MediaType _kind = _MediaType.images;
  List<_MediaItem> _items = [];
  _MediaItem? _selected;
  bool _loading = false;
  String? _deviceId;

  Future<void> _fetch(String deviceId) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _items = [];
      _selected = null;
    });
    final contentPath = switch (_kind) {
      _MediaType.images => 'content://media/external/images/media',
      _MediaType.videos => 'content://media/external/video/media',
      _MediaType.audio => 'content://media/external/audio/media',
    };
    final rows = await AdbContentService.query(deviceId: deviceId, uri: contentPath);
    if (mounted) {
      setState(() {
        _items = rows.map((r) => _MediaItem(raw: r, kind: _kind)).toList();
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

    final tabs = [
      (_MediaType.images, Icons.image, 'Images'),
      (_MediaType.videos, Icons.videocam, 'Videos'),
      (_MediaType.audio, Icons.audiotrack, 'Audio'),
    ];

    return TwoPanelLayout<_MediaItem>(
      items: _items,
      loading: _loading,
      searchHint: 'Search media',
      emptyMessage: 'No media found',
      selectedItem: _selected,
      onItemSelected: (item) => setState(() => _selected = item),
      filter: (item, query) =>
          item.name.toLowerCase().contains(query) ||
          item.path.toLowerCase().contains(query),
      listHeader: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            ...tabs.map((t) => Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: ChoiceChip(
                    label: Text(t.$3, style: const TextStyle(fontSize: 12)),
                    avatar: Icon(t.$2, size: 14),
                    selected: _kind == t.$1,
                    onSelected: (_) {
                      setState(() => _kind = t.$1);
                      _fetch(device.id);
                    },
                  ),
                )),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              onPressed: () => _fetch(device.id),
            ),
          ],
        ),
      ),
      itemBuilder: (ctx, item, sel) => DataListTile(
        title: item.name,
        subtitle: '${item.displaySize} · ${item.path.split('/').last}',
        icon: item.icon,
        isSelected: sel,
        onTap: () => setState(() => _selected = item),
      ),
      detailBuilder: (ctx, item) => item == null
          ? const NoSelectionPanel(message: 'Select a file to view details', icon: Icons.folder_open_outlined)
          : DetailCard(
              title: item.name,
              icon: item.icon,
              fields: {
                'Name': item.name,
                'Path': item.path,
                'Size': item.displaySize,
                ...item.raw,
              },
            ),
    );
  }
}
