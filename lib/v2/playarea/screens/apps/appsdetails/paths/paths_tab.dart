import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:porpita/services/device_manager.dart';
import 'paths_service.dart';

class PathsTab extends StatefulWidget {
  final String packageName;
  const PathsTab({super.key, required this.packageName});

  @override
  State<PathsTab> createState() => _PathsTabState();
}

class _PathsTabState extends State<PathsTab> with AutomaticKeepAliveClientMixin {
  PathsResult? _result;
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
  void didUpdateWidget(covariant PathsTab oldWidget) {
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
      final result = await PathsService.fetch(device.id, widget.packageName);
      if (!mounted) return;
      setState(() { _result = result; _loading = false; });
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
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 8),
            FilledButton.tonal(onPressed: _fetch, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_result == null || _result!.paths.isEmpty) {
      return const Center(child: Text('No paths found'));
    }

    final categories = <String>[];
    for (final p in _result!.paths) {
      if (!categories.contains(p.category)) categories.add(p.category);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final paths = _result!.paths.where((p) => p.category == category).toList();
        return _CategorySection(
          category: category,
          paths: paths,
        );
      },
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String category;
  final List<PathItem> paths;

  const _CategorySection({required this.category, required this.paths});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: true,
      tilePadding: const EdgeInsets.symmetric(horizontal: 4),
      childrenPadding: const EdgeInsets.only(left: 8, right: 4),
      dense: true,
      title: Row(
        children: [
          Icon(_categoryIcon(category), size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(category, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${paths.length}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
          ),
        ],
      ),
      children: paths.map((p) => _PathRow(item: p)).toList(),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Installation':
        return Icons.archive;
      case 'Internal Data':
        return Icons.folder_special;
      case 'External Storage':
        return Icons.sd_storage;
      case 'Runtime':
        return Icons.speed;
      case 'System':
        return Icons.settings_applications;
      default:
        return Icons.folder;
    }
  }
}

class _PathRow extends StatefulWidget {
  final PathItem item;

  const _PathRow({required this.item});

  @override
  State<_PathRow> createState() => _PathRowState();
}

class _PathRowState extends State<_PathRow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 140,
              child: Text(
                widget.item.label,
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SelectableText(
                widget.item.path,
                style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            const SizedBox(width: 4),
            if (_hovering)
              SizedBox(
                width: 28,
                height: 28,
                child: IconButton(
                  icon: const Icon(Icons.copy, size: 14),
                  tooltip: 'Copy path',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(width: 28, height: 28),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.item.path));
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied: ${widget.item.path}'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.only(bottom: 16),
                      ),
                    );
                  },
                ),
              )
            else
              const SizedBox(width: 28),
          ],
        ),
      ),
    );
  }
}