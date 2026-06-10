import 'package:flutter/material.dart';

class FileEntry {
  final String name;
  final String fullPath;
  final bool isDirectory;
  final bool isSymlink;
  final int? size;
  final DateTime? modified;
  final String permissions;
  final String owner;
  final String group;

  const FileEntry({
    required this.name,
    required this.fullPath,
    required this.isDirectory,
    this.isSymlink = false,
    this.size,
    this.modified,
    this.permissions = '',
    this.owner = '',
    this.group = '',
  });

  String get extension {
    if (isDirectory) return '';
    final dot = name.lastIndexOf('.');
    if (dot < 1 || dot == name.length - 1) return '';
    return name.substring(dot + 1);
  }

  String get displaySize {
    if (isDirectory) return '';
    if (size == null || size! <= 0) return '—';
    final b = size!;
    if (b < 1024) return '$b B';
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(1)} KB';
    if (b < 1024 * 1024 * 1024) {
      return '${(b / 1024 / 1024).toStringAsFixed(1)} MB';
    }
    return '${(b / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';
  }

  static FileEntry fromLsLine(String line, String parentPath) {
    final parts = line.split(RegExp(r'\s+'));
    if (parts.length < 7) {
      final name = parts.isNotEmpty ? parts.last : '';
      return FileEntry(
        name: name,
        fullPath: _joinPath(parentPath, name),
        isDirectory: false,
      );
    }

    final perms = parts[0];
    final isDir = perms.startsWith('d');
    final isLink = perms.startsWith('l');
    final owner = parts[2];
    final group = parts[3];
    final sizeStr = parts[4];

    int? size;
    if (!isDir) {
      size = int.tryParse(sizeStr);
    }

    DateTime? modified;
    try {
      final monthStr = parts[5];
      final dayStr = parts[6];
      final timeOrYear = parts[7];
      final now = DateTime.now();
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      final month = months.indexOf(monthStr) + 1;
      final day = int.tryParse(dayStr) ?? 1;
      if (timeOrYear.contains(':')) {
        final timeParts = timeOrYear.split(':');
        final hour = int.tryParse(timeParts[0]) ?? 0;
        final minute = int.tryParse(timeParts[1]) ?? 0;
        modified = DateTime(now.year, month, day, hour, minute);
      } else {
        final year = int.tryParse(timeOrYear) ?? now.year;
        modified = DateTime(year, month, day);
      }
    } catch (_) {}

    String name;
    if (isLink && line.contains(' -> ')) {
      final arrowIdx = line.indexOf(' -> ');
      final beforeArrow = line.substring(0, arrowIdx).trim();
      final beforeParts = beforeArrow.split(RegExp(r'\s+'));
      name = beforeParts.length > 7 ? beforeParts.sublist(7).join(' ') : beforeParts.last;
    } else {
      name = parts.length > 8 ? parts.sublist(8).join(' ') : parts.last;
    }

    if (name.startsWith('/')) {
      final slashIdx = name.lastIndexOf('/');
      name = slashIdx >= 0 ? name.substring(slashIdx + 1) : name;
    }

    return FileEntry(
      name: name,
      fullPath: _joinPath(parentPath, name),
      isDirectory: isDir,
      isSymlink: isLink,
      size: size,
      modified: modified,
      permissions: perms,
      owner: owner,
      group: group,
    );
  }

  static String _joinPath(String parent, String name) {
    if (parent.endsWith('/')) return '$parent$name';
    return '$parent/$name';
  }
}

enum FileViewMode { list, grid }

enum FileSortMode {
  nameAsc('A → Z', Icons.arrow_upward, 'name_asc'),
  nameDesc('Z → A', Icons.arrow_downward, 'name_desc'),
  newestFirst('Newest', Icons.schedule, 'newest'),
  oldestFirst('Oldest', Icons.history, 'oldest'),
  largestFirst('Largest', Icons.bar_chart, 'largest'),
  smallestFirst('Smallest', Icons.show_chart, 'smallest'),
  kindGroup('Kind', Icons.category, 'kind');

  final String label;
  final IconData icon;
  final String value;
  const FileSortMode(this.label, this.icon, this.value);
}

class SearchFilter {
  final String query;
  final bool filesOnly;
  final bool foldersOnly;
  final bool caseSensitive;

  const SearchFilter({
    this.query = '',
    this.filesOnly = false,
    this.foldersOnly = false,
    this.caseSensitive = false,
  });

  List<String> toFindArgs(String searchPath) {
    final args = <String>['find', searchPath];

    if (foldersOnly) {
      args.addAll(['-type', 'd']);
    } else if (filesOnly) {
      args.addAll(['-type', 'f']);
    }

    if (query.isNotEmpty) {
      if (caseSensitive) {
        args.addAll(['-name', query]);
      } else {
        args.addAll(['-iname', query]);
      }
    }

    args.add('2>/dev/null');
    return args;
  }
}
