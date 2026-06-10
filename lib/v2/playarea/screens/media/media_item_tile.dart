import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'media_model.dart';
import 'file_categorizer.dart';
import 'file_shape_tile.dart';

class MediaListTile extends StatelessWidget {
  final MediaEntry entry;
  final BorderRadius borderRadius;
  final VoidCallback onTap;

  const MediaListTile({
    super.key,
    required this.entry,
    required this.borderRadius,
    required this.onTap,
  });

  String _formatDate(DateTime? d) {
    if (d == null) return '—';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dt = DateTime(d.year, d.month, d.day);
    if (dt == today) {
      return 'Today';
    }
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${monthNames[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final name = entry.displayName.isNotEmpty
        ? entry.displayName
        : (entry.path.isNotEmpty ? entry.path : 'Unnamed');
    final secondary = entry.path.isNotEmpty
        ? entry.path
        : (entry.bucketDisplayName.isNotEmpty ? entry.bucketDisplayName : '');

    return Material(
      color: scheme.surfaceContainer,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, top: 6, bottom: 6),
          child: Row(
            children: [
              FileShapeTile(
                extension: entry.extension,
                style: entry.style,
                size: 44,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: entry.style.background.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            entry.category.label,
                            style: TextStyle(
                              color: entry.style.background,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            secondary,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
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
                  Text(
                    entry.sizeDisplay,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(entry.dateAdded ?? entry.dateModified),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.outline,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: IconButton(
                  icon: const Icon(Icons.content_copy),
                  iconSize: 16,
                  color: scheme.onSurfaceVariant,
                  tooltip: 'Copy path',
                  onPressed: entry.path.isEmpty
                      ? null
                      : () {
                          Clipboard.setData(ClipboardData(text: entry.path));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Path copied'),
                              duration: Duration(seconds: 1),
                            ),
                          );
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

class MediaGridCard extends StatelessWidget {
  final MediaEntry entry;
  final VoidCallback onTap;

  const MediaGridCard({
    super.key,
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final name = entry.displayName.isNotEmpty
        ? entry.displayName
        : (entry.path.isNotEmpty ? FileCategorizer.getName(entry.path) : 'Unnamed');

    return Material(
      color: scheme.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: FileShapeTile(
                  extension: entry.extension,
                  style: entry.style,
                  size: 64,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: entry.style.background.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      entry.category.label,
                      style: TextStyle(
                        color: entry.style.background,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    entry.sizeDisplay,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
