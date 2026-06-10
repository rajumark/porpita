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
    setState(() { _isLoading = true; _error = null; });
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
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _manualRefresh(String deviceId) async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      final battery = await BatteryService.fetchBattery(deviceId);
      if (!mounted) return;
      setState(() {
        _battery = battery;
        
      });
    } catch (_) {}
    finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  Future<void> _silentRefresh(String deviceId) async {
    try {
      final battery = await BatteryService.fetchBattery(deviceId);
      if (!mounted) return;
      setState(() {
        _battery = battery;
        
      });
    } catch (_) {}
  }

  Future<void> _setLevel(int level) async {
    final device = context.read<DeviceManager>().selected;
    if (device == null) return;
    setState(() => _isSimulating = true);
    try {
      await BatteryService.setLevel(device.id, level);
      await _manualRefresh(device.id);
    } catch (_) {}
    finally {
      if (mounted) setState(() => _isSimulating = false);
    }
  }

  Future<void> _setCharging(String source, bool on) async {
    final device = context.read<DeviceManager>().selected;
    if (device == null) return;
    setState(() => _isSimulating = true);
    try {
      switch (source) {
        case 'ac':
          await BatteryService.setAcCharging(device.id, on);
        case 'usb':
          await BatteryService.setUsbCharging(device.id, on);
      }
      await _manualRefresh(device.id);
    } catch (_) {}
    finally {
      if (mounted) setState(() => _isSimulating = false);
    }
  }

  Future<void> _reset() async {
    final device = context.read<DeviceManager>().selected;
    if (device == null) return;
    setState(() => _isSimulating = true);
    try {
      await BatteryService.reset(device.id);
      await _manualRefresh(device.id);
    } catch (_) {}
    finally {
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
                      child: Text('Battery', style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  ),
                  if (_isSimulating)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                  if (_isRefreshing)
                    const SizedBox(
                      width: 16, height: 16,
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
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Text(_error!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.error,
        )),
      );
    }
    if (_battery == null) return const Center(child: Text('No device connected'));
    final b = _battery!;
    final percent = b.scale > 0 ? b.level / b.scale : 0.0;
    final displayPercent = (percent * 100).round();

    Color gaugeColor;
    if (percent > 0.6) gaugeColor = Colors.green;
    else if (percent > 0.2) gaugeColor = Colors.orange;
    else gaugeColor = Colors.red;

    return ListView(
      padding: const EdgeInsets.only(bottom: 12),
      children: [
        _buildBatteryGauge(context, b, displayPercent, gaugeColor),
        const SizedBox(height: 8),
        _buildSimControls(b),
        const SizedBox(height: 4),
        _section(context, 'Status', [
          (label: 'Status', value: '${b.status} — ${b.statusLabel}'),
          (label: 'Level', value: '${b.level}/${b.scale}'),
          (label: 'Health', value: '${b.health} — ${b.healthLabel}'),
          (label: 'Present', value: b.present ? 'Yes' : 'No'),
        ]),
        _section(context, 'Power', [
          (label: 'AC powered', value: b.acPowered ? 'Yes' : 'No'),
          (label: 'USB powered', value: b.usbPowered ? 'Yes' : 'No'),
          (label: 'Wireless powered', value: b.wirelessPowered ? 'Yes' : 'No'),
          (label: 'Dock powered', value: b.dockPowered ? 'Yes' : 'No'),
          (label: 'Charging state', value: b.chargingState.toString()),
          (label: 'Charging policy', value: b.chargingPolicy.toString()),
        ]),
        _section(context, 'Technical', [
          (label: 'Voltage', value: '${b.voltage} mV'),
          (label: 'Temperature', value: '${(b.temperature / 10).toStringAsFixed(1)}°C'),
          (label: 'Technology', value: b.technology),
          (label: 'Charge counter', value: b.chargeCounter?.toString() ?? '—'),
          (label: 'Max charging current', value: b.maxChargingCurrent?.toString() ?? '—'),
          (label: 'Max charging voltage', value: b.maxChargingVoltage?.toString() ?? '—'),
          (label: 'Capacity level', value: b.capacityLevel.toString()),
        ]),
      ],
    );
  }

  Widget _buildBatteryGauge(BuildContext context, BatteryInfo battery, int displayPercent, Color gaugeColor) {
    final scheme = Theme.of(context).colorScheme;
    final percent = battery.scale > 0 ? battery.level / battery.scale : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: CustomPaint(
              painter: _BatteryGaugePainter(
                percent: percent,
                color: gaugeColor,
                backgroundColor: scheme.outlineVariant.withValues(alpha: 0.3),
              ),
              child: Center(
                child: Text(
                  '$displayPercent%',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            battery.statusLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildSimControls(BatteryInfo battery) {
    final scheme = Theme.of(context).colorScheme;
    final currentLevel = battery.level;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Icon(Icons.tune, size: 14, color: scheme.primary),
                const SizedBox(width: 4),
                Text(
                  'SIMULATE BATTERY',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _isSimulating ? null : _reset,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text('Reset', style: Theme.of(context).textTheme.labelSmall),
                ),
              ],
            ),
          ),
          Material(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(
                          '${currentLevel}%',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: currentLevel.toDouble(),
                          min: 0,
                          max: 100,
                          divisions: 100,
                          label: '$currentLevel%',
                          onChanged: _isSimulating
                              ? null
                              : (v) => _setLevel(v.round()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Level',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildChargingToggles(battery),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChargingToggles(BatteryInfo battery) {
    final disabled = _isSimulating;

    return Row(
      children: [
        Expanded(
          child: _toggleButton(
            label: 'AC',
            icon: Icons.power,
            isOn: battery.acPowered,
            color: Colors.orange,
            disabled: disabled,
            onTap: () => _setCharging('ac', !battery.acPowered),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _toggleButton(
            label: 'USB',
            icon: Icons.usb,
            isOn: battery.usbPowered,
            color: Colors.blue,
            disabled: disabled,
            onTap: () => _setCharging('usb', !battery.usbPowered),
          ),
        ),
      ],
    );
  }

  Widget _toggleButton({
    required String label,
    required IconData icon,
    required bool isOn,
    required Color color,
    required bool disabled,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: isOn ? color.withValues(alpha: 0.15) : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: disabled ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isOn ? color : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isOn ? color : scheme.onSurfaceVariant,
                  fontWeight: isOn ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOn ? color : scheme.outline,
                ),
              ),
            ],
          ),
        ),
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
            child: Text(title, style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            )),
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
            child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            )),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace', fontSize: 12,
            )),
          ),
        ],
      ),
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
    final strokeWidth = 8.0;
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