import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

class ScreenCaptureService {
  static final ScreenshotController controller = ScreenshotController();

  static Future<String?> captureAndSave(BuildContext context) async {
    try {
      final Uint8List? imageBytes = await controller.capture(
        delay: const Duration(milliseconds: 100),
      );
      if (imageBytes == null) return null;

      final desktopPath = _getDesktopPath();
      final fileName =
          'porpita_screenshot_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('$desktopPath$fileName');
      await file.writeAsBytes(imageBytes);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Screenshot saved to $desktopPath$fileName'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return file.path;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Screenshot failed: $e')),
        );
      }
      return null;
    }
  }

  static String _getDesktopPath() {
    if (Platform.isMacOS || Platform.isLinux) {
      return '${Platform.environment['HOME']}/Desktop/';
    } else if (Platform.isWindows) {
      return '${Platform.environment['USERPROFILE']}\\Desktop\\';
    }
    return '/';
  }
}
