import 'dart:io';

import 'package:flutter/services.dart';

import 'adb_manager.dart';

enum AppType {
  all('All'),
  user('User'),
  system('System'),
  enabled('Enabled'),
  disabled('Disabled');

  final String label;
  const AppType(this.label);

  List<String> get args {
    switch (this) {
      case AppType.all:
        return ['shell', 'pm', 'list', 'packages'];
      case AppType.user:
        return ['shell', 'pm', 'list', 'packages', '-3'];
      case AppType.system:
        return ['shell', 'pm', 'list', 'packages', '-s'];
      case AppType.enabled:
        return ['shell', 'pm', 'list', 'packages', '-e'];
      case AppType.disabled:
        return ['shell', 'pm', 'list', 'packages', '-d'];
    }
  }
}

enum AppAction {
  start,
  stop,
  restart,
  clearData,
  uninstall,
  enable,
  disable,
  appInfo,
  home,
  playStore,
  openInBrowser,
  findOnline,
  copy,
}

class AppsService {
  static Future<List<String>> fetchPackages({
    required String deviceId,
    AppType type = AppType.user,
  }) async {
    final adbPath = _adbPath;
    if (adbPath == null) return [];

    final args = ['-s', deviceId, ...type.args];
    final result = await Process.run(adbPath, args);
    if (result.exitCode != 0) return [];

    final packages = <String>[];
    for (final line in result.stdout.toString().split('\n')) {
      final trimmed = line.trim();
      if (trimmed.startsWith('package:')) {
        packages.add(trimmed.substring(8));
      }
    }
    return packages;
  }

  static Future<String?> runAction({
    required String deviceId,
    required String packageName,
    required AppAction action,
  }) async {
    final adbPath = _adbPath;
    if (adbPath == null) return null;

    if (action == AppAction.copy) {
      Clipboard.setData(ClipboardData(text: packageName));
      return null;
    }

    if (action == AppAction.restart) {
      await Process.run(adbPath, ['-s', deviceId, 'shell', 'am', 'force-stop', packageName]);
      await Process.run(adbPath, [
        '-s', deviceId, 'shell', 'monkey', '-p', packageName,
        '-c', 'android.intent.category.LAUNCHER', '1',
      ]);
      return null;
    }

    final args = _actionArgs(deviceId, packageName, action);
    if (args == null) return null;

    final result = await Process.run(adbPath, args);
    return result.exitCode == 0 ? result.stdout.toString().trim() : result.stderr.toString().trim();
  }

  static List<String>? _actionArgs(String deviceId, String packageName, AppAction action) {
    switch (action) {
      case AppAction.start:
        return ['-s', deviceId, 'shell', 'monkey', '-p', packageName, '-c', 'android.intent.category.LAUNCHER', '1'];
      case AppAction.stop:
        return ['-s', deviceId, 'shell', 'am', 'force-stop', packageName];
      case AppAction.clearData:
        return ['-s', deviceId, 'shell', 'pm', 'clear', packageName];
      case AppAction.uninstall:
        return ['-s', deviceId, 'uninstall', packageName];
      case AppAction.enable:
        return ['-s', deviceId, 'shell', 'pm', 'enable', packageName];
      case AppAction.disable:
        return ['-s', deviceId, 'shell', 'pm', 'disable-user', packageName];
      case AppAction.appInfo:
        return ['-s', deviceId, 'shell', 'am', 'start', '-a', 'android.settings.APPLICATION_DETAILS_SETTINGS', '-d', 'package:$packageName'];
      case AppAction.home:
        return ['-s', deviceId, 'shell', 'input', 'keyevent', 'KEYCODE_HOME'];
      case AppAction.playStore:
        return ['-s', deviceId, 'shell', 'am', 'start', '-a', 'android.intent.action.VIEW', '-d', 'https://play.google.com/store/apps/details?id=$packageName'];
      case AppAction.restart:
      case AppAction.copy:
        return null;
      case AppAction.openInBrowser:
      case AppAction.findOnline:
        return null;
    }
  }

  static String playStoreUrl(String packageName) =>
      'https://play.google.com/store/apps/details?id=$packageName';

  static String findOnlineUrl(String packageName) =>
      'https://www.google.co.in/search?q=download+$packageName+APK';

  static String? get _adbPath => AdbManager.instance.adbPath;
}
