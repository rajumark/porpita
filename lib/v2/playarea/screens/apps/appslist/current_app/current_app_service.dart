import 'package:porpita/services/commands/adb_exec_service.dart';

class ForegroundApp {
  final String packageName;
  final String activityName;
  final List<String> fragments;

  const ForegroundApp({
    required this.packageName,
    required this.activityName,
    this.fragments = const [],
  });
}

class CurrentAppService {
  static Future<ForegroundApp?> fetch(String deviceId) async {
    final result = await AdbExecService.run(deviceId, [
      'dumpsys', 'window',
    ]);

    ForegroundApp? app = _parseForegroundApp(result);
    if (app == null) {
      final fallback = await AdbExecService.run(deviceId, [
        'dumpsys', 'activity', 'activities',
      ]);
      app = _parseResumedActivity(fallback);
    }

    if (app != null) {
      final fragments = await _fetchFragments(deviceId, app);
      app = ForegroundApp(
        packageName: app.packageName,
        activityName: app.activityName,
        fragments: fragments,
      );
    }

    return app;
  }

  static Future<List<String>> _fetchFragments(
      String deviceId, ForegroundApp app) async {
    try {
      final output = await AdbExecService.run(deviceId, [
        'dumpsys',
        'activity',
        '${app.packageName}/${app.activityName}',
      ]);
      return _parseFragments(output);
    } catch (_) {
      return [];
    }
  }

  static List<String> _parseFragments(String output) {
    final fragments = <String>[];
    final lines = output.split('\n');
    var inActiveFragments = false;
    for (final line in lines) {
      if (line.contains('Active Fragments:')) {
        inActiveFragments = true;
        continue;
      }
      if (inActiveFragments) {
        if (line.trim().isEmpty) continue;
        final match = RegExp(r'^\s*(\w+)\{').firstMatch(line);
        if (match != null) {
          fragments.add(match.group(1)!);
          continue;
        }
        if (line.contains('Added Fragments:')) break;
      }
    }
    return fragments;
  }

  static ForegroundApp? _parseForegroundApp(String output) {
    final lines = output.split('\n');
    for (final line in lines) {
      if (line.contains('mCurrentFocus')) {
        return _extractFromFocusLine(line);
      }
      if (line.contains('mFocusedApp')) {
        return _extractFromFocusLine(line);
      }
    }
    return null;
  }

  static ForegroundApp? _parseResumedActivity(String output) {
    final lines = output.split('\n');
    for (final line in lines) {
      if (line.contains('mResumedActivity')) {
        final match = RegExp(r'mResumedActivity.*\{[^}]+\s+([\w.]+)/([\w.}]+)').firstMatch(line);
        if (match != null) {
          return ForegroundApp(
            packageName: match.group(1)!,
            activityName: match.group(2)!.replaceAll('}', ''),
          );
        }
      }
    }
    return null;
  }

  static ForegroundApp? _extractFromFocusLine(String line) {
    final match = RegExp(r'm(CurrentFocus|FocusedApp)=Window\{[^}]+\s+([\w.]+)/([\w.}]+)').firstMatch(line);
    if (match != null) {
      return ForegroundApp(
        packageName: match.group(2)!,
        activityName: match.group(3)!.replaceAll('}', ''),
      );
    }
    return null;
  }
}
