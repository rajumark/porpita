import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../../services/adb_manager.dart';

enum WirelessAdbPhase { idle, pairing, connecting, tcpSwitching, done }

enum WirelessAdbWorkflow { android11Plus, android10AndBelow }

class WirelessAdbResult {
  final bool success;
  final String message;

  const WirelessAdbResult(this.success, this.message);
}

class WirelessAdbService extends ChangeNotifier {
  WirelessAdbPhase _phase = WirelessAdbPhase.idle;
  bool _busy = false;
  String? _error;
  String _output = '';

  WirelessAdbPhase get phase => _phase;
  bool get busy => _busy;
  String? get error => _error;
  String get output => _output;

  String? _adbPath() => AdbManager.instance.adbPath;

  void _setPhase(WirelessAdbPhase p) {
    _phase = p;
    notifyListeners();
  }

  void _setBusy(bool v) {
    _busy = v;
    notifyListeners();
  }

  void _setError(String? e) {
    _error = e;
    notifyListeners();
  }

  void _setOutput(String o) {
    _output = o;
    notifyListeners();
  }

  void reset() {
    _phase = WirelessAdbPhase.idle;
    _busy = false;
    _error = null;
    _output = '';
    notifyListeners();
  }

  Future<WirelessAdbResult> pairDevice(String ipAddress, String pairingPort, String pairingCode) async {
    final adb = _adbPath();
    if (adb == null) return const WirelessAdbResult(false, 'ADB not available');

    _setBusy(true);
    _setError(null);
    _setPhase(WirelessAdbPhase.pairing);
    _setOutput('Pairing with $ipAddress:$pairingPort...');

    try {
      final result = await Process.run(adb, ['pair', '$ipAddress:$pairingPort', pairingCode]);
      final stdout = result.stdout.toString().trim();
      final stderr = result.stderr.toString().trim();
      final output = stdout.isNotEmpty ? stdout : stderr;
      _setOutput(output);

      if (result.exitCode == 0 && output.toLowerCase().contains('successfully paired')) {
        _setPhase(WirelessAdbPhase.pairing);
        _setBusy(false);
        return WirelessAdbResult(true, output);
      } else {
        _setError(output);
        _setBusy(false);
        return WirelessAdbResult(false, output);
      }
    } catch (e) {
      _setError(e.toString());
      _setBusy(false);
      return WirelessAdbResult(false, e.toString());
    }
  }

  Future<WirelessAdbResult> connectDevice(String ipAddress, String connectionPort) async {
    final adb = _adbPath();
    if (adb == null) return const WirelessAdbResult(false, 'ADB not available');

    _setBusy(true);
    _setError(null);
    _setPhase(WirelessAdbPhase.connecting);
    _setOutput('Connecting to $ipAddress:$connectionPort...');

    try {
      final result = await Process.run(adb, ['connect', '$ipAddress:$connectionPort']);
      final stdout = result.stdout.toString().trim();
      final stderr = result.stderr.toString().trim();
      final output = stdout.isNotEmpty ? stdout : stderr;
      _setOutput(output);

      if (output.toLowerCase().contains('connected to') || output.toLowerCase().contains('already connected')) {
        _setPhase(WirelessAdbPhase.done);
        _setBusy(false);
        return WirelessAdbResult(true, output);
      } else {
        _setError(output);
        _setBusy(false);
        return WirelessAdbResult(false, output);
      }
    } catch (e) {
      _setError(e.toString());
      _setBusy(false);
      return WirelessAdbResult(false, e.toString());
    }
  }

  Future<WirelessAdbResult> switchToTcpMode(String deviceId) async {
    final adb = _adbPath();
    if (adb == null) return const WirelessAdbResult(false, 'ADB not available');

    _setBusy(true);
    _setError(null);
    _setPhase(WirelessAdbPhase.tcpSwitching);
    _setOutput('Switching device to TCP mode on port 5555...');

    try {
      final result = await Process.run(adb, ['-s', deviceId, 'tcpip', '5555']);
      final stdout = result.stdout.toString().trim();
      final stderr = result.stderr.toString().trim();
      final output = stdout.isNotEmpty ? stdout : stderr;
      _setOutput(output);

      if (result.exitCode == 0) {
        _setBusy(false);
        return WirelessAdbResult(true, output);
      } else {
        _setError(output);
        _setBusy(false);
        return WirelessAdbResult(false, output);
      }
    } catch (e) {
      _setError(e.toString());
      _setBusy(false);
      return WirelessAdbResult(false, e.toString());
    }
  }

  Future<WirelessAdbResult> disconnectAll() async {
    final adb = _adbPath();
    if (adb == null) return const WirelessAdbResult(false, 'ADB not available');

    _setBusy(true);
    _setError(null);
    _setOutput('Disconnecting all wireless devices...');

    try {
      final result = await Process.run(adb, ['disconnect']);
      final output = result.stdout.toString().trim();
      _setOutput(output.isNotEmpty ? output : 'Disconnected all');
      _setBusy(false);
      return WirelessAdbResult(true, output);
    } catch (e) {
      _setError(e.toString());
      _setBusy(false);
      return WirelessAdbResult(false, e.toString());
    }
  }

  Future<WirelessAdbResult> disconnectDevice(String address) async {
    final adb = _adbPath();
    if (adb == null) return const WirelessAdbResult(false, 'ADB not available');

    _setBusy(true);
    _setError(null);
    _setOutput('Disconnecting $address...');

    try {
      final result = await Process.run(adb, ['disconnect', address]);
      final output = result.stdout.toString().trim();
      _setOutput(output);
      _setBusy(false);
      return WirelessAdbResult(true, output);
    } catch (e) {
      _setError(e.toString());
      _setBusy(false);
      return WirelessAdbResult(false, e.toString());
    }
  }

  Future<WirelessAdbResult> resetServer() async {
    final adb = _adbPath();
    if (adb == null) return const WirelessAdbResult(false, 'ADB not available');

    _setBusy(true);
    _setError(null);
    _setOutput('Killing ADB server...');

    try {
      await Process.run(adb, ['kill-server']);
      _setOutput('ADB server killed. Starting fresh...');
      await Future.delayed(const Duration(seconds: 2));
      await Process.run(adb, ['start-server']);
      _setOutput('ADB server restarted successfully.');
      _setBusy(false);
      return const WirelessAdbResult(true, 'ADB server restarted.');
    } catch (e) {
      _setError(e.toString());
      _setBusy(false);
      return WirelessAdbResult(false, e.toString());
    }
  }

  Future<WirelessAdbResult> pingDevice(String ipAddress) async {
    _setBusy(true);
    _setError(null);
    _setOutput('Pinging $ipAddress...');

    try {
      final countArg = Platform.isWindows ? '-n' : '-c';
      final result = await Process.run('ping', [countArg, '3', ipAddress]);
      final output = result.stdout.toString().trim();
      _setOutput(output);

      if (result.exitCode == 0) {
        _setBusy(false);
        return WirelessAdbResult(true, output);
      } else {
        _setError('Device unreachable. Check network connectivity.');
        _setBusy(false);
        return WirelessAdbResult(false, output);
      }
    } catch (e) {
      _setError(e.toString());
      _setBusy(false);
      return WirelessAdbResult(false, e.toString());
    }
  }

  Future<String> listDevices() async {
    final adb = _adbPath();
    if (adb == null) return 'ADB not available';

    try {
      final result = await Process.run(adb, ['devices', '-l']);
      return result.stdout.toString().trim();
    } catch (e) {
      return 'Error: $e';
    }
  }
}