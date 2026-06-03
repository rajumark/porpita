import 'package:porpita/services/commands/adb_exec_service.dart';

import 'resolver_model.dart';
import 'resolver_parser.dart';

class ResolverService {
  static Future<ResolverResult?> fetch(String deviceId, String packageName, String tableName) async {
    final raw = await AdbExecService.run(deviceId, ['dumpsys', 'package', packageName]);
    return ResolverParser.parse(raw, tableName);
  }
}