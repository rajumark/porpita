import '../adb_content_service.dart';

class CallLogsService {
  static Future<String> fetch(String deviceId) async {
    return AdbContentService.shellRaw(deviceId: deviceId, args: ['content', 'query', '--uri', 'content://call_log/calls']);
  }
}
