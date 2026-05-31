import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:porpita/services/device_manager.dart';
import 'queries_service.dart';

const _keyDescriptions = {
  'system apps queryable:': 'Whether system apps on this device can see all other installed apps by default. "false" means they follow the same visibility rules as regular apps.',
  'queries via forceQueryable:': 'Apps that are always visible to all other apps, regardless of targeting SDK version. Typically empty unless specific apps are force-queryable via device policy.',
  'queries via package name:': 'Apps that have explicitly declared specific package names in their <queries> tag in AndroidManifest.xml. The calling app lists which target apps it needs to see directly by package name.',
  'queries via component:': 'Apps that can see each other because they registered intent filters for specific actions/data. The calling app looks for a specific capability (e.g. sharing, opening links), and the target app provides it.',
  'queryable via interaction:': 'Apps that temporarily gained visibility of each other because the user interacted with them together (e.g. clicking a link in one app that opens another). This visibility is transient and session-based.',
  'queryable via uses-library:': 'Apps that can see each other because they share a common software library framework declared in their manifest. Currently empty for this app.',
};

class QueriesTab extends StatefulWidget {
  final String packageName;
  const QueriesTab({super.key, required this.packageName});

  @override
  State<QueriesTab> createState() => _QueriesTabState();
}

class _QueriesTabState extends State<QueriesTab> with AutomaticKeepAliveClientMixin {
  QueriesInfo? _info;
  bool _loading = true;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void didUpdateWidget(covariant QueriesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.packageName != widget.packageName) _fetch();
  }

  Future<void> _fetch() async {
    final device = context.read<DeviceManager>().selected;
    if (device == null) {
      setState(() { _loading = false; _error = 'No device connected'; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final info = await QueriesService.fetch(device.id, widget.packageName);
      if (!mounted) return;
      setState(() { _info = info; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) {
      return const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)));
    }
    if (_error != null) {
      return Center(child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)));
    }
    if (_info == null || (_info!.systemAppsQueryable.isEmpty && _info!.sections.isEmpty)) {
      return const Center(child: Text('No queries data'));
    }
    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        if (_info!.systemAppsQueryable.isNotEmpty) ...[
          _sectionHeader(context, _info!.systemAppsQueryable),
          const SizedBox(height: 4),
          _keyLine(context, _info!.systemAppsQueryable),
          const SizedBox(height: 16),
        ],
        ..._info!.sections.expand((section) => [
          _sectionHeader(context, section.key),
          const SizedBox(height: 4),
          ...section.children.map((line) => _childLine(context, line, theme)),
          const SizedBox(height: 12),
        ]),
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String key) {
    final desc = _keyDescriptions[key] ?? '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Flexible(child: _keyLine(context, key.replaceAll(':', ''))),
          if (desc.isNotEmpty) ...[
            const SizedBox(width: 6),
            Tooltip(
              message: desc,
              preferBelow: false,
              decoration: BoxDecoration(
                color: theme(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: theme(context).textTheme.bodySmall,
              child: MouseRegion(
                cursor: SystemMouseCursors.help,
                child: Icon(Icons.help_outline, size: 16, color: theme(context).colorScheme.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }

  ThemeData theme(BuildContext context) => Theme.of(context);

  Widget _keyLine(BuildContext context, String text) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: SelectableText(
        text,
        style: t.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'monospace'),
      ),
    );
  }

  Widget _childLine(BuildContext context, String line, ThemeData theme) {
    final trimmed = line.trimLeft();
    final indent = line.length - trimmed.length;
    return Padding(
      padding: EdgeInsets.only(left: indent.toDouble() * 0.5),
      child: SelectableText(
        line,
        style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
      ),
    );
  }
}