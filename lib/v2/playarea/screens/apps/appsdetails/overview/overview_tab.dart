import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:porpita/services/device_manager.dart';
import '../app_details_service.dart';

class OverviewTab extends StatefulWidget {
  final String packageName;
  const OverviewTab({super.key, required this.packageName});

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  AppDetailsInfo? _info;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void didUpdateWidget(covariant OverviewTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.packageName != widget.packageName) {
      _fetch();
    }
  }

  Future<void> _fetch() async {
    final device = context.read<DeviceManager>().selected;
    if (device == null) {
      setState(() {
        _loading = false;
        _error = 'No device connected';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final info = await AppDetailsService.fetch(device.id, widget.packageName);
      if (!mounted) return;
      setState(() {
        _info = info;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)));
    }
    if (_error != null) {
      return Center(child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)));
    }
    if (_info == null) {
      return const Center(child: Text('No data'));
    }
    return _buildInfo(context, _info!);
  }

  Widget _buildInfo(BuildContext context, AppDetailsInfo info) {
    final theme = Theme.of(context);
    final rows = <_Row>[
      _Row('Version Name', info.versionName),
      _Row('Version Code', info.versionCode),
      _Row('Min SDK', info.minSdk),
      _Row('Target SDK', info.targetSdk),
      _Row('App ID', info.appId),
      _Row('Code Path', info.codePath),
      _Row('Resource Path', info.resourcePath),
      _Row('CPU ABI', info.primaryCpuAbi),
      _Row('Flags', info.flags),
      _Row('Private Flags', info.privateFlags),
      _Row('Install Time', info.timeStamp),
      _Row('Last Update', info.lastUpdateTime),
      _Row('Installer', info.installerPackageName),
      _Row('Force Queryable', info.forceQueryable),
      _Row('Shared User', info.sharedUser),
      _Row('Signatures', info.signatures),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final row = rows[index];
        if (row.value.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 140,
                child: Text(row.label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ),
              Expanded(
                child: SelectableText(row.value, style: theme.textTheme.bodySmall),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Row {
  final String label;
  final String value;
  const _Row(this.label, this.value);
}