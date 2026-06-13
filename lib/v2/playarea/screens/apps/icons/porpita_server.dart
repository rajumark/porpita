import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:porpita/services/adb_manager.dart';
import 'package:porpita/services/commands/adb_exec_service.dart';

class PorpitaServer {
  static const String _socketName = 'porpita';
  static const String _dexPath = '/data/local/tmp/porpita/porpita.dex';

  final String deviceId;
  bool _connected = false;
  bool _starting = false;
  Socket? _socket;
  int _forwardedFilePort = 0;
  final _buffer = <int>[];
  final Map<String, Completer<Map<String, dynamic>>> _pendingRequests = {};

  static final Map<String, PorpitaServer> _instances = {};

  PorpitaServer(this.deviceId);

  static PorpitaServer forDevice(String deviceId) {
    return _instances.putIfAbsent(deviceId, () => PorpitaServer(deviceId));
  }

  bool get isConnected => _connected;

  Future<void> ensureRunning() async {
    if (_connected) return;
    if (_starting) return;
    _starting = true;
    try {
      final isRunning = await _checkIfRunning();
      if (!isRunning) {
        await _pushDex();
        await _startServer();
        await _waitForServer();
      }
      await _connect();
    } finally {
      _starting = false;
    }
  }

  Future<bool> _checkIfRunning() async {
    final result = await AdbExecService.run(
      deviceId,
      ['cat', '/proc/net/unix'],
    );
    return result.contains('@$_socketName');
  }

  Future<void> _pushDex() async {
    final appDir = await getApplicationSupportDirectory();
    final dexFile = File('${appDir.path}${Platform.pathSeparator}porpita.dex');

    if (!dexFile.existsSync()) {
      final byteData = await rootBundle.load('assets/dex/porpita.dex');
      dexFile.writeAsBytesSync(byteData.buffer.asUint8List());
    }

    await AdbExecService.runAdb(
      deviceId,
      ['push', dexFile.path, _dexPath],
    );
  }

  Future<void> _startServer() async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) throw Exception('ADB not available');

    final process = await Process.start(adb, [
      '-s',
      deviceId,
      'shell',
      'CLASSPATH=$_dexPath app_process /system/bin io.porpita.server.Server',
    ]);

    process.stdout.listen((_) {});
    process.stderr.listen((_) {});

    await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> _waitForServer() async {
    for (int i = 0; i < 50; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (await _checkIfRunning()) return;
    }
    throw Exception('Server failed to start within 10 seconds');
  }

  Future<void> _connect() async {
    if (_connected) return;

    final adb = AdbManager.instance.adbPath;
    if (adb == null) throw Exception('ADB not available');

    final port = await _findAvailablePort();
    await Process.run(adb, [
      '-s',
      deviceId,
      'forward',
      'tcp:$port',
      'localabstract:$_socketName',
    ]);

    final socket = await Socket.connect('127.0.0.1', port, timeout: const Duration(seconds: 5));
    _connected = true;
    _socket = socket;

    socket.listen(
      (data) => _handleData(data),
      onError: (_) {
        _connected = false;
        socket.destroy();
      },
      onDone: () {
        _connected = false;
      },
    );
  }

  void _handleData(List<int> data) {
    _buffer.addAll(data);

    while (_buffer.length >= 4) {
      final length = _decodeLength(_buffer.sublist(0, 4));

      if (length <= 0 || length > 10 * 1024 * 1024) {
        _buffer.clear();
        return;
      }

      if (_buffer.length < 4 + length) break;

      _buffer.removeRange(0, 4);
      final messageBytes = _buffer.sublist(0, length);
      _buffer.removeRange(0, length);

      try {
        final response = jsonDecode(utf8.decode(messageBytes)) as Map<String, dynamic>;
        final id = response['id'] as String?;
        if (id != null && _pendingRequests.containsKey(id)) {
          _pendingRequests[id]!.complete(response['result'] as Map<String, dynamic>);
          _pendingRequests.remove(id);
        }
      } catch (_) {}
    }
  }

  Future<Map<String, dynamic>> sendMessage(String method, [Map<String, dynamic>? params]) async {
    await ensureRunning();

    final id = _generateId();
    final request = <String, dynamic>{
      'id': id,
      'method': method,
    };
    if (params != null) {
      request['params'] = params;
    }

    final completer = Completer<Map<String, dynamic>>();
    _pendingRequests[id] = completer;

    final requestBytes = utf8.encode(jsonEncode(request));
    final lengthBytes = _encodeLength(requestBytes.length);
    _socket!.add([...lengthBytes, ...requestBytes]);
    await _socket!.flush();

    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        _pendingRequests.remove(id);
        throw TimeoutException('Request timed out: $method');
      },
    );
  }

  Future<Map<String, String>> getAppIcons(List<String> packageNames) async {
    await ensureRunning();

    final result = await sendMessage('getAppIcons', {
      'packageNames': packageNames,
    });

    final iconPaths = <String, String>{};
    for (final entry in result.entries) {
      if (entry.value is String && (entry.value as String).isNotEmpty) {
        iconPaths[entry.key] = entry.value as String;
      }
    }

    return iconPaths;
  }

  Future<int> getFileServerPort() async {
    if (_forwardedFilePort > 0) {
      final running = await _checkFileServerRunning();
      if (running) return _forwardedFilePort;
    }

    final result = await sendMessage('startFileServer');
    final devicePort = result['port'] as num;

    final adb = AdbManager.instance.adbPath;
    if (adb == null) throw Exception('ADB not available');

    final localPort = await _findAvailablePort();
    await Process.run(adb, [
      '-s',
      deviceId,
      'forward',
      'tcp:$localPort',
      'tcp:$devicePort',
    ]);

    _forwardedFilePort = localPort;
    return localPort;
  }

  Future<bool> _checkFileServerRunning() async {
    try {
      final result = await sendMessage('isFileServerRunning');
      return result['running'] == true;
    } catch (_) {
      return false;
    }
  }

  String getIconUrl(int localPort, String iconPath) {
    return 'http://127.0.0.1:$localPort${Uri.encodeFull(iconPath)}';
  }

  Future<int> _findAvailablePort() async {
    final random = Random();
    for (int i = 0; i < 100; i++) {
      final port = 10000 + random.nextInt(50000);
      try {
        final socket = await ServerSocket.bind('127.0.0.1', port);
        socket.close();
        return port;
      } catch (_) {
        continue;
      }
    }
    throw Exception('No available port found');
  }

  String _generateId() {
    return DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  }

  List<int> _encodeLength(int value) {
    return [
      (value >> 24) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 8) & 0xFF,
      value & 0xFF,
    ];
  }

  int _decodeLength(List<int> bytes) {
    return (bytes[0] << 24) | (bytes[1] << 16) | (bytes[2] << 8) | bytes[3];
  }

  void disconnect() {
    _connected = false;
    _socket?.destroy();
    _socket = null;
  }

  static void removeDevice(String deviceId) {
    final instance = _instances.remove(deviceId);
    instance?.disconnect();
  }
}