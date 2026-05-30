import '../adb_content_service.dart';

class MediaService {
  static Future<String> fetch(String deviceId) async {
    return AdbContentService.shellRaw(deviceId: deviceId, args: ['content', 'query', '--uri', 'content://media/external/images/media']);
  }
}
