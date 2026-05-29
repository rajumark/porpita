import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'adb_manager.dart';

class AdbDevice {
  final String id;
  final String status;

  const AdbDevice({required this.id, required this.status});

  bool get isConnected => status == 'device';

  @override
  bool operator ==(Object other) =>
      other is AdbDevice && other.id == id && other.status == status;

  @override
  int get hashCode => Object.hash(id, status);

  @override
  String toString() => '$id\t$status';
}

class DeviceManager extends ChangeNotifier {
  final _devices = <AdbDevice>[];
  AdbDevice? _selected;
  Timer? _timer;
  bool _running = false;

  List<AdbDevice> get devices => List.unmodifiable(_devices);
  AdbDevice? get selected => _selected;
  bool get hasDevices => _devices.isNotEmpty;

  void start() {
    _poll();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _poll());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void select(AdbDevice device) {
    if (_selected == device) return;
    _selected = device;
    notifyListeners();
  }

  Future<void> _poll() async {
    if (_running) return;
    _running = true;

    try {
      final adbPath = AdbManager.instance.adbPath;
      if (adbPath == null) return;

      final result = await Process.run(adbPath, ['devices']);
      if (result.exitCode != 0) return;

      final parsed = _parseDevices(result.stdout.toString());

      final changed = !_listEquals(_devices, parsed);
      if (!changed) return;

      _devices
        ..clear()
        ..addAll(parsed);

      _resolveSelection();

      notifyListeners();
    } catch (_) {
    } finally {
      _running = false;
    }
  }

  void _resolveSelection() {
    if (_devices.isEmpty) {
      _selected = null;
      return;
    }

    final stillConnected =
        _selected != null && _devices.any((d) => d.id == _selected!.id && d.isConnected);

    if (stillConnected) return;

    _selected = _devices.cast<AdbDevice?>().firstWhere(
      (d) => d!.isConnected,
      orElse: () => _devices.first,
    );
  }

  List<AdbDevice> _parseDevices(String output) {
    final lines = output.split('\n');
    if (lines.isEmpty) return [];

    final list = <AdbDevice>[];
    var started = false;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed == 'List of devices attached') {
        started = true;
        continue;
      }
      if (!started || trimmed.isEmpty) continue;

      final parts = trimmed.split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        list.add(AdbDevice(id: parts[0], status: parts[1]));
      }
    }

    return list;
  }

  bool _listEquals(List<AdbDevice> a, List<AdbDevice> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
