import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:porpita/services/device_manager.dart';
import '../../notification_shade/control_center/control_center_service.dart';
import '../../notification_shade/control_center/quick_tile.dart';

class QuickSettingsChip extends StatefulWidget {
  final VoidCallback onTap;

  const QuickSettingsChip({super.key, required this.onTap});

  @override
  State<QuickSettingsChip> createState() => _QuickSettingsChipState();
}

class _QuickSettingsChipState extends State<QuickSettingsChip> {
  bool _isLoading = true;
  int _wifiState = 0;
  int _bluetoothState = 0;
  int _airplaneState = 0;
  int _mobileState = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadStates());
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _loadStates());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadStates() async {
    final dm = context.read<DeviceManager>();
    final device = dm.selected;
    if (device == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final states = await ControlCenterService.fetchTileStates(device.id);
      if (!mounted) return;
      setState(() {
        _wifiState = states['wifi'] ?? 0;
        _bluetoothState = states['bluetooth'] ?? 0;
        _airplaneState = states['airplane'] ?? 0;
        _mobileState = 0;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Color _getIconColor(QuickTileState state) {
    final scheme = Theme.of(context).colorScheme;
    if (state == QuickTileState.on || state == QuickTileState.onDisabled) {
      return scheme.primary;
    }
    return scheme.onSurfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2));
    }

    final wifiTileState = _airplaneState == 1
        ? QuickTileState.onDisabled
        : (_wifiState == 1 ? QuickTileState.on : QuickTileState.off);
    final bluetoothTileState = _airplaneState == 1
        ? QuickTileState.onDisabled
        : (_bluetoothState == 1 ? QuickTileState.on : QuickTileState.off);
    final airplaneTileState = _airplaneState == 1 ? QuickTileState.on : QuickTileState.off;

    return SizedBox(
      height: 24,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _airplaneState == 1 ? Icons.airplanemode_active : Icons.airplanemode_inactive,
            size: 16,
            color: _getIconColor(airplaneTileState),
          ),
          if (_wifiState == 1 || _airplaneState == 1) ...[
            const SizedBox(width: 8),
            Icon(
              _wifiState == 1 ? Icons.wifi : Icons.wifi_off,
              size: 16,
              color: _getIconColor(wifiTileState),
            ),
          ],
          if (_mobileState == 1 || _airplaneState == 1) ...[
            const SizedBox(width: 8),
            Icon(
              _mobileState == 1 ? Icons.signal_cellular_alt : Icons.signal_cellular_off,
              size: 16,
              color: _getIconColor(_airplaneState == 1 ? QuickTileState.onDisabled : QuickTileState.off),
            ),
          ],
          if (_bluetoothState == 1 || _airplaneState == 1) ...[
            const SizedBox(width: 8),
            Icon(
              _bluetoothState == 1 ? Icons.bluetooth : Icons.bluetooth_outlined,
              size: 16,
              color: _getIconColor(bluetoothTileState),
            ),
          ],
        ],
      ),
    );
  }
}