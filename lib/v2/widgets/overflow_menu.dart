import 'package:flutter/material.dart';

class OverflowMenuItem {
  final String value;
  final String label;
  final IconData? icon;
  const OverflowMenuItem({
    required this.value,
    required this.label,
    this.icon,
  });
}

class OverflowMenu extends StatelessWidget {
  final List<OverflowMenuItem> items;
  final ValueChanged<String> onSelected;
  final String? tooltip;

  const OverflowMenu({
    super.key,
    required this.items,
    required this.onSelected,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: tooltip ?? 'More',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      icon: const Icon(Icons.more_vert),
      iconSize: 20,
      padding: EdgeInsets.zero,
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final item in items)
          PopupMenuItem<String>(
            value: item.value,
            child: Row(
              children: [
                if (item.icon != null) ...[
                  Icon(item.icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(item.label),
              ],
            ),
          ),
      ],
    );
  }
}
