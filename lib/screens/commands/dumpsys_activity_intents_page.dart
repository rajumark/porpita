import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/device_manager.dart';
import '../../services/commands/dumpsys_activity_intents_service.dart';
import '../../widgets/data_screen_widgets.dart';

class DumpsysActivityIntentsPage extends StatefulWidget {
  const DumpsysActivityIntentsPage({super.key});

  @override
  State<DumpsysActivityIntentsPage> createState() => _DumpsysActivityIntentsPageState();
}

class _DumpsysActivityIntentsPageState extends State<DumpsysActivityIntentsPage> {
  String _output = '';
  bool _loading = false;
  String? _deviceId;

  Future<void> _fetch(String deviceId) async {
    if (_loading) return;
    setState(() => _loading = true);
    final out = await DumpsysActivityIntentsService.fetch(deviceId);
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.code),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'dumpsys activity intents', 
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                )
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
        const Divider(height: 1),
        Expanded(
          child: Container(
            width: double.infinity,
            color: Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFF1E1E2E) 
                : const Color(0xFFF8F9FA),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: SelectableText(
                _output,
                style: TextStyle(
                  fontFamily: 'monospace', 
                  fontSize: 12.5,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? const Color(0xFFCDD6F4) 
                      : Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
