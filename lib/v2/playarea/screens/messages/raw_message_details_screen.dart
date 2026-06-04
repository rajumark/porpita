import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:porpita/v2/widgets/rounded_container.dart';
import 'raw_message_entry.dart';
import 'message_format.dart';

class RawMessageDetailsScreen extends StatelessWidget {
  final RawMessageEntry entry;
  final VoidCallback onBack;
  const RawMessageDetailsScreen({
    super.key,
    required this.entry,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final date = entry.date;
    final entries = entry.raw.entries.toList();

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
                    'Row ${entry.id.isEmpty ? '—' : entry.id}',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  iconSize: 18,
                  tooltip: 'Copy all',
                  onPressed: () {
                    final text =
                        entries.map((e) => '${e.key}=${e.value}').join('\n');
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All fields copied'),
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
            child: Material(
              color: scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: entries.length + (date != null ? 1 : 0),
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: scheme.outlineVariant.withValues(alpha: 0.4),
                ),
                itemBuilder: (context, index) {
                  if (date != null && index == 0) {
                    return _row(context, '_date_human', formatMessageTime(date));
                  }
                  final i = date != null ? index - 1 : index;
                  final e = entries[i];
                  return _row(context, e.key, e.value);
                },
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
            width: 160,
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
              value.isEmpty ? 'NULL' : value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
          if (value.isNotEmpty)
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
}
