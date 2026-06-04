import 'package:flutter/material.dart';
import 'app_files_service.dart';

class AppFileEntryTile extends StatelessWidget {
  final AppFileEntry entry;
  final VoidCallback? onDirectoryTap;

  const AppFileEntryTile({
    super.key,
    required this.entry,
    this.onDirectoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: entry.isDirectory ? onDirectoryTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              entry.isDirectory ? Icons.folder : Icons.insert_drive_file_outlined,
              size: 18,
              color: entry.isDirectory ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: entry.isDirectory ? FontWeight.w600 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${entry.permissions}  ${entry.owner}:${entry.group}  ${entry.size}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            if (entry.isDirectory)
              Icon(Icons.chevron_right, size: 16, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}