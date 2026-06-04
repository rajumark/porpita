import 'package:porpita/services/commands/adb_exec_service.dart';

class AppFileEntry {
  final String name;
  final String permissions;
  final String owner;
  final String group;
  final String size;
  final String date;
  final String time;
  final bool isDirectory;

  const AppFileEntry({
    required this.name,
    this.permissions = '',
    this.owner = '',
    this.group = '',
    this.size = '',
    this.date = '',
    this.time = '',
    this.isDirectory = false,
  });
}

class AppFilesResult {
  final String path;
  final List<AppFileEntry> entries;
  final String? error;
  final bool isDebuggable;
  final String? commands;
  final String? rawOutput;
  final bool canTryRoot;

  const AppFilesResult({
    required this.path,
    this.entries = const [],
    this.error,
    this.isDebuggable = false,
    this.commands,
    this.rawOutput,
    this.canTryRoot = false,
  });
}

class AppFilesService {
  static Future<AppFilesResult> fetch(String deviceId, String packageName, {String subpath = ''}) async {
    final basePath = '/data/data/$packageName${subpath.isEmpty ? '' : subpath}';
    final runAsCmd = 'adb -s $deviceId shell run-as $packageName ls -la ${subpath.isEmpty ? '/' : subpath}';
    final directCmd = 'adb -s $deviceId shell ls -la $basePath';

    final runAsResult = await AdbExecService.run(deviceId, [
      'run-as', packageName, 'ls', '-la', subpath.isEmpty ? '/' : subpath,
    ]);

    if (!_isError(runAsResult)) {
      final entries = _parseLs(runAsResult);
      if (entries.isNotEmpty || runAsResult.trim().isEmpty || _isEmptyDir(runAsResult)) {
        return AppFilesResult(
          path: basePath,
          entries: entries,
          isDebuggable: true,
        );
      }
    }

    final directResult = await AdbExecService.run(deviceId, [
      'ls', '-la', basePath,
    ]);

    if (_isPermissionDenied(directResult)) {
      final runAsTrimmed = runAsResult.length > 500 ? '${runAsResult.substring(0, 500)}...' : runAsResult;
      final directTrimmed = directResult.length > 500 ? '${directResult.substring(0, 500)}...' : directResult;
      final combinedOutput = '--- Command 1: $runAsCmd ---\n$runAsTrimmed\n\n--- Command 2: $directCmd ---\n$directTrimmed';
      return AppFilesResult(
        path: basePath,
        error: 'Permission denied. This app is not debuggable and the device is not rooted.',
        isDebuggable: false,
        canTryRoot: true,
        commands: '$runAsCmd\n$directCmd',
        rawOutput: combinedOutput,
      );
    }

    final entries = _parseLs(directResult);
    return AppFilesResult(
      path: basePath,
      entries: entries,
      isDebuggable: false,
    );
  }

  static Future<AppFilesResult> fetchWithRoot(String deviceId, String packageName, {String subpath = ''}) async {
    final basePath = '/data/data/$packageName${subpath.isEmpty ? '' : subpath}';
    final rootCmd = 'adb -s $deviceId root';
    final lsCmd = 'adb -s $deviceId shell ls -la $basePath';

    final rootResult = await AdbExecService.runAdb(deviceId, ['root']);

    if (rootResult.contains('cannot run as root') || rootResult.contains('not production') || rootResult.contains('adbd cannot run as root')) {
      final directResult = await AdbExecService.run(deviceId, ['ls', '-la', basePath]);
      final combinedOutput = '--- Command 1: $rootCmd ---\n$rootResult\n\n--- Command 2: $lsCmd ---\n${directResult.length > 500 ? '${directResult.substring(0, 500)}...' : directResult}';
      return AppFilesResult(
        path: basePath,
        error: 'Root access is not available on this device.\n\n'
            'adb root returned:\n${rootResult.trim()}\n\n'
            'Options:\n'
            '• Use a Google APIs emulator image (not Google Play)\n'
            '• Use the "adb backup" command to extract data\n'
            '• Root your device/emulator with tools like rootAVD',
        canTryRoot: false,
        commands: '$rootCmd\n$lsCmd',
        rawOutput: combinedOutput,
      );
    }

    await Future.delayed(const Duration(seconds: 2));

    final lsResult = await AdbExecService.run(deviceId, ['ls', '-la', basePath]);

    if (_isPermissionDenied(lsResult)) {
      final combinedOutput = '--- Command 1: $rootCmd ---\n$rootResult\n\n--- Command 2: $lsCmd ---\n${lsResult.length > 500 ? '${lsResult.substring(0, 500)}...' : lsResult}';
      return AppFilesResult(
        path: basePath,
        error: 'Root access granted but still permission denied.\n\n'
            'adb root returned:\n${rootResult.trim()}\n\n'
            'You may need to remount or change SELinux mode.',
        canTryRoot: false,
        commands: '$rootCmd\n$lsCmd',
        rawOutput: combinedOutput,
      );
    }

    final entries = _parseLs(lsResult);
    return AppFilesResult(
      path: basePath,
      entries: entries,
      isDebuggable: false,
    );
  }

  static bool _isPermissionDenied(String result) {
    return result.contains('Permission denied') ||
        result.contains('No such file or directory') ||
        result.contains('Op not permitted');
  }

  static bool _isError(String result) {
    return result.contains('not debuggable') ||
        result.contains('Permission denied') ||
        result.contains('run-as:') ||
        result.contains('Error:');
  }

  static List<AppFileEntry> _parseLs(String output) {
    final lines = output.split('\n');
    final entries = <AppFileEntry>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('total') || trimmed == '.' || trimmed == '..') continue;

      final parts = trimmed.split(RegExp(r'\s+'));
      if (parts.length < 7) continue;

      final permissions = parts[0];
      final owner = parts.length > 2 ? parts[2] : '';
      final group = parts.length > 3 ? parts[3] : '';
      final size = parts.length > 4 ? parts[4] : '';
      final date = parts.length > 5 ? parts[5] : '';
      final time = parts.length > 6 ? parts[6] : '';
      final name = parts.length > 7 ? parts.sublist(7).join(' ') : '';

      if (name.isEmpty || name == '.' || name == '..') continue;

      entries.add(AppFileEntry(
        name: name,
        permissions: permissions,
        owner: owner,
        group: group,
        size: size,
        date: date,
        time: time,
        isDirectory: permissions.startsWith('d'),
      ));
    }

    return entries;
  }

  static bool _isEmptyDir(String output) {
    return output.trim().isEmpty || output.trim() == '.' || output.split('\n').where((l) => l.trim().isNotEmpty && !l.trim().startsWith('total')).isEmpty;
  }
}