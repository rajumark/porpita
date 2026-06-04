import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'contact_model.dart';

class ContactItemTile extends StatelessWidget {
  final ContactEntry entry;
  final BorderRadius borderRadius;
  final VoidCallback onTap;
  final String? secondaryLine;

  const ContactItemTile({
    super.key,
    required this.entry,
    required this.borderRadius,
    required this.onTap,
    this.secondaryLine,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final name = entry.name;

    return Material(
      color: scheme.surfaceContainer,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, top: 6, bottom: 6),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: scheme.primaryContainer,
                child: Text(
                  entry.initials,
                  style: TextStyle(
                    color: scheme.onPrimaryContainer,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        if (entry.isStarred)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber.shade700,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            name,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (entry.hasPhone)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Icon(
                              Icons.phone,
                              size: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        const SizedBox(width: 4),
                        Text(
                          '#${entry.id}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (secondaryLine != null && secondaryLine!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        secondaryLine!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: IconButton(
                  icon: const Icon(Icons.content_copy),
                  iconSize: 16,
                  color: scheme.onSurfaceVariant,
                  tooltip: 'Copy name',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: name));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Name copied'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tight(const Size(28, 32)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContactDataItemTile extends StatelessWidget {
  final ContactDataEntry entry;
  final BorderRadius borderRadius;
  final VoidCallback onTap;

  const ContactDataItemTile({
    super.key,
    required this.entry,
    required this.borderRadius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final primary = entry.primaryValue;
    final secondary = entry.secondaryValue;

    return Material(
      color: scheme.surfaceContainer,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8, top: 8, bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: scheme.tertiaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  entry.type.icon,
                  size: 18,
                  color: scheme.tertiary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            primary.isEmpty ? '(empty)' : primary,
                            style: Theme.of(context).textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (entry.isSuperPrimary == '1')
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.amber.shade700,
                            ),
                          ),
                        if (entry.isPrimary == '1' && entry.isSuperPrimary != '1')
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.label_important_outline,
                              size: 12,
                              color: scheme.primary,
                            ),
                          ),
                      ],
                    ),
                    if (secondary.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        secondary,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    Text(
                      entry.mimetype.replaceFirst('vnd.android.cursor.item/', ''),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.outline,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
