import 'package:porpita/services/commands/adb_exec_service.dart';

class AppDetailsInfo {
  final String versionName;
  final String versionCode;
  final String minSdk;
  final String targetSdk;
  final String appId;
  final String codePath;
  final String resourcePath;
  final String primaryCpuAbi;
  final String flags;
  final String privateFlags;
  final String timeStamp;
  final String lastUpdateTime;
  final String installerPackageName;
  final String forceQueryable;
  final String sharedUser;
  final String signatures;

  const AppDetailsInfo({
    this.versionName = '',
    this.versionCode = '',
    this.minSdk = '',
    this.targetSdk = '',
    this.appId = '',
    this.codePath = '',
    this.resourcePath = '',
    this.primaryCpuAbi = '',
    this.flags = '',
    this.privateFlags = '',
    this.timeStamp = '',
    this.lastUpdateTime = '',
    this.installerPackageName = '',
    this.forceQueryable = '',
    this.sharedUser = '',
    this.signatures = '',
  });
}

class AppDetailsService {
  static Future<AppDetailsInfo> fetch(String deviceId, String packageName) async {
    final raw = await AdbExecService.run(deviceId, ['dumpsys', 'package', packageName]);
    return _parse(raw, packageName);
  }

  static AppDetailsInfo _parse(String raw, String packageName) {
    final lines = raw.split('\n');

    int start = -1;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('Package [')) {
        start = i;
        break;
      }
    }
    if (start == -1) return const AppDetailsInfo();

    final map = <String, String>{};
    for (int i = start + 1; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty || line.contains('Package [') || line.contains('User 0:') || line.startsWith('Packages:')) {
        if (line.contains('Package [') && i != start) break;
        continue;
      }
      final trimmed = line.trim();
      final eq = trimmed.indexOf('=');
      if (eq > 0) {
        final key = trimmed.substring(0, eq).trim();
        var val = trimmed.substring(eq + 1).trim();
        final brack = val.indexOf(' [');
        if (brack == 0) {
          val = trimmed.substring(eq + 1).trim();
        }
        map[key] = val;
      }
    }

    final vcLine = map['versionCode'];
    String vc = '', ms = '', ts = '';
    if (vcLine != null) {
      final m = RegExp(r'(\d+)\s+minSdk=(\d+)\s+targetSdk=(\d+)').firstMatch(vcLine);
      if (m != null) {
        vc = m.group(1)!;
        ms = m.group(2)!;
        ts = m.group(3)!;
      } else {
        vc = vcLine;
      }
    }

    return AppDetailsInfo(
      versionName: map['versionName'] ?? '',
      versionCode: vc,
      minSdk: ms,
      targetSdk: ts,
      appId: map['appId'] ?? '',
      codePath: map['codePath'] ?? '',
      resourcePath: map['resourcePath'] ?? '',
      primaryCpuAbi: map['primaryCpuAbi'] ?? '',
      flags: map['flags'] ?? map['pkgFlags'] ?? '',
      privateFlags: map['privateFlags'] ?? map['privatePkgFlags'] ?? '',
      timeStamp: map['timeStamp'] ?? '',
      lastUpdateTime: map['lastUpdateTime'] ?? '',
      installerPackageName: map['installerPackageName'] ?? '',
      forceQueryable: map['forceQueryable'] ?? '',
      sharedUser: map['sharedUser'] ?? '',
      signatures: map['signatures'] ?? '',
    );
  }
}