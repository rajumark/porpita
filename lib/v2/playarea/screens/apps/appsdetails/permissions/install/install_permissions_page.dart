import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:porpita/services/device_manager.dart';
import 'install_permissions_model.dart';
import 'install_permissions_service.dart';

class InstallPermissionsPage extends StatefulWidget {
  final String packageName;
  const InstallPermissionsPage({super.key, required this.packageName});

  @override
  State<InstallPermissionsPage> createState() => _InstallPermissionsPageState();
}

class _InstallPermissionsPageState extends State<InstallPermissionsPage> with AutomaticKeepAliveClientMixin {
  List<InstallPermission> _permissions = [];
  bool _loading = true;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void didUpdateWidget(covariant InstallPermissionsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.packageName != widget.packageName) _fetch();
  }

  Future<void> _fetch() async {
    final device = context.read<DeviceManager>().selected;
    if (device == null) {
      setState(() { _loading = false; _error = 'No device connected'; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final list = await InstallPermissionsService.fetch(device.id, widget.packageName);
      if (!mounted) return;
      setState(() { _permissions = list; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) return const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)));
    if (_error != null) return Center(child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)));
    if (_permissions.isEmpty) return const Center(child: Text('No install permissions'));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _permissions.length,
      itemBuilder: (context, index) {
        final p = _permissions[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(p.name, style: Theme.of(context).textTheme.bodySmall),
              ),
              const SizedBox(width: 8),
              _grantedChip(context, p.granted),
            ],
          ),
        );
      },
    );
  }

  Widget _grantedChip(BuildContext context, bool? granted) {
    if (granted == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
        child: Text('null', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey)),
      );
    }
    final color = granted ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
      child: Text(granted ? 'granted' : 'denied', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color)),
    );
  }
}