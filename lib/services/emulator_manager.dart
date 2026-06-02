import 'dart:io';

import 'package:flutter/foundation.dart';

import 'adb_manager.dart';

class AvdInfo {
  final String name;
  const AvdInfo({required this.name});

  @override
  bool operator ==(Object other) => other is AvdInfo && other.name == name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => name;
}

class EmulatorManager extends ChangeNotifier {
  List<AvdInfo> _avds = [];
  bool _loading = false;
  String? _error;
  String? _emulatorPath;

  List<AvdInfo> get avds => _avds;
  bool get loading => _loading;
  String? get error => _error;

  EmulatorManager() {
    _init();
  }

  Future<void> _init() async {
    _emulatorPath = _findEmulatorBinary();
    await refreshAvds();
  }

  String? _findEmulatorBinary() {
    final exeName = Platform.isWindows ? 'emulator.exe' : 'emulator';
    final sep = Platform.pathSeparator;
    final home = Platform.environment['HOME'] ?? '';

    final candidates = <String>[];

    final sdkRelative = _sdkRelativeCandidates(exeName, sep);
    candidates.addAll(sdkRelative);

    for (final envVar in ['ANDROID_HOME', 'ANDROID_SDK_ROOT', 'ANDROID_SDK']) {
      final env = Platform.environment[envVar];
      if (env != null && env.isNotEmpty) {
        candidates.add('$env${sep}emulator$sep$exeName');
      }
    }

    if (Platform.isMacOS) {
      candidates.addAll([
        '$home${sep}Library${sep}Android${sep}sdk${sep}emulator$sep$exeName',
        '$home${sep}Android${sep}Sdk${sep}emulator$sep$exeName',
      ]);
    }

    if (Platform.isLinux) {
      candidates.addAll([
        '$home${sep}Android${sep}Sdk${sep}emulator$sep$exeName',
        '$home${sep}Android${sep}android-sdk${sep}emulator$sep$exeName',
        '${sep}opt${sep}android-sdk${sep}emulator$sep$exeName',
      ]);
    }

    if (Platform.isWindows) {
      final localAppData = Platform.environment['LOCALAPPDATA'] ?? '';
      candidates.addAll([
        '$localAppData${sep}Android${sep}sdk${sep}emulator$sep$exeName',
        'C:${sep}Android${sep}sdk${sep}emulator$sep$exeName',
        'C:${sep}Program Files${sep}Android${sep}android-sdk${sep}emulator$sep$exeName',
      ]);
    }

    for (final path in candidates) {
      if (File(path).existsSync()) return path;
    }

    return null;
  }

  List<String> _sdkRelativeCandidates(String exeName, String sep) {
    final adbPath = AdbManager.instance.adbPath;
    if (adbPath == null) return [];

    final platformToolsDir = File(adbPath).parent;
    final sdkDir = platformToolsDir.parent;

    return [
      '${sdkDir.path}${sep}emulator$sep$exeName',
      '${platformToolsDir.path}$sep$exeName',
    ];
  }

  String _avdDir() {
    final home = Platform.environment['HOME'] ?? '';
    final sep = Platform.pathSeparator;

    if (Platform.isWindows) {
      final userProfile = Platform.environment['USERPROFILE'] ?? home;
      return '$userProfile$sep.android${sep}avd';
    }
    return '$home$sep.android${sep}avd';
  }

  List<AvdInfo> _scanAvdDir() {
    final dir = Directory(_avdDir());
    if (!dir.existsSync()) return [];

    final avds = <AvdInfo>[];
    for (final entity in dir.listSync()) {
      if (entity is File && entity.path.endsWith('.ini')) {
        final name = entity.uri.pathSegments.last.replaceAll('.ini', '');
        avds.add(AvdInfo(name: name));
      }
    }
    return avds..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> refreshAvds() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final fromDir = _scanAvdDir();

      if (_emulatorPath != null) {
        final result = await Process.run(_emulatorPath!, ['-list-avds']);
        if (result.exitCode == 0) {
          final output = result.stdout.toString().trim();
          final fromCli = output.isEmpty
              ? <AvdInfo>[]
              : output
                  .split('\n')
                  .where((l) => l.trim().isNotEmpty)
                  .map((l) => AvdInfo(name: l.trim()))
                  .toList();

          final namesFromDir = fromDir.map((a) => a.name).toSet();
          final merged = <AvdInfo>[...fromDir];
          for (final avd in fromCli) {
            if (!namesFromDir.contains(avd.name)) {
              merged.add(avd);
            }
          }
          merged.sort((a, b) => a.name.compareTo(b.name));
          _avds = merged;
          _error = null;
        } else {
          _avds = fromDir;
          _error = null;
        }
      } else {
        _avds = fromDir;
        if (fromDir.isEmpty) {
          _error = 'Emulator binary not found and no AVDs found in ${_avdDir()}';
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> launchAvd(String avdName) async {
    _emulatorPath ??= _findEmulatorBinary();
    if (_emulatorPath == null) return false;

    try {
      if (Platform.isMacOS) {
        await Process.run('osascript', [
          '-e',
          'tell application "Terminal"',
          '-e',
          'activate',
          '-e',
          'do script "$_emulatorPath -avd $avdName"',
          '-e',
          'end tell',
        ]);
      } else if (Platform.isLinux) {
        final launched = await _tryLinuxTerminal(_emulatorPath!, avdName);
        if (!launched) return false;
      } else if (Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', 'cmd', '/k', '"$_emulatorPath" -avd $avdName']);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _tryLinuxTerminal(String emulatorPath, String avdName) async {
    final terminals = [
      ['gnome-terminal', '--', 'bash', '-c'],
      ['konsole', '-e', 'bash', '-c'],
      ['xfce4-terminal', '-x', 'bash', '-c'],
      ['xterm', '-e', 'bash', '-c'],
    ];

    final cmd = '$emulatorPath -avd $avdName; exec bash';

    for (final terminal in terminals) {
      try {
        final result = await Process.run('which', [terminal.first]);
        if (result.exitCode == 0) {
          await Process.run(terminal.first, [...terminal.sublist(1), cmd]);
          return true;
        }
      } catch (_) {
        continue;
      }
    }

    try {
      await Process.start(emulatorPath, ['-avd', avdName]);
      return true;
    } catch (_) {
      return false;
    }
  }
}