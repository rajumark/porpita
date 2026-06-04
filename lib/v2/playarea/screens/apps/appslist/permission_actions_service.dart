import 'package:flutter/material.dart';
import 'package:porpita/services/commands/adb_exec_service.dart';

class PermissionActionProgress {
  final int total;
  final int done;
  final String action;
  final List<String> errors;

  const PermissionActionProgress({
    required this.total,
    required this.done,
    required this.action,
    this.errors = const [],
  });
}

class PermissionActionsService {
  static Future<void> grantAll({
    required String deviceId,
    required String packageName,
    required List<String> permissions,
    required ValueNotifier<PermissionActionProgress> notifier,
  }) async {
    await _runAll(
      deviceId: deviceId,
      packageName: packageName,
      permissions: permissions,
      notifier: notifier,
      grant: true,
    );
  }

  static Future<void> revokeAll({
    required String deviceId,
    required String packageName,
    required List<String> permissions,
    required ValueNotifier<PermissionActionProgress> notifier,
  }) async {
    await _runAll(
      deviceId: deviceId,
      packageName: packageName,
      permissions: permissions,
      notifier: notifier,
      grant: false,
    );
  }

  static Future<void> _runAll({
    required String deviceId,
    required String packageName,
    required List<String> permissions,
    required ValueNotifier<PermissionActionProgress> notifier,
    required bool grant,
  }) async {
    for (int i = 0; i < permissions.length; i++) {
      try {
        if (grant) {
          await AdbExecService.run(deviceId, ['pm', 'grant', packageName, permissions[i]]);
        } else {
          await AdbExecService.run(deviceId, ['pm', 'revoke', packageName, permissions[i]]);
        }
      } catch (e) {
        final prev = notifier.value;
        notifier.value = PermissionActionProgress(
          total: prev.total,
          done: prev.done + 1,
          action: prev.action,
          errors: [...prev.errors, '${permissions[i]}: $e'],
        );
        continue;
      }
      final prev = notifier.value;
      notifier.value = PermissionActionProgress(
        total: prev.total,
        done: prev.done + 1,
        action: prev.action,
        errors: prev.errors,
      );
    }
  }
}

class PermissionActionProgressDialog extends StatelessWidget {
  final ValueNotifier<PermissionActionProgress> notifier;
  const PermissionActionProgressDialog({super.key, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PermissionActionProgress>(
      valueListenable: notifier,
      builder: (context, state, _) {
        return AlertDialog(
          title: Text('${state.action} permissions...'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(value: state.total > 0 ? state.done / state.total : 0),
              const SizedBox(height: 12),
              Text('${state.done} / ${state.total}', style: Theme.of(context).textTheme.bodySmall),
              if (state.errors.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('Errors:', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.error)),
                const SizedBox(height: 4),
                ...state.errors.take(5).map((e) => Text(e, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error))),
                if (state.errors.length > 5)
                  Text('...and ${state.errors.length - 5} more', style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        );
      },
    );
  }
}
