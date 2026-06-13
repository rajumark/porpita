import 'dart:io';
import 'package:flutter/material.dart';
import 'app_actions_service.dart';

class AppItemTile extends StatefulWidget {
  final String title;
  final Widget? leading;
  final BorderRadius borderRadius;
  final VoidCallback onTap;
  final String packageName;
  final ValueChanged<AppAction>? onMenuItemSelected;
  final bool isPinned;
  final String? iconPath;

  static const _mainActions = [
    AppAction.open,
    AppAction.forceStop,
    AppAction.restart,
    AppAction.clearData,
    AppAction.uninstall,
    AppAction.copy,
  ];

  static const _moreActions = [
    AppAction.appInfo,
    AppAction.playStore,
    AppAction.findOnline,
    AppAction.home,
    AppAction.enable,
    AppAction.disable,
    AppAction.grantAllPermissions,
    AppAction.revokeAllPermissions,
    AppAction.managePermissions,
    AppAction.downloadApks,
  ];

  const AppItemTile({
    super.key,
    required this.title,
    this.leading,
    required this.borderRadius,
    required this.onTap,
    required this.packageName,
    this.onMenuItemSelected,
    this.isPinned = false,
    this.iconPath,
  });

  @override
  State<AppItemTile> createState() => _AppItemTileState();
}

class _AppItemTileState extends State<AppItemTile> {
  final _menuKey = GlobalKey();

  void _showMoreMenu() {
    final box = _menuKey.currentContext?.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (box == null || overlay == null) return;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset.zero, ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        PopupMenuItem<String>(
          value: '__back__',
          child: Row(children: [
            Icon(Icons.arrow_back, size: 18),
            const SizedBox(width: 8),
            const Text('Back'),
          ]),
        ),
        const PopupMenuDivider(),
        ...AppItemTile._moreActions.map((action) => PopupMenuItem<String>(
          value: action.name,
          child: Text(action.label),
        )),
      ],
    ).then((value) {
      if (value != null && value != '__back__') {
        final action = AppAction.values.firstWhere((a) => a.name == value);
        widget.onMenuItemSelected?.call(action);
      }
    });
  }

  Widget _buildIcon() {
    if (widget.iconPath != null && widget.iconPath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(
          File(widget.iconPath!),
          width: 32,
          height: 32,
          fit: BoxFit.cover,
          errorBuilder: (_, e, _) => _buildDefaultIcon(),
        ),
      );
    }
    return _buildDefaultIcon();
  }

  Widget _buildDefaultIcon() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        Icons.android,
        size: 18,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainer,
      borderRadius: widget.borderRadius,
      child: InkWell(
        borderRadius: widget.borderRadius,
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8, top: 6, bottom: 6),
          child: Row(
            children: [
              if (widget.leading != null) ...[
                widget.leading!,
                const SizedBox(width: 10),
              ] else ...[
                _buildIcon(),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton<String>(
                key: _menuKey,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  if (value == '__more__') {
                    _showMoreMenu();
                  } else {
                    final action = AppAction.values.firstWhere((a) => a.name == value);
                    widget.onMenuItemSelected?.call(action);
                  }
                },
                itemBuilder: (_) => [
                  ...AppItemTile._mainActions.map((a) => PopupMenuItem<String>(
                    value: a.name,
                    child: Text(a.label),
                  )),
                  PopupMenuItem<String>(
                    value: widget.isPinned ? AppAction.unpin.name : AppAction.pin.name,
                    child: Row(children: [
                      Icon(widget.isPinned ? Icons.push_pin : Icons.push_pin_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(widget.isPinned ? 'Unpin it' : 'Pin it'),
                    ]),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: '__more__',
                    child: Row(children: [
                      Icon(Icons.more_horiz, size: 18),
                      SizedBox(width: 8),
                      Text('More'),
                    ]),
                  ),
                ],
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