import 'package:porpita/services/commands/adb_exec_service.dart';
import 'lifecycle_model.dart';

class LifecycleService {
  static Future<String> fetchRaw(String deviceId) async {
    return AdbExecService.run(deviceId, ['dumpsys', 'usagestats']);
  }

  static Future<List<UsageEvent>> fetchEvents(String deviceId) async {
    final raw = await fetchRaw(deviceId);
    if (raw.isEmpty) return [];
    return _parseEvents(raw);
  }

  static Future<List<AppUsageStats>> fetchAppStats(String deviceId) async {
    final raw = await fetchRaw(deviceId);
    if (raw.isEmpty) return [];
    return _parseAppStats(raw);
  }

  static List<UsageEvent> _parseEvents(String output) {
    final events = <UsageEvent>[];
    for (final line in output.split('\n')) {
      final trimmed = line.trim();
      if (!trimmed.startsWith('time=')) continue;
      final typeMatch = RegExp(r'\btype=(\S+)').firstMatch(trimmed);
      if (typeMatch == null) continue;
      final typeStr = typeMatch[1]!;
      final pkgMatch = RegExp(r'\bpackage=(\S+)').firstMatch(trimmed);
      final packageName = pkgMatch?[1] ?? '';
      final timeMatch = RegExp(r'time="([^"]+)"').firstMatch(trimmed);
      DateTime? time;
      if (timeMatch != null) {
        time = DateTime.tryParse(timeMatch[1]!.replaceAll(' ', 'T')) ?? DateTime.now();
      }
      final classMatch = RegExp(r'\bclass=(\S+)').firstMatch(trimmed);
      final instanceIdMatch = RegExp(r'\binstanceId=(\S+)').firstMatch(trimmed);
      final taskRootPkgMatch = RegExp(r'\btaskRootPackage=(\S+)').firstMatch(trimmed);
      final taskRootClassMatch = RegExp(r'\btaskRootClass=(\S+)').firstMatch(trimmed);
      final channelIdMatch = RegExp(r'\bchannelId=(\S+)').firstMatch(trimmed);
      final bucketMatch = RegExp(r'\bstandbyBucket=(\S+)').firstMatch(trimmed);
      final reasonMatch = RegExp(r'\breason=(\S+)').firstMatch(trimmed);
      final flagsMatch = RegExp(r'\bflags=(\S+)').firstMatch(trimmed);

      events.add(UsageEvent(
        time: time ?? DateTime.now(),
        type: UsageEventType.fromValue(typeStr),
        packageName: packageName,
        className: classMatch?[1],
        instanceId: instanceIdMatch?[1],
        taskRootPackage: taskRootPkgMatch?[1],
        taskRootClass: taskRootClassMatch?[1],
        channelId: channelIdMatch?[1],
        standbyBucket: bucketMatch?[1],
        reason: reasonMatch?[1],
        flags: flagsMatch?[1] ?? '',
        raw: {
          'rawLine': trimmed,
        },
      ));
    }
    return events;
  }

  static List<AppUsageStats> _parseAppStats(String output) {
    final stats = <AppUsageStats>[];
    for (final line in output.split('\n')) {
      final trimmed = line.trim();
      if (!trimmed.startsWith('package=')) continue;
      if (!trimmed.contains('totalTimeUsed=')) continue;

      final pkgMatch = RegExp(r'package=(\S+)').firstMatch(trimmed);
      final totalTimeUsedMatch = RegExp(r'totalTimeUsed="([^"]*)"').firstMatch(trimmed);
      final lastTimeUsedMatch = RegExp(r'lastTimeUsed="([^"]*)"').firstMatch(trimmed);
      final totalTimeVisibleMatch = RegExp(r'totalTimeVisible="([^"]*)"').firstMatch(trimmed);
      final lastTimeVisibleMatch = RegExp(r'lastTimeVisible="([^"]*)"').firstMatch(trimmed);
      final lastComponentMatch = RegExp(r'lastTimeComponentUsed="([^"]*)"').firstMatch(trimmed);
      final totalTimeFSMatch = RegExp(r'totalTimeFS="([^"]*)"').firstMatch(trimmed);
      final lastTimeFSMatch = RegExp(r'lastTimeFS="([^"]*)"').firstMatch(trimmed);
      final launchCountMatch = RegExp(r'appLaunchCount=(\d+)').firstMatch(trimmed);

      stats.add(AppUsageStats(
        packageName: pkgMatch?[1] ?? '',
        totalTimeUsed: totalTimeUsedMatch?[1] ?? '',
        lastTimeUsed: lastTimeUsedMatch?[1] ?? '',
        totalTimeVisible: totalTimeVisibleMatch?[1] ?? '',
        lastTimeVisible: lastTimeVisibleMatch?[1] ?? '',
        lastTimeComponentUsed: lastComponentMatch?[1] ?? '',
        totalTimeFS: totalTimeFSMatch?[1] ?? '',
        lastTimeFS: lastTimeFSMatch?[1] ?? '',
        appLaunchCount: int.tryParse(launchCountMatch?[1] ?? '0') ?? 0,
      ));
    }
    stats.sort((a, b) {
      final aCount = a.appLaunchCount;
      final bCount = b.appLaunchCount;
      if (aCount != bCount) return bCount.compareTo(aCount);
      return b.totalTimeUsed.compareTo(a.totalTimeUsed);
    });
    return stats;
  }
}