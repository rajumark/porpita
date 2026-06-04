import 'package:flutter/material.dart';
import 'call_log_model.dart';
import 'calllog_item_tile.dart';

class CallLogsListContent extends StatelessWidget {
  final List<CallLogEntry> entries;
  final String searchQuery;
  final void Function(CallLogEntry entry) onEntrySelected;
  final void Function(CallLogEntry entry) onCall;
  final void Function(CallLogEntry entry)? onViewContact;

  const CallLogsListContent({
    super.key,
    required this.entries,
    required this.searchQuery,
    required this.onEntrySelected,
    required this.onCall,
    this.onViewContact,
  });

  bool _matchesSearch(CallLogEntry e) {
    if (searchQuery.isEmpty) return true;
    final q = searchQuery.toLowerCase();
    return e.displayName.toLowerCase().contains(q) ||
        e.displayNumber.toLowerCase().contains(q) ||
        e.type.label.toLowerCase().contains(q);
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
          searchQuery.isEmpty ? 'No call logs' : 'No matching call logs',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final entry = filtered[index];
        return CallLogItemTile(
          entry: entry,
          borderRadius: _borderRadius(index, filtered.length),
          onTap: () => onEntrySelected(entry),
          onCall: () => onCall(entry),
          onViewContact: onViewContact == null
              ? null
              : () => onViewContact!(entry),
        );
      },
    );
  }
}
