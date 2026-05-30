import '../adb_content_service.dart';

class CalendarService {
  static Future<String> fetch(String deviceId) async {
    return AdbContentService.shellRaw(deviceId: deviceId, args: ['content', 'query', '--uri', 'content://com.android.calendar/events']);
  }
}
