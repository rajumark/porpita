import 'package:flutter/material.dart';

enum FileCategory {
  image('Image', Icons.image_outlined),
  video('Video', Icons.movie_outlined),
  audio('Audio', Icons.audiotrack_outlined),
  document('Document', Icons.description_outlined),
  pdf('PDF', Icons.picture_as_pdf_outlined),
  archive('Archive', Icons.archive_outlined),
  code('Code', Icons.code),
  text('Text', Icons.text_snippet_outlined),
  font('Font', Icons.font_download_outlined),
  apk('APK', Icons.android),
  other('File', Icons.insert_drive_file_outlined),
  folder('Folder', Icons.folder_outlined);

  final String label;
  final IconData icon;
  const FileCategory(this.label, this.icon);
}

class FileTypeStyle {
  final Color background;
  final Color foreground;
  final FileCategory category;

  const FileTypeStyle({
    required this.background,
    required this.foreground,
    required this.category,
  });
}

class FileCategorizer {
  static const _imageExts = {
    'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg', 'heic', 'heif', 'tiff', 'tif', 'ico', 'raw',
  };
  static const _videoExts = {
    'mp4', 'mkv', 'avi', 'mov', 'wmv', 'flv', 'webm', 'm4v', '3gp', 'ts', 'm2ts',
  };
  static const _audioExts = {
    'mp3', 'wav', 'flac', 'ogg', 'm4a', 'aac', 'wma', 'opus', 'aiff', 'mka',
  };
  static const _documentExts = {
    'doc', 'docx', 'odt', 'rtf', 'pages',
  };
  static const _pdfExts = {'pdf'};
  static const _archiveExts = {
    'zip', 'rar', '7z', 'tar', 'gz', 'bz2', 'xz', 'tgz',
  };
  static const _codeExts = {
    'dart', 'kt', 'kts', 'java', 'class', 'py', 'js', 'ts', 'jsx', 'tsx',
    'html', 'css', 'scss', 'json', 'xml', 'yaml', 'yml', 'sh', 'rb', 'go',
    'rs', 'c', 'cpp', 'h', 'hpp', 'swift', 'm', 'mm', 'php', 'sql', 'gradle',
  };
  static const _textExts = {'txt', 'log', 'md', 'csv', 'tsv'};
  static const _fontExts = {'ttf', 'otf', 'woff', 'woff2', 'eot'};
  static const _apkExts = {'apk', 'aab', 'xapk'};

  static FileCategory categoryFromMime(String? mime) {
    if (mime == null || mime.isEmpty) return FileCategory.other;
    final m = mime.toLowerCase();
    if (m.startsWith('image/')) return FileCategory.image;
    if (m.startsWith('video/')) return FileCategory.video;
    if (m.startsWith('audio/')) return FileCategory.audio;
    if (m == 'application/pdf') return FileCategory.pdf;
    if (m.contains('zip') || m.contains('rar') || m.contains('tar') ||
        m.contains('gz') || m.contains('7z')) {
      return FileCategory.archive;
    }
    if (m.contains('officedocument') || m.contains('msword') ||
        m.contains('ms-excel') || m.contains('ms-powerpoint') ||
        m.contains('spreadsheet') || m.contains('presentation')) {
      return FileCategory.document;
    }
    if (m.startsWith('text/')) {
      if (m.contains('html') || m.contains('xml') || m.contains('json')) {
        return FileCategory.code;
      }
      return FileCategory.text;
    }
    if (m.contains('font') || m.contains('opentype') || m.contains('truetype')) {
      return FileCategory.font;
    }
    if (m.contains('android.package') || m.contains('vnd.android')) {
      return FileCategory.apk;
    }
    return FileCategory.other;
  }

  static FileCategory categoryFromExt(String ext) {
    final e = ext.toLowerCase();
    if (_imageExts.contains(e)) return FileCategory.image;
    if (_videoExts.contains(e)) return FileCategory.video;
    if (_audioExts.contains(e)) return FileCategory.audio;
    if (_pdfExts.contains(e)) return FileCategory.pdf;
    if (_documentExts.contains(e)) return FileCategory.document;
    if (_archiveExts.contains(e)) return FileCategory.archive;
    if (_codeExts.contains(e)) return FileCategory.code;
    if (_textExts.contains(e)) return FileCategory.text;
    if (_fontExts.contains(e)) return FileCategory.font;
    if (_apkExts.contains(e)) return FileCategory.apk;
    return FileCategory.other;
  }

  static String getExtension(String? path) {
    if (path == null) return '';
    final slash = path.lastIndexOf('/');
    final name = slash >= 0 ? path.substring(slash + 1) : path;
    final dot = name.lastIndexOf('.');
    if (dot < 1 || dot == name.length - 1) return '';
    return name.substring(dot + 1);
  }

  static String getName(String? path) {
    if (path == null || path.isEmpty) return '';
    final slash = path.lastIndexOf('/');
    final name = slash >= 0 ? path.substring(slash + 1) : path;
    return name;
  }

  static String getBaseName(String? path) {
    final name = getName(path);
    final dot = name.lastIndexOf('.');
    if (dot < 1) return name;
    return name.substring(0, dot);
  }

  static FileCategory categoryFromPath(String? path, String? mime) {
    final ext = getExtension(path);
    if (ext.isNotEmpty) {
      return categoryFromExt(ext);
    }
    return categoryFromMime(mime);
  }

  static FileTypeStyle styleFor(FileCategory category) {
    switch (category) {
      case FileCategory.image:
        return const FileTypeStyle(
          background: Color(0xFF1E88E5),
          foreground: Colors.white,
          category: FileCategory.image,
        );
      case FileCategory.video:
        return const FileTypeStyle(
          background: Color(0xFFE53935),
          foreground: Colors.white,
          category: FileCategory.video,
        );
      case FileCategory.audio:
        return const FileTypeStyle(
          background: Color(0xFF43A047),
          foreground: Colors.white,
          category: FileCategory.audio,
        );
      case FileCategory.document:
        return const FileTypeStyle(
          background: Color(0xFFFB8C00),
          foreground: Colors.white,
          category: FileCategory.document,
        );
      case FileCategory.pdf:
        return const FileTypeStyle(
          background: Color(0xFFD32F2F),
          foreground: Colors.white,
          category: FileCategory.pdf,
        );
      case FileCategory.archive:
        return const FileTypeStyle(
          background: Color(0xFF6D4C41),
          foreground: Colors.white,
          category: FileCategory.archive,
        );
      case FileCategory.code:
        return const FileTypeStyle(
          background: Color(0xFF5E35B1),
          foreground: Colors.white,
          category: FileCategory.code,
        );
      case FileCategory.text:
        return const FileTypeStyle(
          background: Color(0xFF546E7A),
          foreground: Colors.white,
          category: FileCategory.text,
        );
      case FileCategory.font:
        return const FileTypeStyle(
          background: Color(0xFF3949AB),
          foreground: Colors.white,
          category: FileCategory.font,
        );
      case FileCategory.apk:
        return const FileTypeStyle(
          background: Color(0xFF00897B),
          foreground: Colors.white,
          category: FileCategory.apk,
        );
      case FileCategory.other:
        return const FileTypeStyle(
          background: Color(0xFF757575),
          foreground: Colors.white,
          category: FileCategory.other,
        );
      case FileCategory.folder:
        return const FileTypeStyle(
          background: Color(0xFFF9A825),
          foreground: Colors.white,
          category: FileCategory.folder,
        );
    }
  }

  static String formatSize(int? bytes) {
    if (bytes == null || bytes <= 0) return '—';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';
  }

  static String formatDuration(int? ms) {
    if (ms == null || ms <= 0) return '—';
    final s = (ms / 1000).round();
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
    }
    return '$m:${sec.toString().padLeft(2, '0')}';
  }
}
