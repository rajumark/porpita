import 'resolver_model.dart';
import 'dump_parser_core.dart';

class DumpSpecialParsers {
  static ResolverResult? parsePackages(String rawDump) {
    final header = 'Packages:';
    final startIndex = rawDump.indexOf(header);
    if (startIndex == -1) return null;

    var searchFrom = startIndex + header.length;
    final nextSection = DumpParserCore.findNextSection(rawDump, searchFrom);
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
    final section = DumpParserCore.extractSection(rawDump, 'Queries');
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
}