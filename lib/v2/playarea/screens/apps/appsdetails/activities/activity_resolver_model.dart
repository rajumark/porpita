class ResolverEntry {
  final String hashClass;
  final String activityName;
  final String filterHash;
  final String rawDetail;

  const ResolverEntry({
    required this.hashClass,
    required this.activityName,
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

class ActivityResolverResult {
  final List<ResolverSection> sections;

  const ActivityResolverResult({required this.sections});
}