import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:porpita/services/device_manager.dart';
import 'quick_tile.dart';
import 'control_center_service.dart';

class ControlCenterScreen extends StatefulWidget {
  const ControlCenterScreen({super.key});

  @override
  State<ControlCenterScreen> createState() => _ControlCenterScreenState();
}

class _ControlCenterScreenState extends State<ControlCenterScreen> {
  bool _isLoading = true;

  int _wifiState = 0;
  int _bluetoothState = 0;
  int _airplaneState = 0;
  int _darkModeState = 0;
  int _dndState = 0;
  int _batterySaverState = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStates();
    });
  }

  Future<void> _loadStates() async {
    final dm = context.read<DeviceManager>();
    final device = dm.selected;
    if (device == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final states = await ControlCenterService.fetchTileStates(device.id);
      if (!mounted) return;
      setState(() {
        _wifiState = states['wifi'] ?? 0;
        _bluetoothState = states['bluetooth'] ?? 0;
        _airplaneState = states['airplane'] ?? 0;
        _darkModeState = states['darkmode'] ?? 0;
        _dndState = states['dnd'] ?? 0;
        _batterySaverState = states['batterySaver'] ?? 0;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  QuickTileState _getWifiState() {
    if (_airplaneState == 1) return QuickTileState.onDisabled;
    return _wifiState == 1 ? QuickTileState.on : QuickTileState.off;
  }

  QuickTileState _getBluetoothState() {
    if (_airplaneState == 1) return QuickTileState.onDisabled;
    return _bluetoothState == 1 ? QuickTileState.on : QuickTileState.off;
  }

  QuickTileState _getMobileState() {
    if (_airplaneState == 1) return QuickTileState.onDisabled;
    return QuickTileState.off;
  }

  QuickTileState _getDarkModeState() {
    return _darkModeState == 2 ? QuickTileState.on : QuickTileState.off;
  }

  QuickTileState _getDndState() {
    return _dndState > 0 ? QuickTileState.on : QuickTileState.off;
  }

  QuickTileState _getBatterySaverState() {
    return _batterySaverState == 1 ? QuickTileState.on : QuickTileState.off;
  }

  Future<void> _toggleWifi() async {
    if (_airplaneState == 1) return;
    final dm = context.read<DeviceManager>();
    final device = dm.selected;
    if (device == null) return;

    final newState = _wifiState == 1 ? false : true;
    await ControlCenterService.setWifi(device.id, newState);
    setState(() => _wifiState = newState ? 1 : 0);
  }

  Future<void> _toggleBluetooth() async {
    if (_airplaneState == 1) return;
    final dm = context.read<DeviceManager>();
    final device = dm.selected;
    if (device == null) return;

    final newState = _bluetoothState == 1 ? false : true;
    await ControlCenterService.setBluetooth(device.id, newState);
    setState(() => _bluetoothState = newState ? 1 : 0);
  }

  Future<void> _toggleAirplane() async {
    final dm = context.read<DeviceManager>();
    final device = dm.selected;
    if (device == null) return;

    final newState = _airplaneState == 1 ? false : true;
    await ControlCenterService.setAirplaneMode(device.id, newState);
    setState(() => _airplaneState = newState ? 1 : 0);
  }

  Future<void> _toggleDarkMode() async {
    final dm = context.read<DeviceManager>();
    final device = dm.selected;
    if (device == null) return;

    final newState = _darkModeState == 2 ? false : true;
    await ControlCenterService.setDarkMode(device.id, newState);
    setState(() => _darkModeState = newState ? 2 : 1);
  }

  Future<void> _toggleDnd() async {
    final dm = context.read<DeviceManager>();
    final device = dm.selected;
    if (device == null) return;

    final newState = _dndState > 0 ? false : true;
    await ControlCenterService.setDnd(device.id, newState);
    setState(() => _dndState = newState ? 1 : 0);
  }

  Future<void> _toggleBatterySaver() async {
    final dm = context.read<DeviceManager>();
    final device = dm.selected;
    if (device == null) return;

    final newState = _batterySaverState == 1 ? false : true;
    await ControlCenterService.setBatterySaver(device.id, newState);
    setState(() => _batterySaverState = newState ? 1 : 0);
  }

  @override
  Widget build(BuildContext context) {
    final dm = context.watch<DeviceManager>();
    final device = dm.selected;

    if (device == null) {
      return _buildNoDevice();
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadStates,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth >= 400 ? 4 : 3;

          return GridView.count(
            crossAxisCount: crossAxisCount,
            padding: const EdgeInsets.all(12),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            mainAxisExtent: 64,
            children: [
              QuickTileWidget(
                tile: QuickTile(
                  id: 'wifi',
                  label: 'Wi-Fi',
                  icon: Icons.wifi,
                  activeIcon: Icons.wifi,
                  state: _getWifiState(),
                ),
                onTap: _toggleWifi,
              ),
              QuickTileWidget(
                tile: QuickTile(
                  id: 'mobile',
                  label: 'Mobile Data',
                  icon: Icons.signal_cellular_alt_outlined,
                  activeIcon: Icons.signal_cellular_alt,
                  state: _getMobileState(),
                ),
                onTap: () {},
              ),
              QuickTileWidget(
                tile: QuickTile(
                  id: 'bluetooth',
                  label: 'Bluetooth',
                  icon: Icons.bluetooth_outlined,
                  activeIcon: Icons.bluetooth,
                  state: _getBluetoothState(),
                ),
                onTap: _toggleBluetooth,
              ),
              QuickTileWidget(
                tile: QuickTile(
                  id: 'airplane',
                  label: 'Airplane',
                  icon: Icons.airplanemode_inactive,
                  activeIcon: Icons.airplanemode_active,
                  state: _airplaneState == 1 ? QuickTileState.on : QuickTileState.off,
                ),
                onTap: _toggleAirplane,
              ),
              QuickTileWidget(
                tile: QuickTile(
                  id: 'darkmode',
                  label: 'Dark Mode',
                  icon: Icons.dark_mode_outlined,
                  activeIcon: Icons.dark_mode,
                  state: _getDarkModeState(),
                ),
                onTap: _toggleDarkMode,
              ),
              QuickTileWidget(
                tile: QuickTile(
                  id: 'flashlight',
                  label: 'Flashlight',
                  icon: Icons.flashlight_off_outlined,
                  activeIcon: Icons.flashlight_on,
                  state: QuickTileState.off,
                ),
                onTap: () async {
                  final newState = true;
                  await ControlCenterService.setFlashlight(device.id, newState);
                  setState(() {});
                },
              ),
              QuickTileWidget(
                tile: QuickTile(
                  id: 'dnd',
                  label: 'DND',
                  icon: Icons.do_not_disturb_outlined,
                  activeIcon: Icons.do_not_disturb_on,
                  state: _getDndState(),
                ),
                onTap: _toggleDnd,
              ),
              QuickTileWidget(
                tile: QuickTile(
                  id: 'batterySaver',
                  label: 'Battery Saver',
                  icon: Icons.battery_std,
                  activeIcon: Icons.battery_saver,
                  state: _getBatterySaverState(),
                ),
                onTap: _toggleBatterySaver,
              ),
              QuickTileWidget(
                tile: QuickTile(
                  id: 'location',
                  label: 'Location',
                  icon: Icons.location_off_outlined,
                  activeIcon: Icons.location_on,
                  state: QuickTileState.off,
                ),
                onTap: () {},
              ),
              QuickTileWidget(
                tile: QuickTile(
                  id: 'hotspot',
                  label: 'Hotspot',
                  icon: Icons.wifi_find,
                  activeIcon: Icons.wifi,
                  state: QuickTileState.disabled,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNoDevice() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.phone_android_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No device connected',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Connect a device to control quick settings',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }
}