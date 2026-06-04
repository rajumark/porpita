import 'resolver_model.dart';
import 'dump_parser_core.dart';

class DumpKeyItemParsers {
  static ResolverResult? parseAsKeyItems(String rawDump, String tableName) {
    final section = DumpParserCore.extractSection(rawDump, tableName);
    if (section.isEmpty) return null;

    final lines = section.split('\n');
    final items = <ResolverGroup>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trimRight().isEmpty) continue;

      if (line.startsWith('  ') && !line.startsWith('    ') && line.trimRight().endsWith(':')) {
        final key = line.trim().replaceAll(RegExp(r':$'), '');
        final detailLines = _collectDetailLines(lines, i);
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
    final section = DumpParserCore.extractSection(rawDump, 'Registered ContentProviders');
    if (section.isEmpty) return null;

    final lines = section.split('\n');
    final items = <ResolverGroup>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trimRight().isEmpty) continue;

      if (line.startsWith('  ') && !line.startsWith('    ') && line.trimRight().endsWith(':')) {
        final name = line.trim().replaceAll(RegExp(r':$'), '');
        final detailLines = _collectDetailLines(lines, i);
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
    final section = DumpParserCore.extractSection(rawDump, 'ContentProvider Authorities');
    if (section.isEmpty) return null;

    final lines = section.split('\n');
    final items = <ResolverGroup>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trimRight().isEmpty) continue;

      if (line.startsWith('  ') && line.trim().startsWith('[') && line.trim().endsWith(']:')) {
        final name = line.trim().replaceAll(RegExp(r':$'), '');
        final detailLines = _collectDetailLines(lines, i);
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

  static List<String> _collectDetailLines(List<String> lines, int startIndex) {
    final detailLines = <String>[];
    var j = startIndex + 1;
    while (j < lines.length && lines[j].startsWith('    ') && lines[j].trimRight().isNotEmpty) {
      detailLines.add(lines[j].trimRight());
      j++;
    }
    return detailLines;
  }
}