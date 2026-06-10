import 'package:flutter/material.dart';
import 'notification_model.dart';
import 'notification_item_tile.dart';

class NotificationsListContent extends StatelessWidget {
  final List<NotificationEntry> entries;
  final String searchQuery;
  final void Function(NotificationEntry entry) onEntrySelected;

  const NotificationsListContent({
    super.key,
    required this.entries,
    required this.searchQuery,
    required this.onEntrySelected,
  });

  bool _matchesSearch(NotificationEntry e) {
    if (searchQuery.isEmpty) return true;
    final q = searchQuery.toLowerCase();
    return e.packageName.toLowerCase().contains(q) ||
        e.title.toLowerCase().contains(q) ||
        e.text.toLowerCase().contains(q) ||
        e.substName.toLowerCase().contains(q) ||
        e.channelName.toLowerCase().contains(q) ||
        e.channelId.toLowerCase().contains(q) ||
        e.importanceLabel.toLowerCase().contains(q);
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
          searchQuery.isEmpty ? 'No notifications' : 'No matching notifications',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final entry = filtered[index];
        return NotificationItemTile(
          entry: entry,
          borderRadius: _borderRadius(index, filtered.length),
          onTap: () => onEntrySelected(entry),
        );
      },
    );
  }
}