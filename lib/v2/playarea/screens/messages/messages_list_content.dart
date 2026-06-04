import 'package:flutter/material.dart';
import 'sms_model.dart';
import 'mms_model.dart';
import 'raw_message_entry.dart';
import 'message_item_tile.dart';

class SmsListContent extends StatelessWidget {
  final List<SmsEntry> entries;
  final String searchQuery;
  final void Function(SmsEntry entry) onEntrySelected;
  final void Function(SmsEntry entry)? onViewContact;

  const SmsListContent({
    super.key,
    required this.entries,
    required this.searchQuery,
    required this.onEntrySelected,
    this.onViewContact,
  });

  bool _matchesSearch(SmsEntry e) {
    if (searchQuery.isEmpty) return true;
    final q = searchQuery.toLowerCase();
    return e.address.toLowerCase().contains(q) ||
        e.body.toLowerCase().contains(q) ||
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
          searchQuery.isEmpty ? 'No SMS messages' : 'No matching SMS',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final entry = filtered[index];
        return SmsItemTile(
          entry: entry,
          borderRadius: _borderRadius(index, filtered.length),
          onTap: () => onEntrySelected(entry),
          onViewContact: onViewContact == null
              ? null
              : () => onViewContact!(entry),
        );
      },
    );
  }
}

class MmsListContent extends StatelessWidget {
  final List<MmsEntry> entries;
  final String searchQuery;
  final void Function(MmsEntry entry) onEntrySelected;
  final void Function(MmsEntry entry)? onViewContact;

  const MmsListContent({
    super.key,
    required this.entries,
    required this.searchQuery,
    required this.onEntrySelected,
    this.onViewContact,
  });

  bool _matchesSearch(MmsEntry e) {
    if (searchQuery.isEmpty) return true;
    final q = searchQuery.toLowerCase();
    return e.mId.toLowerCase().contains(q) ||
        e.sub.toLowerCase().contains(q) ||
        e.ctT.toLowerCase().contains(q) ||
        e.msgBoxLabel.toLowerCase().contains(q);
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
          searchQuery.isEmpty ? 'No MMS messages' : 'No matching MMS',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final entry = filtered[index];
        return MmsItemTile(
          entry: entry,
          borderRadius: _borderRadius(index, filtered.length),
          onTap: () => onEntrySelected(entry),
          onViewContact: onViewContact == null
              ? null
              : () => onViewContact!(entry),
        );
      },
    );
  }
}

class RawMessageListContent extends StatelessWidget {
  final List<RawMessageEntry> entries;
  final String searchQuery;
  final void Function(RawMessageEntry entry) onEntrySelected;

  const RawMessageListContent({
    super.key,
    required this.entries,
    required this.searchQuery,
    required this.onEntrySelected,
  });

  bool _matchesSearch(RawMessageEntry e) {
    if (searchQuery.isEmpty) return true;
    final q = searchQuery.toLowerCase();
    for (final v in e.raw.values) {
      if (v.toLowerCase().contains(q)) return true;
    }
    return false;
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
          searchQuery.isEmpty ? 'No results' : 'No matching rows',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final entry = filtered[index];
        return RawMessageItemTile(
          entry: entry,
          borderRadius: _borderRadius(index, filtered.length),
          onTap: () => onEntrySelected(entry),
        );
      },
    );
  }
}
