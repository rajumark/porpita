import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PathBreadcrumbs extends StatelessWidget {
  final String path;
  final ValueChanged<String> onPathTap;
  final VoidCallback onBack;

  const PathBreadcrumbs({
    super.key,
    required this.path,
    required this.onPathTap,
    required this.onBack,
  });

  List<String> _segments() {
    if (path == '/') return ['/'];
    final parts = path.split('/').where((s) => s.isNotEmpty).toList();
    return ['/'] + parts;
  }

  String _buildPathUpTo(int index, List<String> segments) {
    if (index == 0) return '/';
    return '/${segments.sublist(1, index + 1).join('/')}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final segments = _segments();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 18),
            tooltip: 'Go back',
            onPressed: onBack,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tight(const Size(28, 28)),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () => _showPathDialog(context),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < segments.length; i++) ...[
                        if (i > 0)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Icon(
                              Icons.chevron_right,
                              size: 14,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        _BreadcrumbChip(
                          label: segments[i],
                          isLast: i == segments.length - 1,
                          onTap: () => onPathTap(_buildPathUpTo(i, segments)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Tooltip(
              message: 'Copy path',
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: path));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Path copied'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.copy,
                    size: 14,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPathDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Current Path'),
        content: SelectableText(
          path,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: path));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Path copied'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _BreadcrumbChip extends StatelessWidget {
  final String label;
  final bool isLast;
  final VoidCallback onTap;

  const _BreadcrumbChip({
    required this.label,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
            color: isLast ? scheme.primary : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
