import 'package:flutter/material.dart';

import 'settings_intents_data.dart';

class SettingSectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;

  const SettingSectionHeader({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Row(
          children: [
            Icon(icon, size: 16, color: cs.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: tt.labelLarge?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: tt.labelSmall?.copyWith(color: cs.onPrimaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingIntentChipGrid extends StatelessWidget {
  final List<SettingIntent> items;
  final Set<String> pinnedIds;
  final void Function(SettingIntent) onTap;
  final void Function(SettingIntent) onPinToggle;

  const SettingIntentChipGrid({
    super.key,
    required this.items,
    required this.pinnedIds,
    required this.onTap,
    required this.onPinToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      sliver: SliverToBoxAdapter(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            return SettingIntentChip(
              item: item,
              isPinned: pinnedIds.contains(item.id),
              onTap: () => onTap(item),
              onPinToggle: () => onPinToggle(item),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class SettingIntentChip extends StatefulWidget {
  final SettingIntent item;
  final bool isPinned;
  final VoidCallback onTap;
  final VoidCallback onPinToggle;

  const SettingIntentChip({
    super.key,
    required this.item,
    required this.isPinned,
    required this.onTap,
    required this.onPinToggle,
  });

  @override
  State<SettingIntentChip> createState() => _SettingIntentChipState();
}

class _SettingIntentChipState extends State<SettingIntentChip> {
  bool _hovered = false;
  bool _pressed = false;

  void _showContextMenu(BuildContext context, Offset offset) {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        offset & const Size(4, 4),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          onTap: widget.onPinToggle,
          child: Row(
            children: [
              Icon(
                widget.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(widget.isPinned ? 'Unpin' : 'Pin'),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color bg;
    if (_pressed) {
      bg = cs.primaryContainer;
    } else if (_hovered) {
      bg = cs.surfaceContainerHigh;
    } else if (widget.isPinned) {
      bg = cs.secondaryContainer.withValues(alpha: 0.5);
    } else {
      bg = cs.surfaceContainerLow;
    }

    final border = widget.isPinned
        ? BorderSide(color: cs.secondary, width: 1.2)
        : BorderSide(color: cs.outlineVariant, width: 1);

    return GestureDetector(
      onTap: widget.onTap,
      onSecondaryTapUp: (d) => _showContextMenu(context, d.globalPosition),
      onLongPressStart: (d) => _showContextMenu(context, d.globalPosition),
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.fromBorderSide(border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isPinned) ...[
                Icon(Icons.push_pin, size: 12, color: cs.secondary),
                const SizedBox(width: 4),
              ],
              Text(
                widget.item.text,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurface,
                      fontWeight: widget.isPinned ? FontWeight.w600 : FontWeight.normal,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingEmptyState extends StatelessWidget {
  const SettingEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'No matching intents',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}