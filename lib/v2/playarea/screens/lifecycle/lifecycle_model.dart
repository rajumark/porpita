import 'package:flutter/material.dart';

enum UsageEventType {
  activityResumed('ACTIVITY_RESUMED', Icons.play_arrow),
  activityPaused('ACTIVITY_PAUSED', Icons.pause),
  activityStopped('ACTIVITY_STOPPED', Icons.stop),
  foregroundServiceStart('FOREGROUND_SERVICE_START', Icons.settings_power),
  foregroundServiceStop('FOREGROUND_SERVICE_STOP', Icons.power_off),
  screenInteractive('SCREEN_INTERACTIVE', Icons.screen_lock_portrait),
  screenNonInteractive('SCREEN_NON_INTERACTIVE', Icons.screen_lock_landscape),
  notificationInterruption('NOTIFICATION_INTERRUPTION', Icons.notifications_active),
  standbyBucketChanged('STANDBY_BUCKET_CHANGED', Icons.folder),
  configurationChange('CONFIGURATION_CHANGE', Icons.settings),
  slicePinned('SLICE_PINNED', Icons.push_pin),
  shortcutInvocation('SHORTCUT_INVOCATION', Icons.touch_app),
  userUnlocked('USER_UNLOCKED', Icons.lock_open),
  deviceShutdown('DEVICE_SHUTDOWN', Icons.power_off),
  deviceStartup('DEVICE_STARTUP', Icons.phone_android),
  locusIdSet('LOCUS_ID_SET', Icons.location_on),
  unknown('UNKNOWN', Icons.info);

  final String value;
  final IconData icon;
  const UsageEventType(this.value, this.icon);

  static UsageEventType fromValue(String v) {
    return UsageEventType.values.firstWhere(
      (e) => e.value == v,
      orElse: () => UsageEventType.unknown,
    );
  }
}

class UsageEvent {
  final DateTime time;
  final UsageEventType type;
  final String packageName;
  final String? className;
  final String? instanceId;
  final String? taskRootPackage;
  final String? taskRootClass;
  final String? channelId;
  final String? standbyBucket;
  final String? reason;
  final String flags;
  final Map<String, String> raw;

  const UsageEvent({
    required this.time,
    required this.type,
    required this.packageName,
    this.className,
    this.instanceId,
    this.taskRootPackage,
    this.taskRootClass,
    this.channelId,
    this.standbyBucket,
    this.reason,
    this.flags = '',
    required this.raw,
  });
}

class AppUsageStats {
  final String packageName;
  final String totalTimeUsed;
  final String lastTimeUsed;
  final String totalTimeVisible;
  final String lastTimeVisible;
  final String lastTimeComponentUsed;
  final String totalTimeFS;
  final String lastTimeFS;
  final int appLaunchCount;

  const AppUsageStats({
    required this.packageName,
    this.totalTimeUsed = '',
    this.lastTimeUsed = '',
    this.totalTimeVisible = '',
    this.lastTimeVisible = '',
    this.lastTimeComponentUsed = '',
    this.totalTimeFS = '',
    this.lastTimeFS = '',
    this.appLaunchCount = 0,
  });
}