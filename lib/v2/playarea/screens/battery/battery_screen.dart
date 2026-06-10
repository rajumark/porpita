import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:porpita/services/device_manager.dart';
import 'package:porpita/v2/widgets/rounded_container.dart';
import 'battery_model.dart';
import 'battery_service.dart';

class BatteryScreen extends StatefulWidget {
  const BatteryScreen({super.key});

  @override
  State<BatteryScreen> createState() => _BatteryScreenState();
}

class _BatteryScreenState extends State<BatteryScreen> {
  BatteryInfo? _battery;
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isSimulating = false;
  String? _error;
  String? _lastDeviceId;
  Timer? _refreshTimer;
  static const _refreshInterval = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  void _cancelTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  void _startTimer(String deviceId) {
    _cancelTimer();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) => _silentRefresh(deviceId));
  }

  void _handleDeviceSwitch(String deviceId) {
    _lastDeviceId = deviceId;
    _cancelTimer();
    _initialFetch(deviceId);
  }

  Future<void> _initialFetch(String deviceId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final battery = await BatteryService.fetchBattery(deviceId);
      if (!mounted) return;
      setState(() {
        _battery = battery;
        _isLoading = false;
      });
      _startTimer(deviceId);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _manualRefresh(String deviceId) async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      final battery = await BatteryService.fetchBattery(deviceId);
      if (!mounted) return;
      setState(() => _battery = battery);
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  Future<void> _silentRefresh(String deviceId) async {
    try {
      final battery = await BatteryService.fetchBattery(deviceId);
      if (!mounted) return;
      setState(() => _battery = battery);
    } catch (_) {}
  }

  Widget _buildBatteryGauge(BuildContext context, BatteryInfo battery) {
    final scheme = Theme.of(context).colorScheme;
    final percent = battery.scale > 0 ? battery.level / battery.scale : 0.0;
    final displayPercent = (percent * 100).round();

    Color gaugeColor;
    if (percent > 0.6) {
      gaugeColor = Colors.green;
    } else if (percent > 0.2) {
      gaugeColor = Colors.orange;
    } else {
      gaugeColor = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(
              painter: _BatteryGaugePainter(
                percent: percent,
                color: gaugeColor,
                backgroundColor: scheme.outlineVariant.withValues(alpha: 0.3),
              ),
              child: Center(
                child: Text(
                  '$displayPercent%',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            battery.statusLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<({String label, String value})> rows) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4, top: 4),
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Material(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Column(
                children: [
                  for (int i = 0; i < rows.length; i++) ...[
                    _row(context, rows[i].label, rows[i].value),
                    if (i < rows.length - 1)
                      Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.4)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _boolStr(bool v) => v ? 'Yes' : 'No';
  String _tempStr(int v) => '${(v / 10).toStringAsFixed(1)}°C';

  Future<void> _onSimulate(String value, String? deviceId) async {
    if (deviceId == null) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isSimulating = true);
    try {
      switch (value) {
        case 'reset':
          await BatteryService.reset(deviceId);
          messenger.showSnackBar(const SnackBar(content: Text('Simulation reset'), duration: Duration(seconds: 1)));
        case 'ac_on':
          await BatteryService.setAcCharging(deviceId, true);
          messenger.showSnackBar(const SnackBar(content: Text('AC charging ON'), duration: Duration(seconds: 1)));
        case 'ac_off':
          await BatteryService.setAcCharging(deviceId, false);
          messenger.showSnackBar(const SnackBar(content: Text('AC charging OFF'), duration: Duration(seconds: 1)));
        case 'usb_on':
          await BatteryService.setUsbCharging(deviceId, true);
          messenger.showSnackBar(const SnackBar(content: Text('USB charging ON'), duration: Duration(seconds: 1)));
        case 'usb_off':
          await BatteryService.setUsbCharging(deviceId, false);
          messenger.showSnackBar(const SnackBar(content: Text('USB charging OFF'), duration: Duration(seconds: 1)));
        case 'level_10':
          await BatteryService.setLevel(deviceId, 10);
          messenger.showSnackBar(const SnackBar(content: Text('Level set to 10%'), duration: Duration(seconds: 1)));
        case 'level_25':
          await BatteryService.setLevel(deviceId, 25);
          messenger.showSnackBar(const SnackBar(content: Text('Level set to 25%'), duration: Duration(seconds: 1)));
        case 'level_50':
          await BatteryService.setLevel(deviceId, 50);
          messenger.showSnackBar(const SnackBar(content: Text('Level set to 50%'), duration: Duration(seconds: 1)));
        case 'level_75':
          await BatteryService.setLevel(deviceId, 75);
          messenger.showSnackBar(const SnackBar(content: Text('Level set to 75%'), duration: Duration(seconds: 1)));
        case 'level_100':
          await BatteryService.setLevel(deviceId, 100);
          messenger.showSnackBar(const SnackBar(content: Text('Level set to 100%'), duration: Duration(seconds: 1)));
      }
      await _manualRefresh(deviceId);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _isSimulating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dm = context.watch<DeviceManager>();
    final device = dm.selected;

    if (device != null && device.id != _lastDeviceId) {
      _handleDeviceSwitch(device.id);
    }

    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 8, top: 0, bottom: 8),
      child: RoundedContainer(
        child: Column(
          children: [
            SizedBox(
              height: 36,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        'Battery',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  if (_isRefreshing)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      iconSize: 20,
                      tooltip: 'Refresh',
                      onPressed: device == null ? null : () => _manualRefresh(device.id),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints.tight(const Size(36, 36)),
                    ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.tune),
                    iconSize: 20,
                    tooltip: 'Simulate',
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints.tight(const Size(36, 36)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (value) => _onSimulate(value, device?.id),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'reset', child: Text('Reset simulation')),
                      const PopupMenuItem(value: 'ac_on', child: Text('Simulate AC charging')),
                      const PopupMenuItem(value: 'ac_off', child: Text('Simulate AC unplugged')),
                      const PopupMenuItem(value: 'usb_on', child: Text('Simulate USB charging')),
                      const PopupMenuItem(value: 'usb_off', child: Text('Simulate USB unplugged')),
                      const PopupMenuItem(value: 'level_10', child: Text('Set level to 10%')),
                      const PopupMenuItem(value: 'level_25', child: Text('Set level to 25%')),
                      const PopupMenuItem(value: 'level_50', child: Text('Set level to 50%')),
                      const PopupMenuItem(value: 'level_75', child: Text('Set level to 75%')),
                      const PopupMenuItem(value: 'level_100', child: Text('Set level to 100%')),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
    }
    if (_battery == null) {
      return const Center(child: Text('No device connected'));
    }
    final b = _battery!;
    return ListView(
      padding: const EdgeInsets.only(bottom: 12),
      children: [
        _buildBatteryGauge(context, b),
        _section(context, 'Status', [
          (label: 'Status', value: '${b.status} — ${b.statusLabel}'),
          (label: 'Level', value: '${b.level}/${b.scale}'),
          (label: 'Health', value: '${b.health} — ${b.healthLabel}'),
          (label: 'Present', value: _boolStr(b.present)),
        ]),
        _section(context, 'Power', [
          (label: 'AC powered', value: _boolStr(b.acPowered)),
          (label: 'USB powered', value: _boolStr(b.usbPowered)),
          (label: 'Wireless powered', value: _boolStr(b.wirelessPowered)),
          (label: 'Dock powered', value: _boolStr(b.dockPowered)),
          (label: 'Charging state', value: b.chargingState.toString()),
          (label: 'Charging policy', value: b.chargingPolicy.toString()),
        ]),
        _section(context, 'Technical', [
          (label: 'Voltage', value: '${b.voltage} mV'),
          (label: 'Temperature', value: _tempStr(b.temperature)),
          (label: 'Technology', value: b.technology),
          (label: 'Charge counter', value: b.chargeCounter?.toString() ?? '—'),
          (label: 'Max charging current', value: b.maxChargingCurrent?.toString() ?? '—'),
          (label: 'Max charging voltage', value: b.maxChargingVoltage?.toString() ?? '—'),
          (label: 'Capacity level', value: b.capacityLevel.toString()),
        ]),
      ],
    );
  }
}

class _BatteryGaugePainter extends CustomPainter {
  final double percent;
  final Color color;
  final Color backgroundColor;

  _BatteryGaugePainter({
    required this.percent,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 10.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) / 2) - strokeWidth / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * percent.clamp(0.0, 1.0);

    canvas.drawCircle(center, radius, bgPaint);

    if (percent > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_BatteryGaugePainter oldDelegate) {
    return oldDelegate.percent != percent || oldDelegate.color != color;
  }
}