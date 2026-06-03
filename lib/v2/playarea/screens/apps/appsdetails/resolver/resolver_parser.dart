import 'resolver_model.dart';

class ResolverParser {
  static final _sectionNames = {
    'Full MIME Types',
    'Base MIME Types',
    'Wild MIME Types',
    'Schemes',
    'Non-Data Actions',
    'MIME Typed Actions',
  };

  static ResolverResult? parse(String rawDump, String tableName) {
    final sectionStart = rawDump.indexOf('$tableName:');
    if (sectionStart == -1) return null;

    final nextSection = _findNextSection(rawDump, sectionStart + tableName.length + 1);
    final section = rawDump.substring(sectionStart, nextSection);

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

      final tableHeader = '$tableName:';
      if (trimmed == tableHeader) continue;

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
        if (currentDetailBuffer.isNotEmpty) {
          currentDetailBuffer += '\n';
        }
        currentDetailBuffer += line.trimRight();
        continue;
      }
    }

    _flushEntry(currentEntry, currentDetailBuffer, currentGroup);
    _flushGroup(currentGroup, currentSection);
    _flushSection(currentSection, sections);

    return ResolverResult(tableName: tableName, sections: sections);
  }

  static String? _extractSectionName(String line) {
    if (line.startsWith('  ') && !line.startsWith('    ')) {
      final trimmed = line.trim();
      final name = trimmed.replaceAll(':', '');
      if (_sectionNames.contains(name)) {
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
    final finalized = ResolverEntry(
      hashClass: entry.hashClass,
      componentName: entry.componentName,
      filterHash: entry.filterHash,
      rawDetail: detail.trimRight(),
    );
    group.entries.add(finalized);
  }

  static void _flushGroup(ResolverGroup? group, ResolverSection? section) {
    if (group == null || section == null) return;
    if (group.entries.isNotEmpty) {
      section.groups.add(group);
    }
  }

  static void _flushSection(ResolverSection? section, List<ResolverSection> sections) {
    if (section == null) return;
    if (section.groups.isNotEmpty) {
      sections.add(section);
    }
  }

  static int _findNextSection(String rawDump, int start) {
    final markers = [
      '\nReceiver Resolver Table:',
      '\nService Resolver Table:',
      '\nContentProvider Resolver Table:',
      '\nDomain verification status:',
      '\nPermissions:',
      '\nRegistered ContentProviders:',
      '\nContentProvider Authorities:',
      '\nKey Set Manager:',
      '\nPackages:',
      '\nQueries:',
    ];
    int nearest = rawDump.length;
    for (final marker in markers) {
      final idx = rawDump.indexOf(marker, start);
      if (idx != -1 && idx < nearest) {
        nearest = idx;
      }
    }
    return nearest;
  }
}