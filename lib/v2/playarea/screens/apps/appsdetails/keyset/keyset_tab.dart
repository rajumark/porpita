import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:porpita/services/device_manager.dart';
import 'package:porpita/services/commands/adb_exec_service.dart';
import '../resolver/dump_section_parser.dart';

class KeySetTab extends StatefulWidget {
  final String packageName;
  const KeySetTab({super.key, required this.packageName});

  @override
  State<KeySetTab> createState() => _KeySetTabState();
}

class _KeySetTabState extends State<KeySetTab> with AutomaticKeepAliveClientMixin {
  String _data = '';
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
  void didUpdateWidget(covariant KeySetTab oldWidget) {
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
      final raw = await AdbExecService.run(device.id, ['dumpsys', 'package', widget.packageName]);
      final section = DumpSectionParser.extractSection(raw, 'Key Set Manager');
      if (!mounted) return;
      setState(() { _data = section; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) {
      return const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 8),
            FilledButton.tonal(onPressed: _fetch, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_data.isEmpty) {
      return const Center(child: Text('No key set data'));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SelectableText(
        _data,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace', fontSize: 12),
      ),
    );
  }
}