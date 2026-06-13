import 'package:flutter/material.dart';
import 'apps_item_tile.dart';
import 'app_actions_service.dart';
import 'apps_list_service.dart';
import 'current_app/current_app_service.dart';

class AppsListContent extends StatelessWidget {
  final ForegroundApp? foregroundApp;
  final List<String> systemApps;
  final List<String> userApps;
  final AppFilter selectedFilter;
  final String searchQuery;
  final Set<String> pinnedApps;
  final void Function(String packageName) onAppSelected;
  final void Function(AppAction action, String packageName) onAppAction;
  final Map<String, String> iconPaths;

  const AppsListContent({
    super.key,
    required this.foregroundApp,
    required this.systemApps,
    required this.userApps,
    required this.selectedFilter,
    required this.searchQuery,
    required this.pinnedApps,
    required this.onAppSelected,
    required this.onAppAction,
    required this.iconPaths,
  });

  bool _matchesSearch(String package) {
    if (searchQuery.isEmpty) return true;
    return package.toLowerCase().contains(searchQuery);
  }

  BorderRadius _borderRadius(int index, int total) {
    if (total == 1) return BorderRadius.circular(12);
    if (index == 0) {
      return const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      );
    }
    if (index == total - 1) {
      return const BorderRadius.only(
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      );
    }
    return BorderRadius.circular(2);
  }

  @override
  Widget build(BuildContext context) {
    final showCurrentApp = foregroundApp != null;
    final showSystemSection = selectedFilter == AppFilter.all || selectedFilter == AppFilter.system;
    final showUserSection = selectedFilter == AppFilter.all || selectedFilter == AppFilter.user;

    final filteredSystem = systemApps.where(_matchesSearch).toList();
    final filteredUser = userApps.where(_matchesSearch).toList();
    final currentAppMatches = foregroundApp != null && _matchesSearch(foregroundApp!.packageName);

    final filteredPinned = pinnedApps
        .where((pkg) => _matchesSearch(pkg) && pkg != foregroundApp?.packageName)
        .toList();

    if (!showCurrentApp && !showSystemSection && !showUserSection) {
      return Center(
        child: Text('No apps found', style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    final hasAnyContent = (showCurrentApp && currentAppMatches) ||
        filteredPinned.isNotEmpty ||
        (showSystemSection && filteredSystem.isNotEmpty) ||
        (showUserSection && filteredUser.isNotEmpty);

    if (!hasAnyContent) {
      return Center(
        child: Text('No apps found', style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        if (showCurrentApp && currentAppMatches) ...[
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4, left: 4),
            child: Text(
              'Current Foreground App',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          AppItemTile(
            title: '${foregroundApp!.packageName} (${foregroundApp!.activityName.split('.').last})',
            borderRadius: BorderRadius.circular(12),
            onTap: () => onAppSelected(foregroundApp!.packageName),
            packageName: foregroundApp!.packageName,
            isPinned: pinnedApps.contains(foregroundApp!.packageName),
            onMenuItemSelected: (action) => onAppAction(action, foregroundApp!.packageName),
            iconPath: iconPaths[foregroundApp!.packageName],
          ),
          const SizedBox(height: 8),
        ],
        if (filteredPinned.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4, left: 4),
            child: Text(
              'Pinned Apps (${filteredPinned.length})',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ...filteredPinned.asMap().entries.map((e) => AppItemTile(
            title: e.value,
            borderRadius: _borderRadius(e.key, filteredPinned.length),
            onTap: () => onAppSelected(e.value),
            packageName: e.value,
            isPinned: true,
            onMenuItemSelected: (action) => onAppAction(action, e.value),
            iconPath: iconPaths[e.value],
          )),
          const SizedBox(height: 8),
        ],
        if (showSystemSection && filteredSystem.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4, left: 4),
            child: Text(
              'System Apps (${filteredSystem.length})',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ...filteredSystem.asMap().entries.map((e) => AppItemTile(
            title: e.value,
            borderRadius: _borderRadius(e.key, filteredSystem.length),
            onTap: () => onAppSelected(e.value),
            packageName: e.value,
            isPinned: pinnedApps.contains(e.value),
            onMenuItemSelected: (action) => onAppAction(action, e.value),
            iconPath: iconPaths[e.value],
          )),
          const SizedBox(height: 8),
        ],
        if (showUserSection && filteredUser.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4, left: 4),
            child: Text(
              'User Apps (${filteredUser.length})',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ...filteredUser.asMap().entries.map((e) => AppItemTile(
            title: e.value,
            borderRadius: _borderRadius(e.key, filteredUser.length),
            onTap: () => onAppSelected(e.value),
            packageName: e.value,
            isPinned: pinnedApps.contains(e.value),
            onMenuItemSelected: (action) => onAppAction(action, e.value),
            iconPath: iconPaths[e.value],
          )),
        ],
      ],
    );
  }
}