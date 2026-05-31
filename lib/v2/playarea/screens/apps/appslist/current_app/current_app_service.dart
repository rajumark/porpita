import 'package:porpita/services/commands/adb_exec_service.dart';

class ForegroundApp {
  final String packageName;
  final String activityName;

  const ForegroundApp({
    required this.packageName,
    required this.activityName,
  });
}

class CurrentAppService {
  static Future<ForegroundApp?> fetch(String deviceId) async {
    final result = await AdbExecService.run(deviceId, [
      'dumpsys', 'window',
    ]);

    final app = _parseForegroundApp(result);
    if (app != null) return app;

    final fallback = await AdbExecService.run(deviceId, [
      'dumpsys', 'activity', 'activities',
    ]);
    return _parseResumedActivity(fallback);
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
