import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:porpita/services/device_manager.dart';
import 'package:porpita/v2/widgets/rounded_container.dart';
import 'notifications_service.dart';

class NotificationsBaseScreen extends StatefulWidget {
  const NotificationsBaseScreen({super.key});

  @override
  State<NotificationsBaseScreen> createState() =>
      _NotificationsBaseScreenState();
}

class _NotificationsBaseScreenState extends State<NotificationsBaseScreen> {
  List<String> _sections = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetch(String deviceId) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final sections = await NotificationsService.fetchRawSections(deviceId);
      if (!mounted) return;
      setState(() {
        _sections = sections;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '${e.runtimeType}: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dm = context.watch<DeviceManager>();
    final device = dm.selected;

    if (device == null || !device.isConnected) {
      return const Center(child: Text('No device connected'));
    }

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: RoundedContainer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: 8),
                    Text('Error',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      tooltip: 'Copy error',
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: _error!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Error copied'),
                              duration: Duration(seconds: 2)),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    _error!,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => _fetch(device.id),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_sections.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No notifications'),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed: () => _fetch(device.id),
              icon: const Icon(Icons.refresh),
              label: const Text('Fetch'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(
            children: [
              Text('${_sections.length} notification(s)',
                  style: Theme.of(context).textTheme.bodySmall),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                tooltip: 'Refresh',
                onPressed: () => _fetch(device.id),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
            itemCount: _sections.length,
            itemBuilder: (context, index) {
              return _DumpCard(dumpText: _sections[index], index: index);
            },
          ),
        ),
      ],
    );
  }
}

class _DumpCard extends StatelessWidget {
  final String dumpText;
  final int index;

  const _DumpCard({required this.dumpText, required this.index});

  String _pkg() =>
      RegExp(r'pkg=(\S+)').firstMatch(dumpText)?[1] ?? 'Notification ${index + 1}';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      color: cs.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 4, 4),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: cs.primaryContainer,
                  child: Text('${index + 1}',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: cs.primary, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_pkg(),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  tooltip: 'Copy dump',
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: dumpText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dump copied'),
                          duration: Duration(seconds: 1)),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 300),
            color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF8F9FA),
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: SelectableText(
                    dumpText,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: isDark ? const Color(0xFFCDD6F4) : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: IconButton(
                    icon: Icon(Icons.copy, size: 14, color: cs.outline),
                    tooltip: 'Copy',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints.tight(const Size(24, 24)),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: dumpText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dump copied'),
                            duration: Duration(seconds: 1)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
