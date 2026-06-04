import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:porpita/services/commands/adb_exec_service.dart';

class ApkFileInfo {
  final String devicePath;
  final String fileName;

  const ApkFileInfo({required this.devicePath, required this.fileName});
}

class ApkPullResult {
  final int successCount;
  final int totalCount;
  final String folderPath;
  final List<String> failedFiles;

  const ApkPullResult({
    required this.successCount,
    required this.totalCount,
    required this.folderPath,
    this.failedFiles = const [],
  });
}

class ApksFilesService {
  static Future<List<ApkFileInfo>> fetchApkPaths(String deviceId, String packageName) async {
    final output = await AdbExecService.run(deviceId, ['pm', 'path', packageName]);
    if (output.isEmpty) return [];

    final lines = output.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final apks = <ApkFileInfo>[];

    for (final line in lines) {
      final path = line.replaceFirst(RegExp(r'^package:'), '').trim();
      if (path.isEmpty) continue;
      final fileName = path.split('/').last;
      apks.add(ApkFileInfo(devicePath: path, fileName: fileName));
    }

    return apks;
  }

  static Future<String> getDownloadFolder(String packageName) async {
    final downloadsDir = await getDownloadsDirectory();
    return '${downloadsDir!.path}/$packageName';
  }

  static Future<bool> folderExists(String folderPath) async {
    return Directory(folderPath).exists();
  }

  static Future<void> deleteFolder(String folderPath) async {
    final dir = Directory(folderPath);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  static Future<void> createFolder(String folderPath) async {
    await Directory(folderPath).create(recursive: true);
  }

  static Future<void> pullSingleFile(String deviceId, String devicePath, String localPath) async {
    await AdbExecService.runAdb(deviceId, ['pull', devicePath, localPath]);
  }

  static Future<ApkPullResult> pullAllApks(String deviceId, String packageName, List<ApkFileInfo> apks, String folderPath) async {
    await createFolder(folderPath);

    final nameCount = <String, int>{};
    int successCount = 0;
    final failedFiles = <String>[];

    for (final apk in apks) {
      final baseName = apk.fileName;
      final count = nameCount[baseName] ?? 0;
      nameCount[baseName] = count + 1;

      String localName;
      if (count == 0) {
        localName = baseName;
      } else {
        final dotIndex = baseName.lastIndexOf('.');
        if (dotIndex > 0) {
          localName = '${baseName.substring(0, dotIndex)}_$count${baseName.substring(dotIndex)}';
        } else {
          localName = '${baseName}_$count';
        }
      }

      final localPath = '$folderPath/$localName';
      try {
        await pullSingleFile(deviceId, apk.devicePath, localPath);
        final file = File(localPath);
        if (await file.exists() && await file.length() > 0) {
          successCount++;
        } else {
          failedFiles.add(apk.fileName);
          if (await file.exists()) await file.delete();
        }
      } catch (_) {
        failedFiles.add(apk.fileName);
      }
    }

    return ApkPullResult(
      successCount: successCount,
      totalCount: apks.length,
      folderPath: folderPath,
      failedFiles: failedFiles,
    );
  }
}