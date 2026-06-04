import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:porpita/services/device_manager.dart';
import 'app_files_service.dart';

class AppFilesTab extends StatefulWidget {
  final String packageName;
  const AppFilesTab({super.key, required this.packageName});

  @override
  State<AppFilesTab> createState() => _AppFilesTabState();
}

class _AppFilesTabState extends State<AppFilesTab> with AutomaticKeepAliveClientMixin {
  List<AppFilesResult> _history = [];
  AppFilesResult? _current;
  bool _loading = false;
  String? _error;
  bool _initialLoad = true;
  String? _rootError;

  @override
  bool get wantKeepAlive => true;

  @override
  void didUpdateWidget(covariant AppFilesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.packageName != widget.packageName) {
      _history = [];
      _current = null;
      _error = null;
      _initialLoad = true;
      _rootError = null;
    }
  }

  Future<void> _fetch(String subpath) async {
    final device = context.read<DeviceManager>().selected;
    if (device == null) {
      setState(() { _loading = false; _error = 'No device connected'; });
      return;
    }
    setState(() { _loading = true; _error = null; _initialLoad = false; });
    try {
      final result = await AppFilesService.fetch(device.id, widget.packageName, subpath: subpath);
      if (!mounted) return;
      setState(() {
        _current = result;
        _loading = false;
        if (result.error != null) _error = result.error;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _tryRoot() async {
    final device = context.read<DeviceManager>().selected;
    if (device == null) return;
    setState(() { _loading = true; _error = null; _rootError = null; });
    try {
      final subpath = _current != null
          ? _current!.path.replaceFirst('/data/data/${widget.packageName}', '')
          : '';
      final result = await AppFilesService.fetchWithRoot(device.id, widget.packageName, subpath: subpath.isEmpty ? '' : subpath);
      if (!mounted) return;
      setState(() {
        _current = result;
        _loading = false;
        if (result.error != null) {
          _error = result.error;
          _rootError = 'Root access attempt:\n${result.rawOutput ?? ''}';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _navigateTo(String name, bool isDirectory) {
    if (!isDirectory) return;
    final currentPath = _current?.path ?? '/data/data/${widget.packageName}';
    final newPath = '$currentPath/$name';
    _history.add(_current!);
    _fetch(newPath.replaceFirst('/data/data/${widget.packageName}', ''));
  }

  void _goBack() {
    if (_history.isNotEmpty) {
      setState(() {
        _current = _history.removeLast();
        _error = _current?.error;
        _loading = false;
      });
    }
  }

  void _copyError() {
    final sb = StringBuffer();
    if (_current?.path.isNotEmpty == true) {
      sb.writeln('Path: ${_current!.path}');
      sb.writeln();
    }
    sb.writeln('Error:');
    sb.writeln(_error!);
    sb.writeln();
    if (_current?.commands != null) {
      sb.writeln('--- Commands ---');
      sb.writeln(_current!.commands);
      sb.writeln();
    }
    if (_current?.rawOutput != null) {
      sb.writeln('--- Raw Output ---');
      sb.writeln(_current!.rawOutput);
    }
    if (_rootError != null) {
      sb.writeln();
      sb.writeln(_rootError);
    }
    Clipboard.setData(ClipboardData(text: sb.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) {
      return const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)));
    }
    if (_initialLoad) {
      return _buildInitial(context);
    }
    if (_error != null) {
      return _buildError(context);
    }
    if (_current == null) {
      return const Center(child: Text('No data'));
    }
    return _buildContent(context);
  }

  Widget _buildInitial(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open, size: 48, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('App Files', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Browse files in /data/data/${widget.packageName}/\n\n'
              'This requires the app to be debuggable or the device to be rooted.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _fetch(''),
              icon: const Icon(Icons.upload_file, size: 18),
              label: const Text('Load Files'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    final theme = Theme.of(context);
    final canTryRoot = _current?.canTryRoot ?? false;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_off, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Access Denied', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                if (canTryRoot)
                  FilledButton.icon(
                    onPressed: _tryRoot,
                    icon: const Icon(Icons.admin_panel_settings, size: 18),
                    label: const Text('Try Root Access'),
                  ),
                OutlinedButton.icon(
                  onPressed: _copyError,
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy Error'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _fetch(''),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final entries = _current?.entries ?? [];

    final dirs = entries.where((e) => e.isDirectory).toList();
    final files = entries.where((e) => !e.isDirectory).toList();
    final sorted = [...dirs, ...files];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              if (_history.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 18),
                  onPressed: _goBack,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tight(const Size(32, 32)),
                ),
              Expanded(
                child: Text(
                  _current?.path ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: sorted.isEmpty
              ? const Center(child: Text('Empty directory'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: sorted.length,
                  itemBuilder: (context, index) {
                    final entry = sorted[index];
                    return _buildEntry(context, entry);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEntry(BuildContext context, AppFileEntry entry) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: entry.isDirectory ? () => _navigateTo(entry.name, true) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              entry.isDirectory ? Icons.folder : Icons.insert_drive_file_outlined,
              size: 18,
              color: entry.isDirectory ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: entry.isDirectory ? FontWeight.w600 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${entry.permissions}  ${entry.owner}:${entry.group}  ${entry.size}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            if (entry.isDirectory)
              Icon(Icons.chevron_right, size: 16, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}