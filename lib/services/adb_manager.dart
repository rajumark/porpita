import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

enum PlatformOs { macos, linux, windows }

class AdbManager extends ChangeNotifier {
  static final AdbManager _instance = AdbManager._();
  static AdbManager get instance => _instance;

  AdbManager._();

  String? _adbPath;
  String? _adbVersion;
  String? _error;
  bool _isInitialized = false;
  bool _isInitializing = false;

  String? get adbPath => _adbPath;
  String? get adbVersion => _adbVersion;
  String? get error => _error;
  bool get isInitialized => _isInitialized;
  bool get isInitializing => _isInitializing;

  PlatformOs get platform {
    if (Platform.isMacOS) return PlatformOs.macos;
    if (Platform.isLinux) return PlatformOs.linux;
    if (Platform.isWindows) return PlatformOs.windows;
    return PlatformOs.macos;
  }

  String get _assetZipName {
    switch (platform) {
      case PlatformOs.macos:
        return 'platform-tools-macos.zip';
      case PlatformOs.linux:
        return 'platform-tools-linux.zip';
      case PlatformOs.windows:
        return 'platform-tools-windows.zip';
    }
  }

  Future<void> initialize() async {
    if (_isInitialized || _isInitializing) return;
    _isInitializing = true;
    notifyListeners();

    try {
      await _extractAndSetup();
      await _runAdbVersion();
      _isInitialized = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<Directory> get _appSupportDir async {
    final appDir = await getApplicationSupportDirectory();
    final adbDir = Directory('${appDir.path}${Platform.pathSeparator}adb');
    return adbDir;
  }

  Future<void> _extractAndSetup() async {
    final adbDir = await _appSupportDir;

    if (await _isAdbReady(adbDir)) {
      _adbPath = _findAdbBinary(adbDir);
      return;
    }

    if (adbDir.existsSync()) {
      adbDir.deleteSync(recursive: true);
    }

    final bundle = await _loadAssetBytes();
    await _extractZip(bundle, adbDir);

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
  }

  Future<bool> _isAdbReady(Directory adbDir) async {
    if (!adbDir.existsSync()) return false;
    final binary = _findAdbBinary(adbDir);
    return binary != null;
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

  Future<List<int>> _loadAssetBytes() async {
    final data = await rootBundle.load('assets/adb/$_assetZipName');
    return data.buffer.asUint8List();
  }

  Future<void> _extractZip(List<int> bytes, Directory targetDir) async {
    final archive = ZipDecoder().decodeBytes(bytes);
    for (final file in archive) {
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
}
