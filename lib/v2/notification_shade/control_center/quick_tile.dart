import 'package:flutter/material.dart';

enum QuickTileState {
  on,
  off,
  disabled,
  onDisabled,
}

class QuickTile {
  final String id;
  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final QuickTileState state;
  final VoidCallback? onTap;
  final ValueChanged<QuickTileState>? onStateChanged;

  const QuickTile({
    required this.id,
    required this.label,
    required this.icon,
    this.activeIcon,
    this.state = QuickTileState.off,
    this.onTap,
    this.onStateChanged,
  });

  QuickTile copyWith({
    String? id,
    String? label,
    IconData? icon,
    IconData? activeIcon,
    QuickTileState? state,
    VoidCallback? onTap,
    ValueChanged<QuickTileState>? onStateChanged,
  }) {
    return QuickTile(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      activeIcon: activeIcon ?? this.activeIcon,
      state: state ?? this.state,
      onTap: onTap ?? this.onTap,
      onStateChanged: onStateChanged ?? this.onStateChanged,
    );
  }

  bool get isEnabled => state == QuickTileState.on || state == QuickTileState.off;
  bool get isActive => state == QuickTileState.on || state == QuickTileState.onDisabled;
}

class QuickTileWidget extends StatelessWidget {
  final QuickTile tile;
  final VoidCallback? onTap;

  const QuickTileWidget({
    super.key,
    required this.tile,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final (backgroundColor, foregroundColor, iconColor, opacity) = _getColors(scheme);

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: tile.isEnabled ? (onTap ?? () {}) : null,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: opacity,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  tile.isActive ? (tile.activeIcon ?? tile.icon) : tile.icon,
                  size: 22,
                  color: iconColor,
                ),
                const SizedBox(height: 4),
                Text(
                  tile.label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: foregroundColor,
                        fontWeight: tile.isActive ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 10,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (tile.state == QuickTileState.disabled || tile.state == QuickTileState.onDisabled) ...[
                  const SizedBox(height: 2),
                  Icon(
                    Icons.block,
                    size: 8,
                    color: scheme.error,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  (Color, Color, Color, double) _getColors(ColorScheme scheme) {
    switch (tile.state) {
      case QuickTileState.on:
        return (
          scheme.primaryContainer.withValues(alpha: 0.6),
          scheme.onSurface,
          scheme.primary,
          1.0,
        );
      case QuickTileState.off:
        return (
          scheme.surfaceContainerHighest.withValues(alpha: 0.5),
          scheme.onSurfaceVariant,
          scheme.onSurfaceVariant,
          1.0,
        );
      case QuickTileState.disabled:
        return (
          scheme.surfaceContainerHighest.withValues(alpha: 0.3),
          scheme.onSurface.withValues(alpha: 0.38),
          scheme.onSurface.withValues(alpha: 0.38),
          0.5,
        );
      case QuickTileState.onDisabled:
        return (
          scheme.primaryContainer.withValues(alpha: 0.3),
          scheme.onSurface.withValues(alpha: 0.38),
          scheme.primary.withValues(alpha: 0.6),
          0.6,
        );
    }
  }
}