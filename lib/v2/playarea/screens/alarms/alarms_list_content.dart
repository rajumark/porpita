import 'package:flutter/material.dart';
import 'alarm_model.dart';
import 'alarm_item_tile.dart';

class AlarmsListContent extends StatelessWidget {
  final List<AlarmEntry> entries;
  final String searchQuery;
  final void Function(AlarmEntry entry) onEntrySelected;

  const AlarmsListContent({
    super.key,
    required this.entries,
    required this.searchQuery,
    required this.onEntrySelected,
  });

  bool _matchesSearch(AlarmEntry e) {
    if (searchQuery.isEmpty) return true;
    final q = searchQuery.toLowerCase();
    return e.packageName.toLowerCase().contains(q) ||
        e.tag.toLowerCase().contains(q) ||
        e.alarmType.label.toLowerCase().contains(q) ||
        e.origWhen.toLowerCase().contains(q) ||
        e.displayTag.toLowerCase().contains(q);
  }

  BorderRadius _borderRadius(int index, int total) {
    if (total == 1) return BorderRadius.circular(12);
    if (index == 0) return const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12));
    if (index == total - 1) return const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12));
    return BorderRadius.circular(2);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = entries.where(_matchesSearch).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          searchQuery.isEmpty ? 'No alarms' : 'No matching alarms',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final entry = filtered[index];
        return AlarmItemTile(
          entry: entry,
          borderRadius: _borderRadius(index, filtered.length),
          onTap: () => onEntrySelected(entry),
        );
      },
    );
  }
}