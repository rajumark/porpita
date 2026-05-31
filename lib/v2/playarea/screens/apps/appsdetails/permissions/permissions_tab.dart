import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:porpita/services/device_manager.dart';
import 'package:porpita/services/commands/adb_exec_service.dart';
import 'declared/declared_permissions_page.dart';
import 'requested/requested_permissions_page.dart';
import 'install/install_permissions_page.dart';
import 'runtime/runtime_permissions_page.dart';
import 'permissions_menu_service.dart';

enum _PermSegment { declared, requested, install, runtime }

enum _SpecialAccess {
  overlay('Display Over Other Apps', 'android.settings.action.MANAGE_OVERLAY_PERMISSION'),
  accessibility('Accessibility Services', 'android.settings.ACCESSIBILITY_SETTINGS'),
  defaultApps('Default Apps', 'android.settings.MANAGE_DEFAULT_APPS_SETTINGS'),
  writeSettings('Modify System Settings', 'android.settings.action.MANAGE_WRITE_SETTINGS'),
  usageAccess('Usage Access', 'android.settings.USAGE_ACCESS_SETTINGS'),
  notificationAccess('Notification Access', 'android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS'),
  allFilesAccess('All Files Access', 'android.settings.MANAGE_APP_ALL_FILES_ACCESS_PERMISSION'),
  installUnknownApps('Install Unknown Apps', 'android.settings.MANAGE_UNKNOWN_APP_SOURCES'),
  doNotDisturb('Do Not Disturb Access', 'android.settings.NOTIFICATION_POLICY_ACCESS_SETTINGS');

  final String label;
  final String action;
  const _SpecialAccess(this.label, this.action);
}

class PermissionsTab extends StatefulWidget {
  final String packageName;
  const PermissionsTab({super.key, required this.packageName});

  @override
  State<PermissionsTab> createState() => _PermissionsTabState();
}

class _PermissionsTabState extends State<PermissionsTab> {
  _PermSegment _selected = _PermSegment.runtime;

  final _declaredKey = GlobalKey<DeclaredPermissionsPageState>();
  final _requestedKey = GlobalKey<RequestedPermissionsPageState>();
  final _installKey = GlobalKey<InstallPermissionsPageState>();
  final _runtimeKey = GlobalKey<RuntimePermissionsPageState>();

  void _refresh() {
    switch (_selected) {
      case _PermSegment.declared:
        _declaredKey.currentState?.fetch();
      case _PermSegment.requested:
        _requestedKey.currentState?.fetch();
      case _PermSegment.install:
        _installKey.currentState?.fetch();
      case _PermSegment.runtime:
        _runtimeKey.currentState?.fetch();
    }
  }

  Future<void> _openSpecialAccess(_SpecialAccess access) async {
    final device = context.read<DeviceManager>().selected;
    if (device == null) return;
    await AdbExecService.run(device.id, ['am', 'start', '-a', access.action]);
  }

  Future<void> _openAppInfo() async {
    final device = context.read<DeviceManager>().selected;
    if (device == null) return;
    await PermissionMenuService.openAppInfo(device.id, widget.packageName);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              SegmentedButton<_PermSegment>(
                segments: const [
                  ButtonSegment(value: _PermSegment.runtime, label: Text('Runtime')),
                  ButtonSegment(value: _PermSegment.install, label: Text('Install')),
                  ButtonSegment(value: _PermSegment.declared, label: Text('Declared')),
                  ButtonSegment(value: _PermSegment.requested, label: Text('Requested')),
                ],
                selected: {_selected},
                onSelectionChanged: (s) => setState(() => _selected = s.first),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                tooltip: 'Options',
                onSelected: _onMenuSelected,
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'refresh', child: Text('Refresh')),
                  const PopupMenuItem(value: 'appInfo', child: Text('App Info')),
                  const PopupMenuDivider(),
                  const PopupMenuItem(value: 'header_special', enabled: false, child: Text('Special App Access', style: TextStyle(fontWeight: FontWeight.bold))),
                  ..._SpecialAccess.values.map((a) => PopupMenuItem(value: 'special_${a.name}', child: Text(a.label))),
                ],
              ),
            ],
          ),
        ),
        Expanded(child: _buildPage()),
      ],
    );
  }

  void _onMenuSelected(String value) {
    if (value == 'refresh') {
      _refresh();
    } else if (value == 'appInfo') {
      _openAppInfo();
    } else if (value.startsWith('special_')) {
      final name = value.substring(8);
      final access = _SpecialAccess.values.firstWhere((a) => a.name == name);
      _openSpecialAccess(access);
    }
  }

  Widget _buildPage() {
    switch (_selected) {
      case _PermSegment.declared:
        return DeclaredPermissionsPage(key: _declaredKey, packageName: widget.packageName);
      case _PermSegment.requested:
        return RequestedPermissionsPage(key: _requestedKey, packageName: widget.packageName);
      case _PermSegment.install:
        return InstallPermissionsPage(key: _installKey, packageName: widget.packageName);
      case _PermSegment.runtime:
        return RuntimePermissionsPage(key: _runtimeKey, packageName: widget.packageName);
    }
  }
}