import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:porpita/services/device_manager.dart';
import 'package:porpita/v2/widgets/rounded_container.dart';
import 'deviceinfo_model.dart';
import 'deviceinfo_service.dart';

class DeviceInfoScreen extends StatefulWidget {
  const DeviceInfoScreen({super.key});

  @override
  State<DeviceInfoScreen> createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  BasicDeviceInfo? _basic;
  AdvancedDeviceInfo? _advanced;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;
  String? _lastDeviceId;

  static const _tabs = ['Basic', 'Advanced'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleDeviceSwitch(String deviceId) {
    _lastDeviceId = deviceId;
    _initialFetch(deviceId);
  }

  Future<void> _initialFetch(String deviceId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final basic = await DeviceInfoService.fetchBasic(deviceId);
      if (!mounted) return;
      setState(() {
        _basic = basic;
        _isLoading = false;
      });
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
      if (_tabController.index == 0) {
        final basic = await DeviceInfoService.fetchBasic(deviceId);
        if (!mounted) return;
        setState(() => _basic = basic);
      } else {
        final advanced = await DeviceInfoService.fetchAdvanced(deviceId);
        if (!mounted) return;
        setState(() => _advanced = advanced);
      }
    } catch (_) {}
    finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  Future<void> _loadAdvanced(String deviceId) async {
    if (_advanced != null) return;
    try {
      final advanced = await DeviceInfoService.fetchAdvanced(deviceId);
      if (!mounted) return;
      setState(() => _advanced = advanced);
    } catch (_) {}
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
                      child: Text('Device Info',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  ),
                  if (_isRefreshing)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      iconSize: 20,
                      tooltip: 'Refresh',
                      onPressed: device == null
                          ? null
                          : () => _manualRefresh(device.id),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints.tight(const Size(36, 36)),
                    ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              tabs: _tabs.map((t) => Tab(text: t)).toList(),
              onTap: (_) {
                if (device != null) _loadAdvanced(device.id);
              },
              labelStyle: Theme.of(context).textTheme.labelMedium,
              unselectedLabelStyle:
                  Theme.of(context).textTheme.labelMedium,
              indicatorSize: TabBarIndicatorSize.label,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _BasicTab(
                    info: _basic,
                    isLoading: _isLoading,
                    error: _error,
                  ),
                  _AdvancedTab(
                    info: _advanced,
                    isLoading: _isLoading,
                    onRetry: device != null
                        ? () => _loadAdvanced(device.id)
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BasicTab extends StatelessWidget {
  final BasicDeviceInfo? info;
  final bool isLoading;
  final String? error;

  const _BasicTab({this.info, required this.isLoading, this.error});

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (error != null) {
      return Center(
        child: Text(error!,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Theme.of(context).colorScheme.error)),
      );
    }
    if (info == null) return const Center(child: Text('No device connected'));

    return ListView(
      padding: const EdgeInsets.only(bottom: 12),
      children: [
        _DeviceHeroCard(info: info!),
        _section(context, Icons.perm_device_information, 'Device Identity', [
          (label: 'Device Name', value: info!.deviceName),
          (label: 'Manufacturer', value: info!.manufacturer),
          (label: 'Codename', value: info!.codename),
          (label: 'Serial Number', value: info!.serialNumber),
        ]),
        _section(context, Icons.android, 'Android Info', [
          (label: 'Android Version', value: info!.androidVersion),
          (label: 'SDK Version', value: info!.sdkVersion),
          (label: 'Build Fingerprint', value: info!.buildFingerprint),
          (label: 'Security Patch', value: info!.securityPatch),
        ]),
        _section(context, Icons.battery_std, 'Battery', [
          (label: 'Battery Level', value: info!.batteryLevel),
          (label: 'Status', value: info!.batteryStatus),
          (label: 'Health', value: info!.batteryHealth),
          (label: 'Temperature', value: info!.batteryTemp),
          (label: 'Technology', value: info!.batteryTech),
        ]),
        _section(context, Icons.screen_lock_portrait, 'Screen', [
          (label: 'Resolution', value: info!.screenResolution),
          (label: 'Density', value: info!.screenDensity),
        ]),
        _section(context, Icons.memory, 'Hardware', [
          (label: 'CPU ABI', value: info!.cpuAbi),
          (label: 'RAM Total', value: info!.ramTotal),
          (label: 'RAM Free', value: info!.ramFree),
          (label: 'Storage Total', value: info!.internalStorageTotal),
          (label: 'Storage Free', value: info!.internalStorageFree),
        ]),
        _section(context, Icons.wifi, 'Network', [
          (label: 'IP Address', value: info!.ipAddress),
          (label: 'WiFi State', value: info!.wifiState),
        ]),
        _section(context, Icons.admin_panel_settings, 'Security', [
          (label: 'Root Status', value: info!.rootStatus),
          (label: 'USB Debugging', value: info!.usbDebugging),
          (label: 'Device Uptime', value: info!.deviceUptime),
        ]),
      ],
    );
  }
}

class _AdvancedTab extends StatelessWidget {
  final AdvancedDeviceInfo? info;
  final bool isLoading;
  final VoidCallback? onRetry;

  const _AdvancedTab({this.info, required this.isLoading, this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (info == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Advanced info not loaded',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Load'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 12),
      children: [
        _section(context, Icons.settings_system_daydream, 'System', [
          (label: 'Kernel Version', value: info!.kernelVersion),
          (label: 'Bootloader', value: info!.bootloaderVersion),
          (label: 'Baseband', value: info!.basebandVersion),
          (label: 'SELinux', value: info!.selinuxStatus),
          (label: 'Encryption', value: info!.encryptionState),
          (label: 'Treble', value: info!.trebleSupport),
          (label: 'Verified Boot', value: info!.verifiedBoot),
        ]),
        _section(context, Icons.developer_board, 'CPU', [
          (label: 'CPU Model', value: info!.cpuModel),
          (label: 'CPU Cores', value: info!.cpuCores),
          (label: 'CPU Frequency', value: info!.cpuFrequency),
        ]),
        _section(context, Icons.storage, 'Memory', [
          (label: 'Used RAM', value: info!.ramUsed),
          (label: 'Low Memory', value: info!.lowMemoryState),
        ]),
        _section(context, Icons.monitor, 'Display', [
          (label: 'Refresh Rate', value: info!.refreshRate),
          (label: 'Display State', value: info!.displayState),
          (label: 'Orientation', value: info!.orientation),
        ]),
        _section(context, Icons.network_check, 'Network', [
          (label: 'WiFi SSID', value: info!.wifiSsid),
          (label: 'Mobile Network', value: info!.mobileNetwork),
          (label: 'Airplane Mode', value: info!.airplaneMode),
          (label: 'DNS Servers', value: info!.dnsServers),
        ]),
        _section(context, Icons.sensors, 'Sensors', [
          (label: 'Sensor Count', value: info!.sensorCount),
        ]),
        _section(context, Icons.videogame_asset, 'Graphics', [
          (label: 'GPU Model', value: info!.gpuModel),
          (label: 'OpenGL Version', value: info!.openGlVersion),
          (label: 'Vulkan', value: info!.vulkanSupport),
        ]),
        _section(context, Icons.code, 'Developer Diagnostics', [
          (label: 'Running Processes', value: info!.runningProcesses),
          (label: 'Foreground App', value: info!.foregroundApp),
          (label: 'Installed Apps', value: info!.installedAppsCount),
          (label: 'Logcat Buffer', value: info!.logcatBufferSize),
        ]),
      ],
    );
  }
}

class _DeviceHeroCard extends StatelessWidget {
  final BasicDeviceInfo info;

  const _DeviceHeroCard({required this.info});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Material(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.phone_android,
                  size: 36, color: scheme.onPrimaryContainer),
              const SizedBox(height: 8),
              Text(
                info.deviceName != '—' ? info.deviceName : 'Unknown Device',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '${info.manufacturer} • Android ${info.androidVersion}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _chip(context, Icons.battery_std, info.batteryLevel != '—'
                      ? '${info.batteryLevel}%'
                      : '—'),
                  const SizedBox(width: 8),
                  _chip(context, Icons.screen_lock_portrait,
                      info.screenResolution),
                  const SizedBox(width: 8),
                  _chip(context, Icons.memory, info.cpuAbi),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, IconData icon, String text) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.onPrimaryContainer.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: scheme.onPrimaryContainer),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

Widget _section(
    BuildContext context, IconData icon, String title, List<({String label, String value})> rows) {
  final scheme = Theme.of(context).colorScheme;
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4, top: 4),
          child: Row(
            children: [
              Icon(icon, size: 14, color: scheme.primary),
              const SizedBox(width: 6),
              Text(
                title.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
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
                    Divider(
                        height: 1,
                        color: scheme.outlineVariant.withValues(alpha: 0.4)),
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
          child: Text(label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onDoubleTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Copied'), duration: Duration(seconds: 1)),
              );
            },
            child: SelectableText(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
            ),
          ),
        ),
      ],
    ),
  );
}
