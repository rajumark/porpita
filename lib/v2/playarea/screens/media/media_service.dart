import 'package:porpita/services/content_query_parser.dart';
import 'media_model.dart';
import 'media_uri.dart';

const List<String> kMediaColumns = [
  '_id',
  '_display_name',
  '_data',
  'mime_type',
  '_size',
  'date_added',
  'date_modified',
  'datetaken',
  'date_expires',
  'bucket_display_name',
  'owner_package_name',
  'volume_name',
  'relative_path',
  'title',
  'artist',
  'album',
  'duration',
  'resolution',
  'width',
  'height',
  'bitrate',
  'samplerate',
  'is_favorite',
  'is_trashed',
  'is_download',
  'is_music',
  'is_ringtone',
  'is_alarm',
  'is_notification',
  'is_podcast',
  'description',
  'format',
  'parent',
  'media_type',
  'download_uri',
  'referer_uri',
  'is_drm',
  'is_pending',
  'language',
  'group_id',
  'document_id',
  'original_document_id',
  'oem_metadata',
  'genre',
  'track',
  'year',
  'composer',
  'cd_track_number',
  'disc_number',
  'album_artist',
  'tags',
  'category',
  'color_standard',
  'color_transfer',
  'color_range',
  'capture_framerate',
  'latitude',
  'longitude',
  'orientation',
  'xmp',
  'instance_id',
];

class MediaService {
  static Future<List<MediaEntry>> fetch(String deviceId, MediaUri uri) async {
    final rows = await ContentQueryParser.query(
      deviceId: deviceId,
      uri: uri.uri,
      knownColumns: kMediaColumns,
    );
    final list = rows.map(MediaEntry.fromMap).toList();
    list.sort((a, b) {
      final ad = a.dateAdded ?? a.dateModified;
      final bd = b.dateAdded ?? b.dateModified;
      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;
      return bd.compareTo(ad);
    });
    return list;
  }

  static String labelFor(MediaUri uri) {
    return uri.label;
  }
}
