import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'mms_model.dart';
import 'message_format.dart';
import 'package:porpita/v2/widgets/rounded_container.dart';

class MmsDetailsScreen extends StatelessWidget {
  final MmsEntry entry;
  final VoidCallback onBack;
  const MmsDetailsScreen({
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
                  tooltip: 'Copy subject',
                  onPressed: entry.sub.isEmpty
                      ? null
                      : () {
                          Clipboard.setData(ClipboardData(text: entry.sub));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Subject copied'),
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
                _section(context, 'Subject', [
                  (label: 'Subject', value: entry.sub.isEmpty ? '—' : entry.sub),
                  (label: 'Charset', value: entry.subCs.isEmpty ? '—' : entry.subCs),
                ]),
                _section(context, 'Summary', [
                  (label: 'ID', value: entry.id),
                  (label: 'Thread ID', value: entry.threadId.isEmpty ? '—' : entry.threadId),
                  (label: 'Message Box', value: entry.msgBoxLabel),
                  (label: 'M ID', value: entry.mId.isEmpty ? '—' : entry.mId),
                  (label: 'Read', value: _boolRow(entry.read)),
                  (label: 'Seen', value: _boolRow(entry.seen)),
                  (label: 'Date', value: formatMessageTime(entry.date)),
                  (label: 'Date (ms)', value: entry.date.millisecondsSinceEpoch.toString()),
                  (label: 'Date Sent', value: formatMessageTime(entry.dateSent)),
                  (label: 'Locked', value: _boolRow(entry.locked)),
                  (label: 'Text Only', value: _boolRow(entry.textOnly)),
                ]),
                _section(context, 'Content', [
                  (label: 'Type', value: entry.contentType),
                  (label: 'Location', value: entry.ctL.isEmpty ? '—' : entry.ctL),
                  (label: 'Class', value: entry.ctCls.isEmpty ? '—' : entry.ctCls),
                  (label: 'MIME Type', value: entry.mType.isEmpty ? '—' : entry.mType),
                  (label: 'MIME Vendor', value: entry.mTypeVnd.isEmpty ? '—' : entry.mTypeVnd),
                  (label: 'Size', value: entry.sizeDisplay),
                  (label: 'Size (bytes)', value: entry.mSize.isEmpty ? '—' : entry.mSize),
                  (label: 'Message Class', value: entry.mCls.isEmpty ? '—' : entry.mCls),
                  (label: 'Version', value: entry.v.isEmpty ? '—' : entry.v),
                ]),
                _section(context, 'Delivery', [
                  (label: 'Status', value: entry.st.isEmpty ? '—' : entry.st),
                  (label: 'Read Status', value: entry.readStatus.isEmpty ? '—' : entry.readStatus),
                  (label: 'Response Status', value: entry.respSt.isEmpty ? '—' : entry.respSt),
                  (label: 'Response Text', value: entry.respTxt.isEmpty ? '—' : entry.respTxt),
                  (label: 'Retrieve Status', value: entry.retrSt.isEmpty ? '—' : entry.retrSt),
                  (label: 'Retrieve Text', value: entry.retrTxt.isEmpty ? '—' : entry.retrTxt),
                  (label: 'Retrieve Text CS', value: entry.retrTxtCs.isEmpty ? '—' : entry.retrTxtCs),
                  (label: 'Delivery Time', value: entry.dTm.isEmpty ? '—' : entry.dTm),
                  (label: 'Delivery Report', value: _boolRow(entry.dRpt)),
                  (label: 'Read Report', value: _boolRow(entry.rr)),
                  (label: 'Report Allowed', value: _boolRow(entry.rptA)),
                  (label: 'Priority', value: entry.pri.isEmpty ? '—' : entry.pri),
                  (label: 'Expiry', value: entry.exp.isEmpty ? '—' : entry.exp),
                  (label: 'TR ID', value: entry.trId.isEmpty ? '—' : entry.trId),
                  (label: 'Subscription ID', value: entry.subId.isEmpty ? '—' : entry.subId),
                ]),
                _section(context, 'Misc', [
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
