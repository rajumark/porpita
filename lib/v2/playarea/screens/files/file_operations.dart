import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'file_explorer_model.dart';
import 'file_explorer_service.dart';

class FileOperations {
  static Future<void> showNewFolderDialog(
    BuildContext context, {
    required String currentPath,
    required String deviceId,
    required VoidCallback onCompleted,
  }) async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.create_new_folder_outlined, size: 20,
                color: Theme.of(ctx).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('New Folder'),
          ],
        ),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create in: $currentPath',
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                      fontFamily: 'monospace',
                    ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Folder name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (result == null || result.isEmpty) return;

    final opResult = await FileExplorerService.createFolder(
      deviceId,
      '$currentPath/$result',
    );

    if (context.mounted) {
      _showResultSnackBar(context, opResult);
      if (opResult.success) onCompleted();
    }
  }

  static Future<void> showRenameDialog(
    BuildContext context, {
    required FileEntry entry,
    required String currentPath,
    required String deviceId,
    required VoidCallback onCompleted,
  }) async {
    final controller = TextEditingController(text: entry.name);

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.drive_file_rename_outline, size: 20,
                color: Theme.of(ctx).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Rename'),
          ],
        ),
        content: SizedBox(
          width: 360,
          child: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'New name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (result == null || result.isEmpty || result == entry.name) return;

    final newPath = '${entry.fullPath.substring(0, entry.fullPath.lastIndexOf('/') + 1)}$result';
    final opResult = await FileExplorerService.moveOnDevice(
      deviceId,
      entry.fullPath,
      newPath,
    );

    if (context.mounted) {
      _showResultSnackBar(context, opResult);
      if (opResult.success) onCompleted();
    }
  }

  static Future<void> showDeleteConfirm(
    BuildContext context, {
    required FileEntry entry,
    required String deviceId,
    required VoidCallback onCompleted,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete_outline, size: 20,
                color: Theme.of(ctx).colorScheme.error),
            const SizedBox(width: 8),
            const Text('Delete'),
          ],
        ),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this ${entry.isDirectory ? 'folder' : 'file'}?',
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  entry.fullPath,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              if (entry.isDirectory) ...[
                const SizedBox(height: 8),
                Text(
                  'This will delete all contents recursively.',
                  style: TextStyle(
                    color: Theme.of(ctx).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final opResult = await FileExplorerService.deleteOnDevice(
      deviceId,
      entry.fullPath,
      recursive: entry.isDirectory,
    );

    if (context.mounted) {
      _showResultSnackBar(context, opResult);
      if (opResult.success) onCompleted();
    }
  }

  static Future<void> showCopyDialog(
    BuildContext context, {
    required FileEntry entry,
    required String currentPath,
    required String deviceId,
    required VoidCallback onCompleted,
  }) async {
    final parentDir = entry.fullPath.substring(0, entry.fullPath.lastIndexOf('/'));
    final controller = TextEditingController(text: parentDir);

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.content_copy, size: 20,
                color: Theme.of(ctx).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Copy To'),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Source: ${entry.fullPath}',
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Destination directory',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Copy'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (result == null || result.isEmpty) return;

    final destPath = '$result/${entry.name}';
    final opResult = await FileExplorerService.copyOnDevice(
      deviceId,
      entry.fullPath,
      destPath,
    );

    if (context.mounted) {
      _showResultSnackBar(context, opResult);
      if (opResult.success) onCompleted();
    }
  }

  static Future<void> showMoveDialog(
    BuildContext context, {
    required FileEntry entry,
    required String currentPath,
    required String deviceId,
    required VoidCallback onCompleted,
  }) async {
    final parentDir = entry.fullPath.substring(0, entry.fullPath.lastIndexOf('/'));
    final controller = TextEditingController(text: parentDir);

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.drive_file_move_outline, size: 20,
                color: Theme.of(ctx).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Move To'),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Source: ${entry.fullPath}',
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Destination directory',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Move'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (result == null || result.isEmpty) return;

    final destPath = '$result/${entry.name}';
    final opResult = await FileExplorerService.moveOnDevice(
      deviceId,
      entry.fullPath,
      destPath,
    );

    if (context.mounted) {
      _showResultSnackBar(context, opResult);
      if (opResult.success) onCompleted();
    }
  }

  static Future<void> pullToDownloads(
    BuildContext context, {
    required FileEntry entry,
    required String deviceId,
  }) async {
    final downloadsDir = await getDownloadsDirectory();
    final localDir = downloadsDir?.path ?? '${Platform.environment['HOME']}/Downloads';

    final opResult = await FileExplorerService.pullFile(
      deviceId,
      entry.fullPath,
      localDir: localDir,
    );

    if (context.mounted) {
      _showResultSnackBar(context, opResult);
    }
  }

  static Future<void> showPushDialog(
    BuildContext context, {
    required String currentPath,
    required String deviceId,
    required VoidCallback onCompleted,
  }) async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.upload_file, size: 20,
                color: Theme.of(ctx).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Upload File'),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload to: $currentPath',
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Local file path (e.g. ~/Documents/file.txt)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Upload'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (result == null || result.isEmpty) return;

    final expanded = _expandPath(result);
    if (!File(expanded).existsSync()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Local file not found')),
        );
      }
      return;
    }

    final opResult = await FileExplorerService.pushFile(
      deviceId,
      expanded,
      currentPath,
    );

    if (context.mounted) {
      _showResultSnackBar(context, opResult);
      if (opResult.success) onCompleted();
    }
  }

  static String _expandPath(String path) {
    if (path.startsWith('~/')) {
      return '${Platform.environment['HOME']}${path.substring(1)}';
    }
    return path;
  }

  static void _showResultSnackBar(BuildContext context, FileOperationResult result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        duration: Duration(seconds: result.success ? 2 : 4),
        backgroundColor: result.success ? null : Theme.of(context).colorScheme.error,
      ),
    );
  }
}
