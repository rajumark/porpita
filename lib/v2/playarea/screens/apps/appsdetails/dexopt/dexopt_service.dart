import 'package:porpita/services/commands/adb_exec_service.dart';

class DexoptEntry {
  final String packageName;
  final String? path;
  final List<DexoptArch> archs;

  const DexoptEntry({this.packageName = '', this.path, this.archs = const []});
}

class DexoptArch {
  final String arch;
  final String? status;
  final String? reason;
  final bool isPrimaryAbi;
  final String? location;

  const DexoptArch({this.arch = '', this.status, this.reason, this.isPrimaryAbi = false, this.location});
}

class DexoptService {
  static Future<List<DexoptEntry>> fetch(String deviceId, String packageName) async {
    final raw = await AdbExecService.run(deviceId, ['dumpsys', 'package', packageName]);
    return _parse(raw);
  }

  static List<DexoptEntry> _parse(String raw) {
    final lines = raw.split('\n');
    int start = -1;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].trim().startsWith('Dexopt state:')) {
        start = i;
        break;
      }
    }
    if (start == -1) return [];

    final endMarkers = ['Packages:', 'Activity Resolver Table:', 'Receiver Resolver Table:'];
    final sectionLines = <String>[];
    for (int i = start; i < lines.length; i++) {
      final trimmed = lines[i].trim();
      for (final marker in endMarkers) {
        if (trimmed.startsWith(marker)) {
          return _parseEntries(sectionLines);
        }
      }
      sectionLines.add(lines[i]);
    }

    return _parseEntries(sectionLines);
  }

  static List<DexoptEntry> _parseEntries(List<String> lines) {
    if (lines.isEmpty) return [];

    final entries = <DexoptEntry>[];
    DexoptEntry? current;
    DexoptArch? currentArch;

    for (int i = 0; i < lines.length; i++) {
      final trimmed = lines[i].trim();
      if (trimmed.isEmpty || trimmed.startsWith('Dexopt state:')) continue;

      final pkgMatch = RegExp(r'^\[(.+)\]$').firstMatch(trimmed);
      if (pkgMatch != null) {
if (current != null && currentArch != null) {
        current = DexoptEntry(
          packageName: current.packageName,
          path: current.path,
          archs: [...current.archs, currentArch],
        );
        currentArch = null;
      }
      current = DexoptEntry(packageName: pkgMatch.group(1)!);
        continue;
      }

      if (trimmed.startsWith('path:')) {
        current = DexoptEntry(
          packageName: current?.packageName ?? '',
          path: trimmed.substring(5).trim(),
          archs: current?.archs ?? [],
        );
        continue;
      }

      if (trimmed.startsWith('[') && trimmed.contains('location is')) {
        continue;
      }

      final archMatch = RegExp(r'^(\w+):\s*\[(.+)\]').firstMatch(trimmed);
      if (archMatch != null) {
        if (currentArch != null && current != null) {
          current = DexoptEntry(
            packageName: current.packageName,
            path: current.path,
            archs: [...current.archs, currentArch],
          );
        }
        final arch = archMatch.group(1)!;
        final rest = archMatch.group(2)!;
        String? status;
        final statusMatch = RegExp(r'status=(\w+)').firstMatch(rest);
        if (statusMatch != null) status = statusMatch.group(1);

        String? reason;
        final reasonMatch = RegExp(r'reason=(\w+)').firstMatch(rest);
        if (reasonMatch != null) reason = reasonMatch.group(1);

        final isPrimaryAbi = rest.contains('primary-abi');
        currentArch = DexoptArch(arch: arch, status: status, reason: reason, isPrimaryAbi: isPrimaryAbi);
        continue;
      }

      if (trimmed.startsWith('[location is ') && currentArch != null) {
        final loc = trimmed.replaceFirst('[location is ', '').replaceAll(']', '').trim();
        currentArch = DexoptArch(
          arch: currentArch.arch,
          status: currentArch.status,
          reason: currentArch.reason,
          isPrimaryAbi: currentArch.isPrimaryAbi,
          location: loc,
        );
      }
    }

    if (current != null) {
      if (currentArch != null) {
        current = DexoptEntry(
          packageName: current.packageName,
          path: current.path,
          archs: [...current.archs, currentArch],
        );
      }
      entries.add(current);
    }

    return entries;
  }
}