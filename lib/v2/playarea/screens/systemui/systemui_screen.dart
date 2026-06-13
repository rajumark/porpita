import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:porpita/services/device_manager.dart';
import '../../../widgets/rounded_container.dart';
import 'systemui_service.dart';

class SystemUiScreen extends StatefulWidget {
  const SystemUiScreen({super.key});

  @override
  State<SystemUiScreen> createState() => _SystemUiScreenState();
}

class _SystemUiScreenState extends State<SystemUiScreen> {
  bool _demoActive = false;
  bool _loading = false;

  int _batteryLevel = 100;
  bool _batteryPlugged = true;
  bool _batteryPowersave = false;

  bool _wifiShow = true;
  int _wifiLevel = 4;
  String _wifiHotspot = 'none';

  bool _mobileShow = true;
  String _mobileDatatype = 'lte';
  int _mobileLevel = 4;

  bool _fullyConnected = false;
  bool _airplaneShow = false;
  int _simsCount = 1;
  bool _noSimShow = false;
  bool _carrierNetworkChangeShow = false;

  bool _satelliteShow = false;
  String _satelliteConnection = 'unknown';
  int _satelliteLevel = 0;

  String _barsMode = 'opaque';

  String _volumeSlot = 'hide';
  String _bluetoothSlot = 'hide';
  bool _locationShow = false;
  bool _alarmShow = false;
  bool _syncShow = false;
  bool _ttyShow = false;
  bool _muteShow = false;
  bool _speakerphoneShow = false;
  bool _eriShow = false;

  bool _notificationsVisible = true;

  int _clockHour = 12;
  int _clockMinute = 0;

  @override
  Widget build(BuildContext context) {
    final dm = context.watch<DeviceManager>();
    final device = dm.selected;

    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 8, top: 0, bottom: 8),
      child: RoundedContainer(
        child: Column(
          children: [
            _buildHeader(device),
            Expanded(child: _buildBody(device)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AdbDevice? device) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Switch(
            value: _demoActive,
            onChanged: device == null ? null : (v) => _toggleDemo(device.id, v),
          ),
          const SizedBox(width: 8),
          Icon(Icons.dashboard, size: 22, color: scheme.primary),
          const SizedBox(width: 10),
          Text(
            'SystemUI Demo Mode',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(),
          if (_loading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Text(
              _demoActive ? 'Active' : 'Inactive',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: _demoActive ? Colors.green : scheme.onSurfaceVariant,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(AdbDevice? device) {
    if (device == null) {
      return const Center(child: Text('No device connected'));
    }

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_demoActive) {
      return _buildInactiveInfo();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 2 : 1;
        final sections = [
          _buildClockSection(device.id),
          _buildBatterySection(device.id),
          _buildNetworkSection(device.id),
          _buildSatelliteSection(device.id),
          _buildBarsSection(device.id),
          _buildStatusIconsSection(device.id),
          _buildNotificationsSection(device.id),
        ];
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: _layoutSections(sections, columns),
        );
      },
    );
  }

  List<Widget> _layoutSections(List<Widget> sections, int columns) {
    if (columns <= 1) {
      return sections
          .expand((s) => [s, const SizedBox(height: 12)])
          .toList();
    }
    final rows = <Widget>[];
    for (int i = 0; i < sections.length; i += columns) {
      final row = <Widget>[];
      for (int j = i; j < i + columns && j < sections.length; j++) {
        if (row.isNotEmpty) row.add(const SizedBox(width: 12));
        row.add(Expanded(child: sections[j]));
      }
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: row,
          ),
        ),
      );
    }
    return rows;
  }

  Widget _buildInactiveInfo() {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 48, color: scheme.primary.withValues(alpha: 0.6)),
            const SizedBox(height: 16),
            Text(
              'Demo Mode is Inactive',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Demo mode overrides the status bar appearance for screenshots '
              'and testing. When active, you can control battery, network, '
              'clock, status icons, and notification display independently '
              'of the actual device state.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.errorContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_rounded, size: 18, color: scheme.error),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Remember to turn off demo mode after testing to restore '
                      'normal status bar behavior.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onErrorContainer,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClockSection(String deviceId) {
    return _sectionCard(
      icon: Icons.schedule,
      title: 'Clock',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _numberField(
                  label: 'Hour',
                  value: _clockHour,
                  min: 0,
                  max: 23,
                  onChanged: (v) {
                    _clockHour = v;
                    _sendClock(deviceId);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _numberField(
                  label: 'Minute',
                  value: _clockMinute,
                  min: 0,
                  max: 59,
                  onChanged: (v) {
                    _clockMinute = v;
                    _sendClock(deviceId);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_clockHour.toString().padLeft(2, '0')}:${_clockMinute.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w300,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatterySection(String deviceId) {
    return _sectionCard(
      icon: Icons.battery_std,
      title: 'Battery',
      child: Column(
        children: [
          _labeledSlider(
            label: 'Level',
            value: _batteryLevel.toDouble(),
            displayValue: '$_batteryLevel%',
            min: 0,
            max: 100,
            divisions: 100,
            onChanged: (v) {
              setState(() => _batteryLevel = v.round());
              SystemUiService.setBatteryLevel(deviceId, v.round());
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _toggleChip(
                  label: 'Plugged',
                  icon: Icons.power,
                  value: _batteryPlugged,
                  onChanged: (v) {
                    setState(() => _batteryPlugged = v);
                    SystemUiService.setBatteryPlugged(deviceId, v);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _toggleChip(
                  label: 'Power Save',
                  icon: Icons.battery_saver,
                  value: _batteryPowersave,
                  onChanged: (v) {
                    setState(() => _batteryPowersave = v);
                    SystemUiService.setBatteryPowersave(deviceId, v);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkSection(String deviceId) {
    final datatypes = ['1x', '3g', '4g', '5g', 'e', 'g', 'h', 'lte', 'roam', 'hide', 'none'];
    final hotspotTypes = ['none', 'unknown', 'phone', 'tablet', 'laptop', 'watch', 'auto'];

    return _sectionCard(
      icon: Icons.wifi,
      title: 'Network',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _toggleChip(
                  label: 'Wi-Fi',
                  icon: Icons.wifi,
                  value: _wifiShow,
                  onChanged: (v) {
                    setState(() => _wifiShow = v);
                    SystemUiService.setWifi(deviceId, show: v, level: _wifiLevel, hotspot: _wifiHotspot == 'none' ? null : _wifiHotspot);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _labeledSlider(
                  label: 'Level',
                  value: _wifiLevel.toDouble(),
                  displayValue: '$_wifiLevel',
                  min: 0,
                  max: 4,
                  divisions: 4,
                  enabled: _wifiShow,
                  onChanged: (v) {
                    setState(() => _wifiLevel = v.round());
                    SystemUiService.setWifi(deviceId, show: _wifiShow, level: v.round(), hotspot: _wifiHotspot == 'none' ? null : _wifiHotspot);
                  },
                ),
              ),
            ],
          ),
          if (_wifiShow) ...[
            const SizedBox(height: 8),
            _dropdown(
              label: 'Hotspot',
              value: _wifiHotspot,
              items: hotspotTypes,
              enabled: _wifiShow,
              onChanged: (v) {
                setState(() => _wifiHotspot = v!);
                SystemUiService.setWifi(deviceId, show: _wifiShow, level: _wifiLevel, hotspot: v == 'none' ? null : v);
              },
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _toggleChip(
                  label: 'Mobile',
                  icon: Icons.signal_cellular_alt,
                  value: _mobileShow,
                  onChanged: (v) {
                    setState(() => _mobileShow = v);
                    SystemUiService.setMobile(
                      deviceId,
                      show: v,
                      datatype: _mobileDatatype,
                      level: _mobileLevel,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dropdown(
                  label: 'Type',
                  value: _mobileDatatype,
                  items: datatypes,
                  enabled: _mobileShow,
                  onChanged: (v) {
                    setState(() => _mobileDatatype = v!);
                    SystemUiService.setMobile(
                      deviceId,
                      show: _mobileShow,
                      datatype: v!,
                      level: _mobileLevel,
                    );
                  },
                ),
              ),
            ],
          ),
          if (_mobileShow) ...[
            const SizedBox(height: 8),
            _labeledSlider(
              label: 'Signal',
              value: _mobileLevel.toDouble(),
              displayValue: '$_mobileLevel',
              min: 0,
              max: 4,
              divisions: 4,
              onChanged: (v) {
                setState(() => _mobileLevel = v.round());
                SystemUiService.setMobile(
                  deviceId,
                  show: _mobileShow,
                  datatype: _mobileDatatype,
                  level: v.round(),
                );
              },
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _toggleChip(
                  label: 'Fully',
                  icon: Icons.cloud_done,
                  value: _fullyConnected,
                  onChanged: (v) {
                    setState(() => _fullyConnected = v);
                    SystemUiService.setFully(deviceId, v);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _toggleChip(
                  label: 'Airplane',
                  icon: Icons.airplanemode_active,
                  value: _airplaneShow,
                  onChanged: (v) {
                    setState(() => _airplaneShow = v);
                    SystemUiService.setAirplane(deviceId, v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _toggleChip(
                  label: 'No SIM',
                  icon: Icons.sim_card_alert,
                  value: _noSimShow,
                  onChanged: (v) {
                    setState(() => _noSimShow = v);
                    SystemUiService.setNoSim(deviceId, v);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _toggleChip(
                  label: 'Carrier Change',
                  icon: Icons.swap_vert,
                  value: _carrierNetworkChangeShow,
                  onChanged: (v) {
                    setState(() => _carrierNetworkChangeShow = v);
                    SystemUiService.setCarrierNetworkChange(deviceId, v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _numberField(
            label: 'SIMs',
            value: _simsCount,
            min: 1,
            max: 8,
            onChanged: (v) {
              setState(() => _simsCount = v);
              SystemUiService.setSims(deviceId, v);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSatelliteSection(String deviceId) {
    final connections = ['unknown', 'connected', 'on', 'off'];

    return _sectionCard(
      icon: Icons.satellite_alt,
      title: 'Satellite',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _toggleChip(
                  label: 'Show',
                  icon: Icons.satellite_alt,
                  value: _satelliteShow,
                  onChanged: (v) {
                    setState(() => _satelliteShow = v);
                    SystemUiService.setSatellite(
                      deviceId,
                      show: v,
                      connection: _satelliteConnection,
                      level: _satelliteLevel,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dropdown(
                  label: 'Connection',
                  value: _satelliteConnection,
                  items: connections,
                  enabled: _satelliteShow,
                  onChanged: (v) {
                    setState(() => _satelliteConnection = v!);
                    SystemUiService.setSatellite(
                      deviceId,
                      show: _satelliteShow,
                      connection: v!,
                      level: _satelliteLevel,
                    );
                  },
                ),
              ),
            ],
          ),
          if (_satelliteShow) ...[
            const SizedBox(height: 8),
            _labeledSlider(
              label: 'Level',
              value: _satelliteLevel.toDouble(),
              displayValue: '$_satelliteLevel',
              min: 0,
              max: 4,
              divisions: 4,
              onChanged: (v) {
                setState(() => _satelliteLevel = v.round());
                SystemUiService.setSatellite(
                  deviceId,
                  show: _satelliteShow,
                  connection: _satelliteConnection,
                  level: v.round(),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBarsSection(String deviceId) {
    final modes = ['opaque', 'translucent', 'semi-transparent'];

    return _sectionCard(
      icon: Icons.view_agenda,
      title: 'Bar Style',
      child: Row(
        children: modes.map((mode) {
          final selected = _barsMode == mode;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: mode == modes.first ? 0 : 4,
                right: mode == modes.last ? 0 : 4,
              ),
              child: _chip(
                label: mode,
                selected: selected,
                onTap: () {
                  setState(() => _barsMode = mode);
                  SystemUiService.setBarsMode(deviceId, mode);
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusIconsSection(String deviceId) {
    return _sectionCard(
      icon: Icons.info,
      title: 'Status Icons',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _statusDropdown(
            label: 'Volume',
            icon: Icons.volume_up,
            value: _volumeSlot,
            items: const ['hide', 'silent', 'vibrate'],
            onChanged: (v) {
              setState(() => _volumeSlot = v!);
              SystemUiService.setStatusIcon(deviceId, 'volume', v!);
            },
          ),
          _statusDropdown(
            label: 'Bluetooth',
            icon: Icons.bluetooth,
            value: _bluetoothSlot,
            items: const ['hide', 'connected', 'disconnected'],
            onChanged: (v) {
              setState(() => _bluetoothSlot = v!);
              SystemUiService.setStatusIcon(deviceId, 'bluetooth', v!);
            },
          ),
          _statusToggle(
            label: 'Location',
            icon: Icons.location_on,
            value: _locationShow,
            onChanged: (v) {
              setState(() => _locationShow = v);
              SystemUiService.setStatusIcon(deviceId, 'location', v ? 'show' : 'hide');
            },
          ),
          _statusToggle(
            label: 'Alarm',
            icon: Icons.alarm,
            value: _alarmShow,
            onChanged: (v) {
              setState(() => _alarmShow = v);
              SystemUiService.setStatusIcon(deviceId, 'alarm', v ? 'show' : 'hide');
            },
          ),
          _statusToggle(
            label: 'Sync',
            icon: Icons.sync,
            value: _syncShow,
            onChanged: (v) {
              setState(() => _syncShow = v);
              SystemUiService.setStatusIcon(deviceId, 'sync', v ? 'show' : 'hide');
            },
          ),
          _statusToggle(
            label: 'TTY',
            icon: Icons.tty,
            value: _ttyShow,
            onChanged: (v) {
              setState(() => _ttyShow = v);
              SystemUiService.setStatusIcon(deviceId, 'tty', v ? 'show' : 'hide');
            },
          ),
          _statusToggle(
            label: 'Mute',
            icon: Icons.mic_off,
            value: _muteShow,
            onChanged: (v) {
              setState(() => _muteShow = v);
              SystemUiService.setStatusIcon(deviceId, 'mute', v ? 'show' : 'hide');
            },
          ),
          _statusToggle(
            label: 'Speaker',
            icon: Icons.volume_up,
            value: _speakerphoneShow,
            onChanged: (v) {
              setState(() => _speakerphoneShow = v);
              SystemUiService.setStatusIcon(deviceId, 'speakerphone', v ? 'show' : 'hide');
            },
          ),
          _statusToggle(
            label: 'ERI',
            icon: Icons.cell_tower,
            value: _eriShow,
            onChanged: (v) {
              setState(() => _eriShow = v);
              SystemUiService.setStatusIcon(deviceId, 'eri', v ? 'show' : 'hide');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection(String deviceId) {
    return _sectionCard(
      icon: Icons.notifications,
      title: 'Notifications',
      child: _toggleChip(
        label: 'Visible',
        icon: _notificationsVisible ? Icons.notifications_active : Icons.notifications_off,
        value: _notificationsVisible,
        onChanged: (v) {
          setState(() => _notificationsVisible = v);
          SystemUiService.setNotificationsVisible(deviceId, v);
        },
      ),
    );
  }

  // ---- Reusable helpers ----

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: scheme.primary),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  Widget _toggleChip({
    required String label,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: value ? scheme.primaryContainer.withValues(alpha: 0.4) : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: value ? scheme.primary : scheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                      ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: value ? scheme.primary : scheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: selected ? scheme.primaryContainer : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    color: selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _labeledSlider({
    required String label,
    required double value,
    required String displayValue,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    bool enabled = true,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text(
              displayValue,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: enabled ? scheme.primary : scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }

  Widget _numberField({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove, size: 18),
          constraints: const BoxConstraints.tightFor(width: 32, height: 32),
          padding: EdgeInsets.zero,
          onPressed: value > min
              ? () => onChanged(value - 1)
              : null,
        ),
        SizedBox(
          width: 40,
          child: Text(
            value.toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add, size: 18),
          constraints: const BoxConstraints.tightFor(width: 32, height: 32),
          padding: EdgeInsets.zero,
          onPressed: value < max
              ? () => onChanged(value + 1)
              : null,
        ),
      ],
    );
  }

  Widget _statusToggle({
    required String label,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: value ? scheme.primaryContainer.withValues(alpha: 0.4) : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: value ? scheme.primary : scheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final active = value != 'hide';

    return Material(
      color: active ? scheme.primaryContainer.withValues(alpha: 0.4) : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: active ? scheme.primary : scheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(width: 4),
            SizedBox(
              width: 100,
              child: DropdownButton<String>(
                value: value,
                isDense: true,
                underline: const SizedBox.shrink(),
                style: Theme.of(context).textTheme.bodySmall,
                items: items.map((i) {
                  return DropdownMenuItem(value: i, child: Text(i));
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 2),
        SizedBox(
          height: 32,
          child: DropdownButton<String>(
            value: value,
            isDense: true,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            style: Theme.of(context).textTheme.bodySmall,
            items: items.map((i) {
              return DropdownMenuItem(value: i, child: Text(i));
            }).toList(),
            onChanged: enabled ? onChanged : null,
          ),
        ),
      ],
    );
  }

  // ---- Logic ----

  Future<void> _toggleDemo(String deviceId, bool activate) async {
    setState(() => _loading = true);
    try {
      if (activate) {
        await SystemUiService.setDemoAllowed(deviceId, true);
      } else {
        await SystemUiService.exitDemoMode(deviceId);
        await SystemUiService.setDemoAllowed(deviceId, false);
      }
      if (!mounted) return;
      setState(() {
        _demoActive = activate;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _sendClock(String deviceId) {
    SystemUiService.setClock(deviceId, _clockHour, _clockMinute);
  }
}
