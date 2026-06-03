class ResolverEntry {
  final String hashClass;
  final String componentName;
  final String filterHash;
  final String rawDetail;

  const ResolverEntry({
    required this.hashClass,
    required this.componentName,
    required this.filterHash,
    required this.rawDetail,
  });
}

class ResolverGroup {
  final String key;
  final List<ResolverEntry> entries;

  const ResolverGroup({required this.key, required this.entries});
}

class ResolverSection {
  final String name;
  final List<ResolverGroup> groups;

  const ResolverSection({required this.name, required this.groups});
}

class ResolverResult {
  final String tableName;
  final List<ResolverSection> sections;

  const ResolverResult({required this.tableName, required this.sections});
}