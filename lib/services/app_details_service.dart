import 'dart:io';

import 'adb_manager.dart';

class DumpsysSection {
  final String title;
  final String rawText;

  const DumpsysSection({required this.title, required this.rawText});
}

class DumpsysResult {
  final PackageDetails details;
  final List<DumpsysSection> sections;

  const DumpsysResult({required this.details, required this.sections});
}

class PackageDetails {
  String packageName;

  // Core app information
  String? appId;
  String? versionName;
  String? versionCode;
  String? minSdk;
  String? targetSdk;

  // Installation and update details
  String? installerPackageName;
  String? installerPackageUid;
  String? initiatingPackageName;
  String? originatingPackageName;
  String? updateOwnerPackageName;
  String? packageSource;
  String? timeStamp;
  String? lastUpdateTime;

  // Technical details
  String? codePath;
  String? resourcePath;
  String? legacyNativeLibraryDir;
  String? extractNativeLibs;
  String? primaryCpuAbi;
  String? usesNonSdkApi;
  String? isMiuiPreinstall;
  String? splits;
  String? apkSigningVersion;
  String? flags;
  String? privateFlags;
  String? forceQueryable;
  String? queriesPackages;
  String? queriesIntents;
  String? dataDir;
  String? supportsScreens;
  String? appMetadataFilePath;
  String? installPermissionsFixed;

  PackageDetails({required this.packageName});

  List<DetailEntry> toDetailEntries() {
    final entries = <DetailEntry>[];
    void add(String key, String? value) {
      if (value == null || value.isEmpty) return;
      entries.add(DetailEntry(key: key, value: value, description: _descriptions[key] ?? ''));
    }

    add('appId', appId);
    add('pkg', packageName);
    add('versionName', versionName);
    add('versionCode', versionCode);
    add('minSdk', minSdk);
    add('targetSdk', targetSdk);
    add('installerPackageName', installerPackageName);
    add('installerPackageUid', installerPackageUid);
    add('initiatingPackageName', initiatingPackageName);
    add('originatingPackageName', originatingPackageName);
    add('updateOwnerPackageName', updateOwnerPackageName);
    add('packageSource', packageSource);
    add('timeStamp', timeStamp);
    add('lastUpdateTime', lastUpdateTime);
    add('codePath', codePath);
    add('resourcePath', resourcePath);
    add('legacyNativeLibraryDir', legacyNativeLibraryDir);
    add('extractNativeLibs', extractNativeLibs);
    add('primaryCpuAbi', primaryCpuAbi);
    add('usesNonSdkApi', usesNonSdkApi);
    add('isMiuiPreinstall', isMiuiPreinstall);
    add('splits', splits);
    add('apkSigningVersion', apkSigningVersion);
    add('flags', flags);
    add('privateFlags', privateFlags);
    add('forceQueryable', forceQueryable);
    add('queriesPackages', queriesPackages);
    add('queriesIntents', queriesIntents);
    add('dataDir', dataDir);
    add('supportsScreens', supportsScreens);
    add('appMetadataFilePath', appMetadataFilePath);
    add('installPermissionsFixed', installPermissionsFixed);

    return entries;
  }

  static const _descriptions = <String, String>{
    'appId': 'Application ID (same as package name for Android app)',
    'pkg': 'Package name of the app',
    'versionName': 'Human-readable version name',
    'versionCode': 'Internal version code used by the system',
    'minSdk': 'Minimum Android SDK level required to run',
    'targetSdk': 'Target Android SDK level the app is optimized for',
    'installerPackageName': 'Package responsible for installing this app',
    'installerPackageUid': 'UID of the installer package',
    'initiatingPackageName': 'Package that initiated installation',
    'originatingPackageName': 'Original source package for install',
    'updateOwnerPackageName': 'Package that owns updates for this app',
    'packageSource': 'Source of the package (e.g., system, user)',
    'timeStamp': 'Initial install timestamp',
    'lastUpdateTime': 'Last time the app was updated',
    'codePath': 'Path to base APK code on device',
    'resourcePath': 'Path to resources for the app',
    'legacyNativeLibraryDir': 'Directory for native .so libraries (legacy)',
    'extractNativeLibs': 'Whether native libs are extracted from APK',
    'primaryCpuAbi': 'Primary supported CPU ABI',
    'usesNonSdkApi': 'Whether app uses non-SDK APIs',
    'isMiuiPreinstall': 'MIUI preinstalled application flag',
    'splits': 'APK splits present for this install',
    'apkSigningVersion': 'APK signing scheme version',
    'flags': 'Package flags (bitmask)',
    'privateFlags': 'Private package flags (bitmask)',
    'forceQueryable': 'Whether app is force-queryable for queries',
    'queriesPackages': 'Packages this app can query',
    'queriesIntents': 'Intents this app can query',
    'dataDir': 'App data directory on device',
    'supportsScreens': 'Screen sizes/densities supported',
    'appMetadataFilePath': 'Path to app metadata file',
    'installPermissionsFixed': 'Whether install-time permissions are fixed',
  };
}

class DetailEntry {
  final String key;
  final String value;
  final String description;

  const DetailEntry({
    required this.key,
    required this.value,
    this.description = '',
  });
}

class AppDetailsService {
  static Future<DumpsysResult?> fetchPackageDetails({
    required String deviceId,
    required String packageName,
  }) async {
    final adbPath = AdbManager.instance.adbPath;
    if (adbPath == null) return null;

    final result = await Process.run(
      adbPath,
      ['-s', deviceId, 'shell', 'dumpsys', 'package', packageName],
    );

    if (result.exitCode != 0) return null;

    final rawOutput = result.stdout.toString();
    final details = _parseDumpsysOutput(rawOutput, packageName);
    final sections = _splitIntoSections(rawOutput);

    return DumpsysResult(details: details, sections: sections);
  }

  static List<DumpsysSection> _splitIntoSections(String rawOutput) {
    final lines = rawOutput.split('\n');
    final sections = <DumpsysSection>[];
    int? sectionStart;
    String? currentTitle;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      // Match top-level section headers like "Activity Resolver Table:", "Packages:", etc.
      if (RegExp(r'^[A-Z][a-zA-Z /]+:$').hasMatch(line)) {
        if (currentTitle != null && sectionStart != null) {
          final text = lines.sublist(sectionStart, i).join('\n');
          sections.add(DumpsysSection(title: currentTitle, rawText: text));
        }
        currentTitle = line.substring(0, line.length - 1); // Remove trailing ":"
        sectionStart = i;
      }
    }

    // Last section
    if (currentTitle != null && sectionStart != null) {
      final text = lines.sublist(sectionStart).join('\n');
      sections.add(DumpsysSection(title: currentTitle, rawText: text));
    }

    return sections;
  }

  static PackageDetails _parseDumpsysOutput(String output, String packageName) {
    final details = PackageDetails(packageName: packageName);
    final lines = output.split('\n');

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      if (line.startsWith('appId=')) {
        details.appId = line.substring(6);
      } else if (line.startsWith('versionName=')) {
        details.versionName = line.substring(12);
      } else if (line.startsWith('codePath=')) {
        details.codePath = line.substring(9);
      } else if (line.startsWith('resourcePath=')) {
        details.resourcePath = line.substring(13);
      } else if (line.startsWith('legacyNativeLibraryDir=')) {
        details.legacyNativeLibraryDir = line.substring(23);
      } else if (line.startsWith('extractNativeLibs=')) {
        details.extractNativeLibs = line.substring(18);
      } else if (line.startsWith('primaryCpuAbi=')) {
        details.primaryCpuAbi = line.substring(14);
      } else if (line.startsWith('versionCode=') && line.contains('minSdk=')) {
        _parseVersionCodeLine(line, details);
      } else if (line.startsWith('usesNonSdkApi=')) {
        details.usesNonSdkApi = line.substring(14);
      } else if (line.startsWith('isMiuiPreinstall=')) {
        details.isMiuiPreinstall = line.substring(17);
      } else if (line.startsWith('splits=')) {
        details.splits = line.substring(7);
      } else if (line.startsWith('apkSigningVersion=')) {
        details.apkSigningVersion = line.substring(18);
      } else if (line.startsWith('flags=')) {
        details.flags = line.substring(6);
      } else if (line.startsWith('privateFlags=')) {
        details.privateFlags = line.substring(13);
      } else if (line.startsWith('forceQueryable=')) {
        details.forceQueryable = line.substring(15);
      } else if (line.startsWith('queriesPackages=')) {
        details.queriesPackages = line.substring(16);
      } else if (line.startsWith('queriesIntents=')) {
        details.queriesIntents = line.substring(15);
      } else if (line.startsWith('dataDir=')) {
        details.dataDir = line.substring(8);
      } else if (line.startsWith('supportsScreens=')) {
        details.supportsScreens = line.substring(16);
      } else if (line.startsWith('timeStamp=')) {
        details.timeStamp = line.substring(10);
      } else if (line.startsWith('lastUpdateTime=')) {
        details.lastUpdateTime = line.substring(15);
      } else if (line.startsWith('installerPackageName=')) {
        details.installerPackageName = line.substring(21);
      } else if (line.startsWith('installerPackageUid=')) {
        details.installerPackageUid = line.substring(19);
      } else if (line.startsWith('initiatingPackageName=')) {
        details.initiatingPackageName = line.substring(22);
      } else if (line.startsWith('originatingPackageName=')) {
        details.originatingPackageName = line.substring(23);
      } else if (line.startsWith('updateOwnerPackageName=')) {
        details.updateOwnerPackageName = line.substring(23);
      } else if (line.startsWith('packageSource=')) {
        details.packageSource = line.substring(14);
      } else if (line.startsWith('appMetadataFilePath=')) {
        details.appMetadataFilePath = line.substring(20);
      } else if (line.startsWith('installPermissionsFixed=')) {
        details.installPermissionsFixed = line.substring(24);
      }
    }

    return details;
  }

  static void _parseVersionCodeLine(String line, PackageDetails details) {
    final parts = line.split(' ');
    for (final part in parts) {
      if (part.startsWith('versionCode=')) {
        details.versionCode = part.substring(12);
      } else if (part.startsWith('minSdk=')) {
        details.minSdk = part.substring(7);
      } else if (part.startsWith('targetSdk=')) {
        details.targetSdk = part.substring(10);
      }
    }
  }
}
