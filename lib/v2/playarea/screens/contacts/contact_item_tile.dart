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
