import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../../services/adb_manager.dart';

enum QrPairingState {
  idle,
  generating,
  waitingForScan,
  deviceFound,
  pairing,
  pairingSuccess,
  discovering,
  connecting,
  connected,
  failed,
}

class DiscoveredDevice {
  final String ip;
  final int port;
  final String serviceName;

  const DiscoveredDevice({required this.ip, required this.port, required this.serviceName});
}

class QrPairingService extends ChangeNotifier {
  QrPairingState _state = QrPairingState.idle;
  String? _error;
  String _password = '';
  String _serviceName = '';
  String _qrPayload = '';
  DiscoveredDevice? _discoveredDevice;
  String _pairingOutput = '';
  String _connectionOutput = '';

  Process? _mdnsProcess;
  Timer? _discoveryTimer;

  QrPairingState get state => _state;
  String? get error => _error;
  String get password => _password;
  String get serviceName => _serviceName;
  String get qrPayload => _qrPayload;
  DiscoveredDevice? get discoveredDevice => _discoveredDevice;
  String get pairingOutput => _pairingOutput;
  String get connectionOutput => _connectionOutput;

  String? _adbPath() => AdbManager.instance.adbPath;

  void _setState(QrPairingState s) {
    _state = s;
    notifyListeners();
  }

  void _setError(String e) {
    _error = e;
    _state = QrPairingState.failed;
    notifyListeners();
  }

  void reset() {
    _mdnsProcess?.kill();
    _discoveryTimer?.cancel();
    _state = QrPairingState.idle;
    _error = null;
    _password = '';
    _serviceName = '';
    _qrPayload = '';
    _discoveredDevice = null;
    _pairingOutput = '';
    _connectionOutput = '';
    notifyListeners();
  }

  Future<void> startQrPairing() async {
    _setState(QrPairingState.generating);

    _password = _generatePassword();
    _serviceName = 'Porpita_${Random().nextInt(9999).toString().padLeft(4, '0')}';
    _qrPayload = 'WIFI:T:ADB;S:$_serviceName;P:$_password;;';

    _setState(QrPairingState.waitingForScan);
    _startMdnsDiscovery();
  }

  String _generatePassword() {
    const chars = '0123456789';
    final rng = Random.secure();
    return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  void _startMdnsDiscovery() {
    _discoveryTimer?.cancel();
    _mdnsProcess?.kill();

    _discoveryTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _pollMdns();
    });

    _pollMdns();
  }

  Future<void> _pollMdns() async {
    final adb = _adbPath();
    if (adb == null) {
      _setError('ADB not available');
      return;
    }

    try {
      final result = await Process.run(adb, ['mdns', 'check']);
      final output = result.stdout.toString().trim();

      if (output.contains('_adb-tls-pairing._tcp')) {
        final lines = output.split('\n');
        for (final line in lines) {
          if (line.contains('_adb-tls-pairing._tcp') && line.contains(_serviceName)) {
            final match = RegExp(r'(\d+\.\d+\.\d+\.\d+):(\d+)').firstMatch(line);
            if (match != null) {
              final ip = match.group(1)!;
              final port = int.parse(match.group(2)!);
              _discoveredDevice = DiscoveredDevice(ip: ip, port: port, serviceName: _serviceName);
              _discoveryTimer?.cancel();
              _setState(QrPairingState.deviceFound);
              await _pairDevice();
              return;
            }
          }
        }
      }

      final connectResult = await Process.run(adb, ['mdns', 'check']);
      final connectOutput = connectResult.stdout.toString().trim();
      final connectLines = connectOutput.split('\n');
      for (final line in connectLines) {
        final match = RegExp(r'(\d+\.\d+\.\d+\.\d+):(\d+)').firstMatch(line);
        if (match != null) {
          final ip = match.group(1)!;
          final port = int.parse(match.group(2)!);
          if (_discoveredDevice == null) {
            _discoveredDevice = DiscoveredDevice(ip: ip, port: port, serviceName: line);
          }
        }
      }

      final devicesResult = await Process.run(adb, ['devices']);
      final deviceLines = devicesResult.stdout.toString().trim().split('\n');
      for (final line in deviceLines.skip(1)) {
        final parts = line.trim().split(RegExp(r'\s+'));
        if (parts.length >= 2 && parts[0].contains(RegExp(r'\d+\.\d+\.\d+\.\d+')) && parts[1] == 'device') {
          _discoveryTimer?.cancel();
          _pairingOutput = 'Device already connected: ${parts[0]}';
          _connectionOutput = parts[0];
          _setState(QrPairingState.connected);
          return;
        }
      }
    } catch (e) {
      // Continue polling silently
    }
  }

  Future<void> _pairDevice() async {
    final adb = _adbPath();
    if (adb == null || _discoveredDevice == null) {
      _setError('ADB not available or no device found');
      return;
    }

    _setState(QrPairingState.pairing);

    try {
      final result = await Process.run(adb, [
        'pair',
        '${_discoveredDevice!.ip}:${_discoveredDevice!.port}',
        _password,
      ]).timeout(const Duration(seconds: 15));

      _pairingOutput = result.stdout.toString().trim();
      final stderr = result.stderr.toString().trim();
      if (stderr.isNotEmpty && _pairingOutput.isEmpty) _pairingOutput = stderr;

      if (_pairingOutput.toLowerCase().contains('successfully paired') ||
          result.exitCode == 0) {
        _setState(QrPairingState.pairingSuccess);
        await _discoverAndConnect();
      } else {
        _setError(_pairingOutput.isNotEmpty ? _pairingOutput : 'Pairing failed');
      }
    } on TimeoutException {
      _setError('Pairing timed out. Make sure your phone is on the same network and scan the QR code.');
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> _discoverAndConnect() async {
    _setState(QrPairingState.discovering);

    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(seconds: 2));

      final adb = _adbPath();
      if (adb == null) {
        _setError('ADB not available');
        return;
      }

      try {
        final result = await Process.run(adb, ['mdns', 'check']);
        final output = result.stdout.toString().trim();
        final lines = output.split('\n');
        for (final line in lines) {
          if (line.contains('_adb-tls-connect._tcp')) {
            final match = RegExp(r'(\d+\.\d+\.\d+\d*):(\d+)').firstMatch(line);
            if (match != null) {
              final ip = match.group(1)!;
              final port = match.group(2)!;
              await _connectDevice(ip, port);
              return;
            }
          }
        }
      } catch (_) {
        continue;
      }
    }
    _setError('Could not discover connection port. Try connecting manually.');
  }

  Future<void> _connectDevice(String ip, String port) async {
    _setState(QrPairingState.connecting);
    final adb = _adbPath();
    if (adb == null) {
      _setError('ADB not available');
      return;
    }

    try {
      final result = await Process.run(adb, ['connect', '$ip:$port']).timeout(const Duration(seconds: 10));
      _connectionOutput = result.stdout.toString().trim();
      final stderr = result.stderr.toString().trim();
      if (stderr.isNotEmpty && _connectionOutput.isEmpty) _connectionOutput = stderr;

      if (_connectionOutput.toLowerCase().contains('connected') ||
          _connectionOutput.toLowerCase().contains('already connected')) {
        _setState(QrPairingState.connected);
      } else {
        _setError(_connectionOutput.isNotEmpty ? _connectionOutput : 'Connection failed');
      }
    } on TimeoutException {
      _setError('Connection timed out');
    } catch (e) {
      _setError(e.toString());
    }
  }

  @override
  void dispose() {
    _mdnsProcess?.kill();
    _discoveryTimer?.cancel();
    super.dispose();
  }
}