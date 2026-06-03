import 'package:porpita/services/commands/adb_exec_service.dart';

class PathItem {
  final String label;
  final String path;
  final String category;

  const PathItem({
    required this.label,
    required this.path,
    required this.category,
  });
}

class PathsResult {
  final List<PathItem> paths;

  const PathsResult({required this.paths});
}

class PathsService {
  static Future<PathsResult> fetch(String deviceId, String packageName) async {
    final items = <PathItem>[];

    final pmPathResult = await AdbExecService.run(deviceId, ['pm', 'path', packageName]);
    final apkPaths = pmPathResult
        .split('\n')
        .where((l) => l.startsWith('package:'))
        .map((l) => l.substring('package:'.length).trim())
        .where((l) => l.isNotEmpty)
        .toList();

    String? basePath;
    if (apkPaths.isNotEmpty) {
      basePath = _extractBasePath(apkPaths.first);
      items.add(PathItem(
        label: 'APK',
        path: apkPaths.first,
        category: 'Installation',
      ));
      for (var i = 1; i < apkPaths.length; i++) {
        items.add(PathItem(
          label: 'Split APK $i',
          path: apkPaths[i],
          category: 'Installation',
        ));
      }

      if (basePath != null) {
        items.add(PathItem(
          label: 'Code Path',
          path: basePath,
          category: 'Installation',
        ));
        items.add(PathItem(
          label: 'Native Libraries',
          path: '$basePath/lib',
          category: 'Installation',
        ));
        items.add(PathItem(
          label: 'OAT Directory',
          path: '$basePath/oat',
          category: 'Runtime',
        ));
      }
    }

    final dumpResult = await AdbExecService.run(deviceId, ['dumpsys', 'package', packageName]);

    String? dataDir;
    String? codePath;
    String? resourcePath;
    String? nativeLibDir;
    String? primaryCpuAbi;
    String? userId;

    for (final line in dumpResult.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.startsWith('dataDir=')) {
        dataDir = trimmed.substring('dataDir='.length).trim();
      } else if (trimmed.startsWith('codePath=')) {
        codePath = trimmed.substring('codePath='.length).trim();
      } else if (trimmed.startsWith('resourcePath=')) {
        resourcePath = trimmed.substring('resourcePath='.length).trim();
      } else if (trimmed.startsWith('legacyNativeLibraryDir=')) {
        nativeLibDir = trimmed.substring('legacyNativeLibraryDir='.length).trim();
      } else if (trimmed.startsWith('primaryCpuAbi=')) {
        primaryCpuAbi = trimmed.substring('primaryCpuAbi='.length).trim();
      } else if (trimmed.startsWith('userId=')) {
        final val = trimmed.substring('userId='.length).trim();
        if (val.isNotEmpty && int.tryParse(val) != null) {
          userId = val;
        }
      }
    }

    if (codePath != null && codePath.isNotEmpty && items.every((i) => i.label != 'Code Path')) {
      items.add(PathItem(
        label: 'Code Path',
        path: codePath,
        category: 'Installation',
      ));
    }

    if (resourcePath != null && resourcePath.isNotEmpty && resourcePath != codePath) {
      items.add(PathItem(
        label: 'Resource Path',
        path: resourcePath,
        category: 'Installation',
      ));
    }

    if (nativeLibDir != null && nativeLibDir.isNotEmpty && items.every((i) => i.path != nativeLibDir)) {
      items.add(PathItem(
        label: 'Native Library Dir',
        path: nativeLibDir,
        category: 'Installation',
      ));
    }

    if (dataDir != null && dataDir.isNotEmpty) {
      items.add(PathItem(
        label: 'Data Directory',
        path: dataDir,
        category: 'Internal Data',
      ));

      items.addAll([
        PathItem(label: 'Shared Preferences', path: '$dataDir/shared_prefs', category: 'Internal Data'),
        PathItem(label: 'Databases', path: '$dataDir/databases', category: 'Internal Data'),
        PathItem(label: 'Cache', path: '$dataDir/cache', category: 'Internal Data'),
        PathItem(label: 'Code Cache', path: '$dataDir/code_cache', category: 'Internal Data'),
        PathItem(label: 'Files', path: '$dataDir/files', category: 'Internal Data'),
      ]);
    } else if (userId != null) {
      final fallbackDataDir = '/data/user/$userId/$packageName';
      items.add(PathItem(
        label: 'Data Directory',
        path: fallbackDataDir,
        category: 'Internal Data',
      ));
      items.addAll([
        PathItem(label: 'Shared Preferences', path: '$fallbackDataDir/shared_prefs', category: 'Internal Data'),
        PathItem(label: 'Databases', path: '$fallbackDataDir/databases', category: 'Internal Data'),
        PathItem(label: 'Cache', path: '$fallbackDataDir/cache', category: 'Internal Data'),
        PathItem(label: 'Code Cache', path: '$fallbackDataDir/code_cache', category: 'Internal Data'),
        PathItem(label: 'Files', path: '$fallbackDataDir/files', category: 'Internal Data'),
      ]);
    }

    items.add(PathItem(label: 'Data (symlink)', path: '/data/data/$packageName', category: 'Internal Data'));

    items.addAll([
      PathItem(label: 'External Data', path: '/storage/emulated/0/Android/data/$packageName', category: 'External Storage'),
      PathItem(label: 'External Files', path: '/storage/emulated/0/Android/data/$packageName/files', category: 'External Storage'),
      PathItem(label: 'External Cache', path: '/storage/emulated/0/Android/data/$packageName/cache', category: 'External Storage'),
      PathItem(label: 'External Media', path: '/storage/emulated/0/Android/media/$packageName', category: 'External Storage'),
      PathItem(label: 'OBB Files', path: '/storage/emulated/0/Android/obb/$packageName', category: 'External Storage'),
    ]);

    if (userId != null) {
      items.addAll([
        PathItem(label: 'Profile (Current)', path: '/data/misc/profiles/cur/$userId/$packageName', category: 'Runtime'),
        PathItem(label: 'Profile (Reference)', path: '/data/misc/profiles/ref/$packageName', category: 'Runtime'),
      ]);
    }

    if (primaryCpuAbi != null && primaryCpuAbi.isNotEmpty && primaryCpuAbi != 'null') {
      final oatBasePath = codePath ?? basePath;
      if (oatBasePath != null) {
        items.add(PathItem(
          label: 'Compiled DEX (ODEX)',
          path: '$oatBasePath/oat/$primaryCpuAbi/base.odex',
          category: 'Runtime',
        ));
        items.add(PathItem(
          label: 'Verified DEX (VDEX)',
          path: '$oatBasePath/oat/$primaryCpuAbi/base.vdex',
          category: 'Runtime',
        ));
      }
    }

    items.addAll([
      PathItem(label: 'Package Registry', path: '/data/system/packages.xml', category: 'System'),
      PathItem(label: 'Component Restrictions', path: '/data/system/users/0/package-restrictions.xml', category: 'System'),
    ]);

    return PathsResult(paths: items);
  }

  static String? _extractBasePath(String apkPath) {
    if (!apkPath.contains('/base.apk') && !apkPath.endsWith('.apk')) return null;
    final lastSlash = apkPath.lastIndexOf('/');
    if (lastSlash == -1) return null;
    return apkPath.substring(0, lastSlash);
  }
}