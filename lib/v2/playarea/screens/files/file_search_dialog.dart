import 'package:flutter/material.dart';
import 'file_explorer_model.dart';

class FileSearchDialog extends StatefulWidget {
  final String currentPath;
  final ValueChanged<SearchFilter> onSearch;

  const FileSearchDialog({
    super.key,
    required this.currentPath,
    required this.onSearch,
  });

  @override
  State<FileSearchDialog> createState() => _FileSearchDialogState();
}

class _FileSearchDialogState extends State<FileSearchDialog> {
  final _queryController = TextEditingController();
  bool _filesOnly = false;
  bool _foldersOnly = false;
  bool _caseSensitive = false;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _submit() {
    final filter = SearchFilter(
      query: _queryController.text.trim(),
      filesOnly: _filesOnly,
      foldersOnly: _foldersOnly,
      caseSensitive: _caseSensitive,
    );
    if (filter.query.isEmpty && !filter.filesOnly && !filter.foldersOnly) return;
    widget.onSearch(filter);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.search, size: 20, color: scheme.primary),
          const SizedBox(width: 8),
          const Text('Search Files'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Searching in: ${widget.currentPath}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _queryController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'File name pattern (e.g. *.apk, test.txt)',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            Text(
              'Filter type',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Files only'),
                  selected: _filesOnly,
                  onSelected: (v) => setState(() {
                    _filesOnly = v;
                    if (v) _foldersOnly = false;
                  }),
                ),
                FilterChip(
                  label: const Text('Folders only'),
                  selected: _foldersOnly,
                  onSelected: (v) => setState(() {
                    _foldersOnly = v;
                    if (v) _filesOnly = false;
                  }),
                ),
                FilterChip(
                  label: const Text('Case sensitive'),
                  selected: _caseSensitive,
                  onSelected: (v) => setState(() => _caseSensitive = v),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Search'),
        ),
      ],
    );
  }
}
