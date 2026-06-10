import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

enum AdbSetupStatus { idle, downloading, extracting, ready, error }

enum PlatformOs { macos, linux, windows }

class AdbManager extends ChangeNotifier {
  static final AdbManager _instance = AdbManager._();
  static AdbManager get instance => _instance;

  AdbManager._();

  static const _baseUrl =
      'https://github.com/rajumark/adbcontent/raw/main';

  String? _adbPath;
  String? _adbVersion;
  String? _error;
  AdbSetupStatus _status = AdbSetupStatus.idle;

  int _downloadedBytes = 0;
  int _totalBytes = 0;

  String? get adbPath => _adbPath;
  String? get adbVersion => _adbVersion;
  String? get error => _error;
  AdbSetupStatus get status => _status;
  int get downloadedBytes => _downloadedBytes;
  int get totalBytes => _totalBytes;

  bool get isReady => _status == AdbSetupStatus.ready;

  double get downloadProgress =>
      _totalBytes > 0 ? _downloadedBytes / _totalBytes : 0.0;

  PlatformOs get platform {
    if (Platform.isMacOS) return PlatformOs.macos;
    if (Platform.isLinux) return PlatformOs.linux;
    if (Platform.isWindows) return PlatformOs.windows;
    return PlatformOs.macos;
  }

  String get _zipFileName {
    switch (platform) {
      case PlatformOs.macos:
        return 'platform-tools-macos.zip';
      case PlatformOs.linux:
        return 'platform-tools-linux.zip';
      case PlatformOs.windows:
        return 'platform-tools-windows.zip';
    }
  }

  String get _downloadUrl => '$_baseUrl/$_zipFileName';

  String get platformLabel {
    switch (platform) {
      case PlatformOs.macos:
        return 'macOS';
      case PlatformOs.linux:
        return 'Linux';
      case PlatformOs.windows:
        return 'Windows';
    }
  }

  Future<void> initialize() async {
    if (_status == AdbSetupStatus.ready ||
        _status == AdbSetupStatus.downloading ||
        _status == AdbSetupStatus.extracting) {
      return;
    }

    final adbDir = await _appSupportDir;

    if (await _isAdbReady(adbDir)) {
      _adbPath = _findAdbBinary(adbDir);
      await _runAdbVersion();
      _status = AdbSetupStatus.ready;
      notifyListeners();
      return;
    }

    await setup();
  }

  Future<void> setup() async {
    if (_status == AdbSetupStatus.downloading ||
        _status == AdbSetupStatus.extracting) {
      return;
    }

    _error = null;
    _downloadedBytes = 0;
    _totalBytes = 0;
    _status = AdbSetupStatus.downloading;
    notifyListeners();

    try {
      final bytes = await _downloadZip();

      _status = AdbSetupStatus.extracting;
      notifyListeners();

      final adbDir = await _appSupportDir;
      if (adbDir.existsSync()) {
        adbDir.deleteSync(recursive: true);
      }

      await _extractZip(bytes, adbDir);

      final binary = _findAdbBinary(adbDir);
      if (binary == null) {
        throw Exception('ADB binary not found after extraction');
      }

      _adbPath = binary;

      if (platform != PlatformOs.windows) {
        await Process.run('chmod', ['+x', binary]);
      }

      if (platform == PlatformOs.macos) {
        await Process.run('xattr', ['-dr', 'com.apple.quarantine', binary]);
      }

      await _runAdbVersion();
      _status = AdbSetupStatus.ready;
    } catch (e) {
      _error = _humanizeError(e);
      _status = AdbSetupStatus.error;
    }
    notifyListeners();
  }

  Future<void> retry() async {
    _error = null;
    _status = AdbSetupStatus.idle;
    notifyListeners();
    await setup();
  }

  Future<Directory> get _appSupportDir async {
    final appDir = await getApplicationSupportDirectory();
    return Directory('${appDir.path}${Platform.pathSeparator}adb');
  }

  Future<bool> _isAdbReady(Directory adbDir) async {
    if (!adbDir.existsSync()) return false;
    return _findAdbBinary(adbDir) != null;
  }

  String? _findAdbBinary(Directory adbDir) {
    final platformTools = Directory(
      '${adbDir.path}${Platform.pathSeparator}platform-tools',
    );
    if (!platformTools.existsSync()) return null;

    final binaryName = platform == PlatformOs.windows ? 'adb.exe' : 'adb';
    final binary = File(
      '${platformTools.path}${Platform.pathSeparator}$binaryName',
    );
    return binary.existsSync() ? binary.path : null;
  }

  Future<List<int>> _downloadZip() async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(_downloadUrl));
      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception(
          'Download failed (HTTP ${response.statusCode}). '
          'Please check your internet connection and try again.',
        );
      }

      _totalBytes = response.contentLength;
      if (_totalBytes < 0) _totalBytes = 0;
      notifyListeners();

      final chunks = <List<int>>[];
      _downloadedBytes = 0;

      await for (final chunk in response) {
        chunks.add(chunk);
        _downloadedBytes += chunk.length;
        notifyListeners();
      }

      final result = <int>[];
      for (final chunk in chunks) {
        result.addAll(chunk);
      }
      return result;
    } on SocketException catch (e) {
      throw Exception(
        'Network error: ${e.message}. '
        'Please check your internet connection and try again.',
      );
    } on HttpException catch (e) {
      throw Exception('HTTP error: ${e.message}');
    } finally {
      client.close();
    }
  }

  Future<void> _extractZip(List<int> bytes, Directory targetDir) async {
    final archive = ZipDecoder().decodeBytes(bytes);
    for (final file in archive) {
      if (file.name.startsWith('__MACOSX')) continue;

      final filePath = '${targetDir.path}${Platform.pathSeparator}${file.name}';
      if (file.isFile) {
        final outFile = File(filePath);
        outFile.createSync(recursive: true);
        outFile.writeAsBytesSync(file.content as List<int>);
      } else {
        Directory(filePath).createSync(recursive: true);
      }
    }
  }

  Future<void> _runAdbVersion() async {
    if (_adbPath == null) return;
    final result = await Process.run(_adbPath!, ['version']);
    _adbVersion = (result.exitCode == 0)
        ? result.stdout.toString().trim()
        : result.stderr.toString().trim();
  }

  String _humanizeError(Object e) {
    final msg = e.toString();
    if (msg.contains('SocketException') ||
        msg.contains('Network error')) {
      return 'No internet connection. Please connect to the internet and retry.';
    }
    if (msg.contains('Http')) {
      return 'Failed to download ADB tools from server. Please retry.';
    }
    if (msg.contains('not found after extraction')) {
      return 'ADB binary was not found after extracting. The download may be corrupted.';
    }
    return msg.replaceFirst('Exception: ', '');
  }
}
