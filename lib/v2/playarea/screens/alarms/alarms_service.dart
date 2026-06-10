import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:porpita/services/adb_manager.dart';
import 'alarm_model.dart';

class AlarmsService {
  static Future<String> fetchRaw(String deviceId) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) return '';
    final process = await Process.start(adb, ['-s', deviceId, 'shell', 'dumpsys', 'alarm']);
    final out = await process.stdout.transform(utf8.decoder).join();
    final err = await process.stderr.transform(utf8.decoder).join();
    await process.exitCode;
    return '$out\n$err';
  }

  static Future<(AlarmSettings, List<AlarmEntry>)> fetchAlarms(String deviceId) async {
    final raw = await fetchRaw(deviceId);
    if (raw.isEmpty) {
      return (AlarmSettings(version: '', minFuturity: '', minInterval: '', maxInterval: '', minWindow: '', maxAlarmsPerUid: '', raw: {}), <AlarmEntry>[]);
    }
    return compute(_parseAlarmsInBackground, raw);
  }
}

(AlarmSettings, List<AlarmEntry>) _parseAlarmsInBackground(String raw) {
  final settings = _parseSettings(raw);
  final entries = _parseAlarms(raw);
  return (settings, entries);
}

AlarmSettings _parseSettings(String output) {
  final raw = <String, String>{};
  bool inSettings = false;
  for (final line in output.split('\n')) {
    final trimmed = line.trim();
    if (trimmed.startsWith('Settings:')) {
      inSettings = true;
      continue;
    }
    if (inSettings && trimmed.isEmpty) break;
    if (!inSettings) continue;
    final kvMatch = RegExp(r'^([\w_]+)\s*=\s*(.+)$').firstMatch(trimmed);
    if (kvMatch != null) {
      raw[kvMatch[1]!.trim()] = kvMatch[2]!.trim();
    }
  }
  return AlarmSettings(
    version: raw['version'] ?? '',
    minFuturity: raw['min_futurity'] ?? '',
    minInterval: raw['min_interval'] ?? '',
    maxInterval: raw['max_interval'] ?? '',
    minWindow: raw['min_window'] ?? '',
    maxAlarmsPerUid: raw['max_alarms_per_uid'] ?? '',
    raw: raw,
  );
}

List<AlarmEntry> _parseAlarms(String output) {
  final entries = <AlarmEntry>[];
  final lines = output.split('\n');

  int i = 0;
  while (i < lines.length) {
    final trimmed = lines[i].trim();
    final headerMatch = RegExp(r'^(ELAPSED_WAKEUP|ELAPSED|RTC_WAKEUP|RTC)\s+#(\d+)').firstMatch(trimmed);
    if (headerMatch == null) {
      i++;
      continue;
    }

    final blockLines = <String>[];
    int endLine = i + 1;
    while (endLine < lines.length) {
      final nextTrimmed = lines[endLine].trim();
      if (nextTrimmed.isEmpty ||
          RegExp(r'^(ELAPSED_WAKEUP|ELAPSED|RTC_WAKEUP|RTC)\s+#\d+').hasMatch(nextTrimmed) ||
          nextTrimmed.startsWith('LazyAlarmStore') ||
          nextTrimmed.startsWith('Pending user') ||
          nextTrimmed.startsWith('Pending alarms per') ||
          nextTrimmed.startsWith('Scheduled user') ||
          nextTrimmed.startsWith('App Alarm history') ||
          nextTrimmed.startsWith('Top Alarms') ||
          nextTrimmed.startsWith('Alarm Stats') ||
          nextTrimmed.startsWith('Alarm manager stats')) {
        break;
      }
      blockLines.add(lines[endLine]);
      endLine++;
    }

    entries.add(_parseAlarmBlock(headerMatch[1]!, int.tryParse(headerMatch[2]!) ?? 0, trimmed, blockLines));
    i = endLine;
  }

  return entries;
}

AlarmEntry _parseAlarmBlock(String typeLabel, int alarmIndex, String headerLine, List<String> blockLines) {
  final raw = <String, String>{};
  raw['header'] = headerLine;

  final typeMatch = RegExp(r'\btype\s*=\s*(\d+)').firstMatch(headerLine);
  int typeValue = 3;
  if (typeMatch != null) typeValue = int.tryParse(typeMatch[1]!) ?? 3;
  final alarmType = AlarmType.fromValue(typeValue);

  final pkgMatch = RegExp(r'\s(\S+)\}$').firstMatch(headerLine);
  String packageName = 'android';
  if (pkgMatch != null) {
    final pkg = pkgMatch[1]!;
    if (pkg != 'android' && !pkg.startsWith('Alarm{')) packageName = pkg;
  }

  String tag = '';
  String origWhen = '';
  String whenElapsed = '';
  String window = '';
  String exactAllowReason = '';
  String repeatInterval = '';
  String count = '';
  String flags = '';
  String policyWhenElapsed = '';
  String maxWhenElapsed = '';
  String operation = '';
  String listener = '';
  bool isAlarmClock = false;
  String alarmClockTriggerTime = '';
  String alarmClockShowIntent = '';

  final fullBlock = '$headerLine\n${blockLines.join('\n')}';

  final tagMatch = RegExp(r'^\s*tag=(.+)$', multiLine: true).firstMatch(fullBlock);
  if (tagMatch != null) tag = tagMatch[1]!.trim();

  final typeLineMatch = RegExp(r'^\s*type=\S+\s+origWhen=(\S+)\s+window=(\S+)').firstMatch(fullBlock);
  if (typeLineMatch != null) {
    origWhen = typeLineMatch[1]!;
    window = typeLineMatch[2]!;
  }

  final origWhenDirectMatch = RegExp(r'^\s*type=\S+\s+origWhen=(\S+)').firstMatch(fullBlock);
  if (origWhenDirectMatch != null && origWhen.isEmpty) {
    origWhen = origWhenDirectMatch[1]!;
  }

  final exactMatch = RegExp(r'\bexactAllowReason=(\S+)').firstMatch(fullBlock);
  if (exactMatch != null) exactAllowReason = exactMatch[1]!;
  final repeatMatch = RegExp(r'\brepeatInterval=(\d+)').firstMatch(fullBlock);
  if (repeatMatch != null) repeatInterval = repeatMatch[1]!;
  final countMatch = RegExp(r'\bcount=(\d+)').firstMatch(fullBlock);
  if (countMatch != null) count = countMatch[1]!;
  final flagsMatch = RegExp(r'\bflags=(0x[0-9a-fA-F]+)').firstMatch(fullBlock);
  if (flagsMatch != null) flags = flagsMatch[1]!;

  final whenElapsedMatch = RegExp(r'^\s*whenElapsed=(\S+)\s+maxWhenElapsed=(\S+)', multiLine: true).firstMatch(fullBlock);
  if (whenElapsedMatch != null) {
    whenElapsed = whenElapsedMatch[1]!;
    maxWhenElapsed = whenElapsedMatch[2]!;
  }

  final policyMatch = RegExp(r'^\s*policyWhenElapsed:\s+(.+)$', multiLine: true).firstMatch(fullBlock);
  if (policyMatch != null) policyWhenElapsed = policyMatch[1]!.trim();
  final opMatch = RegExp(r'^\s*operation=(.+)$', multiLine: true).firstMatch(fullBlock);
  if (opMatch != null) operation = opMatch[1]!.trim();
  final listenerMatch = RegExp(r'^\s*listener=(.+)$', multiLine: true).firstMatch(fullBlock);
  if (listenerMatch != null) listener = listenerMatch[1]!.trim();

  if (fullBlock.contains('Alarm clock:')) {
    isAlarmClock = true;
    final triggerMatch = RegExp(r'triggerTime=(\S+)').firstMatch(fullBlock);
    if (triggerMatch != null) alarmClockTriggerTime = triggerMatch[1]!;
    final showMatch = RegExp(r'showIntent=(.+)$', multiLine: true).firstMatch(fullBlock);
    if (showMatch != null) alarmClockShowIntent = showMatch[1]!.trim();
  }

  return AlarmEntry(
    index: alarmIndex,
    alarmType: alarmType,
    packageName: packageName,
    tag: tag,
    origWhen: origWhen,
    whenElapsed: whenElapsed,
    window: window,
    exactAllowReason: exactAllowReason,
    repeatInterval: repeatInterval,
    count: count,
    flags: flags,
    policyWhenElapsed: policyWhenElapsed,
    maxWhenElapsed: maxWhenElapsed,
    operation: operation,
    listener: listener,
    isAlarmClock: isAlarmClock,
    alarmClockTriggerTime: alarmClockTriggerTime,
    alarmClockShowIntent: alarmClockShowIntent,
    rawBlock: fullBlock,
    raw: raw,
  );
}