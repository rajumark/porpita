import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'call_log_model.dart';
import 'call_log_format.dart';

class CallLogItemTile extends StatelessWidget {
  final CallLogEntry entry;
  final BorderRadius borderRadius;
  final VoidCallback onTap;
  final VoidCallback onCall;
  final VoidCallback? onViewContact;

  const CallLogItemTile({
    super.key,
    required this.entry,
    required this.borderRadius,
    required this.onTap,
    required this.onCall,
    this.onViewContact,
  });

  Color _typeColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (entry.type) {
      case CallType.incoming:
        return Colors.green;
      case CallType.outgoing:
        return scheme.primary;
      case CallType.missed:
        return scheme.error;
      case CallType.rejected:
      case CallType.blocked:
        return scheme.error;
      case CallType.voicemail:
        return scheme.tertiary;
      case CallType.unknown:
        return scheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final typeColor = _typeColor(context);
    final hasName = entry.name.isNotEmpty;

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
                  color: typeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  entry.type.icon,
                  size: 18,
                  color: typeColor,
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
                            entry.displayName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: hasName ? FontWeight.w500 : FontWeight.w400,
                              color: entry.type == CallType.missed ||
                                      entry.type == CallType.rejected ||
                                      entry.type == CallType.blocked
                                  ? scheme.error
                                  : scheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatCallLogTime(entry.date),
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
                            hasName ? entry.displayNumber : entry.type.label,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (entry.type == CallType.incoming || entry.type == CallType.outgoing)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              formatCallDuration(entry.duration),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
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
                            onPressed: entry.displayNumber.isEmpty || onViewContact == null
                                ? null
                                : onViewContact,
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints.tight(const Size(32, 32)),
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: IconButton(
                            icon: const Icon(Icons.call),
                            iconSize: 18,
                            color: scheme.primary,
                            tooltip: 'Call ${entry.displayName}',
                            onPressed: entry.displayNumber.isEmpty ? null : onCall,
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
                            tooltip: 'Copy number',
                            onPressed: entry.displayNumber.isEmpty
                                ? null
                                : () {
                                    Clipboard.setData(
                                      ClipboardData(text: entry.displayNumber),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Number copied'),
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
