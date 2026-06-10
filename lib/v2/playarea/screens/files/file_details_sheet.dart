import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:porpita/services/commands/adb_exec_service.dart';
import 'file_explorer_model.dart';

class FileDetailsSheet extends StatefulWidget {
  final FileEntry entry;
  final String deviceId;

  const FileDetailsSheet({
    super.key,
    required this.entry,
    required this.deviceId,
  });

  @override
  State<FileDetailsSheet> createState() => _FileDetailsSheetState();
}

class _FileDetailsSheetState extends State<FileDetailsSheet> {
  String _statOutput = '';
  String _diskUsage = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final results = await Future.wait([
      AdbExecService.run(widget.deviceId, ['stat', widget.entry.fullPath]),
      widget.entry.isDirectory
          ? AdbExecService.run(widget.deviceId, ['du', '-sh', widget.entry.fullPath])
          : Future.value(''),
    ]);

    if (!mounted) return;
    setState(() {
      _statOutput = results[0];
      _diskUsage = results[1];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  widget.entry.isDirectory ? Icons.folder : Icons.description,
                  size: 20,
                  color: scheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.entry.name,
                    style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => Navigator.pop(context),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      _DetailRow(label: 'Path', value: widget.entry.fullPath, mono: true),
                      _DetailRow(label: 'Type', value: widget.entry.isDirectory ? 'Directory' : 'File'),
                      if (widget.entry.size != null)
                        _DetailRow(label: 'Size', value: widget.entry.displaySize),
                      if (widget.entry.modified != null)
                        _DetailRow(label: 'Modified', value: widget.entry.modified.toString()),
                      if (widget.entry.permissions.isNotEmpty)
                        _DetailRow(label: 'Permissions', value: widget.entry.permissions, mono: true),
                      if (widget.entry.owner.isNotEmpty)
                        _DetailRow(label: 'Owner', value: '${widget.entry.owner}:${widget.entry.group}'),
                      if (_diskUsage.isNotEmpty)
                        _DetailRow(label: 'Disk Usage', value: _diskUsage.trim()),
                      const SizedBox(height: 12),
                      Text('Stat Output', style: tt.labelMedium),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(
                          _statOutput,
                          style: tt.bodySmall?.copyWith(fontFamily: 'monospace'),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;

  const _DetailRow({
    required this.label,
    required this.value,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: mono ? 'monospace' : null,
                    ),
                  ),
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(Icons.copy, size: 12, color: scheme.onSurfaceVariant),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
