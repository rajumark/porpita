import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'porpita_server.dart';

class AppIconService {
  static final AppIconService _instance = AppIconService._();
  static AppIconService get instance => _instance;
  AppIconService._();

  final Map<String, Map<String, String>> _deviceIconCaches = {};
  bool _isFetching = false;

  Map<String, String> getIconCacheForDevice(String deviceId) {
    return Map.unmodifiable(_deviceIconCaches[deviceId] ?? {});
  }

  Map<String, String> get iconCache {
    final merged = <String, String>{};
    for (final cache in _deviceIconCaches.values) {
      merged.addAll(cache);
    }
    return Map.unmodifiable(merged);
  }

  Future<void> fetchIcons(String deviceId, List<String> packageNames) async {
    if (packageNames.isEmpty) return;

    _deviceIconCaches.putIfAbsent(deviceId, () => {});
    final deviceCache = _deviceIconCaches[deviceId]!;

    final uncached = packageNames.where((p) => !deviceCache.containsKey(p)).toList();
    if (uncached.isEmpty) return;

    if (_isFetching) return;
    _isFetching = true;

    try {
      final server = PorpitaServer.forDevice(deviceId);
      final iconPaths = await server.getAppIcons(uncached);

      if (iconPaths.isEmpty) return;

      final fileServerPort = await server.getFileServerPort();

      for (final entry in iconPaths.entries) {
        final packageName = entry.key;
        final devicePath = entry.value;
        if (devicePath.isEmpty) {
          deviceCache[packageName] = '';
          continue;
        }

        try {
          final localPath = await _downloadIcon(deviceId, packageName, server, fileServerPort, devicePath);
          if (localPath != null) {
            deviceCache[packageName] = localPath;
          } else {
            deviceCache[packageName] = '';
          }
        } catch (e) {
          debugPrint('[AppIconService] Failed to download icon for $packageName: $e');
          deviceCache[packageName] = '';
        }
      }
    } catch (e) {
      debugPrint('[AppIconService] Failed to fetch icons: $e');
    } finally {
      _isFetching = false;
    }
  }

  Future<String?> _downloadIcon(
    String deviceId,
    String packageName,
    PorpitaServer server,
    int fileServerPort,
    String devicePath,
  ) async {
    try {
      final appDir = await getApplicationSupportDirectory();
      final iconDir = Directory('${appDir.path}/app_icons/$deviceId');
      if (!iconDir.existsSync()) {
        iconDir.createSync(recursive: true);
      }

      final iconFile = File('${iconDir.path}/$packageName.png');

      if (iconFile.existsSync() && iconFile.lengthSync() > 0) {
        return iconFile.path;
      }

      final url = server.getIconUrl(fileServerPort, devicePath);
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode != 200) {
        client.close();
        return null;
      }

      final sink = iconFile.openSync(mode: FileMode.write);
      await for (final chunk in response) {
        sink.writeFromSync(chunk);
      }
      await sink.close();
      client.close();

      return iconFile.path;
    } catch (e) {
      debugPrint('[AppIconService] Error downloading icon for $packageName: $e');
      return null;
    }
  }

  void clearCache(String deviceId) {
    _deviceIconCaches[deviceId]?.clear();
  }

  void clearAllCaches() {
    _deviceIconCaches.clear();
  }

  void removeDevice(String deviceId) {
    _deviceIconCaches.remove(deviceId);
    PorpitaServer.removeDevice(deviceId);
  }

  String? getIconPath(String deviceId, String packageName) {
    return _deviceIconCaches[deviceId]?[packageName];
  }
}