import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:porpita/services/device_manager.dart';
import 'dexopt_service.dart';

const _keyHints = {
  'Package': 'The app this dexopt entry belongs to.',
  'Path': 'The exact secure folder on your device where the original APK file (base.apk) is installed. The random characters are a security feature to prevent unauthorized apps from guessing the location.',
  'Arch': 'The CPU architecture this optimization applies to (e.g. arm64 = 64-bit ARM, the standard for modern phones).',
  'Status': 'How Android has processed the app\'s code.\n• verify — Only verified for safety, not yet compiled. The app runs via interpretation or JIT.\n• speed — Fully compiled to machine code for maximum performance.\n• speed-profile — Compiled based on real usage patterns (Profile-Guided Optimization).\n• everything — Compiled with maximum optimization.',
  'Reason': 'Why the app is in this dexopt state.\n• install — Optimized during app installation.\n• bg-dexopt — Optimized in the background (usually overnight while charging).\n• cmdline — Optimized manually via a command.\n• shared — Optimized as a shared app.',
  'Primary ABI': 'Indicates this is the native, preferred architecture for your device\'s processor. Apps run best on their primary ABI.',
  'Location': 'Where the optimized .odex (Optimized Dalvik Executable) file is stored on your device. This contains pre-verified or pre-compiled bytecode for faster app startup.',
};

class DexoptTab extends StatefulWidget {
  final String packageName;
  const DexoptTab({super.key, required this.packageName});

  @override
  State<DexoptTab> createState() => _DexoptTabState();
}

class _DexoptTabState extends State<DexoptTab> with AutomaticKeepAliveClientMixin {
  List<DexoptEntry> _entries = [];
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
  void didUpdateWidget(covariant DexoptTab oldWidget) {
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
      final entries = await DexoptService.fetch(device.id, widget.packageName);
      if (!mounted) return;
      setState(() { _entries = entries; _loading = false; });
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
      return Center(child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)));
    }
    if (_entries.isEmpty) {
      return const Center(child: Text('No dexopt data'));
    }
    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _entries.length,
      itemBuilder: (context, index) => _buildEntry(context, _entries[index], theme),
    );
  }

  Widget _buildEntry(BuildContext context, DexoptEntry entry, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _row(context, 'Package', '[${entry.packageName}]'),
        if (entry.path != null) _row(context, 'Path', entry.path!),
        ...entry.archs.map((arch) => _buildArch(context, arch)),
        const Divider(height: 24),
      ],
    );
  }

  Widget _buildArch(BuildContext context, DexoptArch arch) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _row(context, 'Arch', arch.arch),
        if (arch.status != null) _row(context, 'Status', arch.status!),
        if (arch.reason != null) _row(context, 'Reason', arch.reason!),
        if (arch.isPrimaryAbi) _row(context, 'Primary ABI', 'Yes'),
        if (arch.location != null) _row(context, 'Location', arch.location!),
      ],
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final hint = _keyHints[label];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Row(
              children: [
                Flexible(child: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
                if (hint != null) ...[
                  const SizedBox(width: 4),
                  Tooltip(
                    message: hint,
                    preferBelow: false,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: theme.textTheme.bodySmall,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.help,
                      child: Icon(Icons.help_outline, size: 14, color: theme.colorScheme.primary),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: SelectableText(value, style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }
}