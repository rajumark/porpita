import 'file_categorizer.dart';

enum MediaVolume { external, internal }

enum MediaFilter { all, image, video, audio, downloaded }

class MediaEntry {
  final String id;
  final String displayName;
  final String path;
  final String mimeType;
  final int? size;
  final DateTime? dateAdded;
  final DateTime? dateModified;
  final DateTime? dateTaken;
  final DateTime? dateExpires;
  final String bucketDisplayName;
  final String ownerPackageName;
  final String volumeName;
  final String relativePath;
  final String title;
  final String artist;
  final String album;
  final String duration;
  final String resolution;
  final String width;
  final String height;
  final String bitrate;
  final String samplerate;
  final String isFavorite;
  final String isTrashed;
  final String isDownload;
  final String isMusic;
  final String isRingtone;
  final String isAlarm;
  final String isNotification;
  final String isPodcast;
  final String description;
  final String format;
  final String parent;
  final String mediaType;
  final String downloadUri;
  final String refererUri;
  final Map<String, String> raw;

  const MediaEntry({
    required this.id,
    required this.displayName,
    required this.path,
    required this.mimeType,
    required this.size,
    required this.dateAdded,
    required this.dateModified,
    required this.dateTaken,
    required this.dateExpires,
    required this.bucketDisplayName,
    required this.ownerPackageName,
    required this.volumeName,
    required this.relativePath,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.resolution,
    required this.width,
    required this.height,
    required this.bitrate,
    required this.samplerate,
    required this.isFavorite,
    required this.isTrashed,
    required this.isDownload,
    required this.isMusic,
    required this.isRingtone,
    required this.isAlarm,
    required this.isNotification,
    required this.isPodcast,
    required this.description,
    required this.format,
    required this.parent,
    required this.mediaType,
    required this.downloadUri,
    required this.refererUri,
    required this.raw,
  });

  String get extension => FileCategorizer.getExtension(path.isNotEmpty ? path : displayName);

  String get baseName {
    final n = displayName.isNotEmpty ? displayName : FileCategorizer.getName(path);
    return FileCategorizer.getBaseName(n);
  }

  FileCategory get category => FileCategorizer.categoryFromPath(
        path.isNotEmpty ? path : displayName,
        mimeType,
      );

  FileTypeStyle get style => FileCategorizer.styleFor(category);

  String get sizeDisplay => FileCategorizer.formatSize(size);

  String get durationDisplay => FileCategorizer.formatDuration(int.tryParse(duration));

  bool get isInternal => volumeName == 'internal' || path.startsWith('/product/');

  factory MediaEntry.fromMap(Map<String, String> map) {
    return MediaEntry(
      id: map['_id'] ?? '',
      displayName: map['_display_name'] ?? '',
      path: map['_data'] ?? '',
      mimeType: map['mime_type'] ?? '',
      size: int.tryParse(map['_size'] ?? ''),
      dateAdded: _dateFromSeconds(map['date_added']),
      dateModified: _dateFromSeconds(map['date_modified']),
      dateTaken: _dateFromMillis(map['datetaken']),
      dateExpires: _dateFromMillis(map['date_expires']),
      bucketDisplayName: map['bucket_display_name'] ?? '',
      ownerPackageName: map['owner_package_name'] ?? '',
      volumeName: map['volume_name'] ?? '',
      relativePath: map['relative_path'] ?? '',
      title: map['title'] ?? '',
      artist: map['artist'] ?? '',
      album: map['album'] ?? '',
      duration: map['duration'] ?? '',
      resolution: map['resolution'] ?? '',
      width: map['width'] ?? '',
      height: map['height'] ?? '',
      bitrate: map['bitrate'] ?? '',
      samplerate: map['samplerate'] ?? '',
      isFavorite: map['is_favorite'] ?? '',
      isTrashed: map['is_trashed'] ?? '',
      isDownload: map['is_download'] ?? '',
      isMusic: map['is_music'] ?? '',
      isRingtone: map['is_ringtone'] ?? '',
      isAlarm: map['is_alarm'] ?? '',
      isNotification: map['is_notification'] ?? '',
      isPodcast: map['is_podcast'] ?? '',
      description: map['description'] ?? '',
      format: map['format'] ?? '',
      parent: map['parent'] ?? '',
      mediaType: map['media_type'] ?? '',
      downloadUri: map['download_uri'] ?? '',
      refererUri: map['referer_uri'] ?? '',
      raw: Map<String, String>.from(map),
    );
  }

  static DateTime? _dateFromSeconds(String? v) {
    final secs = int.tryParse(v ?? '');
    if (secs == null || secs <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(secs * 1000);
  }

  static DateTime? _dateFromMillis(String? v) {
    final ms = int.tryParse(v ?? '');
    if (ms == null || ms <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }
}
