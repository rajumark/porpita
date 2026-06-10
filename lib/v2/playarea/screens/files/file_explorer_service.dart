import 'dart:io';

import 'package:porpita/services/commands/adb_exec_service.dart';
import 'package:porpita/services/adb_manager.dart';
import 'file_explorer_model.dart';

class FileOperationResult {
  final bool success;
  final String message;
  final String? localPath;

  const FileOperationResult({
    required this.success,
    required this.message,
    this.localPath,
  });
}

class FileExplorerService {
  static Future<List<FileEntry>> listDirectory(String deviceId, String path) async {
    final results = await Future.wait([
      AdbExecService.run(deviceId, ['ls', '-la', path]),
      AdbExecService.run(deviceId, ['find', '-L', path, '-maxdepth', '1', '-type', 'd']),
    ]);

    final lsOutput = results[0];
    final findOutput = results[1];

    final dirNames = <String>{};
    if (findOutput.isNotEmpty) {
      for (final line in findOutput.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed == path) continue;
        final slashIdx = trimmed.lastIndexOf('/');
        final name = slashIdx >= 0 ? trimmed.substring(slashIdx + 1) : trimmed;
        if (name.isNotEmpty && name != '.' && name != '..') {
          dirNames.add(name);
        }
      }
    }

    if (lsOutput.isEmpty && dirNames.isEmpty) return [];

    final lines = lsOutput.split('\n');
    final entries = <FileEntry>[];
    final seenNames = <String>{};

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.startsWith('total')) continue;
      if (trimmed.startsWith('ls:') || trimmed.startsWith('opendir')) continue;
      if (trimmed.contains('No such file or directory')) continue;
      if (trimmed.contains('Permission denied')) continue;

      final entry = FileEntry.fromLsLine(trimmed, path);
      if (entry.name == '.' || entry.name == '..') continue;
      if (entry.name.isEmpty) continue;
      if (seenNames.contains(entry.name)) continue;

      seenNames.add(entry.name);
      final isDir = dirNames.contains(entry.name) || entry.isDirectory;
      entries.add(FileEntry(
        name: entry.name,
        fullPath: entry.fullPath,
        isDirectory: isDir,
        isSymlink: entry.isSymlink,
        size: isDir ? null : entry.size,
        modified: entry.modified,
        permissions: entry.permissions,
        owner: entry.owner,
        group: entry.group,
      ));
    }

    for (final dirName in dirNames) {
      if (!seenNames.contains(dirName)) {
        entries.add(FileEntry(
          name: dirName,
          fullPath: path.endsWith('/') ? '$path$dirName' : '$path/$dirName',
          isDirectory: true,
        ));
      }
    }

    entries.sort((a, b) {
      if (a.isDirectory && !b.isDirectory) return -1;
      if (!a.isDirectory && b.isDirectory) return 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return entries;
  }

  static Future<String> getStat(String deviceId, String path) async {
    return AdbExecService.run(deviceId, ['stat', path]);
  }

  static Future<String> getDiskUsage(String deviceId, String path) async {
    return AdbExecService.run(deviceId, ['du', '-sh', path]);
  }

  static Future<List<FileEntry>> search(
    String deviceId,
    String searchPath,
    SearchFilter filter,
  ) async {
    if (filter.query.isEmpty && !filter.filesOnly && !filter.foldersOnly) {
      return [];
    }

    final args = filter.toFindArgs(searchPath);
    final output = await AdbExecService.run(deviceId, args);

    if (output.isEmpty) return [];

    final lines = output.split('\n');
    final entries = <FileEntry>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.startsWith('find:') || trimmed.startsWith('Permission denied')) continue;

      final isDir = trimmed.endsWith('/');
      final slashIdx = trimmed.lastIndexOf('/');
      final name = slashIdx >= 0 ? trimmed.substring(slashIdx + 1) : trimmed;

      if (name.isNotEmpty && name != '.' && name != '..') {
        entries.add(FileEntry(
          name: name,
          fullPath: isDir ? trimmed.substring(0, trimmed.length - 1) : trimmed,
          isDirectory: isDir,
        ));
      }
    }

    entries.sort((a, b) {
      if (a.isDirectory && !b.isDirectory) return -1;
      if (!a.isDirectory && b.isDirectory) return 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return entries;
  }

  static Future<FileOperationResult> pullFile(
    String deviceId,
    String remotePath, {
    String? localDir,
  }) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) {
      return const FileOperationResult(success: false, message: 'ADB not available');
    }

    final args = ['-s', deviceId, 'pull', remotePath];
    if (localDir != null) {
      args.add(localDir);
    }

    final result = await Process.run(adb, args);
    final stdout = result.stdout.toString().trim();
    final stderr = result.stderr.toString().trim();

    if (result.exitCode == 0) {
      final localPath = _parsePullDestination(stdout) ?? localDir ?? remotePath;
      return FileOperationResult(
        success: true,
        message: stdout.isNotEmpty ? stdout : 'Downloaded successfully',
        localPath: localPath,
      );
    }

    return FileOperationResult(
      success: false,
      message: stderr.isNotEmpty ? stderr : 'Pull failed',
    );
  }

  static Future<FileOperationResult> pushFile(
    String deviceId,
    String localPath,
    String remoteDir,
  ) async {
    final adb = AdbManager.instance.adbPath;
    if (adb == null) {
      return const FileOperationResult(success: false, message: 'ADB not available');
    }

    final result = await Process.run(adb, ['-s', deviceId, 'push', localPath, remoteDir]);
    final stdout = result.stdout.toString().trim();
    final stderr = result.stderr.toString().trim();

    if (result.exitCode == 0) {
      return FileOperationResult(
        success: true,
        message: stdout.isNotEmpty ? stdout : 'Uploaded successfully',
      );
    }

    return FileOperationResult(
      success: false,
      message: stderr.isNotEmpty ? stderr : 'Push failed',
    );
  }

  static Future<FileOperationResult> copyOnDevice(
    String deviceId,
    String srcPath,
    String destPath,
  ) async {
    final output = await AdbExecService.run(deviceId, ['cp', srcPath, destPath]);
    if (output.contains('Permission denied') || output.contains('No such file')) {
      return FileOperationResult(success: false, message: output);
    }
    return const FileOperationResult(success: true, message: 'Copied successfully');
  }

  static Future<FileOperationResult> moveOnDevice(
    String deviceId,
    String srcPath,
    String destPath,
  ) async {
    final output = await AdbExecService.run(deviceId, ['mv', srcPath, destPath]);
    if (output.contains('Permission denied') || output.contains('No such file')) {
      return FileOperationResult(success: false, message: output);
    }
    return const FileOperationResult(success: true, message: 'Moved successfully');
  }

  static Future<FileOperationResult> deleteOnDevice(
    String deviceId,
    String path, {
    bool recursive = false,
  }) async {
    final args = recursive ? ['rm', '-r', path] : ['rm', path];
    final output = await AdbExecService.run(deviceId, args);
    if (output.contains('Permission denied') || output.contains('No such file')) {
      return FileOperationResult(success: false, message: output);
    }
    return const FileOperationResult(success: true, message: 'Deleted successfully');
  }

  static Future<FileOperationResult> createFolder(
    String deviceId,
    String path, {
    bool recursive = true,
  }) async {
    final args = recursive ? ['mkdir', '-p', path] : ['mkdir', path];
    final output = await AdbExecService.run(deviceId, args);
    if (output.contains('Permission denied') || output.contains('cannot create')) {
      return FileOperationResult(success: false, message: output);
    }
    return const FileOperationResult(success: true, message: 'Folder created');
  }

  static String? _parsePullDestination(String stdout) {
    final lines = stdout.split('\n');
    for (final line in lines) {
      if (line.contains(']') && line.contains('pushed') || line.contains('pulled')) {
        continue;
      }
      final match = RegExp(r'/[\w/.\- ]+').firstMatch(line);
      if (match != null) return match.group(0);
    }
    return null;
  }
}
