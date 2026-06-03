import 'package:porpita/services/commands/adb_exec_service.dart';

import 'activity_resolver_model.dart';
import 'activity_resolver_parser.dart';

class ActivityResolverService {
  static Future<ActivityResolverResult?> fetch(String deviceId, String packageName) async {
    final raw = await AdbExecService.run(deviceId, ['dumpsys', 'package', packageName]);
    return ActivityResolverParser.parse(raw);
  }
}