import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:porpita/services/device_manager.dart';
import 'package:porpita/v2/widgets/search_view.dart';
import '../permission_row.dart';
import '../permissions_menu_service.dart';
import 'runtime_permissions_model.dart';
import 'runtime_permissions_service.dart';

class RuntimePermissionsPage extends StatefulWidget {
  final String packageName;
  final VoidCallback? onRefresh;
  const RuntimePermissionsPage({super.key, required this.packageName, this.onRefresh});

  @override
  State<RuntimePermissionsPage> createState() => RuntimePermissionsPageState();
}

class RuntimePermissionsPageState extends State<RuntimePermissionsPage> with AutomaticKeepAliveClientMixin {
  List<RuntimePermission> _permissions = [];
  bool _loading = true;
  String? _error;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
    fetch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant RuntimePermissionsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.packageName != widget.packageName) fetch();
  }

  Future<void> fetch() async {
    final device = context.read<DeviceManager>().selected;
    if (device == null) {
      setState(() { _loading = false; _error = 'No device connected'; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final list = await RuntimePermissionsService.fetch(device.id, widget.packageName);
      if (!mounted) return;
      setState(() { _permissions = list; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _togglePermission(RuntimePermission perm, bool grant) async {
    final device = context.read<DeviceManager>().selected;
    if (device == null) return;
    setState(() {
      final idx = _permissions.indexWhere((p) => p.name == perm.name);
      if (idx >= 0) {
        _permissions[idx] = RuntimePermission(name: perm.name, granted: grant, flags: perm.flags);
      }
    });
    try {
      if (grant) {
        await RuntimePermissionsService.grant(device.id, widget.packageName, perm.name);
      } else {
        await RuntimePermissionsService.revoke(device.id, widget.packageName, perm.name);
      }
    } catch (_) {}
  }

  Future<void> _openAppInfo() async {
    final device = context.read<DeviceManager>().selected;
    if (device == null) return;
    await PermissionMenuService.openAppInfo(device.id, widget.packageName);
  }

  Future<void> _grantOrRevokeAll(bool grant) async {
    final device = context.read<DeviceManager>().selected;
    if (device == null) return;

    final filtered = _permissions.toList();
    if (filtered.isEmpty) return;

    final progressNotifier = ValueNotifier<_ProgressState>(_ProgressState(total: filtered.length, done: 0, action: grant ? 'Granting' : 'Revoking'));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ProgressDialogProgress(notifier: progressNotifier),
    );

    for (int i = 0; i < filtered.length; i++) {
      try {
        if (grant) {
          await RuntimePermissionsService.grant(device.id, widget.packageName, filtered[i].name);
        } else {
          await RuntimePermissionsService.revoke(device.id, widget.packageName, filtered[i].name);
        }
      } catch (e) {
        final prev = progressNotifier.value;
        progressNotifier.value = _ProgressState(
          total: prev.total,
          done: prev.done + 1,
          action: prev.action,
          errors: [...prev.errors, '${filtered[i].name}: $e'],
        );
        continue;
      }
      final prev = progressNotifier.value;
      progressNotifier.value = _ProgressState(
        total: prev.total,
        done: prev.done + 1,
        action: prev.action,
        errors: prev.errors,
      );
    }

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      await fetch();
    }
  }

  List<RuntimePermission> get _filtered {
    var list = _permissions;
    if (_query.isNotEmpty) list = list.where((p) => p.name.toLowerCase().contains(_query)).toList();
    list = list.where((p) => p.name.contains('.')).toList();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) return const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)));
    if (_error != null) return Center(child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)));
    if (_permissions.isEmpty) return const Center(child: Text('No runtime permissions'));

    final filtered = _filtered;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SearchView(controller: _searchController, hintText: 'Search runtime permissions...'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _grantOrRevokeAll(true),
                icon: const Icon(Icons.check_circle_outline, size: 16),
                label: const Text('Grant All'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _grantOrRevokeAll(false),
                icon: const Icon(Icons.cancel_outlined, size: 16),
                label: const Text('Revoke All'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _openAppInfo,
                icon: const Icon(Icons.info_outline, size: 16),
                label: const Text('App Info'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final p = filtered[index];
              return PermissionRow(
                name: p.name,
                trailing: Switch(
                  value: p.granted == true,
                  onChanged: p.granted == null ? null : (v) => _togglePermission(p, v),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProgressState {
  final int total;
  final int done;
  final String action;
  final List<String> errors;

  const _ProgressState({required this.total, required this.done, required this.action, this.errors = const []});
}

class _ProgressDialogProgress extends StatelessWidget {
  final ValueNotifier<_ProgressState> notifier;
  const _ProgressDialogProgress({required this.notifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_ProgressState>(
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