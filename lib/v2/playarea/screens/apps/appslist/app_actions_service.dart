import 'package:flutter/services.dart';
import 'package:porpita/services/commands/adb_exec_service.dart';
import 'package:url_launcher/url_launcher.dart';

enum AppAction {
  open('Open'),
  forceStop('Force Stop'),
  restart('Restart'),
  uninstall('Uninstall'),
  clearData('Clear Data'),
  enable('Enable'),
  disable('Disable'),
  home('Home'),
  copy('Copy'),
  appInfo('App Info'),
  playStore('Play Store'),
  findOnline('Find Online'),
  grantAllPermissions('Grant All Permissions'),
  revokeAllPermissions('Revoke All Permissions'),
  managePermissions('Manage Permissions'),
  downloadApks('Download Apks'),
  pin('Pin it'),
  unpin('Unpin it');

  final String label;
  const AppAction(this.label);
}

class AppActionsService {
  static Future<void> run(String deviceId, AppAction action, String packageName) async {
    switch (action) {
      case AppAction.open:
        await _openApp(deviceId, packageName);
      case AppAction.forceStop:
        await _forceStop(deviceId, packageName);
      case AppAction.restart:
        await _restart(deviceId, packageName);
      case AppAction.uninstall:
        await _uninstall(deviceId, packageName);
      case AppAction.clearData:
        await _clearData(deviceId, packageName);
      case AppAction.enable:
        await _enable(deviceId, packageName);
      case AppAction.disable:
        await _disable(deviceId, packageName);
      case AppAction.home:
        await _home(deviceId);
      case AppAction.copy:
        _copy(packageName);
      case AppAction.appInfo:
        await _openAppInfo(deviceId, packageName);
      case AppAction.playStore:
        await _openPlayStore(deviceId, packageName);
      case AppAction.findOnline:
        _findOnline(packageName);
      case AppAction.grantAllPermissions:
      case AppAction.revokeAllPermissions:
      case AppAction.managePermissions:
      case AppAction.downloadApks:
      case AppAction.pin:
      case AppAction.unpin:
        break;
    }
  }

  static Future<String> _openApp(String deviceId, String packageName) {
    return AdbExecService.run(deviceId, [
      'monkey', '-p', packageName,
      '-c', 'android.intent.category.LAUNCHER', '1',
    ]);
  }

  static Future<String> _forceStop(String deviceId, String packageName) {
    return AdbExecService.run(deviceId, ['am', 'force-stop', packageName]);
  }

  static Future<void> _restart(String deviceId, String packageName) async {
    await _forceStop(deviceId, packageName);
    await _openApp(deviceId, packageName);
  }

  static Future<String> _uninstall(String deviceId, String packageName) {
    return AdbExecService.runAdb(deviceId, ['uninstall', packageName]);
  }

  static Future<String> _clearData(String deviceId, String packageName) {
    return AdbExecService.run(deviceId, ['pm', 'clear', packageName]);
  }

  static Future<String> _enable(String deviceId, String packageName) {
    return AdbExecService.run(deviceId, ['pm', 'enable', packageName]);
  }

  static Future<String> _disable(String deviceId, String packageName) {
    return AdbExecService.run(deviceId, ['pm', 'disable-user', packageName]);
  }

  static Future<String> _home(String deviceId) {
    return AdbExecService.run(deviceId, ['input', 'keyevent', 'KEYCODE_HOME']);
  }

  static void _copy(String packageName) {
    Clipboard.setData(ClipboardData(text: packageName));
  }

  static Future<String> _openAppInfo(String deviceId, String packageName) {
    return AdbExecService.run(deviceId, [
      'am', 'start',
      '-a', 'android.settings.APPLICATION_DETAILS_SETTINGS',
      '-d', 'package:$packageName',
    ]);
  }

  static Future<void> _openPlayStore(String deviceId, String packageName) async {
    final url = 'https://play.google.com/store/apps/details?id=$packageName';
    await AdbExecService.run(deviceId, [
      'am', 'start',
      '-a', 'android.intent.action.VIEW',
      '-d', url,
    ]);
  }

  static void _findOnline(String packageName) {
    final url = Uri.parse('https://www.google.com/search?q=download+$packageName+APK');
    launchUrl(url, mode: LaunchMode.externalApplication);
  }

  static List<AppAction> get menuItems => [
    AppAction.open,
    AppAction.forceStop,
    AppAction.restart,
    AppAction.uninstall,
    AppAction.clearData,
    AppAction.enable,
    AppAction.disable,
    AppAction.home,
    AppAction.copy,
    AppAction.appInfo,
    AppAction.playStore,
    AppAction.findOnline,
    AppAction.pin,
    AppAction.unpin,
  ];
}
