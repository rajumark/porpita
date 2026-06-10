import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:porpita/services/adb_manager.dart';
import 'notification_model.dart';

List<NotificationEntry> _parseInBackground(String raw) {
  return _parseDumpsys(raw);
}

List<NotificationEntry> _parseDumpsys(String output) {
  final entries = <NotificationEntry>[];
  final lines = output.split('\n');

  int i = 0;
  while (i < lines.length) {
    final line = lines[i].trim();
    if (line.startsWith('NotificationRecord(')) {
      final record = _parseRecord(lines, i);
      if (record != null) {
        entries.add(record);
      }
      while (i < lines.length &&
          !lines[i].trim().startsWith('NotificationRecord(') &&
          !lines[i].trim().startsWith('mMaxPackage') &&
          !lines[i].trim().startsWith('Notification attention')) {
        i++;
      }
      continue;
    }
    i++;
  }

  entries.sort((a, b) => b.when.compareTo(a.when));
  return entries;
}

NotificationEntry? _parseRecord(List<String> lines, int startLine) {
  final raw = <String, String>{};
  String packageName = '';
  String id = '';
  String tag = '';
  int importance = 0;
  String key = '';
  String uid = '';
  String userId = '';
  String opPkg = '';
  String flags = '';
  String title = '';
  String text = '';
  String bigText = '';
  String substName = '';
  String channel = '';
  String channelId = '';
  String channelName = '';
  String whenStr = '';
  bool seen = false;
  String importanceLabel = '';
  String groupKey = '';
  String iconPkg = '';
  String color = '';
  String visibility = '';
  String template = '';
  List<String> actionLabels = [];

  final headerLine = lines[startLine].trim();
  final pkgMatch = RegExp(r'pkg=(\S+)').firstMatch(headerLine);
  if (pkgMatch != null) packageName = pkgMatch[1]!;

  final idMatch = RegExp(r'\bid=(\d+)').firstMatch(headerLine);
  if (idMatch != null) id = idMatch[1]!;

  final tagMatch = RegExp(r'\btag=(\S*)').firstMatch(headerLine);
  if (tagMatch != null) tag = tagMatch[1] ?? '';

  final impMatch = RegExp(r'\bimportance=(\d+)').firstMatch(headerLine);
  if (impMatch != null) importance = int.tryParse(impMatch[1]!) ?? 0;

  final keyMatch = RegExp(r'\bkey=([^\s|]+(?:\|[^s]+)?)').firstMatch(headerLine);
  if (keyMatch != null) key = keyMatch[1]!;

  final notificationLine = lines[startLine].trim();
  final channelMatch = RegExp(r'channel=(\S+)').firstMatch(notificationLine);
  if (channelMatch != null) channelId = channelMatch[1]!;

  int endLine = startLine + 1;
  while (endLine < lines.length) {
    final trimmed = lines[endLine].trim();
    if (trimmed.startsWith('NotificationRecord(') ||
        trimmed.startsWith('mMaxPackage') ||
        trimmed.startsWith('Notification attention')) {
      break;
    }
    endLine++;
  }

  for (int j = startLine + 1; j < endLine && j < lines.length; j++) {
    final trimmed = lines[j].trim();

    if (trimmed.startsWith('uid=')) {
      uid = trimmed.substring(4).trim();
    } else if (trimmed.startsWith('userId=')) {
      userId = trimmed.substring(7).trim();
    } else if (trimmed.startsWith('opPkg=')) {
      opPkg = trimmed.substring(6).trim();
    } else if (trimmed.startsWith('icon=')) {
      final iconMatch = RegExp(r'pkg=(\S+)').firstMatch(trimmed);
      if (iconMatch != null) iconPkg = iconMatch[1]!;
    } else if (trimmed.startsWith('flags=')) {
      flags = trimmed.substring(6).trim();
    } else if (trimmed.startsWith('seen=')) {
      seen = trimmed.substring(5).trim().toLowerCase() == 'true';
    } else if (trimmed.startsWith('key=')) {
      final k = trimmed.substring(4).trim();
      if (k.isNotEmpty) key = k;
    } else if (trimmed.startsWith('groupKey=')) {
      groupKey = trimmed.substring(9).trim();
    } else if (trimmed == 'extras={') {
      int k = j + 1;
      while (k < lines.length && k < endLine) {
        final extraLine = lines[k].trim();
        if (extraLine == '}') break;
        _parseExtraLine(extraLine, (t, v) {
          if (t == 'android.title') title = v;
          if (t == 'android.text') text = v;
          if (t == 'android.bigText') bigText = v;
          if (t == 'android.substName') substName = v;
          if (t == 'android.template') template = v;
        });
        k++;
      }
    } else if (trimmed.startsWith('channel=')) {
      final channelStart = trimmed.indexOf('channel=');
      if (channelStart != -1) {
        channel = trimmed.substring(channelStart + 8).trim();
        final parts = channel.split(RegExp(r'\s+'));
        if (parts.isNotEmpty) channelId = parts.first;
      }
    } else if (trimmed.startsWith('when=')) {
      whenStr = trimmed.substring(5).trim();
    } else if (trimmed.startsWith('actions={')) {
      int k = j + 1;
      while (k < lines.length && k < endLine) {
        final actionLine = lines[k].trim();
        if (actionLine.startsWith('}')) break;
        final actionMatch = RegExp(r'"([^"]+)"\s*->').firstMatch(actionLine);
        if (actionMatch != null) {
          actionLabels.add(actionMatch[1]!);
        }
        k++;
      }
    } else if (trimmed.startsWith('mImportance=')) {
      importanceLabel = trimmed.substring(12).trim();
    } else if (trimmed.startsWith('color=')) {
      color = trimmed.substring(6).trim();
    } else if (trimmed.startsWith('vis=')) {
      visibility = trimmed.substring(4).trim();
    } else if (trimmed.startsWith('effectiveNotificationChannel=')) {
      final channelIdMatch = RegExp(r"mId='([^']+)'").firstMatch(trimmed);
      if (channelIdMatch != null) channelId = channelIdMatch[1]!;
      final channelNameMatch = RegExp(r"mName=([^,\s]+)").firstMatch(trimmed);
      if (channelNameMatch != null) channelName = channelNameMatch[1]!;
    }
  }

  raw['packageName'] = packageName;
  raw['id'] = id;
  raw['tag'] = tag;
  raw['importance'] = importance.toString();
  raw['key'] = key;
  raw['uid'] = uid;
  raw['userId'] = userId;
  raw['opPkg'] = opPkg;
  raw['flags'] = flags;
  raw['title'] = title;
  raw['text'] = text;
  raw['bigText'] = bigText;
  raw['substName'] = substName;
  raw['channel'] = channel;
  raw['channelId'] = channelId;
  raw['channelName'] = channelName;
  raw['seen'] = seen.toString();
  raw['importanceLabel'] = importanceLabel;
  raw['groupKey'] = groupKey;
  raw['iconPkg'] = iconPkg;
  raw['color'] = color;
  raw['visibility'] = visibility;
  raw['template'] = template;

  DateTime when;
  if (whenStr.contains('/')) {
    final parts = whenStr.split('/');
    final ms = int.tryParse(parts[0]) ?? 0;
    when = DateTime.fromMillisecondsSinceEpoch(ms);
  } else {
    final ms = int.tryParse(whenStr) ?? 0;
    when = DateTime.fromMillisecondsSinceEpoch(ms);
  }

  if (packageName.isEmpty && key.isEmpty) return null;

  return NotificationEntry(
    packageName: packageName,
    id: id,
    tag: tag,
    importance: importance,
    key: key,
    uid: uid,
    userId: userId,
    opPkg: opPkg,
    flags: flags,
    title: title,
    text: text,
    bigText: bigText,
    substName: substName,
    channel: channel,
    channelId: channelId,
    channelName: channelName,
    when: when,
    seen: seen,
    importanceLabel: importanceLabel,
    actionLabels: actionLabels,
    groupKey: groupKey,
    iconPkg: iconPkg,
    color: color,
    visibility: visibility,
    template: template,
    raw: raw,
  );
}

void _parseExtraLine(String line, void Function(String, String) onExtra) {
  final match = RegExp(r'(\S+)\s*=\s*(.+?)$').firstMatch(line);
  if (match != null) {
    final key = match[1]!;
    var value = match[2]!;
    final stringMatch = RegExp(r"String\s*\(([^)]+)\)").firstMatch(value);
    if (stringMatch != null) {
      value = stringMatch[1]!;
    }
    onExtra(key, value);
  }
}

class NotificationsService {
  static Future<List<NotificationEntry>> fetchNotifications(String deviceId) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) return [];

    final process = await Process.start(adb, ['-s', deviceId, 'shell', 'dumpsys', 'notification', '--noredact']);
    final out = await process.stdout.transform(utf8.decoder).join();
    final err = await process.stderr.transform(utf8.decoder).join();
    await process.exitCode;

    final raw = '$out\n$err';
    if (raw.isEmpty || (out.isEmpty && err.isEmpty)) return [];
    return compute(_parseInBackground, raw);
  }

  static Future<String> fetchRaw(String deviceId) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) return '';
    final process = await Process.start(adb, ['-s', deviceId, 'shell', 'dumpsys', 'notification', '--noredact']);
    final out = await process.stdout.transform(utf8.decoder).join();
    final err = await process.stderr.transform(utf8.decoder).join();
    await process.exitCode;
    return '$out\n$err';
  }
}