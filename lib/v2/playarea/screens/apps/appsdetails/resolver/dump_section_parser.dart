import 'resolver_model.dart';

class DumpSectionParser {
  static final _sectionHeaders = [
    'Activity Resolver Table',
    'Receiver Resolver Table',
    'Service Resolver Table',
    'Domain verification status',
    'Registered ContentProviders',
    'ContentProvider Authorities',
    'Key Set Manager',
    'Packages',
    'Queries',
  ];

  static String extractSection(String rawDump, String sectionName) {
    final header = '$sectionName:';
    final startIndex = rawDump.indexOf(header);
    if (startIndex == -1) return '';

    var searchFrom = startIndex + header.length;
    final nextSection = _findNextSection(rawDump, searchFrom);
    return rawDump.substring(startIndex, nextSection).trimRight();
  }

  static int _findNextSection(String rawDump, int start) {
    var nearest = rawDump.length;
    for (final header in _sectionHeaders) {
      final search = '\n$header:';
      var idx = rawDump.indexOf(search, start);
      if (idx == -1) {
        idx = rawDump.indexOf('\n$header\n', start);
      }
      if (idx != -1 && idx < nearest) {
        nearest = idx;
      }
    }
    return nearest;
  }

  static ResolverResult? parseAsEntries(String rawDump, String tableName) {
    final section = extractSection(rawDump, tableName);
    if (section.isEmpty) return null;

    final lines = section.split('\n');
    final sections = <ResolverSection>[];
    ResolverSection? currentSection;
    ResolverGroup? currentGroup;
    ResolverEntry? currentEntry;
    String currentDetailBuffer = '';

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trimRight();
      if (trimmed.isEmpty) continue;

      final headerLine = '$tableName:';
      if (trimmed == headerLine) continue;

      final sectionName = _extractSectionName(line);
      if (sectionName != null) {
        _flushEntry(currentEntry, currentDetailBuffer, currentGroup);
        currentDetailBuffer = '';
        currentEntry = null;
        _flushGroup(currentGroup, currentSection);
        currentGroup = null;
        _flushSection(currentSection, sections);
        currentSection = ResolverSection(name: sectionName, groups: []);
        continue;
      }

      final groupKey = _extractGroupKey(line);
      if (groupKey != null) {
        _flushEntry(currentEntry, currentDetailBuffer, currentGroup);
        currentDetailBuffer = '';
        currentEntry = null;
        _flushGroup(currentGroup, currentSection);
        currentGroup = ResolverGroup(key: groupKey, entries: []);
        continue;
      }

      final entryMatch = RegExp(r'^\s{4,8}([0-9a-f]+)\s+(\S+)\s+filter\s+([0-9a-f]+)').firstMatch(line);
      if (entryMatch != null) {
        _flushEntry(currentEntry, currentDetailBuffer, currentGroup);
        currentDetailBuffer = '';
        currentEntry = ResolverEntry(
          hashClass: entryMatch.group(1)!,
          componentName: entryMatch.group(2)!,
          filterHash: entryMatch.group(3)!,
          rawDetail: '',
        );
        continue;
      }

      if (currentEntry != null && line.startsWith('          ')) {
        if (currentDetailBuffer.isNotEmpty) currentDetailBuffer += '\n';
        currentDetailBuffer += line.trimRight();
        continue;
      }
    }

    _flushEntry(currentEntry, currentDetailBuffer, currentGroup);
    _flushGroup(currentGroup, currentSection);
    _flushSection(currentSection, sections);

    return ResolverResult(tableName: tableName, sections: sections);
  }

  static ResolverResult? parseAsKeyItems(String rawDump, String tableName) {
    final section = extractSection(rawDump, tableName);
    if (section.isEmpty) return null;

    final lines = section.split('\n');
    final items = <ResolverGroup>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trimRight().isEmpty) continue;

      if (line.startsWith('  ') && !line.startsWith('    ') && line.trimRight().endsWith(':')) {
        final key = line.trim().replaceAll(RegExp(r':$'), '');
        final detailLines = <String>[];
        var j = i + 1;
        while (j < lines.length && lines[j].startsWith('    ') && lines[j].trimRight().isNotEmpty) {
          detailLines.add(lines[j].trimRight());
          j++;
        }
        final entry = ResolverEntry(
          hashClass: '',
          componentName: key,
          filterHash: '',
          rawDetail: detailLines.join('\n'),
        );
        items.add(ResolverGroup(key: key, entries: [entry]));
      }
    }

    if (items.isEmpty) return null;
    return ResolverResult(tableName: tableName, sections: [
      ResolverSection(name: tableName, groups: items),
    ]);
  }

  static ResolverResult? parseContentProviders(String rawDump) {
    final section = extractSection(rawDump, 'Registered ContentProviders');
    if (section.isEmpty) return null;

    final lines = section.split('\n');
    final items = <ResolverGroup>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trimRight().isEmpty) continue;

      if (line.startsWith('  ') && !line.startsWith('    ') && line.trimRight().endsWith(':')) {
        final name = line.trim().replaceAll(RegExp(r':$'), '');
        final detailLines = <String>[];
        var j = i + 1;
        while (j < lines.length && lines[j].startsWith('    ') && lines[j].trimRight().isNotEmpty) {
          detailLines.add(lines[j].trimRight());
          j++;
        }
        final entry = ResolverEntry(
          hashClass: '',
          componentName: name,
          filterHash: '',
          rawDetail: detailLines.join('\n'),
        );
        items.add(ResolverGroup(key: name, entries: [entry]));
      }
    }

    if (items.isEmpty) return null;
    return ResolverResult(tableName: 'Registered ContentProviders', sections: [
      ResolverSection(name: 'Registered ContentProviders', groups: items),
    ]);
  }

  static ResolverResult? parseContentProviderAuthorities(String rawDump) {
    final section = extractSection(rawDump, 'ContentProvider Authorities');
    if (section.isEmpty) return null;

    final lines = section.split('\n');
    final items = <ResolverGroup>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trimRight().isEmpty) continue;

      if (line.startsWith('  ') && line.trim().startsWith('[') && line.trim().endsWith(']:')) {
        final name = line.trim().replaceAll(RegExp(r':$'), '');
        final detailLines = <String>[];
        var j = i + 1;
        while (j < lines.length && lines[j].startsWith('    ') && lines[j].trimRight().isNotEmpty) {
          detailLines.add(lines[j].trimRight());
          j++;
        }
        final entry = ResolverEntry(
          hashClass: '',
          componentName: name,
          filterHash: '',
          rawDetail: detailLines.join('\n'),
        );
        items.add(ResolverGroup(key: name, entries: [entry]));
      }
    }

    if (items.isEmpty) return null;
    return ResolverResult(tableName: 'ContentProvider Authorities', sections: [
      ResolverSection(name: 'ContentProvider Authorities', groups: items),
    ]);
  }

  static ResolverResult? parsePackages(String rawDump) {
    final header = 'Packages:';
    final startIndex = rawDump.indexOf(header);
    if (startIndex == -1) return null;

    var searchFrom = startIndex + header.length;
    final nextSection = _findNextSection(rawDump, searchFrom);
    final section = rawDump.substring(startIndex, nextSection).trimRight();
    if (section.isEmpty) return null;

    final lines = section.split('\n');
    final items = <ResolverGroup>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trimRight().isEmpty) continue;

      if (line.startsWith('  Package [') && line.contains(']:')) {
        final name = line.trim().replaceAll(RegExp(r'\]:$'), '').replaceFirst('Package [', '').replaceFirst(']', '');
        final detailLines = <String>[];
        var j = i + 1;
        while (j < lines.length && lines[j].startsWith('    ') && lines[j].trimRight().isNotEmpty) {
          detailLines.add(lines[j].trimRight());
          j++;
        }
        final entry = ResolverEntry(
          hashClass: '',
          componentName: name,
          filterHash: '',
          rawDetail: detailLines.join('\n'),
        );
        items.add(ResolverGroup(key: name, entries: [entry]));
      }
    }

    if (items.isEmpty) return null;
    return ResolverResult(tableName: 'Packages', sections: [
      ResolverSection(name: 'Packages', groups: items),
    ]);
  }

  static ResolverResult? parseQueries(String rawDump) {
    final section = extractSection(rawDump, 'Queries');
    if (section.isEmpty) return null;

    final lines = section.split('\n');
    final sections = <ResolverSection>[];
    var currentSectionName = '';
    var currentGroupKey = '';
    var currentItems = <String>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trimRight();
      if (line.isEmpty) continue;

      if (line == 'Queries:') continue;

      if (line.startsWith('  ') && !line.startsWith('    ') && line.endsWith(':')) {
        currentSectionName = line.trim().replaceAll(':', '');
        continue;
      }

      if (line.startsWith('    ') && !line.startsWith('      ') && line.endsWith(':')) {
        if (currentGroupKey.isNotEmpty && currentItems.isNotEmpty) {
          _addQueryGroup(sections, currentSectionName, currentGroupKey, currentItems);
        }
        currentGroupKey = line.trim().replaceAll(RegExp(r':$'), '');
        currentItems = [];
        continue;
      }

      if (line.startsWith('      ') && line.trim().isNotEmpty) {
        currentItems.add(line.trim());
        continue;
      }

      if (line.startsWith('  ') && !line.startsWith('    ')) {
        final kv = line.trim();
        if (currentGroupKey.isNotEmpty) {
          _addQueryGroup(sections, currentSectionName, currentGroupKey, currentItems);
          currentGroupKey = '';
          currentItems = [];
        }
        currentItems.add(kv);
        _addQueryGroup(sections, currentSectionName.isEmpty ? 'Info' : currentSectionName, kv.split(':')[0].trim(), []);
        currentItems = [];
        currentGroupKey = '';
      }
    }

    if (currentGroupKey.isNotEmpty && currentItems.isNotEmpty) {
      _addQueryGroup(sections, currentSectionName, currentGroupKey, currentItems);
    }

    if (sections.isEmpty) return null;
    return ResolverResult(tableName: 'Queries', sections: sections);
  }

  static void _addQueryGroup(List<ResolverSection> sections, String sectionName, String groupKey, List<String> items) {
    var section = sections.where((s) => s.name == sectionName).firstOrNull;
    if (section == null) {
      section = ResolverSection(name: sectionName, groups: []);
      sections.add(section);
    }
    final entry = ResolverEntry(
      hashClass: '',
      componentName: groupKey,
      filterHash: '',
      rawDetail: items.join('\n'),
    );
    section.groups.add(ResolverGroup(key: groupKey, entries: [entry]));
  }

  static String? _extractSectionName(String line) {
    if (line.startsWith('  ') && !line.startsWith('    ')) {
      final trimmed = line.trim();
      final name = trimmed.replaceAll(RegExp(r':$'), '');
      const known = {'Full MIME Types', 'Base MIME Types', 'Wild MIME Types', 'Schemes', 'Non-Data Actions', 'MIME Typed Actions'};
      if (known.contains(name)) {
        return name;
      }
    }
    return null;
  }

  static String? _extractGroupKey(String line) {
    if (line.startsWith('      ') && line.trim().endsWith(':')) {
      if (_extractSectionName(line) != null) return null;
      return line.trim().replaceAll(RegExp(r':$'), '');
    }
    if (line.startsWith('    ') && !line.startsWith('      ') && line.trim().endsWith(':')) {
      if (_extractSectionName(line) != null) return null;
      if (RegExp(r'^\s{4}[0-9a-f]+\s+\S+\s+filter\s+[0-9a-f]+').hasMatch(line)) return null;
      return line.trim().replaceAll(RegExp(r':$'), '');
    }
    return null;
  }

  static void _flushEntry(ResolverEntry? entry, String detail, [ResolverGroup? group]) {
    if (entry == null || group == null) return;
    group.entries.add(ResolverEntry(
      hashClass: entry.hashClass,
      componentName: entry.componentName,
      filterHash: entry.filterHash,
      rawDetail: detail.trimRight(),
    ));
  }

  static void _flushGroup(ResolverGroup? group, ResolverSection? section) {
    if (group == null || section == null) return;
    if (group.entries.isNotEmpty) section.groups.add(group);
  }

  static void _flushSection(ResolverSection? section, List<ResolverSection> sections) {
    if (section == null) return;
    if (section.groups.isNotEmpty) sections.add(section);
  }
}