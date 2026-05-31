import 'package:porpita/services/commands/adb_exec_service.dart';

class PermissionMenuService {
  static Future<String> openAppInfo(String deviceId, String packageName) {
    return AdbExecService.run(deviceId, [
      'am', 'start',
      '-a', 'android.settings.APPLICATION_DETAILS_SETTINGS',
      '-d', 'package:$packageName',
    ]);
  }

  static Future<String> openOverlayPermission(String deviceId) {
    return AdbExecService.run(deviceId, ['am', 'start', '-a', 'android.settings.action.MANAGE_OVERLAY_PERMISSION']);
  }

  static Future<String> openAccessibility(String deviceId) {
    return AdbExecService.run(deviceId, ['am', 'start', '-a', 'android.settings.ACCESSIBILITY_SETTINGS']);
  }

  static Future<String> openDefaultApps(String deviceId) {
    return AdbExecService.run(deviceId, ['am', 'start', '-a', 'android.settings.MANAGE_DEFAULT_APPS_SETTINGS']);
  }

  static Future<String> openWriteSettings(String deviceId) {
    return AdbExecService.run(deviceId, ['am', 'start', '-a', 'android.settings.action.MANAGE_WRITE_SETTINGS']);
  }

  static Future<String> openUsageAccess(String deviceId) {
    return AdbExecService.run(deviceId, ['am', 'start', '-a', 'android.settings.USAGE_ACCESS_SETTINGS']);
  }

  static Future<String> openNotificationAccess(String deviceId) {
    return AdbExecService.run(deviceId, ['am', 'start', '-a', 'android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS']);
  }

  static Future<String> openAllFilesAccess(String deviceId) {
    return AdbExecService.run(deviceId, ['am', 'start', '-a', 'android.settings.MANAGE_APP_ALL_FILES_ACCESS_PERMISSION']);
  }

  static Future<String> openInstallUnknownApps(String deviceId) {
    return AdbExecService.run(deviceId, ['am', 'start', '-a', 'android.settings.MANAGE_UNKNOWN_APP_SOURCES']);
  }

  static Future<String> openDoNotDisturbAccess(String deviceId) {
    return AdbExecService.run(deviceId, ['am', 'start', '-a', 'android.settings.NOTIFICATION_POLICY_ACCESS_SETTINGS']);
  }
}