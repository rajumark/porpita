import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:porpita/services/device_manager.dart';
import 'package:porpita/v2/playarea/screens/apps/appsdetails/permissions/runtime/runtime_permissions_service.dart';
import 'app_actions_service.dart';
import 'permission_actions_service.dart';
import '../../../../topbar/porpita_preferences/screens/alert/alert_screen.dart';

class AppsActionHandler {
  static Future<void> handleAppAction({
    required BuildContext context,
    required AppAction action,
    required String packageName,
    required void Function(String packageName, {int tabIndex}) onAppSelected,
    required VoidCallback onDataRefresh,
  }) async {
    if (action == AppAction.grantAllPermissions || action == AppAction.revokeAllPermissions) {
      await handleGrantOrRevokeAll(
        context: context,
        packageName: packageName,
        action: action,
      );
      return;
    }
    if (action == AppAction.managePermissions) {
      onAppSelected(packageName, tabIndex: 1);
      return;
    }
    if (action == AppAction.downloadApks) {
      onAppSelected(packageName, tabIndex: 13);
      return;
    }
    final device = context.read<DeviceManager>().selected;
    if (device == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No device connected')),
      );
      return;
    }

    if (action == AppAction.uninstall || action == AppAction.clearData) {
      final confirmed = await _confirmAction(context, action, packageName);
      if (confirmed != true) return;
    }

    AppActionsService.run(device.id, action, packageName).then((_) {
      if (!context.mounted) return;
      final msg = '${action.label}: $packageName';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
      );
      if (action == AppAction.uninstall || action == AppAction.enable || action == AppAction.disable || action == AppAction.clearData) {
        onDataRefresh();
      }
    });
  }

  static Future<bool?> _confirmAction(BuildContext context, AppAction action, String packageName) async {
    final prefs = await SharedPreferences.getInstance();
    final key = action == AppAction.uninstall ? AlertScreen.keyUninstall : AlertScreen.keyClearData;
    final shouldConfirm = prefs.getBool(key) ?? true;
    if (!shouldConfirm) return true;

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(action.label),
        content: Text('Are you sure you want to ${action.label.toLowerCase()} $packageName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  static Future<void> handleGrantOrRevokeAll({
    required BuildContext context,
    required String packageName,
    required AppAction action,
  }) async {
    final device = context.read<DeviceManager>().selected;
    if (device == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No device connected')),
      );
      return;
    }

    List<String> permissionNames;
    try {
      final list = await RuntimePermissionsService.fetch(device.id, packageName);
      permissionNames = list.map((p) => p.name).toList();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch permissions: $e')),
      );
      return;
    }

    if (permissionNames.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No runtime permissions found')),
      );
      return;
    }

    final isGrant = action == AppAction.grantAllPermissions;
    final progressNotifier = ValueNotifier(PermissionActionProgress(
      total: permissionNames.length,
      done: 0,
      action: isGrant ? 'Granting' : 'Revoking',
    ));

    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PermissionActionProgressDialog(notifier: progressNotifier),
    );

    if (isGrant) {
      await PermissionActionsService.grantAll(
        deviceId: device.id,
        packageName: packageName,
        permissions: permissionNames,
        notifier: progressNotifier,
      );
    } else {
      await PermissionActionsService.revokeAll(
        deviceId: device.id,
        packageName: packageName,
        permissions: permissionNames,
        notifier: progressNotifier,
      );
    }

    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${action.label}: $packageName'), duration: const Duration(seconds: 1)),
    );
  }
}