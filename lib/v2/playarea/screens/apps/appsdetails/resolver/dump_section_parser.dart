import 'resolver_model.dart';
import 'dump_parser_core.dart';
import 'dump_entry_parser.dart';
import 'dump_key_item_parsers.dart';
import 'dump_special_parsers.dart';

class DumpSectionParser {
  static String extractSection(String rawDump, String sectionName) {
    return DumpParserCore.extractSection(rawDump, sectionName);
  }

  static ResolverResult? parseAsEntries(String rawDump, String tableName) {
    return DumpEntryParser.parseAsEntries(rawDump, tableName);
  }

  static ResolverResult? parseAsKeyItems(String rawDump, String tableName) {
    return DumpKeyItemParsers.parseAsKeyItems(rawDump, tableName);
  }

  static ResolverResult? parseContentProviders(String rawDump) {
    return DumpKeyItemParsers.parseContentProviders(rawDump);
  }

  static ResolverResult? parseContentProviderAuthorities(String rawDump) {
    return DumpKeyItemParsers.parseContentProviderAuthorities(rawDump);
  }

  static ResolverResult? parsePackages(String rawDump) {
    return DumpSpecialParsers.parsePackages(rawDump);
  }

  static ResolverResult? parseQueries(String rawDump) {
    return DumpSpecialParsers.parseQueries(rawDump);
  }
}