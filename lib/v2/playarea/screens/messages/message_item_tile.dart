import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'sms_model.dart';
import 'mms_model.dart';
import 'raw_message_entry.dart';
import 'message_format.dart';

class SmsItemTile extends StatelessWidget {
  final SmsEntry entry;
  final BorderRadius borderRadius;
  final VoidCallback onTap;
  final VoidCallback? onViewContact;

  const SmsItemTile({
    super.key,
    required this.entry,
    required this.borderRadius,
    required this.onTap,
    this.onViewContact,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dirColor = entry.directionColor(context);

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
                  color: dirColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(entry.directionIcon, size: 18, color: dirColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        if (entry.isUnread)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            entry.displayAddress,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: entry.isUnread
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          formatMessageTime(entry.date),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.preview,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: entry.isUnread
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: IconButton(
                  icon: const Icon(Icons.person_outline),
                  iconSize: 18,
                  color: scheme.onSurfaceVariant,
                  tooltip: 'View contact',
                  onPressed: entry.address.isEmpty || onViewContact == null
                      ? null
                      : onViewContact,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tight(const Size(32, 32)),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: IconButton(
                  icon: const Icon(Icons.content_copy),
                  iconSize: 16,
                  color: scheme.onSurfaceVariant,
                  tooltip: 'Copy body',
                  onPressed: entry.body.isEmpty
                      ? null
                      : () {
                          Clipboard.setData(ClipboardData(text: entry.body));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Body copied'),
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

class MmsItemTile extends StatelessWidget {
  final MmsEntry entry;
  final BorderRadius borderRadius;
  final VoidCallback onTap;
  final VoidCallback? onViewContact;

  const MmsItemTile({
    super.key,
    required this.entry,
    required this.borderRadius,
    required this.onTap,
    this.onViewContact,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dirColor = entry.directionColor(context);

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
                  color: dirColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.attachment_outlined,
                  size: 18,
                  color: dirColor,
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
                        if (entry.isUnread)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            entry.displayAddress,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: entry.isUnread
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          formatMessageTime(entry.date),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.preview,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          entry.sizeDisplay,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: IconButton(
                  icon: const Icon(Icons.person_outline),
                  iconSize: 18,
                  color: scheme.onSurfaceVariant,
                  tooltip: 'View contact',
                  onPressed: onViewContact,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tight(const Size(32, 32)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RawMessageItemTile extends StatelessWidget {
  final RawMessageEntry entry;
  final BorderRadius borderRadius;
  final VoidCallback onTap;

  const RawMessageItemTile({
    super.key,
    required this.entry,
    required this.borderRadius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final date = entry.date;
    final primary = entry.primaryText;
    final secondary = entry.secondaryText;
    final id = entry.id;

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
                  Icons.dataset_outlined,
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
                            primary,
                            style: Theme.of(context).textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (date != null)
                          Text(
                            formatMessageTime(date),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            secondary.isEmpty ? id : secondary,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: IconButton(
                  icon: const Icon(Icons.copy),
                  iconSize: 16,
                  color: scheme.onSurfaceVariant,
                  tooltip: 'Copy raw row',
                  onPressed: () {
                    final text = entry.raw.entries
                        .map((e) => '${e.key}=${e.value}')
                        .join(', ');
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Row copied'),
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
