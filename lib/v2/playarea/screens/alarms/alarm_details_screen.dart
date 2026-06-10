import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:porpita/v2/widgets/rounded_container.dart';
import 'alarm_model.dart';

class AlarmDetailsScreen extends StatelessWidget {
  final AlarmEntry entry;
  final VoidCallback onBack;
  const AlarmDetailsScreen({super.key, required this.entry, required this.onBack});

  Widget _section(BuildContext context, String title, List<({String label, String value})> rows) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4, top: 4),
            child: Text(title, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
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
                    if (i < rows.length - 1) Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.4)),
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
            child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace', fontSize: 12)),
          ),
          if (value.isNotEmpty && value != '—')
            IconButton(
              icon: const Icon(Icons.copy, size: 14),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tight(const Size(24, 24)),
              visualDensity: VisualDensity.compact,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied'), duration: Duration(seconds: 1)));
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
                IconButton(icon: const Icon(Icons.arrow_back), iconSize: 24, onPressed: onBack, padding: EdgeInsets.zero, constraints: BoxConstraints.tight(const Size(36, 36))),
                Expanded(child: Text(entry.displayTag, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium)),
                if (entry.isAlarmClock)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                    child: Text('ALARM CLOCK', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 12),
              children: [
                _section(context, 'Summary', [
                  (label: 'Type', value: entry.alarmType.label),
                  (label: 'Tag', value: entry.displayTag),
                  (label: 'Package', value: entry.packageName),
                  (label: 'Origin', value: entry.origWhen),
                  (label: 'Wakeup', value: entry.alarmType.isWakeup ? 'Yes' : 'No'),
                  if (entry.isAlarmClock) ...[
                    (label: 'Trigger Time', value: entry.alarmClockTriggerTime.isEmpty ? '—' : entry.alarmClockTriggerTime),
                    (label: 'Show Intent', value: entry.alarmClockShowIntent.isEmpty ? '—' : entry.alarmClockShowIntent),
                  ],
                ]),
                _section(context, 'Timing', [
                  (label: 'When Elapsed', value: entry.whenElapsed.isEmpty ? '—' : entry.whenElapsed),
                  (label: 'Max When', value: entry.maxWhenElapsed.isEmpty ? '—' : entry.maxWhenElapsed),
                  (label: 'Window', value: entry.window.isEmpty ? '—' : entry.window),
                  (label: 'Repeat Interval', value: entry.repeatInterval.isEmpty ? '0' : entry.repeatInterval),
                  (label: 'Count', value: entry.count.isEmpty ? '0' : entry.count),
                ]),
                _section(context, 'Policy', [
                  (label: 'Exact Allow', value: entry.exactAllowReason.isEmpty ? '—' : entry.exactAllowReason),
                  (label: 'Flags', value: entry.flags.isEmpty ? '—' : entry.flags),
                  (label: 'Policy When', value: entry.policyWhenElapsed.isEmpty ? '—' : entry.policyWhenElapsed),
                ]),
                if (entry.operation.isNotEmpty || entry.listener.isNotEmpty)
                  _section(context, 'Target', [
                    (label: 'Operation', value: entry.operation.isEmpty ? '—' : entry.operation),
                    (label: 'Listener', value: entry.listener.isEmpty ? '—' : entry.listener),
                  ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}