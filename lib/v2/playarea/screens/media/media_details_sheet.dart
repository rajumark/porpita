import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:porpita/services/commands/adb_exec_service.dart';
import 'file_categorizer.dart';
import 'file_shape_tile.dart';
import 'media_model.dart';

class MediaDetailsSheet extends StatelessWidget {
  final MediaEntry entry;
  final String deviceId;

  const MediaDetailsSheet({
    super.key,
    required this.entry,
    required this.deviceId,
  });

  Future<void> _pull(BuildContext context) async {
    if (entry.path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file path available')),
      );
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final result = await AdbExecService.run(deviceId, [
      'pull',
      entry.path,
      '.',
    ]);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          result.isEmpty ? 'Pull started' : result.split('\n').first,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openInApp(BuildContext context) async {
    if (entry.path.isEmpty) return;
    await AdbExecService.run(deviceId, [
      'am', 'start',
      '-W', '-a', 'android.intent.action.VIEW',
      '-d', 'file://${entry.path}',
      '-t', entry.mimeType.isNotEmpty ? entry.mimeType : '*/*',
    ]);
  }

  Widget _row(BuildContext context, String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              value.isEmpty ? '—' : value,
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

  Widget _section(BuildContext context, String title, List<({String label, String value})> rows) {
    if (rows.every((r) => r.value.isEmpty)) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                      Divider(
                        height: 1,
                        color: scheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                  ],
                ],
              ),
            ),
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

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}:${d.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final name = entry.displayName.isNotEmpty
        ? entry.displayName
        : (entry.path.isNotEmpty ? FileCategorizer.getName(entry.path) : 'File');

    return Drawer(
      backgroundColor: scheme.surfaceContainerLow,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              color: scheme.surfaceContainerLow,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    iconSize: 20,
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints.tight(const Size(32, 32)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'File details',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.download, size: 20),
                    tooltip: 'Pull to host',
                    onPressed: () => _pull(context),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints.tight(const Size(32, 32)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.open_in_new, size: 20),
                    tooltip: 'Open in app',
                    onPressed: () => _openInApp(context),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints.tight(const Size(32, 32)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        FileShapeTile(
                          extension: entry.extension,
                          style: entry.style,
                          size: 80,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SelectableText(
                                name,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: entry.style.background.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  entry.category.label,
                                  style: TextStyle(
                                    color: entry.style.background,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                entry.sizeDisplay,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _section(context, 'Identity', [
                    (label: 'ID', value: entry.id),
                    (label: 'Display name', value: entry.displayName),
                    (label: 'Title', value: entry.title),
                    (label: 'MIME type', value: entry.mimeType),
                    (label: 'Extension', value: entry.extension),
                    (label: 'Format', value: entry.format),
                    (label: 'Media type', value: entry.mediaType),
                    (label: 'Parent', value: entry.parent),
                  ]),
                  _section(context, 'Location', [
                    (label: 'Path', value: entry.path),
                    (label: 'Bucket', value: entry.bucketDisplayName),
                    (label: 'Relative', value: entry.relativePath),
                    (label: 'Volume', value: entry.volumeName),
                    (label: 'Owner pkg', value: entry.ownerPackageName),
                  ]),
                  _section(context, 'Media metadata', [
                    (label: 'Width', value: entry.width),
                    (label: 'Height', value: entry.height),
                    (label: 'Resolution', value: entry.resolution),
                    (label: 'Duration', value: entry.durationDisplay),
                    (label: 'Bitrate', value: entry.bitrate),
                    (label: 'Sample rate', value: entry.samplerate),
                    (label: 'Artist', value: entry.artist),
                    (label: 'Album', value: entry.album),
                    (label: 'Description', value: entry.description),
                  ]),
                  _section(context, 'Dates', [
                    (label: 'Added', value: _formatDate(entry.dateAdded)),
                    (label: 'Modified', value: _formatDate(entry.dateModified)),
                    (label: 'Taken', value: _formatDate(entry.dateTaken)),
                    (label: 'Expires', value: _formatDate(entry.dateExpires)),
                  ]),
                  _section(context, 'Flags', [
                    (label: 'Favorite', value: _boolRow(entry.isFavorite)),
                    (label: 'Trashed', value: _boolRow(entry.isTrashed)),
                    (label: 'Download', value: _boolRow(entry.isDownload)),
                    (label: 'Music', value: _boolRow(entry.isMusic)),
                    (label: 'Ringtone', value: _boolRow(entry.isRingtone)),
                    (label: 'Alarm', value: _boolRow(entry.isAlarm)),
                    (label: 'Notification', value: _boolRow(entry.isNotification)),
                    (label: 'Podcast', value: _boolRow(entry.isPodcast)),
                  ]),
                  _section(context, 'Origin', [
                    (label: 'Download URI', value: entry.downloadUri),
                    (label: 'Referer URI', value: entry.refererUri),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
