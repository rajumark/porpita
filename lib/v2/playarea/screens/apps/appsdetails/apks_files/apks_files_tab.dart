import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:porpita/services/device_manager.dart';
import 'package:porpita/v2/topbar/porpita_preferences/screens/alert/alert_screen.dart';
import 'apks_files_service.dart';

class ApksFilesTab extends StatefulWidget {
  final String packageName;
  const ApksFilesTab({super.key, required this.packageName});

  @override
  State<ApksFilesTab> createState() => _ApksFilesTabState();
}

class _ApksFilesTabState extends State<ApksFilesTab> with AutomaticKeepAliveClientMixin {
  List<ApkFileInfo> _apks = [];
  bool _loading = true;
  String? _error;
  String? _folderPath;
  bool _downloading = false;
  double? _downloadProgress;
  String? _downloadingFile;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchApks();
    _initFolderPath();
  }

  @override
  void didUpdateWidget(covariant ApksFilesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.packageName != widget.packageName) {
      _apks = [];
      _loading = true;
      _error = null;
      _folderPath = null;
      _fetchApks();
      _initFolderPath();
    }
  }

  Future<void> _initFolderPath() async {
    final path = await ApksFilesService.getDownloadFolder(widget.packageName);
    if (mounted) {
      setState(() => _folderPath = path);
    }
  }

  Future<void> _fetchApks() async {
    final device = context.read<DeviceManager>().selected;
    if (device == null) {
      setState(() { _loading = false; _error = 'No device connected'; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final apks = await ApksFilesService.fetchApkPaths(device.id, widget.packageName);
      if (!mounted) return;
      setState(() {
        _apks = apks;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<bool> _shouldReplaceFolder(String folderPath) async {
    final exists = await ApksFilesService.folderExists(folderPath);
    if (!exists) return true;

    final prefs = await SharedPreferences.getInstance();
    final skipConfirm = prefs.getBool(AlertScreen.keyReplaceFolder) ?? false;
    if (skipConfirm) return true;

    if (!mounted) return false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Folder Already Exists'),
        content: Text('A folder for "${widget.packageName}" already exists in Downloads.\n\nDo you want to replace its contents?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Replace'),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _downloadAll() async {
    if (_apks.isEmpty || _folderPath == null) return;
    final device = context.read<DeviceManager>().selected;
    if (device == null) return;

    final shouldReplace = await _shouldReplaceFolder(_folderPath!);
    if (!shouldReplace) return;

    if (!mounted) return;
    setState(() {
      _downloading = true;
      _downloadProgress = 0;
    });

    try {
      await ApksFilesService.deleteFolder(_folderPath!);
      final result = await ApksFilesService.pullAllApks(device.id, widget.packageName, _apks, _folderPath!);

      if (!mounted) return;
      setState(() { _downloading = false; _downloadProgress = null; });
      _showSuccessDialog(result, device.id);
    } catch (e) {
      if (!mounted) return;
      setState(() { _downloading = false; _downloadProgress = null; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e'), duration: const Duration(seconds: 3)),
      );
    }
  }

  Future<void> _downloadSingle(ApkFileInfo apk) async {
    final device = context.read<DeviceManager>().selected;
    if (device == null || _folderPath == null) return;

    if (!await _shouldReplaceFolder(_folderPath!)) return;

    if (!mounted) return;
    setState(() { _downloading = true; _downloadingFile = apk.fileName; });

    try {
      await ApksFilesService.createFolder(_folderPath!);

      final nameCount = <String, int>{};
      for (final a in _apks) {
        nameCount[a.fileName] = (nameCount[a.fileName] ?? 0) + 1;
      }
      final count = nameCount[apk.fileName] ?? 1;
      final isDuplicate = count > 1;

      final filesInDir = Directory(_folderPath!).listSync();
      final existingIndex = filesInDir.whereType<File>().where((f) {
        final name = f.path.split('/').last;
        return name == apk.fileName || name.startsWith(apk.fileName.replaceAll('.apk', '_')) && name.endsWith('.apk');
      }).length;

      String localName;
      if (isDuplicate || existingIndex > 0) {
        final dotIndex = apk.fileName.lastIndexOf('.');
        final idx = existingIndex + 1;
        if (dotIndex > 0) {
          localName = '${apk.fileName.substring(0, dotIndex)}_$idx${apk.fileName.substring(dotIndex)}';
        } else {
          localName = '${apk.fileName}_$idx';
        }
      } else {
        localName = apk.fileName;
      }

      final localPath = '$_folderPath/$localName';
      await ApksFilesService.pullSingleFile(device.id, apk.devicePath, localPath);

      final file = File(localPath);
      final exists = await file.exists() && await file.length() > 0;

      if (!mounted) return;
      setState(() { _downloading = false; _downloadingFile = null; });

      if (exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded: ${apk.fileName}'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download: ${apk.fileName}'), duration: const Duration(seconds: 3)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { _downloading = false; _downloadingFile = null; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e'), duration: const Duration(seconds: 3)),
      );
    }
  }

  void _showSuccessDialog(ApkPullResult result, String deviceId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
        title: const Text('Download Complete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Successfully pulled ${result.successCount} of ${result.totalCount} APK file${result.totalCount > 1 ? "s" : ""}.'),
            const SizedBox(height: 8),
            Text(
              result.folderPath,
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
            ),
            if (result.failedFiles.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Failed: ${result.failedFiles.join(", ")}',
                style: TextStyle(color: Theme.of(ctx).colorScheme.error),
              ),
            ],
          ],
        ),
        actions: [
          FilledButton.tonalIcon(
            onPressed: () {
              Navigator.pop(ctx);
              _openFolder(result.folderPath);
            },
            icon: const Icon(Icons.folder_open, size: 18),
            label: const Text('Open Folder'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _openFolder(String? path) async {
    if (path == null) return;
    final dir = Directory(path);
    if (await dir.exists()) {
      launchUrl(Uri.file(path), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openExistingFolder() async {
    if (_folderPath == null) return;
    final dir = Directory(_folderPath!);
    if (await dir.exists()) {
      launchUrl(Uri.file(_folderPath!), mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Folder does not exist yet. Download APKs first.'), duration: Duration(seconds: 2)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (_loading) {
      return const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: scheme.error),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: _fetchApks,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_apks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.android_outlined, size: 48, color: scheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text('No APKs Found', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                'No APK paths found for ${widget.packageName}.\nThe app may not be installed.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: _fetchApks,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${_apks.length} APK file${_apks.length > 1 ? "s" : ""} found',
                  style: theme.textTheme.titleSmall,
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _folderPath != null ? _openExistingFolder : null,
                icon: const Icon(Icons.folder_open, size: 18),
                label: const Text('Open Folder'),
              ),
              const SizedBox(width: 8),
              FilledButton.tonalIcon(
                onPressed: _downloading ? null : _downloadAll,
                icon: _downloading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.download, size: 18),
                label: const Text('Download All'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _downloading && _downloadProgress != null
              ? Column(
                  children: [
                    LinearProgressIndicator(value: _downloadProgress),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Downloading${_downloadingFile != null ? ": $_downloadingFile" : ""}...',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: _apks.length,
                  itemBuilder: (context, index) => _buildApkItem(context, _apks[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildApkItem(BuildContext context, ApkFileInfo apk) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDownloading = _downloading && _downloadingFile == apk.fileName;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.android_outlined, size: 20, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      apk.fileName,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      apk.devicePath,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isDownloading)
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              else
                FilledButton.tonalIcon(
                  onPressed: _downloading ? null : () => _downloadSingle(apk),
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Download'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}