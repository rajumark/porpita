import 'media_model.dart';

class MediaUri {
  final String label;
  final String uri;
  final bool isStandard;
  const MediaUri({
    required this.label,
    required this.uri,
    this.isStandard = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaUri && uri == other.uri && label == other.label;

  @override
  int get hashCode => Object.hash(uri, label);
}

const List<MediaUri> kExternalMediaUris = [
  MediaUri(
    label: 'All Files',
    uri: 'content://media/external/file',
    isStandard: true,
  ),
  MediaUri(
    label: 'Images',
    uri: 'content://media/external/images/media',
    isStandard: true,
  ),
  MediaUri(
    label: 'Video',
    uri: 'content://media/external/video/media',
    isStandard: true,
  ),
  MediaUri(
    label: 'Audio',
    uri: 'content://media/external/audio/media',
    isStandard: true,
  ),
  MediaUri(
    label: 'Downloads',
    uri: 'content://media/external/downloads',
    isStandard: true,
  ),
];

const List<MediaUri> kInternalMediaUris = [
  MediaUri(
    label: 'All Files',
    uri: 'content://media/internal/file',
    isStandard: true,
  ),
  MediaUri(
    label: 'Images',
    uri: 'content://media/internal/images/media',
  ),
  MediaUri(
    label: 'Video',
    uri: 'content://media/internal/video/media',
  ),
  MediaUri(
    label: 'Audio',
    uri: 'content://media/internal/audio/media',
    isStandard: true,
  ),
];

List<MediaUri> mediaUrisFor(MediaVolume v) {
  return v == MediaVolume.external ? kExternalMediaUris : kInternalMediaUris;
}
