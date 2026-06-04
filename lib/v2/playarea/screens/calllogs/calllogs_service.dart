import 'package:porpita/services/adb_content_service.dart';
import 'package:porpita/services/commands/adb_exec_service.dart';
import 'call_log_model.dart';

class CallLogsService {
  static const _uri = 'content://call_log/calls';

  static Future<List<CallLogEntry>> fetchCallLogs(String deviceId) async {
    final rows = await AdbContentService.query(deviceId: deviceId, uri: _uri);
    final entries = rows.map(CallLogEntry.fromMap).toList();
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  static Future<String> fetchRaw(String deviceId) async {
    return AdbContentService.shellRaw(
      deviceId: deviceId,
      args: ['content', 'query', '--uri', _uri],
    );
  }

  static Future<String> callNumber(String deviceId, String number) {
    final sanitized = number.replaceAll(RegExp(r'[^\d+*#,]'), '');
    return AdbExecService.run(deviceId, [
      'am', 'start',
      '-a', 'android.intent.action.CALL',
      '-d', 'tel:$sanitized',
    ]);
  }
}
