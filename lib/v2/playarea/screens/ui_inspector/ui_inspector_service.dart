import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:porpita/services/adb_manager.dart';
import 'package:porpita/v2/playarea/screens/apps/appslist/current_app/current_app_service.dart';

class UiInspectorResult {
  final String? xmlContent;
  final String? screenshotPath;
  final ForegroundApp? foregroundApp;
  final String? error;

  const UiInspectorResult({
    this.xmlContent,
    this.screenshotPath,
    this.foregroundApp,
    this.error,
  });
}

class UiInspectorService {
  static Future<UiInspectorResult> fetch(String deviceId) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) {
      return const UiInspectorResult(error: 'ADB not initialized');
    }

    final appDir = await getApplicationSupportDirectory();
    final uiDir = Directory('${appDir.path}${Platform.pathSeparator}ui_inspector');
    if (!uiDir.existsSync()) {
      uiDir.createSync(recursive: true);
    }

    final xmlPath = '${uiDir.path}${Platform.pathSeparator}window_dump.xml';
    final screenshotPath = '${uiDir.path}${Platform.pathSeparator}screenshot.png';

    final results = await Future.wait([
      _fetchXml(adb, deviceId, xmlPath),
      _fetchScreenshot(adb, deviceId, screenshotPath),
      CurrentAppService.fetch(deviceId),
    ]);

    final xmlResult = results[0] as _FetchResult;
    final screenshotResult = results[1] as _FetchResult;
    final foregroundApp = results[2] as ForegroundApp?;

    final errors = <String>[];
    if (xmlResult.error != null) errors.add('XML: ${xmlResult.error}');
    if (screenshotResult.error != null) errors.add('Screenshot: ${screenshotResult.error}');

    return UiInspectorResult(
      xmlContent: xmlResult.content,
      screenshotPath: screenshotResult.path,
      foregroundApp: foregroundApp,
      error: errors.isNotEmpty ? errors.join('\n') : null,
    );
  }

  static Future<_FetchResult> _fetchXml(String adb, String deviceId, String localPath) async {
    try {
      await Process.run(adb, ['-s', deviceId, 'shell', 'uiautomator', 'dump', '/sdcard/window_dump.xml']);
      await Process.run(adb, ['-s', deviceId, 'pull', '/sdcard/window_dump.xml', localPath]);

      final file = File(localPath);
      if (await file.exists()) {
        final content = await file.readAsString();
        return _FetchResult(content: content);
      }
      return const _FetchResult(error: 'Failed to pull XML dump');
    } catch (e) {
      return _FetchResult(error: e.toString());
    }
  }

  static Future<_FetchResult> _fetchScreenshot(String adb, String deviceId, String localPath) async {
    try {
      await Process.run(adb, ['-s', deviceId, 'shell', 'screencap', '-p', '/sdcard/screenshot.png']);
      await Process.run(adb, ['-s', deviceId, 'pull', '/sdcard/screenshot.png', localPath]);

      final file = File(localPath);
      if (await file.exists()) {
        return _FetchResult(path: localPath);
      }
      return const _FetchResult(error: 'Failed to pull screenshot');
    } catch (e) {
      return _FetchResult(error: e.toString());
    }
  }
}

class _FetchResult {
  final String? content;
  final String? path;
  final String? error;

  const _FetchResult({this.content, this.path, this.error});
}
