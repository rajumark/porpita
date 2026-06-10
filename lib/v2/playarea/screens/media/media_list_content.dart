import 'package:flutter/material.dart';
import 'media_model.dart';
import 'media_item_tile.dart';

enum MediaViewMode { list, grid }

class MediaListContent extends StatelessWidget {
  final List<MediaEntry> entries;
  final String searchQuery;
  final MediaViewMode viewMode;
  final void Function(MediaEntry entry) onEntrySelected;

  const MediaListContent({
    super.key,
    required this.entries,
    required this.searchQuery,
    required this.viewMode,
    required this.onEntrySelected,
  });

  bool _matchesSearch(MediaEntry e) {
    if (searchQuery.isEmpty) return true;
    final q = searchQuery.toLowerCase();
    return e.displayName.toLowerCase().contains(q) ||
        e.path.toLowerCase().contains(q) ||
        e.bucketDisplayName.toLowerCase().contains(q) ||
        e.category.label.toLowerCase().contains(q) ||
        e.extension.toLowerCase().contains(q);
  }

  BorderRadius _borderRadius(int index, int total) {
    if (total == 1) return BorderRadius.circular(12);
    if (index == 0) {
      return const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      );
    }
    if (index == total - 1) {
      return const BorderRadius.only(
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      );
    }
    return BorderRadius.circular(2);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = entries.where(_matchesSearch).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          searchQuery.isEmpty ? 'No files' : 'No matching files',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    if (viewMode == MediaViewMode.grid) {
      return GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 140,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.85,
        ),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final entry = filtered[index];
          return MediaGridCard(
            entry: entry,
            onTap: () => onEntrySelected(entry),
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final entry = filtered[index];
        return MediaListTile(
          entry: entry,
          borderRadius: _borderRadius(index, filtered.length),
          onTap: () => onEntrySelected(entry),
        );
      },
    );
  }
}
