import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:porpita/services/device_manager.dart';
import 'activity_resolver_model.dart';
import 'activity_resolver_service.dart';

class ActivitiesTab extends StatefulWidget {
  final String packageName;
  const ActivitiesTab({super.key, required this.packageName});

  @override
  State<ActivitiesTab> createState() => _ActivitiesTabState();
}

class _ActivitiesTabState extends State<ActivitiesTab> with AutomaticKeepAliveClientMixin {
  ActivityResolverResult? _result;
  bool _loading = true;
  String? _error;
  String _query = '';
  final _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
    _fetch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ActivitiesTab oldWidget) {
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
      final result = await ActivityResolverService.fetch(device.id, widget.packageName);
      if (!mounted) return;
      setState(() { _result = result; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<ResolverSection> _filteredSections() {
    if (_result == null) return [];
    if (_query.isEmpty) return _result!.sections;

    return _result!.sections.map((section) {
      final filteredGroups = section.groups.where((group) {
        if (group.key.toLowerCase().contains(_query)) return true;
        return group.entries.any((e) =>
            e.activityName.toLowerCase().contains(_query) ||
            e.rawDetail.toLowerCase().contains(_query) ||
            e.filterHash.toLowerCase().contains(_query));
      }).map((group) {
        if (group.key.toLowerCase().contains(_query)) return group;
        final filteredEntries = group.entries.where((e) =>
            e.activityName.toLowerCase().contains(_query) ||
            e.rawDetail.toLowerCase().contains(_query) ||
            e.filterHash.toLowerCase().contains(_query)).toList();
        return ResolverGroup(key: group.key, entries: filteredEntries);
      }).where((g) => g.entries.isNotEmpty).toList();

      return ResolverSection(name: section.name, groups: filteredGroups);
    }).where((s) => s.groups.isNotEmpty).toList();
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
    if (_result == null || _result!.sections.isEmpty) {
      return const Center(child: Text('No activity resolver data'));
    }

    final sections = _filteredSections();
    final totalEntries = sections.fold<int>(0, (sum, s) => sum + s.groups.fold<int>(0, (g, g2) => g + g2.entries.length));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search activities...',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      prefixIcon: const Icon(Icons.search, size: 16),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 14),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints.tightFor(width: 24, height: 24),
                            )
                          : null,
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('$totalEntries', style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: sections.length,
            itemBuilder: (context, index) => _SectionWidget(section: sections[index]),
          ),
        ),
      ],
    );
  }
}

class _SectionWidget extends StatelessWidget {
  final ResolverSection section;
  const _SectionWidget({required this.section});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: false,
      tilePadding: const EdgeInsets.symmetric(horizontal: 4),
      childrenPadding: EdgeInsets.zero,
      dense: true,
      title: Row(
        children: [
          Icon(_sectionIcon(section.name), size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(section.name, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${section.groups.fold<int>(0, (sum, g) => sum + g.entries.length)}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
          ),
        ],
      ),
      children: section.groups.map((group) => _GroupWidget(group: group)).toList(),
    );
  }

  IconData _sectionIcon(String name) {
    switch (name) {
      case 'Full MIME Types':
        return Icons.description;
      case 'Base MIME Types':
        return Icons.description_outlined;
      case 'Wild MIME Types':
        return Icons.auto_fix_high;
      case 'Schemes':
        return Icons.link;
      case 'Non-Data Actions':
        return Icons.flash_on;
      case 'MIME Typed Actions':
        return Icons.mediation;
      default:
        return Icons.category;
    }
  }
}

class _GroupWidget extends StatelessWidget {
  final ResolverGroup group;
  const _GroupWidget({required this.group});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: false,
      tilePadding: const EdgeInsets.only(left: 12, right: 4),
      childrenPadding: EdgeInsets.zero,
      dense: true,
      title: Text(group.key, style: Theme.of(context).textTheme.bodySmall),
      trailing: Text('${group.entries.length}', style: Theme.of(context).textTheme.labelSmall),
      children: group.entries.map((entry) => _EntryWidget(entry: entry)).toList(),
    );
  }
}

class _EntryWidget extends StatelessWidget {
  final ResolverEntry entry;
  const _EntryWidget({required this.entry});

  @override
  Widget build(BuildContext context) {
    final hasDetail = entry.rawDetail.isNotEmpty;
    if (!hasDetail) {
      return _entryHeader(context);
    }
    return ExpansionTile(
      initiallyExpanded: false,
      tilePadding: const EdgeInsets.only(left: 24, right: 4),
      childrenPadding: const EdgeInsets.only(left: 32, right: 8, bottom: 4),
      dense: true,
      title: Text(
        entry.activityName,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace', fontSize: 11),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(entry.filterHash, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontFamily: 'monospace')),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(6),
          ),
          child: SelectableText(
            entry.rawDetail,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace', fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _entryHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 4, top: 2, bottom: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              entry.activityName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace', fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(entry.filterHash, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontFamily: 'monospace')),
        ],
      ),
    );
  }
}