import 'activity_resolver_model.dart';

class ActivityResolverParser {
  static final _sectionNames = {
    'Full MIME Types',
    'Base MIME Types',
    'Wild MIME Types',
    'Schemes',
    'Non-Data Actions',
    'MIME Typed Actions',
  };

  static ActivityResolverResult? parse(String rawDump) {
    final activityStart = rawDump.indexOf('Activity Resolver Table:');
    if (activityStart == -1) return null;

    final nextSection = _findNextSection(rawDump, activityStart);
    final section = rawDump.substring(activityStart, nextSection);

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

      if (trimmed == 'Activity Resolver Table:') continue;

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

      final entryMatch = RegExp(r'^\s{4,8}([0-9a-f]+)\s+(\S+)\s+filter\s+([0-9a-f]+)$').firstMatch(line);
      if (entryMatch != null) {
        _flushEntry(currentEntry, currentDetailBuffer, currentGroup);
        currentDetailBuffer = '';
        currentEntry = ResolverEntry(
          hashClass: entryMatch.group(1)!,
          activityName: entryMatch.group(2)!,
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

    return ActivityResolverResult(sections: sections);
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
      return line.trim().replaceAll(':', '');
    }
    if (line.startsWith('    ') && !line.startsWith('      ') && line.trim().endsWith(':')) {
      if (_extractSectionName(line) != null) return null;
      if (RegExp(r'^\s{4}[0-9a-f]+\s+\S+\s+filter\s+[0-9a-f]+$').hasMatch(line)) return null;
      return line.trim().replaceAll(':', '');
    }
    return null;
  }

  static void _flushEntry(ResolverEntry? entry, String detail, [ResolverGroup? group]) {
    if (entry == null || group == null) return;
    final finalized = ResolverEntry(
      hashClass: entry.hashClass,
      activityName: entry.activityName,
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
      'Receiver Resolver Table:',
      'Service Resolver Table:',
      'ContentProvider Resolver Table:',
    ];
    int nearest = rawDump.length;
    for (final marker in markers) {
      final idx = rawDump.indexOf(marker, start + 1);
      if (idx != -1 && idx < nearest) {
        nearest = idx;
      }
    }
    return nearest;
  }
}