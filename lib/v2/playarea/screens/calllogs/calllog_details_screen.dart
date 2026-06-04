import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:porpita/services/device_manager.dart';
import 'package:porpita/v2/widgets/rounded_container.dart';
import 'call_log_model.dart';
import 'call_log_format.dart';
import 'calllogs_service.dart';

class CallLogDetailsScreen extends StatelessWidget {
  final CallLogEntry entry;
  final VoidCallback onBack;
  const CallLogDetailsScreen({
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
          if (value.isNotEmpty && value != 'NULL')
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

  Future<void> _call(BuildContext context) async {
    final device = context.read<DeviceManager>().selected;
    final messenger = ScaffoldMessenger.of(context);
    if (device == null) {
      messenger.showSnackBar(const SnackBar(content: Text('No device connected')));
      return;
    }
    final number = entry.displayNumber;
    if (number.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('No number available')));
      return;
    }
    try {
      await CallLogsService.callNumber(device.id, number);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Calling $number…'),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Failed to call: $e')));
    }
  }

  String _boolRow(String v) {
    if (v == '1') return 'Yes';
    if (v == '0') return 'No';
    return v.isEmpty ? '—' : v;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

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
                    entry.displayName,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.call),
                  iconSize: 20,
                  color: scheme.primary,
                  tooltip: 'Call',
                  onPressed: entry.displayNumber.isEmpty ? null : () => _call(context),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tight(const Size(36, 36)),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  iconSize: 18,
                  tooltip: 'Copy number',
                  onPressed: entry.displayNumber.isEmpty
                      ? null
                      : () {
                          Clipboard.setData(ClipboardData(text: entry.displayNumber));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Number copied'),
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
                  (label: 'Name', value: entry.name.isEmpty ? '—' : entry.name),
                  (label: 'Number', value: entry.number.isEmpty ? '—' : entry.number),
                  (label: 'Formatted', value: entry.formattedNumber.isEmpty ? '—' : entry.formattedNumber),
                  (label: 'Normalized', value: entry.normalizedNumber.isEmpty ? '—' : entry.normalizedNumber),
                  (label: 'Type', value: entry.type.label),
                  (label: 'Date', value: formatCallLogTime(entry.date)),
                  (label: 'Date (ms)', value: entry.date.millisecondsSinceEpoch.toString()),
                  (label: 'Duration', value: formatCallDuration(entry.duration)),
                  (label: 'Country ISO', value: entry.countryIso.isEmpty ? '—' : entry.countryIso),
                  (label: 'Location', value: entry.geoLocation.isEmpty ? '—' : entry.geoLocation),
                ]),
                _section(context, 'Routing', [
                  (label: 'ID', value: entry.id),
                  (label: 'Presentation', value: entry.presentation.isEmpty ? '—' : entry.presentation),
                  (label: 'Subscription', value: entry.subscriptionComponentName.isEmpty ? '—' : entry.subscriptionComponentName),
                  (label: 'Subscription ID', value: entry.subscriptionId.isEmpty ? '—' : entry.subscriptionId),
                  (label: 'Phone Account', value: entry.phoneAccountAddress.isEmpty ? '—' : entry.phoneAccountAddress),
                  (label: 'Phone Hidden', value: _boolRow(entry.phoneAccountHidden)),
                  (label: 'Via Number', value: entry.viaNumber.isEmpty ? '—' : entry.viaNumber),
                  (label: 'Add For All Users', value: _boolRow(entry.addForAllUsers)),
                ]),
                _section(context, 'Contact', [
                  (label: 'Number Type', value: entry.numberType.isEmpty ? '—' : entry.numberType),
                  (label: 'Number Label', value: entry.numberLabel.isEmpty ? '—' : entry.numberLabel),
                  (label: 'Person', value: '—'),
                  (label: 'Photo URI', value: entry.photoUri.isEmpty ? '—' : entry.photoUri),
                  (label: 'Composer Photo', value: entry.composerPhotoUri.isEmpty ? '—' : entry.composerPhotoUri),
                  (label: 'Lookup URI', value: entry.lookupUri.isEmpty ? '—' : entry.lookupUri),
                  (label: 'Matched Number', value: entry.matchedNumber.isEmpty ? '—' : entry.matchedNumber),
                  (label: 'Preferred Name', value: entry.preferredDisplayName.isEmpty ? '—' : entry.preferredDisplayName),
                  (label: 'Asserted Name', value: entry.assertedDisplayName.isEmpty ? '—' : entry.assertedDisplayName),
                  (label: 'Post Dial Digits', value: entry.postDialDigits.isEmpty ? '—' : entry.postDialDigits),
                ]),
                _section(context, 'Status', [
                  (label: 'New', value: _boolRow(entry.new_)),
                  (label: 'Read', value: entry.isRead.isEmpty ? '—' : _boolRow(entry.isRead)),
                  (label: 'Seen', value: _boolRow(entry.isRead)),
                  (label: 'Business Call', value: _boolRow(entry.isBusinessCall)),
                  (label: 'Block Reason', value: entry.blockReason.isEmpty ? '—' : entry.blockReason),
                  (label: 'Missed Reason', value: entry.missedReason.isEmpty ? '—' : entry.missedReason),
                  (label: 'Priority', value: entry.priority.isEmpty ? '—' : entry.priority),
                  (label: 'Features', value: entry.features.isEmpty ? '—' : entry.features),
                ]),
                _section(context, 'Screening', [
                  (label: 'Screening App', value: entry.callScreeningAppName.isEmpty ? '—' : entry.callScreeningAppName),
                  (label: 'Screening Comp.', value: entry.callScreeningComponentName.isEmpty ? '—' : entry.callScreeningComponentName),
                  (label: 'Transcription', value: entry.transcription.isEmpty ? '—' : entry.transcription),
                  (label: 'Transcription St.', value: entry.transcriptionState.isEmpty ? '—' : entry.transcriptionState),
                ]),
                _section(context, 'Misc', [
                  (label: 'UUID', value: entry.uuid.isEmpty ? '—' : entry.uuid),
                  (label: 'Subject', value: entry.subject.isEmpty ? '—' : entry.subject),
                  (label: 'Location', value: entry.location.isEmpty ? '—' : entry.location),
                  (label: 'Data Usage', value: entry.dataUsage.isEmpty ? '—' : entry.dataUsage),
                  (label: 'Voicemail URI', value: entry.voicemailUri.isEmpty ? '—' : entry.voicemailUri),
                  (label: 'Photo ID', value: entry.photoId.isEmpty ? '—' : entry.photoId),
                  (label: 'Last Modified', value: entry.lastModified.isEmpty ? '—' : entry.lastModified),
                  (label: 'Migration Pend.', value: _boolRow(entry.isCallLogPhoneAccountMigrationPending)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
