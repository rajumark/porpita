import 'resolver_model.dart';
import 'dump_parser_core.dart';

class DumpEntryParser {
  static ResolverResult? parseAsEntries(String rawDump, String tableName) {
    final section = DumpParserCore.extractSection(rawDump, tableName);
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

      final sectionName = DumpParserCore.extractSectionName(line);
      if (sectionName != null) {
        DumpParserCore.flushEntry(currentEntry, currentDetailBuffer, currentGroup);
        currentDetailBuffer = '';
        currentEntry = null;
        DumpParserCore.flushGroup(currentGroup, currentSection);
        currentGroup = null;
        DumpParserCore.flushSection(currentSection, sections);
        currentSection = ResolverSection(name: sectionName, groups: []);
        continue;
      }

      final groupKey = DumpParserCore.extractGroupKey(line);
      if (groupKey != null) {
        DumpParserCore.flushEntry(currentEntry, currentDetailBuffer, currentGroup);
        currentDetailBuffer = '';
        currentEntry = null;
        DumpParserCore.flushGroup(currentGroup, currentSection);
        currentGroup = ResolverGroup(key: groupKey, entries: []);
        continue;
      }

      final entryMatch = RegExp(r'^\s{4,8}([0-9a-f]+)\s+(\S+)\s+filter\s+([0-9a-f]+)').firstMatch(line);
      if (entryMatch != null) {
        DumpParserCore.flushEntry(currentEntry, currentDetailBuffer, currentGroup);
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

    DumpParserCore.flushEntry(currentEntry, currentDetailBuffer, currentGroup);
    DumpParserCore.flushGroup(currentGroup, currentSection);
    DumpParserCore.flushSection(currentSection, sections);

    return ResolverResult(tableName: tableName, sections: sections);
  }
}