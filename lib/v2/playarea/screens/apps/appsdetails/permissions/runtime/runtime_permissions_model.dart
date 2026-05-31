class RuntimePermission {
  final String name;
  final bool? granted;
  final String flags;

  const RuntimePermission({required this.name, this.granted, this.flags = ''});
}