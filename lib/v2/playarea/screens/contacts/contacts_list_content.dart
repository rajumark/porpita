import 'package:flutter/material.dart';
import 'contact_model.dart';
import 'contact_item_tile.dart';

class ContactsListContent extends StatelessWidget {
  final List<ContactEntry> entries;
  final String searchQuery;
  final void Function(ContactEntry entry) onEntrySelected;
  final String? Function(ContactEntry entry)? secondaryLineBuilder;

  const ContactsListContent({
    super.key,
    required this.entries,
    required this.searchQuery,
    required this.onEntrySelected,
    this.secondaryLineBuilder,
  });

  bool _matchesSearch(ContactEntry e) {
    if (searchQuery.isEmpty) return true;
    final q = searchQuery.toLowerCase();
    return e.name.toLowerCase().contains(q) ||
        e.displayNameAlt.toLowerCase().contains(q) ||
        e.lookup.toLowerCase().contains(q);
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
          searchQuery.isEmpty ? 'No contacts' : 'No matching contacts',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final entry = filtered[index];
        return ContactItemTile(
          entry: entry,
          borderRadius: _borderRadius(index, filtered.length),
          onTap: () => onEntrySelected(entry),
          secondaryLine: secondaryLineBuilder?.call(entry),
        );
      },
    );
  }
}

class ContactDataListContent extends StatelessWidget {
  final List<ContactDataEntry> entries;
  final String searchQuery;
  final void Function(ContactDataEntry entry) onEntrySelected;

  const ContactDataListContent({
    super.key,
    required this.entries,
    required this.searchQuery,
    required this.onEntrySelected,
  });

  bool _matchesSearch(ContactDataEntry e) {
    if (searchQuery.isEmpty) return true;
    final q = searchQuery.toLowerCase();
    return e.primaryValue.toLowerCase().contains(q) ||
        e.secondaryValue.toLowerCase().contains(q) ||
        e.mimetype.toLowerCase().contains(q);
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
          searchQuery.isEmpty ? 'No data rows' : 'No matching rows',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final entry = filtered[index];
        return ContactDataItemTile(
          entry: entry,
          borderRadius: _borderRadius(index, filtered.length),
          onTap: () => onEntrySelected(entry),
        );
      },
    );
  }
}
