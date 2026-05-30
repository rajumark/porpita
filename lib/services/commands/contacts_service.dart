import '../adb_content_service.dart';

class ContactsService {
  static Future<String> fetch(String deviceId) async {
    return AdbContentService.shellRaw(deviceId: deviceId, args: ['content', 'query', '--uri', 'content://com.android.contacts/data']);
  }
}
