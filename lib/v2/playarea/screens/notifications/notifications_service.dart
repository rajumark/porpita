import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:porpita/services/adb_manager.dart';

List<String> _splitRawSections(String raw) {
  final lines = raw.split('\n');
  final sections = <String>[];
  StringBuffer? buf;
  for (final line in lines) {
    if (line.trimLeft().startsWith('NotificationRecord(')) {
      if (buf != null) sections.add(buf.toString().trimRight());
      buf = StringBuffer();
    }
    if (buf != null) buf.writeln(line);
  }
  return sections;
}

class NotificationsService {
  static Future<String> fetchRaw(String deviceId) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) return '';
    final process = await Process.start(
        adb, ['-s', deviceId, 'shell', 'dumpsys', 'notification', '--noredact']);
    final out = await process.stdout.transform(utf8.decoder).join();
    final err = await process.stderr.transform(utf8.decoder).join();
    await process.exitCode;
    return '$out\n$err';
  }

  static Future<List<String>> fetchRawSections(String deviceId) async {
    final raw = await fetchRaw(deviceId);
    if (raw.isEmpty) return [];
    return compute(_splitRawSections, raw);
  }
}
