import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:porpita/services/device_manager.dart';
import 'package:porpita/v2/widgets/rounded_container.dart';
import 'package:porpita/v2/widgets/app_icon.dart';
import 'package:porpita/v2/playarea/screens/apps/icons/app_icon_service.dart';
import 'package:porpita/v2/quickpanel/quick_panel_service.dart';
import 'notifications_service.dart';

class NotificationsBaseScreen extends StatefulWidget {
  const NotificationsBaseScreen({super.key});

  @override
  State<NotificationsBaseScreen> createState() =>
      _NotificationsBaseScreenState();
}

class _NotificationsBaseScreenState extends State<NotificationsBaseScreen> {
  List<String> _sections = [];
  bool _loading = false;
  String? _error;
  int? _selectedIndex;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetch(String deviceId) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final sections = await NotificationsService.fetchRawSections(deviceId);
      if (!mounted) return;
      setState(() {
        _sections = sections;
        _loading = false;
      });
      final pkgs = sections
          .map((s) => RegExp(r'pkg=(\S+)').firstMatch(s)?[1])
          .whereType<String>()
          .toSet()
          .toList();
      if (pkgs.isNotEmpty) {
        AppIconService.instance.fetchIcons(deviceId, pkgs);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '${e.runtimeType}: $e';
        _loading = false;
      });
    }
  }

  List<String> get _filteredSections {
    if (_searchQuery.isEmpty) return _sections;
    final q = _searchQuery.toLowerCase();
    return _sections.where((s) => s.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dm = context.watch<DeviceManager>();
    final device = dm.selected;

    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 8, top: 0, bottom: 8),
      child: RoundedContainer(
        child: Stack(
          children: [
            _buildList(device),
            if (_selectedIndex != null)
              _DumpDetailScreen(
                dumpText: _sections[_selectedIndex!],
                index: _selectedIndex!,
                searchQuery: _searchQuery,
                onBack: () => setState(() => _selectedIndex = null),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(dynamic device) {
    if (device == null || !device.isConnected) {
      return const Center(child: Text('No device connected'));
    }

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.error_outline,
                      color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 8),
                  Text('Error',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: 'Copy error',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _error!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Error copied'),
                            duration: Duration(seconds: 2)),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(_error!,
                    style: const TextStyle(
                        fontFamily: 'monospace', fontSize: 12)),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _fetch(device.id),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final filtered = _filteredSections;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                tooltip: 'Refresh',
                onPressed: () => _fetch(device.id),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: Theme.of(context).textTheme.bodySmall,
                  decoration: InputDecoration(
                    hintText: 'Search notifications…',
                    hintStyle: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Theme.of(context).colorScheme.outline),
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    prefixIcon:
                        Icon(Icons.search, size: 18, color: Theme.of(context).colorScheme.outline),
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: 32, minHeight: 0),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear,
                                size: 16,
                                color: Theme.of(context).colorScheme.outline),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            padding: EdgeInsets.zero,
                            constraints:
                                const BoxConstraints(minWidth: 32, minHeight: 0),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v.trim()),
                ),
              ),
              const SizedBox(width: 8),
              _quickAction(Icons.grid_view_outlined, 'Quick Settings',
                  () => QuickPanelService.expandQuickSettings(device.id)),
              _quickAction(Icons.notifications_outlined, 'Notifications',
                  () => QuickPanelService.expandNotifications(device.id)),
              _quickAction(Icons.unfold_less, 'Collapse',
                  () => QuickPanelService.collapseAll(device.id)),
              const SizedBox(width: 4),
              Text('${filtered.length}/${_sections.length}',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: _sections.isEmpty
                      ? FilledButton.tonalIcon(
                          onPressed: () => _fetch(device.id),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Fetch'),
                        )
                      : const Text('No matching notifications'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final section = filtered[index];
                    final globalIndex = _sections.indexOf(section);
                    final data = _parseDump(section);
                    return _DetailsCard(
                      data: data,
                      deviceId: device.id,
                      onTap: () =>
                          setState(() => _selectedIndex = globalIndex),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _DumpDetailScreen extends StatefulWidget {
  final String dumpText;
  final int index;
  final String searchQuery;
  final VoidCallback onBack;

  const _DumpDetailScreen({
    required this.dumpText,
    required this.index,
    required this.searchQuery,
    required this.onBack,
  });

  @override
  State<_DumpDetailScreen> createState() => _DumpDetailScreenState();
}

class _DumpDetailScreenState extends State<_DumpDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RoundedContainer(
      child: Column(
        children: [
          SizedBox(
            height: 36,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  iconSize: 24,
                  onPressed: widget.onBack,
                  padding: EdgeInsets.zero,
                  constraints:
                      BoxConstraints.tight(const Size(36, 36)),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Notification #${widget.index}',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  tooltip: 'Copy dump',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.dumpText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Dump copied'),
                          duration: Duration(seconds: 1)),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints:
                      BoxConstraints.tight(const Size(36, 36)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Container(
              width: double.infinity,
              color: isDark
                  ? const Color(0xFF1E1E2E)
                  : const Color(0xFFF8F9FA),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: _highlightedDump(
                  context,
                  widget.dumpText,
                  widget.searchQuery,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _highlightedDump(BuildContext context, String text, String query) {
    final lines = text.split('\n');
    final spans = <InlineSpan>[];

    for (int i = 0; i < lines.length; i++) {
      if (i > 0) spans.add(const TextSpan(text: '\n'));
      spans.addAll(_highlightLine(context, lines[i], query));
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 12.5,
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFFCDD6F4)
              : Colors.black87,
        ),
      ),
    );
  }

  List<InlineSpan> _highlightLine(
      BuildContext context, String line, String query) {
    final cs = Theme.of(context).colorScheme;
    final eqIndex = line.indexOf('=');

    if (eqIndex == -1) {
      return [_highlightMatch(line, query, cs.onSurface)];
    }

    final keyPart = line.substring(0, eqIndex + 1);
    final valPart = line.substring(eqIndex + 1);

    return [
      TextSpan(
        text: keyPart,
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF89B4FA)
              : Colors.blue.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
      _highlightMatch(valPart, query, cs.onSurface),
    ];
  }

  InlineSpan _highlightMatch(String text, String query, Color defaultColor) {
    if (query.isEmpty) return TextSpan(text: text, style: TextStyle(color: defaultColor));

    final lower = text.toLowerCase();
    final qLower = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final idx = lower.indexOf(qLower, start);
      if (idx == -1) {
        if (start < text.length) {
          spans.add(TextSpan(text: text.substring(start), style: TextStyle(color: defaultColor)));
        }
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx), style: TextStyle(color: defaultColor)));
      }
      spans.add(TextSpan(
        text: text.substring(idx, idx + query.length),
        style: const TextStyle(
          backgroundColor: Color(0xFFFFF176),
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ));
      start = idx + query.length;
    }

    return TextSpan(children: spans);
  }
}

class _ParsedData {
  final String packageName;
  final String channelName;
  final String channelId;
  final String title;
  final String text;
  final String bigText;
  final String template;
  final String color;
  final String flags;
  final String importance;
  final DateTime? whenTime;
  final String key;
  final String visibility;
  final List<String> actions;
  final String uid;

  _ParsedData({
    required this.packageName,
    required this.channelName,
    required this.channelId,
    required this.title,
    required this.text,
    required this.bigText,
    required this.template,
    required this.color,
    required this.flags,
    required this.importance,
    required this.whenTime,
    required this.key,
    required this.visibility,
    required this.actions,
    required this.uid,
  });
}

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${(diff.inDays / 7).floor()}w ago';
}

_ParsedData _parseDump(String dump) {
  String packageName = '';
  String channelName = '';
  String channelId = '';
  String title = '';
  String text = '';
  String bigText = '';
  String template = '';
  String color = '';
  String flags = '';
  String importance = '';
  String key = '';
  String visibility = '';
  List<String> actions = [];
  String uid = '';

  final pkgMatch = RegExp(r'pkg=(\S+)').firstMatch(dump);
  if (pkgMatch != null) packageName = pkgMatch[1]!;

  final keyMatch = RegExp(r'\bkey=(\S+)').firstMatch(dump);
  if (keyMatch != null) key = keyMatch[1]!;

  final impMatch = RegExp(r'importance=(\d+)').firstMatch(dump);
  if (impMatch != null) importance = impMatch[1]!;

  final flagsMatch = RegExp(r'flags=(\S+)').firstMatch(dump);
  if (flagsMatch != null) flags = flagsMatch[1]!;

  final colorMatch = RegExp(r'\bcolor=(0xff[0-9a-fA-F]+)').firstMatch(dump);
  if (colorMatch != null) color = colorMatch[1]!;

  final visMatch = RegExp(r'\bvis=(\S+)').firstMatch(dump);
  if (visMatch != null) visibility = visMatch[1]!;

  final whenMatch = RegExp(r'when=(\S+)').firstMatch(dump);
  DateTime? whenTime;
  if (whenMatch != null) {
    final raw = whenMatch[1]!;
    final msStr = raw.contains('/') ? raw.split('/').first : raw;
    final ms = int.tryParse(msStr);
    if (ms != null && ms > 0) whenTime = DateTime.fromMillisecondsSinceEpoch(ms);
  }

  final uidMatch = RegExp(r'uid=(\d+)').firstMatch(dump);
  if (uidMatch != null) uid = uidMatch[1]!;

  final channelNameMatch = RegExp(r"mName=([^,\s}]+)").firstMatch(dump);
  if (channelNameMatch != null) channelName = channelNameMatch[1]!;

  final channelIdMatch = RegExp(r"mId='([^']+)'").firstMatch(dump);
  if (channelIdMatch != null) channelId = channelIdMatch[1]!;

  final titleMatch =
      RegExp(r'android\.title=String \((.+)\)\s*$').firstMatch(dump);
  if (titleMatch != null) title = titleMatch[1]!;

  final textMatch =
      RegExp(r'android\.text=String \((.+)\)\s*$').firstMatch(dump);
  if (textMatch != null) text = textMatch[1]!;

  final bigTextMatch =
      RegExp(r'android\.bigText=String \((.+)\)\s*$').firstMatch(dump);
  if (bigTextMatch != null) bigText = bigTextMatch[1]!;

  final templateMatch =
      RegExp(r'android\.template=String \((.+)\)\s*$').firstMatch(dump);
  if (templateMatch != null) template = templateMatch[1]!;

  final actionMatches = RegExp(r'\[\d+\]\s*"([^"]+)"').allMatches(dump);
  actions = actionMatches.map((m) => m[1]!).toList();

  return _ParsedData(
    packageName: packageName,
    channelName: channelName,
    channelId: channelId,
    title: title,
    text: text,
    bigText: bigText,
    template: template,
    color: color,
    flags: flags,
      importance: importance,
      whenTime: whenTime,
      key: key,
    visibility: visibility,
    actions: actions,
    uid: uid,
  );
}

class _DetailsCard extends StatelessWidget {
  final _ParsedData data;
  final String deviceId;
  final VoidCallback onTap;
  const _DetailsCard(
      {required this.data, required this.deviceId, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: cs.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppIcon(
                    packageName: data.packageName,
                    deviceId: deviceId,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.title.isNotEmpty
                              ? data.title
                              : data.channelName.isNotEmpty
                                  ? data.channelName
                                  : data.packageName,
                          style: tt.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                data.packageName,
                                style: tt.bodySmall
                                    ?.copyWith(color: cs.onSurfaceVariant),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (data.whenTime != null) ...[
                              Text(
                                ' · ${_timeAgo(data.whenTime!)}',
                                style: tt.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 20, color: cs.outline),
                ],
              ),
              const SizedBox(height: 10),
                  if (data.channelName.isNotEmpty)
                    _Row(label: 'Channel', value: data.channelName),
                  if (data.channelId.isNotEmpty)
                    _Row(label: 'Channel ID', value: data.channelId),
                  if (data.title.isNotEmpty)
                    _Row(label: 'Title', value: data.title),
                  if (data.text.isNotEmpty)
                    _Row(label: 'Text', value: data.text),
                  if (data.bigText.isNotEmpty)
                    _Row(label: 'Big Text', value: data.bigText),
                  if (data.template.isNotEmpty)
                    _Row(label: 'Template', value: data.template),
                  _Row(label: 'Key', value: data.key),
                  _Row(label: 'Importance', value: _importanceLabel(data.importance)),
                  _Row(label: 'Flags', value: data.flags),
                  _Row(label: 'Visibility', value: data.visibility),
                  _Row(label: 'Color', value: data.color),
                  _Row(label: 'UID', value: data.uid),
                  _Row(label: 'When', value: data.whenTime?.toString() ?? ''),
              if (data.actions.isNotEmpty) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: data.actions
                        .map((a) => Chip(
                              label: Text(a,
                                  style: tt.labelSmall?.copyWith(fontSize: 11)),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ))
                        .toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _importanceLabel(String val) {
    switch (val) {
      case '0': return 'None (0)';
      case '1': return 'Min (1)';
      case '2': return 'Low (2)';
      case '3': return 'Default (3)';
      case '4': return 'High (4)';
      case '5': return 'Max (5)';
      default: return val;
    }
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              value,
              style: tt.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: cs.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _quickAction(IconData icon, String tooltip, VoidCallback onTap) {
  return Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Icon(icon, size: 18),
      ),
    ),
  );
}
