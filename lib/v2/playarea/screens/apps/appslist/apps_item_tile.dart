import 'package:flutter/material.dart';
import 'app_actions_service.dart';

class AppItemTile extends StatelessWidget {
  final String title;
  final Widget? leading;
  final BorderRadius borderRadius;
  final VoidCallback onTap;
  final String packageName;
  final ValueChanged<AppAction>? onMenuItemSelected;

  const AppItemTile({
    super.key,
    required this.title,
    this.leading,
    required this.borderRadius,
    required this.onTap,
    required this.packageName,
    this.onMenuItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainer,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8, top: 6, bottom: 6),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton<AppAction>(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (action) => onMenuItemSelected?.call(action),
                itemBuilder: (context) {
                  final items = <PopupMenuEntry<AppAction>>[];
                  for (final action in AppActionsService.menuItems) {
                    items.add(PopupMenuItem<AppAction>(
                      value: action,
                      child: Text(action.label),
                    ));
                    if (action == AppAction.copy) {
                      items.add(const PopupMenuDivider());
                    }
                  }
                  return items;
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: IconButton(
                    icon: const Icon(Icons.more_vert),
                    iconSize: 20,
                    onPressed: null,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints.tight(const Size(32, 32)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
