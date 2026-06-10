import 'package:porpita/services/commands/adb_exec_service.dart';

class SystemSettingsService {
  static Future<String> openDefaultAppsSettings(String deviceId) {
    return AdbExecService.run(deviceId, [
      'am', 'start',
      '-a', 'android.settings.MANAGE_DEFAULT_APPS_SETTINGS',
    ]);
  }

  static Future<String> openContactsApp(String deviceId) {
    return AdbExecService.run(deviceId, [
      'am', 'start',
      '-a', 'android.intent.action.VIEW',
      '-t', 'vnd.android.cursor.dir/contact',
    ]);
  }

  static Future<String> openDialerApp(String deviceId) {
    return AdbExecService.run(deviceId, [
      'am', 'start',
      '-a', 'android.intent.action.DIAL',
    ]);
  }

  static Future<String> openMessagingApp(String deviceId) {
    return AdbExecService.run(deviceId, [
      'am', 'start',
      '-a', 'android.intent.action.MAIN',
      '-t', 'vnd.android-dir/mms-sms',
    ]);
  }

  static Future<String> openFilesApp(String deviceId) {
    return AdbExecService.run(deviceId, [
      'am', 'start',
      '-a', 'android.intent.action.OPEN_DOCUMENT',
      '-t', '*/*',
    ]);
  }
}
