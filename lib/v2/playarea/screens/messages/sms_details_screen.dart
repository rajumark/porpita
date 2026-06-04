import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'sms_model.dart';
import 'message_format.dart';
import 'package:porpita/v2/widgets/rounded_container.dart';

class SmsDetailsScreen extends StatelessWidget {
  final SmsEntry entry;
  final VoidCallback onBack;
  const SmsDetailsScreen({
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

  String _boolRow(String v) {
    if (v == '1') return 'Yes';
    if (v == '0') return 'No';
    return v.isEmpty ? '—' : v;
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
                    entry.displayAddress,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  iconSize: 18,
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
                  constraints: BoxConstraints.tight(const Size(36, 36)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 12),
              children: [
                _section(context, 'Message Body', [
                  (label: 'Body', value: entry.body.isEmpty ? '—' : entry.body),
                ]),
                _section(context, 'Summary', [
                  (label: 'ID', value: entry.id),
                  (label: 'Thread ID', value: entry.threadId.isEmpty ? '—' : entry.threadId),
                  (label: 'Type', value: entry.type.label),
                  (label: 'Address', value: entry.address.isEmpty ? '—' : entry.address),
                  (label: 'Person', value: entry.person.isEmpty ? '—' : entry.person),
                  (label: 'Read', value: _boolRow(entry.read)),
                  (label: 'Seen', value: _boolRow(entry.seen)),
                  (label: 'Date', value: formatMessageTime(entry.date)),
                  (label: 'Date (ms)', value: entry.date.millisecondsSinceEpoch.toString()),
                  (label: 'Date Sent', value: formatMessageTime(entry.dateSent)),
                  (label: 'Locked', value: _boolRow(entry.locked)),
                  (label: 'Restricted', value: _boolRow(entry.restricted)),
                ]),
                _section(context, 'Delivery', [
                  (label: 'Status', value: entry.status.isEmpty ? '—' : entry.status),
                  (label: 'Error Code', value: entry.errorCode.isEmpty ? '—' : entry.errorCode),
                  (label: 'Protocol', value: entry.protocol.isEmpty ? '—' : entry.protocol),
                  (label: 'Reply Path', value: _boolRow(entry.replyPathPresent)),
                  (label: 'Service Center', value: entry.serviceCenter.isEmpty ? '—' : entry.serviceCenter),
                  (label: 'TR ID', value: entry.trId.isEmpty ? '—' : entry.trId),
                  (label: 'Subscription ID', value: entry.subId.isEmpty ? '—' : entry.subId),
                  (label: 'Contains OTP', value: _boolRow(entry.containsOtp)),
                ]),
                _section(context, 'Misc', [
                  (label: 'Subject', value: entry.subject.isEmpty ? '—' : entry.subject),
                  (label: 'Creator', value: entry.creator.isEmpty ? '—' : entry.creator),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
