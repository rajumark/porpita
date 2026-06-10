import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'notification_model.dart';
import 'notification_format.dart';

class NotificationItemTile extends StatelessWidget {
  final NotificationEntry entry;
  final BorderRadius borderRadius;
  final VoidCallback onTap;

  const NotificationItemTile({
    super.key,
    required this.entry,
    required this.borderRadius,
    required this.onTap,
  });

  Color _importanceColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (entry.importanceLevel) {
      case NotificationImportance.high:
      case NotificationImportance.max:
        return scheme.error;
      case NotificationImportance.default_:
        return scheme.primary;
      case NotificationImportance.low:
      case NotificationImportance.min:
        return scheme.onSurfaceVariant;
      case NotificationImportance.none:
        return scheme.outline;
    }
  }

  IconData _flagIcon() {
    if (entry.flags.contains('ONGOING_EVENT')) return Icons.sync;
    if (entry.flags.contains('AUTO_CANCEL')) return Icons.cancel_outlined;
    return Icons.notifications;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final impColor = _importanceColor(context);

    return Material(
      color: scheme.surfaceContainer,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8, top: 8, bottom: 8),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: impColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _flagIcon(),
                  size: 18,
                  color: impColor,
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
                            entry.displayTitle,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: scheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatNotificationTime(entry.when),
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
                            entry.displayText.isNotEmpty
                                ? entry.displayText
                                : entry.channelName.isNotEmpty
                                    ? entry.channelName
                                    : entry.channelId.isNotEmpty
                                        ? entry.channelId
                                        : entry.importanceLabel,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: impColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            entry.importanceLevel.label,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: impColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: IconButton(
                            icon: const Icon(Icons.copy),
                            iconSize: 16,
                            color: scheme.onSurfaceVariant,
                            tooltip: 'Copy key',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: entry.key));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Key copied'),
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
                    const SizedBox(height: 1),
                    Text(
                      entry.displayApp,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.outline,
                      ),
                      overflow: TextOverflow.ellipsis,
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