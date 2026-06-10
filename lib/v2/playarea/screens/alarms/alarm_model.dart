import 'package:flutter/material.dart';

enum AlarmType {
  rtcWakeup(0, 'RTC Wakeup', Icons.alarm, true),
  rtc(1, 'RTC', Icons.schedule, false),
  elapsedWakeup(2, 'Elapsed Wakeup', Icons.alarm, true),
  elapsed(3, 'Elapsed', Icons.schedule, false);

  final int value;
  final String label;
  final IconData icon;
  final bool isWakeup;
  const AlarmType(this.value, this.label, this.icon, this.isWakeup);

  static AlarmType fromValue(int v) {
    return AlarmType.values.firstWhere(
      (e) => e.value == v,
      orElse: () => AlarmType.elapsed,
    );
  }
}

class AlarmEntry {
  final int index;
  final AlarmType alarmType;
  final String packageName;
  final String tag;
  final String origWhen;
  final String whenElapsed;
  final String window;
  final String exactAllowReason;
  final String repeatInterval;
  final String count;
  final String flags;
  final String policyWhenElapsed;
  final String maxWhenElapsed;
  final String operation;
  final String listener;
  final bool isAlarmClock;
  final String alarmClockTriggerTime;
  final String alarmClockShowIntent;
  final String rawBlock;
  final Map<String, String> raw;

  const AlarmEntry({
    required this.index,
    required this.alarmType,
    required this.packageName,
    required this.tag,
    required this.origWhen,
    required this.whenElapsed,
    required this.window,
    required this.exactAllowReason,
    required this.repeatInterval,
    required this.count,
    required this.flags,
    required this.policyWhenElapsed,
    required this.maxWhenElapsed,
    required this.operation,
    required this.listener,
    required this.isAlarmClock,
    required this.alarmClockTriggerTime,
    required this.alarmClockShowIntent,
    required this.rawBlock,
    required this.raw,
  });

  String get displayTag {
    if (tag.isEmpty) return 'Alarm #$index';
    final cleaned = tag.replaceFirst(RegExp(r'^\*w?alarm\*[:]?\s*'), '');
    return cleaned.isEmpty ? tag : cleaned;
  }

  String get displayPackage {
    if (packageName == 'android') return 'System';
    final parts = packageName.split('.');
    return parts.isNotEmpty ? parts.last : packageName;
  }

  String get displayTime {
    if (origWhen.isEmpty) return '--';
    final dt = DateTime.tryParse(origWhen);
    if (dt != null) {
      final hour12 = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
      final period = dt.hour < 12 ? 'AM' : 'PM';
      return '$hour12:${dt.minute.toString().padLeft(2, '0')} $period';
    }
    return origWhen;
  }

  String get displayWhen {
    if (whenElapsed.isEmpty) return '--';
    return whenElapsed;
  }

  Color typeColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (isAlarmClock) return scheme.primary;
    if (alarmType.isWakeup) return scheme.error;
    return scheme.onSurfaceVariant;
  }
}

class AlarmSettings {
  final String version;
  final String minFuturity;
  final String minInterval;
  final String maxInterval;
  final String minWindow;
  final String maxAlarmsPerUid;
  final Map<String, String> raw;

  const AlarmSettings({
    required this.version,
    required this.minFuturity,
    required this.minInterval,
    required this.maxInterval,
    required this.minWindow,
    required this.maxAlarmsPerUid,
    required this.raw,
  });
}