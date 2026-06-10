import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:porpita/v2/widgets/rounded_container.dart';
import 'notification_model.dart';
import 'notification_format.dart';

class NotificationDetailsScreen extends StatelessWidget {
  final NotificationEntry entry;
  final VoidCallback onBack;
  const NotificationDetailsScreen({
    super.key,
    required this.entry,
    required this.onBack,
  });

  Widget _section(BuildContext context, String title, List<({String label, String value})> rows) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4, top: 4),
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Material(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Column(
                children: [
                  for (int i = 0; i < rows.length; i++) ...[
                    _row(context, rows[i].label, rows[i].value),
                    if (i < rows.length - 1)
                      Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.4)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
          if (value.isNotEmpty && value != '—')
            IconButton(
              icon: const Icon(Icons.copy, size: 14),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tight(const Size(24, 24)),
              visualDensity: VisualDensity.compact,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Copied'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RoundedContainer(
      child: Column(
        children: [
          SizedBox(
            height: 36,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  iconSize: 24,
                  onPressed: onBack,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tight(const Size(36, 36)),
                ),
                Expanded(
                  child: Text(
                    entry.displayTitle,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  iconSize: 18,
                  tooltip: 'Copy info',
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: 'Package: ${entry.packageName}\nTitle: ${entry.title}\nText: ${entry.text}\nKey: ${entry.key}'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notification info copied'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tight(const Size(36, 36)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 12),
              children: [
                _section(context, 'Summary', [
                  (label: 'Title', value: entry.title.isEmpty ? '—' : entry.title),
                  (label: 'Text', value: entry.text.isEmpty ? '—' : entry.text),
                  (label: 'Big Text', value: entry.bigText.isEmpty ? '—' : entry.bigText),
                  (label: 'Subst Name', value: entry.substName.isEmpty ? '—' : entry.substName),
                  (label: 'Template', value: entry.template.isEmpty ? '—' : entry.template),
                  (label: 'Time', value: formatNotificationTime(entry.when)),
                  (label: 'Time (ms)', value: entry.when.millisecondsSinceEpoch.toString()),
                  (label: 'Importance', value: '${entry.importanceLevel.label} (${entry.importance})'),
                  (label: 'Seen', value: entry.seen ? 'Yes' : 'No'),
                ]),
                _section(context, 'Package', [
                  (label: 'Package', value: entry.packageName),
                  (label: 'OpPkg', value: entry.opPkg.isEmpty ? '—' : entry.opPkg),
                  (label: 'IconPkg', value: entry.iconPkg.isEmpty ? '—' : entry.iconPkg),
                  (label: 'UID', value: entry.uid.isEmpty ? '—' : entry.uid),
                  (label: 'User ID', value: entry.userId.isEmpty ? '—' : entry.userId),
                ]),
                _section(context, 'Notification', [
                  (label: 'ID', value: entry.id),
                  (label: 'Tag', value: entry.tag.isEmpty ? '—' : entry.tag),
                  (label: 'Key', value: entry.key),
                  (label: 'Group Key', value: entry.groupKey.isEmpty ? '—' : entry.groupKey),
                  (label: 'Flags', value: entry.flags.isEmpty ? '—' : entry.flags),
                  (label: 'Visibility', value: entry.visibility.isEmpty ? '—' : entry.visibility),
                  (label: 'Color', value: entry.color.isEmpty ? '—' : entry.color),
                ]),
                _section(context, 'Channel', [
                  (label: 'Channel ID', value: entry.channelId.isEmpty ? '—' : entry.channelId),
                  (label: 'Channel Name', value: entry.channelName.isEmpty ? '—' : entry.channelName),
                  (label: 'Channel', value: entry.channel.isEmpty ? '—' : entry.channel),
                  (label: 'Imp. Label', value: entry.importanceLabel.isEmpty ? '—' : entry.importanceLabel),
                ]),
                if (entry.actionLabels.isNotEmpty)
                  _section(context, 'Actions', [
                    for (int i = 0; i < entry.actionLabels.length; i++)
                      (label: 'Action $i', value: entry.actionLabels[i]),
                  ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}