import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/device_manager.dart';

/// A card showing a map of key→value pairs. Used as the detail panel for most data screens.
class DetailCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Map<String, String> fields;
  final List<Widget>? actions;

  const DetailCard({
    super.key,
    required this.title,
    required this.icon,
    required this.fields,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Row(
          children: [
            CircleAvatar(
              backgroundColor: cs.primaryContainer,
              child: Icon(icon, color: cs.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ),
            if (actions != null) ...actions!,
          ],
        ),
        const SizedBox(height: 16),
        // Fields
        Card(
          elevation: 0,
          color: cs.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: fields.entries.map((e) => _FieldRow(label: e.key, value: e.value)).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final String value;
  const _FieldRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isEmpty = value.isEmpty || value == 'NULL';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onLongPress: isEmpty
                  ? null
                  : () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('"$label" copied'), duration: const Duration(seconds: 1)),
                      );
                    },
              child: SelectableText(
                isEmpty ? '—' : value,
                style: tt.bodySmall?.copyWith(
                  color: isEmpty ? cs.outlineVariant : cs.onSurface,
                  fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact list tile used in left panels.
class DataListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? iconColor;

  const DataListTile({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: isSelected ? cs.primaryContainer : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? cs.primary : (iconColor ?? cs.onSurfaceVariant),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? cs.primary : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty)
                      Text(
                        subtitle!,
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty detail placeholder shown when nothing is selected.
class NoSelectionPanel extends StatelessWidget {
  final String message;
  final IconData icon;

  const NoSelectionPanel({
    super.key,
    this.message = 'Select an item to view details',
    this.icon = Icons.touch_app_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: cs.outlineVariant),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

/// No device connected placeholder.
class NoDevicePanel extends StatelessWidget {
  const NoDevicePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.phone_android, size: 56),
          SizedBox(height: 12),
          Text('Connect a device to view data'),
        ],
      ),
    );
  }
}

/// Reusable command screen that shows an ADB command with copy button,
/// loading state, and selectable text output with copy button.
class CommandScreen extends StatefulWidget {
  final String title;
  final String adbCommand;
  final Future<String> Function(String deviceId) fetchData;

  const CommandScreen({
    super.key,
    required this.title,
    required this.adbCommand,
    required this.fetchData,
  });

  @override
  State<CommandScreen> createState() => _CommandScreenState();
}

class _CommandScreenState extends State<CommandScreen> {
  String _output = '';
  bool _loading = false;
  String? _deviceId;

  Future<void> _fetch(String deviceId) async {
    if (_loading) return;
    setState(() => _loading = true);
    final out = await widget.fetchData(deviceId);
    if (mounted) {
      setState(() {
        _output = out.isEmpty ? '(No output)' : out;
        _loading = false;
        _deviceId = deviceId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dm = context.watch<DeviceManager>();
    final device = dm.selected;
    if (device == null || !device.isConnected) return const NoDevicePanel();

    if (_deviceId != device.id) WidgetsBinding.instance.addPostFrameCallback((_) => _fetch(device.id));

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Row(
            children: [
              const Icon(Icons.code),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.title,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              if (_loading) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _fetch(device.id),
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.terminal, size: 14, color: cs.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.adbCommand,
                    style: TextStyle(fontFamily: 'monospace', fontSize: 11.5, color: cs.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  tooltip: 'Copy command',
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.adbCommand));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Command copied'), duration: Duration(seconds: 1)),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Container(
            width: double.infinity,
            color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF8F9FA),
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: SelectableText(
                    _output,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12.5,
                      color: isDark ? const Color(0xFFCDD6F4) : Colors.black87,
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: 'Copy output',
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _output));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Output copied'), duration: Duration(seconds: 1)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
