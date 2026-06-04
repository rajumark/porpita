import 'resolver_model.dart';

class DumpParserCore {
  static final sectionHeaders = [
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
    final nextSection = findNextSection(rawDump, searchFrom);
    return rawDump.substring(startIndex, nextSection).trimRight();
  }

  static int findNextSection(String rawDump, int start) {
    var nearest = rawDump.length;
    for (final header in sectionHeaders) {
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

  static void flushEntry(ResolverEntry? entry, String detail, [ResolverGroup? group]) {
    if (entry == null || group == null) return;
    group.entries.add(ResolverEntry(
      hashClass: entry.hashClass,
      componentName: entry.componentName,
      filterHash: entry.filterHash,
      rawDetail: detail.trimRight(),
    ));
  }

  static void flushGroup(ResolverGroup? group, ResolverSection? section) {
    if (group == null || section == null) return;
    if (group.entries.isNotEmpty) section.groups.add(group);
  }

  static void flushSection(ResolverSection? section, List<ResolverSection> sections) {
    if (section == null) return;
    if (section.groups.isNotEmpty) sections.add(section);
  }

  static String? extractSectionName(String line) {
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

  static String? extractGroupKey(String line) {
    if (line.startsWith('      ') && line.trim().endsWith(':')) {
      if (extractSectionName(line) != null) return null;
      return line.trim().replaceAll(RegExp(r':$'), '');
    }
    if (line.startsWith('    ') && !line.startsWith('      ') && line.trim().endsWith(':')) {
      if (extractSectionName(line) != null) return null;
      if (RegExp(r'^\s{4}[0-9a-f]+\s+\S+\s+filter\s+[0-9a-f]+').hasMatch(line)) return null;
      return line.trim().replaceAll(RegExp(r':$'), '');
    }
    return null;
  }
}