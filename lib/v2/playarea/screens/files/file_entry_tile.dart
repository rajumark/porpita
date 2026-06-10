import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'file_categorizer.dart';
import 'file_explorer_model.dart';

typedef FileEntryActionCallback = void Function(FileEntry entry, String action);

List<PopupMenuEntry<String>> _buildContextMenuItems(FileEntry entry) {
  return [
    if (entry.isDirectory)
      const PopupMenuItem(value: 'open', child: ListTile(leading: Icon(Icons.folder_open, size: 18), title: Text('Open'), dense: true))
    else
      const PopupMenuItem(value: 'details', child: ListTile(leading: Icon(Icons.info_outline, size: 18), title: Text('Properties'), dense: true)),
    const PopupMenuItem(value: 'copy_path', child: ListTile(leading: Icon(Icons.content_copy, size: 18), title: Text('Copy path'), dense: true)),
    const PopupMenuDivider(),
    const PopupMenuItem(value: 'pull', child: ListTile(leading: Icon(Icons.download, size: 18), title: Text('Download to PC'), dense: true)),
    const PopupMenuItem(value: 'copy', child: ListTile(leading: Icon(Icons.content_copy_outlined, size: 18), title: Text('Copy to...'), dense: true)),
    const PopupMenuItem(value: 'move', child: ListTile(leading: Icon(Icons.drive_file_move_outline, size: 18), title: Text('Move to...'), dense: true)),
    const PopupMenuItem(value: 'rename', child: ListTile(leading: Icon(Icons.drive_file_rename_outline, size: 18), title: Text('Rename'), dense: true)),
    const PopupMenuDivider(),
    PopupMenuItem(
      value: 'delete',
      child: ListTile(
        leading: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade400),
        title: Text('Delete', style: TextStyle(color: Colors.red.shade400)),
        dense: true,
      ),
    ),
  ];
}

void _showContextMenu(BuildContext context, Offset position, FileEntry entry, FileEntryActionCallback? onAction) {
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  final relPos = RelativeRect.fromRect(
    Rect.fromPoints(position, position),
    Offset.zero & overlay.size,
  );
  showMenu<String>(
    context: context,
    position: relPos,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    items: _buildContextMenuItems(entry),
  ).then((v) {
    if (v != null) onAction?.call(entry, v);
  });
}

class FileIcon extends StatelessWidget {
  final bool isDirectory;
  final String extension;
  final FileCategory category;
  final double size;

  const FileIcon({
    super.key,
    required this.isDirectory,
    required this.extension,
    required this.category,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final style = FileCategorizer.styleFor(isDirectory ? FileCategory.folder : category);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: style.background.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      child: Center(
        child: Icon(
          isDirectory ? Icons.folder_rounded : category.icon,
          size: size * 0.5,
          color: style.background,
        ),
      ),
    );
  }
}

class FileEntryListTile extends StatelessWidget {
  final FileEntry entry;
  final BorderRadius borderRadius;
  final VoidCallback onTap;
  final FileEntryActionCallback? onAction;

  const FileEntryListTile({
    super.key,
    required this.entry,
    required this.borderRadius,
    required this.onTap,
    this.onAction,
  });

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${monthNames[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ext = entry.isDirectory ? '' : entry.extension;
    final category = entry.isDirectory ? FileCategory.folder : FileCategorizer.categoryFromExt(ext);
    final style = FileCategorizer.styleFor(category);

    return Material(
      color: scheme.surfaceContainer,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        onSecondaryTapDown: onAction != null
            ? (d) => _showContextMenu(context, d.globalPosition, entry, onAction)
            : null,
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, top: 6, bottom: 6),
          child: Row(
            children: [
              FileIcon(isDirectory: entry.isDirectory, extension: ext, category: category, size: 44),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: entry.isDirectory ? FontWeight.w600 : FontWeight.normal,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: style.background.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            entry.isDirectory ? 'Folder' : category.label,
                            style: TextStyle(color: style.background, fontSize: 9, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            entry.permissions.isNotEmpty ? '${entry.permissions}  ${entry.owner}' : '',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant, fontFamily: 'monospace', fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!entry.isDirectory)
                    Text(entry.displaySize, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                  if (entry.modified != null)
                    Text(_formatDate(entry.modified), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.outline, fontSize: 10)),
                ],
              ),
              const SizedBox(width: 2),
              if (onAction != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: IconButton(
                    icon: const Icon(Icons.more_vert),
                    iconSize: 16,
                    color: scheme.onSurfaceVariant,
                    tooltip: 'More actions',
                    onPressed: () {
                      final box = context.findRenderObject() as RenderBox;
                      _showContextMenu(context, box.localToGlobal(Offset.zero) + Offset(box.size.width, box.size.height), entry, onAction);
                    },
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints.tight(const Size(28, 32)),
                  ),
                ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: IconButton(
                  icon: const Icon(Icons.content_copy),
                  iconSize: 16,
                  color: scheme.onSurfaceVariant,
                  tooltip: 'Copy path',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: entry.fullPath));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Path copied'), duration: Duration(seconds: 1)));
                  },
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tight(const Size(28, 32)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FileEntryGridCard extends StatelessWidget {
  final FileEntry entry;
  final VoidCallback onTap;
  final FileEntryActionCallback? onAction;

  const FileEntryGridCard({super.key, required this.entry, required this.onTap, this.onAction});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ext = entry.isDirectory ? '' : entry.extension;
    final category = entry.isDirectory ? FileCategory.folder : FileCategorizer.categoryFromExt(ext);
    final style = FileCategorizer.styleFor(category);

    return Material(
      color: scheme.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        onSecondaryTapDown: onAction != null
            ? (d) => _showContextMenu(context, d.globalPosition, entry, onAction)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onAction != null)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: IconButton(
                        icon: const Icon(Icons.more_vert),
                        iconSize: 14,
                        color: scheme.onSurfaceVariant,
                        tooltip: 'More actions',
                        onPressed: () {
                          final box = context.findRenderObject() as RenderBox;
                          _showContextMenu(context, box.localToGlobal(Offset.zero), entry, onAction);
                        },
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints.tight(const Size(20, 20)),
                      ),
                    ),
                ],
              ),
              Center(child: FileIcon(isDirectory: entry.isDirectory, extension: ext, category: category, size: 64)),
              const SizedBox(height: 8),
              Text(
                entry.name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: entry.isDirectory ? FontWeight.w600 : FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: style.background.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      entry.isDirectory ? 'Folder' : category.label,
                      style: TextStyle(color: style.background, fontSize: 8, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Spacer(),
                  if (!entry.isDirectory)
                    Text(entry.displaySize, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant, fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
