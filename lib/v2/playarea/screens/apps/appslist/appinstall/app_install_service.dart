import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:porpita/services/commands/adb_exec_service.dart';

class AppInstallResult {
  final bool success;
  final String message;
  final String? filePath;

  const AppInstallResult({
    required this.success,
    required this.message,
    this.filePath,
  });
}

class AppInstallService {
  static Future<FilePickerResult?> pickApkFile() {
    return FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['apk'],
      allowMultiple: false,
    );
  }

  static Future<AppInstallResult> installApk(
    String deviceId,
    String filePath,
  ) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return const AppInstallResult(
        success: false,
        message: 'File not found.',
      );
    }

    final result = await AdbExecService.runAdb(deviceId, ['install', '-r', filePath]);

    if (result.contains('Success')) {
      return AppInstallResult(
        success: true,
        message: 'APK installed successfully.',
        filePath: filePath,
      );
    }

    if (result.contains('INSTALL_FAILED_ALREADY_EXISTS')) {
      return AppInstallResult(
        success: false,
        message: 'App already exists. Uninstall it first or use reinstall flag.',
        filePath: filePath,
      );
    }

    if (result.contains('INSTALL_FAILED_INSUFFICIENT_STORAGE')) {
      return const AppInstallResult(
        success: false,
        message: 'Insufficient storage on device.',
      );
    }

    if (result.isEmpty) {
      return const AppInstallResult(
        success: false,
        message: 'Install failed: no response from ADB.',
      );
    }

    return AppInstallResult(
      success: false,
      message: 'Install failed:\n$result',
      filePath: filePath,
    );
  }

  static Future<AppInstallResult> pickAndInstall(String deviceId) async {
    final pickerResult = await pickApkFile();
    if (pickerResult == null || pickerResult.files.isEmpty) {
      return const AppInstallResult(
        success: false,
        message: 'No file selected.',
      );
    }

    final path = pickerResult.files.single.path;
    if (path == null) {
      return const AppInstallResult(
        success: false,
        message: 'Could not read file path.',
      );
    }

    return installApk(deviceId, path);
  }
}
