import 'package:porpita/services/commands/adb_exec_service.dart';

import 'resolver_model.dart';
import 'resolver_parser.dart';
import 'dump_section_parser.dart';

class ResolverService {
  static Future<ResolverResult?> fetch(String deviceId, String packageName, String tableName) async {
    final raw = await AdbExecService.run(deviceId, ['dumpsys', 'package', packageName]);
    return ResolverParser.parse(raw, tableName);
  }

  static Future<String> fetchRaw(String deviceId, String packageName) async {
    return AdbExecService.run(deviceId, ['dumpsys', 'package', packageName]);
  }

  static Future<ResolverResult?> fetchDomainVerification(String deviceId, String packageName) async {
    final raw = await AdbExecService.run(deviceId, ['dumpsys', 'package', packageName]);
    return DumpSectionParser.parseAsKeyItems(raw, 'Domain verification status');
  }

  static Future<ResolverResult?> fetchContentProviders(String deviceId, String packageName) async {
    final raw = await AdbExecService.run(deviceId, ['dumpsys', 'package', packageName]);
    return DumpSectionParser.parseContentProviders(raw);
  }

  static Future<ResolverResult?> fetchContentProviderAuthorities(String deviceId, String packageName) async {
    final raw = await AdbExecService.run(deviceId, ['dumpsys', 'package', packageName]);
    return DumpSectionParser.parseContentProviderAuthorities(raw);
  }

  static Future<ResolverResult?> fetchKeySetManager(String deviceId, String packageName) async {
    final raw = await AdbExecService.run(deviceId, ['dumpsys', 'package', packageName]);
    return DumpSectionParser.parseAsKeyItems(raw, 'Key Set Manager');
  }

  static Future<ResolverResult?> fetchPackages(String deviceId, String packageName) async {
    final raw = await AdbExecService.run(deviceId, ['dumpsys', 'package', packageName]);
    return DumpSectionParser.parsePackages(raw);
  }

  static Future<ResolverResult?> fetchQueries(String deviceId, String packageName) async {
    final raw = await AdbExecService.run(deviceId, ['dumpsys', 'package', packageName]);
    return DumpSectionParser.parseQueries(raw);
  }
}